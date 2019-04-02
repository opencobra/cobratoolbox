function [model,computedSpeciesData] = assignThermoToModel(model, Alberty2006, Legendre, LegendreCHI, useKeqData, printToFile, GCpriorityMetList, metGroupCont, metSpeciespKa)
% Assigns thermodynamic data to model at given temperature, pH, ionic strength and electrical potential.
%
% Physicochemically, this is the most important function for setting up a
% thermodynamic model. It takes the standard Gibbs energies of the
% metabolite species and uses this data to create a standard transformed
% Gibbs energy for each reactant. It uses the metabolite species standard
% Gibbs energies of formation backcalculated from equilibrium constants, in
% preference to the group contribution estimates.
%
% USAGE:
%
%    [model,computedSpeciesData] = assignThermoToModel(model, Alberty2006, Legendre, LegendreCHI, useKeqData, printToFile, GCpriorityMetList, metGroupCont, metSpeciespKa)
%
% INPUTS:
%    model:            structure with fields:
%
%                        * model.T - temperature 298.15 K to 313.15 K
%                        * model.ph(p) - real pH in compartment defined by letter p
%                        * model.is(p) - ionic strength (0 - 0.35M) in compartment defined by letter p
%                        * model.chi(p) - electrical potential (mV) in compartment defined by letter p
%                        * model.cellCompartments(p) - `1 x #` cell array of distinct compartment letters
%                        * model.NaNdfG0GCMetBool(m) - `m x 1` boolean vector with 1 when no group contribution
%                          data is available for a metabolite
%    Alberty2006:      Alberty's data
%
% OPTIONAL INPUTS:
%    Legendre:         {(1), 0} Legendre Transformation for specifc real pH?
%    LegendreCHI:      {(1), 0} Legendre Transformation for specifc electrical potential?
%    useKeqData:       {(1), 0} Use `dGf0` back calculated from `Keq`?
%    printToFile:      {(0), 1} 1 = print out repetitive material to log file
%    metGroupCont:     Structure containing output from `Jankowski et al.'s
%                      2008 implementation of the group contribution method (GCM).`
%                      Contains the following fields for each metabolite:
%
%                        * .abbreviation: Metabolite ID
%                        * .formulaMarvin: Metabolite formula output by GCM
%                        * .delta_G_formation: Estimated standard Gibbs energy of formation
%                        * .delta_G_formation_uncertainty: Uncertainty in
%                          estimated delta_G_formation
%                        * .chargeMarvin: Metabolite charge output by GCM
%    metSpeciespKa:    Structure containing `pKa` for acid-base equilibria between
%                      metabolite species. `pKa` are estimated with ChemAxon's
%                      pKa calculator plugin (see function
%                      `assignpKasToSpecies`).
%
% OUTPUTS:
%    model:            structure with fields:
%
%                        * model.dfG0(m) - standard Gibbs energy of formation
%                        * model.dfG(m) - Gibbs energy of formation
%                        * model.dfGt0(m) - standard transformed Gibbs energy of formation
%                        * model.dHzerot(m) - standard transformed enthalpy of formation
%                        * model.dfGt0Source(m) - origin of data, Keq or groupContFileName.txt
%                        * model.dfGt0Keq(m)
%                        * model.dfGt0GroupCont(m)
%                        * model.dfHt0Keq(m)
%                        * model.mf(m) - mole fraction of each species within a pseudoisomer group
%                        * model.aveZi(m) - average charge
%                        * model.chi - electrical potential
%                        * model.aveHbound(m) - average number of protons bound to a reactant
%                        * modelT.gasConstant - Gas Constant (deprecated)
%                        * model.faradayConstant - Faraday Constant
%                        * modelT.temp - Temperature (deprecated)
%                        * model.ph(p) - real pH in compartment defined by letter p
%                        * model.is(p) - ionic strength (0 - 0.35M) in compartment defined by letter p
%                        * model.chi(p) - electrical potential (mV) in compartment defined by letter p
%
% .. Authors:
%       - Ronan M. T. Fleming
%       - Hulda SH, Dec 2010, Added computedSpeciesData as input. Coded the transformation of species standard Gibbs energies of formation in
%         computedSpeciesData to reactant standard Gibbs energies of formation at in vivo conditions.
%       - Hulda SH, Nov 2011, computedSpeciesData now created within this function using metGroupCont and metSpeciespKa.
%       - Lemmer El Assal, 2016/10/14 Adaptation to old COBRA model structure

for p=1:length(model.cellCompartments)
    %if isfield(PHR,compartments{p,1})
    if model.ph(p)
        %test to ensure that pHc is in the applicable range
        %if PHR.(compartments{p,1})<5 || PHR.(compartments{p,1})>9
        %if PHR.(compartments{p,1})<4.7 || PHR.(compartments{p,1})>9.3
        if model.ph(p)<4.7 || model.ph(p)>9.3
            %error([compartments{p,2} ' pHr = ' num2str(PHR.(compartments{p,1})) ' out of applicable range']);
            error([model.cellCompartments(p) ' pHr = ' num2str(model.ph(p)) ' out of applicable range']);
        end
        %test to ensure that ionic strength is in the applicable range
        %if IS.(compartments{p,1})<0 || IS.(compartments{p,1})>0.35
        if model.is(p)<0 || model.is(p)>0.35
            %error([compartments{p,2} ' ionic strength = ' num2str(IS.(compartments{p,1})) ' out of applicable range, (0 to 0.35 M).']);
            error([model.cellCompartments(p) ' ionic strength = ' num2str(model.is(p)) ' out of applicable range, (0 to 0.35 M).']);
        end
    end
end

if ~exist('Legendre','var')
    Legendre=1;
end
if ~exist('useKeqData','var')
    useKeqData=1;
end
if ~exist('adjustedMetList','var')
    adjustedMetList={''};
end
if ~exist('GCpriorityMetList','var')
    GCpriorityMetList={''};
end

if Legendre==0
    fprintf('%s\n','Not making a Legendre transformation for pH');
end
if ~exist('printToFile','var')
    printToFile=0;
end
if printToFile==1
    fid1=fopen('reactants_using_group_contribution_estimates.txt','w');
    fid2=fopen('reactants_with_no_standard_Gibbs_energy.txt','w');
end
%stamp model
model.Legendre=Legendre;
model.LegendreCHI=LegendreCHI;

%Physico-Chemical Constants (Energies are expressed in kJ/mol)
%gasConstant=8.314472/1000; %kJ/mol
faradayConstant=96.48; %kJ/mol
%model.gasConstant=gasConstant;
model.faradayConstant=faradayConstant;
%stamp model with intensive thermodynamic constants
% model.PHR=PHR;
% model.IS=IS;
% model.CHI=CHI;
%model.temp=temp;

nMet=size(model.S,1);
model.mf = cell(nMet,1); % initialize model.mf

%transform Group Contribution's estimates
% come back here later!!!!
model=dGfzeroGroupContToBiochemical(model,Legendre);

% Create computedSpeciesData
if ~isempty(model.metSpeciespKa)
    computedSpeciesData = createComputedSpeciesData(model.metSpeciespKa,model.metGroupCont);
else
    computedSpeciesData = [];
end

% Overwrite transformed group contribution estimates with data from
% computedSpeciesData where available. - Hulda
if ~isempty(computedSpeciesData)
    for m=1:nMet
        metAbbr = model.mets(m);
        metAbbr = metAbbr{1};
        metcompartment = find(model.cellCompartments==model.metComps{m});

        if strcmp('succ[e]',model.mets{m})
            pause(eps)
        end
        if strcmp('h[e]',model.mets{m})
            pause(eps)
        end
        % set the pH, ionic strength & electrical potential for the metabolite depending on the compartment
%         if ~isfield(PHR,model.met(m).abbreviation(end-1))
%             error(['Missing pHr for compartment ' model.met(m).abbreviation(end-1)]);
%         end
%         if ~isfield(IS,model.met(m).abbreviation(end-1))
%             error(['Missing ionic strength for compartment ' model.met(m).abbreviation(end-1)]);
%         end
%         if ~isfield(CHI,model.met(m).abbreviation(end-1))
%             error(['Missing chi for compartment ' model.met(m).abbreviation(end-1)]);
%         end
        pHr=model.ph(metcompartment); %PHR.(model.met(m).abbreviation(end-1));
        is=model.is(metcompartment); %IS.(model.met(m).abbreviation(end-1));
        chi=model.chi(metcompartment); %CHI.(model.met(m).abbreviation(end-1));

        %         if strcmp(model.met(m).abbreviation(end-1),'c')
        %             if chi~=0
        %                 error('We assume that the electrical potential of the cytoplasm is zero');
        %             end
        %         end

        nCSD=size(computedSpeciesData,2);

        for n=1:nCSD
            if strcmp(metAbbr(1:(end-2)),[computedSpeciesData(n).abbreviation, '['])
                % find the number of species within pseudoisomer group
                p=length(computedSpeciesData(n).basicData(:,1));
                % transform to pH and ionic strength
                % [dGfnp,dHfnp,chi]=calcdGHT(dGzero,dHzero,zi,nH,pHa,is,model.T,Legendre)
                [dGf0,dHf0,mf,aveHbound,aveZi,lambda,gpfnsp]=calcdGHT(computedSpeciesData(n).basicData(1:p,1),[],computedSpeciesData(n).basicData(1:p,3),computedSpeciesData(n).basicData(1:p,4),pHr,is,model.T,chi,Legendre,LegendreCHI);
                model.dfGt0GroupCont(m)=dGf0;
%                 speciesUncertainty = model.dfG0GroupContUncertainty(m)*ones(length(mf),1);
%                 speciesUncertainty(~computedSpeciesData(n).gcmSpecies) = speciesUncertainty(~computedSpeciesData(n).gcmSpecies) + 8.9; % Add uncertainty due to pKa estimates. - Hulda
%                 model.dfGt0GroupContUncertainty(m) = mf'*speciesUncertainty;
                model.dfGt0GroupContUncertainty(m) = model.dfGt0GroupContUncertainty(m);
                model.mf{m}=mf;
                model.aveHbound(m)=aveHbound;
                model.aveZi(m)=aveZi;
                model.lambda{m}=lambda; %activity coefficients
                model.dfGt0Source{m}='GC';
                model.gcmSpecies{m} = computedSpeciesData(n).gcmSpecies;
                break;
            end
        end
    end
end

% End addition. - Hulda

exceptions = {'cyclicamp'; 'malylcoA'; 'methionineL'; 'acetoacetate'; 'nicotinamideribonucleotide' ; 'adenosinephosphosulfate'}; % The entries for these metabolites in Alberty's tables contain errors (incorrect nr. of hydrogen atoms relative to charge).

%RTalpha p 49 Alberty 2003
%where alpha is the Debye-Huckel Constant
gibbscoeff = (9.20483*model.T)/10^3 - (1.284668*model.T^2)/10^5 + (4.95199*model.T^3)/10^8;

%Overwrite Group Contribution estimates with values derived from
%equilibrium constants (Alberty's tables)
for m=1:nMet
    metAbbr = model.mets(m);
    metAbbr = metAbbr{1};
    metcompartment = find(model.cellCompartments==model.metComps{m});

    albertyMatch=0;
    if ~any(strcmp(metAbbr(1:end-3),exceptions))
        if strcmp('succ[e]',model.mets{m})
            pause(eps)
        end
        if strcmp('h[e]',model.mets{m})
            pause(eps)
        end
        %set the pH, ionic strength & electrical potential for the metabolite depending on the compartment
%         if ~isfield(PHR,model.met(m).abbreviation(end-1))
%             error(['Missing pHr for compartment ' model.met(m).abbreviation(end-1)]);
%         end
%         if ~isfield(IS,model.met(m).abbreviation(end-1))
%             error(['Missing ionic strength for compartment ' model.met(m).abbreviation(end-1)]);
%         end
%         if ~isfield(CHI,model.met(m).abbreviation(end-1))
%             error(['Missing chi for compartment ' model.met(m).abbreviation(end-1)]);
%         end
        pHr=model.ph(metcompartment); %PHR.(model.met(m).abbreviation(end-1));
        is=model.is(metcompartment); %IS.(model.met(m).abbreviation(end-1));
        chi=model.chi(metcompartment); %CHI.(model.met(m).abbreviation(end-1));

        %     if strcmp(model.met(m).abbreviation(end-1),'c')
        %         if chi~=0
        %             error('We assume that the electrical potential of the cytoplasm is zero');
        %         end
        %     end

        nAlb=size(Alberty2006,2);


        for n=1:nAlb
            if strcmp(metAbbr,Alberty2006(n).abbreviation)
                albertyMatch=1;
                %find the number of species within pseudoisomer group
                p=max(find(~isnan(Alberty2006(n).basicData(:,1))));
                if isnan(Alberty2006(n).basicData(1,2))
                    %transform to pH and ionic strength
                    %[dGfnp,dHfnp,chi]=calcdGHT(dGzero,dHzero,zi,nH,pHa,is,model.T,Legendre)
                    [dGf0,dHf0,mf,aveHbound,aveZi,lambda]=calcdGHT(Alberty2006(n).basicData(1:p,1),[],Alberty2006(n).basicData(1:p,3),Alberty2006(n).basicData(1:p,4),pHr,is,model.T,chi,Legendre,LegendreCHI);
                    model.dfGt0Keq(m)=dGf0;
                    model.dfHt0Keq(m)=NaN;
                    model.dHft0(m)=NaN;
                    model.mf(m)=mf;
                    model.aveHbound(m)=aveHbound;
                    model.aveZi(m)=aveZi;
                    model.lambda(m)=lambda; %activity coefficients
                    model.dfGt0Source(m)='Keq';
                else
                    %transform to new temperature, pH and ionic strength
                    %[dGfnp,dHfnp,chi]=calcdGHT(dGzero,dHzero,zi,nH,pHa,is,model.T
                    %,Legendre)
                    [dGf0,dHf0,mf,aveHbound,aveZi,lambda]=calcdGHT(Alberty2006(n).basicData(1:p,1),Alberty2006(n).basicData(1:p,2),Alberty2006(n).basicData(1:p,3),Alberty2006(n).basicData(1:p,4),pHr,is,model.T,chi,Legendre,LegendreCHI);
                    model.dfGt0Keq(m)=dGf0;
                    model.dfHt0Keq(m)=dHf0;
                    model.dHft0(m)=NaN;
                    model.mf(m)=mf;
                    model.aveHbound(m)=aveHbound;
                    model.aveZi(m)=aveZi;
                    model.lambda(m)=lambda; %activity coefficients
                    model.dfGt0Source(m)='Keq';
                    if strcmp(model.albertyAbbreviation(m),'h2o');
                        if lambda~=1
                            error('assignThermoToModel: Activity of water should always be one.')
                        end
                    end
                end
                break;
            end
        end



    end

    %setting albertyMatch to zero bypasses all use of Albertys Data
    if useKeqData==0
        albertyMatch=0;
    end

    %if no data from equilibrium constants, use group contribution
    %estimates if available
    if albertyMatch
        if ~any(strcmp(model.met(m).abbreviation(1:end-3),GCpriorityMetList))
            model.dfGt0(m)=model.dfGt0Keq(m);
            model.dHft0(m)=model.dfHt0Keq(m);
        else
            model.dHft0(m)=NaN;
            model.dfGt0(m)=model.dfGt0GroupCont(m);
            model.dfGt0Source(m)='GC';
        end
    else
        %put NaN in place of missing Keq data
        model.albertyAbbreviation=NaN;
        model.dfGt0Keq(m)=NaN;
        model.dfHt0(m)=NaN;
        model.dfHt0Keq(m)=NaN;

        if model.NaNdfG0GCMetBool(m)
            %dummy values if no group contribution data
            model.dfGt0(m)=NaN;
            model.dHft0(m)=NaN;
            model.mf(m)=NaN;
            model.aveHbound(m)=NaN;
            model.aveZi(m)=NaN;
            model.lambda(m)=NaN;
            model.dfGt0Source(m)=NaN;
            %print out that there are no data fof this metabolite
            %metAbbr = model.mets(m);
            if strcmp(metAbbr(end-2:end),'[c]')
                if printToFile==0
                    fprintf('%s\t%s\t%20s\t%s\n','No standard Gibbs energy from any source for metabolite', int2str(m),model.mets{m},model.met(m).officialName);
                else
                    fprintf(fid2,'%s\t%s\t%s\t%s\n','No standard Gibbs energy from any source for metabolite', int2str(m),model.mets{m},model.met(m).officialName);
                end
            end
        else
            %use group contribution data
            model.dfGt0(m)=model.dfGt0GroupCont(m);
            % model.mf(m)=1; Commented out. - Hulda
            model.dfGt0Source{m}='GC';

            %print out the reason for doing so
            %metAbbr=model.mets(m);
            if any(strcmp(metAbbr(1:end-3),GCpriorityMetList))
                %in exceptional cases, use group contribution estimates over estimates
                %from Equilibrium constants. see line 80 for list of adjustedMetList
                if strcmp(metAbbr(end-2:end),'[c]')
                    if printToFile==0
                        fprintf('%s\t%s\t%20s\t%s\n','Transformed g.c. estimate (298.15K, pH 7) for metabolite (exceptional)', int2str(m),model.mets{m},model.metNames{m});
                    else
                        fprintf(fid1,'%s\t%s\t%s\t%s\n','Transformed g.c. estimate (298.15K, pH 7) for metabolite (exceptional)', int2str(m),model.mets{m},model.metNames{m});
                    end
                end
            else
                if strcmp(metAbbr(end-2:end),'[c]')
                    if printToFile==0
                        fprintf('%s\t%s\t%20s\t%s\n','Transformed g.c. estimate (298.15K, pH 7) for metabolite', int2str(m),model.mets{m},model.metNames{m});
                    else
                        fprintf(fid1,'%s\t%s\t%s\t%s\n','Transformed g.c. estimate (298.15K, pH 7) for metabolite', int2str(m),model.mets{m},model.metNames{m});
                    end
                end
            end
        end
    end


    if length(metAbbr)==4 && strcmp(metAbbr(1),'h')
        if Legendre
            zi=1;
            %Ionic strength
            %Eq 4.4-10 p67 Alberty 2003 with temp dependent gibbscoeff
            isTerm = (gibbscoeff*zi.^2*is^0.5)/(1 + 1.6*is^0.5);
            %Electrical Potential
            %eq 8.5-1 p148 Alberty 2003
            electricalTerm=(faradayConstant*(chi/1000))*zi;
            %pH
            %Eq 4.4-9 p67 Alberty 2003

            pHterm = model.gasConstant*model.T*log(10^-model.ph(metcompartment));

            %transformed thermodynamic properties
            if LegendreCHI
                %Legendre transformation for hydrogen ion chemical
                %potential and charge
                model.dfGt0(m) = - pHterm;
            else
                %Legendre transformation for hydrogen ion chemical
                %potential
                model.dfGt0(m) = - pHterm + electricalTerm;
            end
            model.dfGt(m)  = 0;
            model.dfGt0Source{m}='Keq';

            if LegendreCHI
                %untransformed chemical potential
                model.dfG0(m) = - isTerm;
                model.dfG(m)  = - isTerm + pHterm;
            else
                %untransformed electrochemical potential
                model.dfG0(m) = - isTerm + electricalTerm;
                model.dfG(m)  = - isTerm + electricalTerm + pHterm;
            end
        else
            %Henry et al method of adjusting the proton potential to
            %specific pH
            pHTerm=log(10)*model.gasConstant*model.T*(model.ph(metcompartment));
            %ionic strength adjustment eqn 4.4-10 p67 Alberty 2003
            isTerm=-gibbscoeff*(is^.5)/(1 + 1.6*is^.5);
            %potential difference due to difference in charge across
            %the cytoplasmic membrane
            zi=1;
            electricalTerm=(faradayConstant*(chi/1000))*zi;
            model.dfGt0(m)=pHTerm + isTerm + electricalTerm;
            model.dfGt0Source{m}='GC';
        end

    end
end

if printToFile
    fclose(fid1);
    fclose(fid2);
end


%     if 0
%     %DOUBLE CHECK - this is a bit of very tricky code, its not clear in
%     %Albertys work what to do if there are two compartments with fixed pH
%     %which are different from eachother.
%     if length(model.met(m).abbreviation)==4 && strcmp(model.met(m).abbreviation(1),'h')
%         %By convention
%         %(1) standard transformed chemical potential of H+ is zero
%         model.dfG(m)t0=0;
%         %(2) electrical potential of the cytoplasm is zero
%         if Legendre
%             %Legendre Transformation for Electrical Potential, relative to
%             %cytoplasmic electrical potential of zero
%             zi=1;
%             electricalTerm=(faradayConstant*(chi/1000))*zi;
%
%
%             %Eq 4.4-9 p67 Alberty 2003
%             %pH term
%             pHterm = model.gasConstant*model.T*log(10^-PHR.(model.met(m).abbreviation(end-1)));
%
%             %Eq 4.4-10 p67 Alberty 2003 with temp dependent gibbscoeff
%             %isTerm = (gibbscoeff*(zi.^2 - nH)*is^0.5)/(1 + 1.6*is^0.5);
%             isTerm = 0; %i.e. zi.^2 - nH ==0
%
%             %standard transformed Gibbs energy of a hydrogen ion
%             model.dfG(m)t0 = - pHterm - isTerm + electricalTerm;
%
%             model.dfGt0Source(m)='Keq';
%         else
%             %Henry et al method of adjusting the proton potential to
%             %specific pH
%             pHTerm=log(10)*model.gasConstant*model.T*(PHR.(model.met(m).abbreviation(end-1)));
%             %ionic strength adjustment eqn 4.4-10 p67 Alberty 2003
%             isTerm=-gibbscoeff*(is^.5)/(1 + 1.6*is^.5);
%             %potential difference due to difference in charge across
%             %the cytoplasmic membrane
%             zi=1;
%             electricalTerm=(faradayConstant*(chi/1000))*zi;
%             model.dfG(m)t0=pHTerm + isTerm + electricalTerm;
%             model.dfGt0Source(m)='GC';
%         end
%     end
%     end

%DOUBLE CHECK - this is a bit of very tricky code, its not clear in
%Albertys work what to do if there are two compartments with fixed pH
%which are different from eachother.
%%%%%% Compartment specific code for H+ ions used for iAF1260 in:
%   Quantitative assignment of reaction directionality in constraint-based
%   models of metabolism: Application to Escherichia coli.    %%%%%%%%%%%%%
%
%     %if using a Legendre Transform set the standard chemical potential
%     %of internal H+ ion to zero
%     if strcmp(model.met(m).abbreviation,'h[c]');
%         if Legendre
%             %By convention electrical potential in cytoplasm is zero
%             model.dfG(m)t0=0;
%             %necessary for later when doing stats of reaction directions
%             model.dfGt0Source(m)='Keq';
%         else
%             %Henry et al method of adjusting the proton potential to
%             %specific pH
%             pHTerm=model.gasConstant*model.T*log(10^-cpHc);
%             %ionic strength adjustment eqn 4.4-10 p67 Alberty 2003
%             isTerm=-gibbscoeff*(is^.5)/(1 + 1.6*is^.5);
%             model.dfG(m)t0=pHTerm + isTerm;
%             model.dfGt0Source(m)='GC';
%         end
%     end
%     %adjust standard chemical potential of external H+ ion to account
%     %for difference in pH across boundary
%     if strcmp(model.met(m).abbreviation,'h[e]');
%         if Legendre
%             %DOUBLE CHECK Legendre Transformation for Electrical Potential
%             %potential difference due to difference in charge across
%             %the cytoplasmic membrane
%             zi=1;
%             electricalTerm=(faradayConstant*(chi/1000))*zi;
%             %potential difference due to difference in concentration across
%             %the cytoplasmic membrane
%             pHDiffTerm=log(10)*model.gasConstant*model.T*(cpHc-epHc);
%             model.dfG(m)t0= electricalTerm + pHDiffTerm;
%             model.dfGt0Source(m)='Keq';
%         else
%             %Henry et al method of adjusting the proton potential to
%             %specific pH
%             pHTerm=model.gasConstant*model.T*log(10^-epHc);
%             %ionic strength adjustment eqn 4.4-10 p67 Alberty 2003
%             isTerm=-gibbscoeff*(is^.5)/(1 + 1.6*is^.5);
%             %potential difference due to difference in charge across
%             %the cytoplasmic membrane
%             zi=1;
%             electricalTerm=(faradayConstant*(chi/1000))*zi;
%             model.dfG(m)t0=pHTerm + isTerm + electricalTerm;
%             model.dfGt0Source(m)='GC';
%         end
%     end
%     %adjust standard chemical potential of external H+ ion to account
%     %for difference in pH across boundary
%     if strcmp(model.met(m).abbreviation,'h[p]');
%         if Legendre
%             %DOUBLE CHECK Legendre Transformation for Electrical Potential
%             %potential difference due to difference in charge across
%             %the cytoplasmic membrane
%             zi=1;
%             electricalTerm=(faradayConstant*(chi/1000))*zi;
%             %potential difference due to difference in concentration across
%             %the cytoplasmic membrane
%             pHDiffTerm=log(10)*model.gasConstant*model.T*(cpHc-ppHc);
%             model.dfG(m)t0=electricalTerm + pHDiffTerm;
%             model.dfGt0Source(m)='Keq';
%         else
%             %Henry et al method of adjusting the proton potential to
%             %specific pH
%             pHTerm=model.gasConstant*model.T*log(10^-ppHc);
%             %ionic strength adjustment eqn 4.4-10 p67 Alberty 2003
%             isTerm=-gibbscoeff*(is^.5)/(1 + 1.6*is^.5);
%             %potential difference due to difference in charge across
%             %the cytoplasmic membrane
%             electricalTerm=(faradayConstant*(chi/1000))*zi;
%             model.dfG(m)t0=pHTerm + isTerm + electricalTerm;
%             model.dfGt0Source(m)='GC';
%         end
%     end
