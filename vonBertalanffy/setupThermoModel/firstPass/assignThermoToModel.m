function [model,computedSpeciesData]=assignThermoToModel(model,Alberty2006,temp,PHR,IS,CHI,compartments,NaNdGf0GCMetBool,Legendre,LegendreCHI,useKeqData,printToFile,GCpriorityMetList,metGroupCont,metSpeciespKa)
% Assigns thermodynamic data to model at given temperature, pH, ionic strength and electrical potential.
%
% Physicochemically, this is the most important function for setting up a
% thermodynamic model. It takes the standard Gibbs energies of the
% metabolite species and uses this data to create a standard transformed
% Gibbs energy for each reactant. It uses the metabolite species standard
% Gibbs energies of formation backcalculated from equilibrium constants, in
% preference to the group contribution estimates
%
%INPUT
% model
% Alberty2006       Alberty's data
% temp              temperature 298.15 K to 313.15 K
% PHR.*             real pH in compartment defined by letter *
% IS.*              ionic strength (0 - 0.35M) in compartment defined by letter *
% CHI.*             electrical potential (mV) in compartment defined by letter *
% compartments      2 x # cell array of distinct compartment letters and
%                   compartment names
% NaNdGf0GCMetBool  m x 1 boolean vector with 1 when no group contribution
%                   data is available for a metabolite
%
%OPTIONAL INPUT
% Legendre          {(1),0} Legendre Transformation for specifc real pH?
% LegendreCHI       {(1),0} Legendre Transformation for specifc electrical potential?
% useKeqData        {(1),0} Use dGf0 back calculated from Keq?
% printToFile       {(0),1} 1 = print out repetitive material to log file
% metGroupCont      Structure containing output from Jankowski et al.'s
%                   2008 implementation of the group contribution method (GCM).
%                   Contains the following fields for each metabolite:
%                   .abbreviation: Metabolite ID
%                   .formulaMarvin: Metabolite formula output by GCM
%                   .delta_G_formation: Estimated standard Gibbs energy of
%                   formation
%                   .delta_G_formation_uncertainty: Uncertainty in
%                   estimated delta_G_formation
%                   .chargeMarvin: Metabolite charge output by GCM
% metSpeciespKa     Structure containing pKa for acid-base equilibria between
%                   metabolite species. pKa are estimated with ChemAxon's
%                   pKa calculator plugin (see function
%                   "assignpKasToSpecies").
%
%OUTPUT
% model.met(m).dGf0            standard Gibbs energy of formation
% model.met(m).dGf             Gibbs energy of formation
% model.met(m).dGft0           standard transformed Gibbs energy of formation
% model.met(m).dHzerot         standard transformed enthalpy of formation
% model.met(m).dGft0Source     origin of data, Keq or groupContFileName.txt
% model.met(m).dGft0Keq
% model.met(m).dGft0GroupCont
% model.met(m).dHft0Keq
% model.met(m).mf               mole fraction of each species within a pseudoisomer group
% model.met(m).aveZi            average charge
% model.met(m).chi              electrical potential
% model.met(m).aveHbound        average number of protons bound to a reactant
% modelT.gasConstant            Gas Constant
% modelT.faradayConstant        Faraday Constant
% modelT.temp                   Temperature
% model.PHR.*                   real pH in compartment defined by letter *
% model.IS.*                    ionic strength (0 - 0.35M) in compartment defined by letter *
% model.CHI.*                   electrical potential (mV) in compartment defined by letter *
%
% Ronan M. T. Fleming
% Hulda SH, Dec 2010    Added computedSpeciesData as input. Coded the
%                       transformation of species standard Gibbs energies of formation in
%                       computedSpeciesData to reactant standard Gibbs energies of formation at
%                       in vivo conditions.
% Hulda SH, Nov 2011    computedSpeciesData now created within this
%                       function using metGroupCont and metSpeciespKa.

for p=1:length(compartments)
    if isfield(PHR,compartments{p,1})
        %test to ensure that pHc is in the applicable range
        %if PHR.(compartments{p,1})<5 || PHR.(compartments{p,1})>9
        if PHR.(compartments{p,1})<4.7 || PHR.(compartments{p,1})>9.3
            error([compartments{p,2} ' pHr = ' num2str(PHR.(compartments{p,1})) ' out of applicable range']);
        end
        %test to ensure that ionic strength is in the applicable range
        if IS.(compartments{p,1})<0 || IS.(compartments{p,1})>0.35
            error([compartments{p,2} ' ionic strength = ' num2str(IS.(compartments{p,1})) ' out of applicable range, (0 to 0.35 M).']);
        end
    end
end

if ~exist('Legendre','var')
    Legendre=1;
end
if ~exist('adjustedMetList','var')
    adjustedMetList={''};
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
gasConstant=8.314472/1000; %kJ/mol
faradayConstant=96.48; %kJ/mol
model.gasConstant=gasConstant;
model.faradayConstant=faradayConstant;
%stamp model with intensive thermodynamic constants
model.PHR=PHR;
model.IS=IS;
model.CHI=CHI;
model.temp=temp;

nMet=size(model.S,1);
%transform Group Contribution's estimates
model=dGfzeroGroupContToBiochemical(model,temp,PHR,IS,CHI,compartments,NaNdGf0GCMetBool,Legendre);

% Create computedSpeciesData
if ~isempty(metSpeciespKa)
    computedSpeciesData = createComputedSpeciesData(metSpeciespKa,metGroupCont);
else
    computedSpeciesData = [];
end

% Overwrite transformed group contribution estimates with data from
% computedSpeciesData where available. - Hulda
if ~isempty(computedSpeciesData)
    for m=1:nMet
        if strcmp('succ[e]',model.mets{m})
            pause(eps)
        end
        if strcmp('h[e]',model.mets{m})
            pause(eps)
        end
        % set the pH, ionic strength & electrical potential for the metabolite depending on the compartment
        if ~isfield(PHR,model.met(m).abbreviation(end-1))
            error(['Missing pHr for compartment ' model.met(m).abbreviation(end-1)]);
        end
        if ~isfield(IS,model.met(m).abbreviation(end-1))
            error(['Missing ionic strength for compartment ' model.met(m).abbreviation(end-1)]);
        end
        if ~isfield(CHI,model.met(m).abbreviation(end-1))
            error(['Missing chi for compartment ' model.met(m).abbreviation(end-1)]);
        end
        pHr=PHR.(model.met(m).abbreviation(end-1));
        is=IS.(model.met(m).abbreviation(end-1));
        chi=CHI.(model.met(m).abbreviation(end-1));
        
        %         if strcmp(model.met(m).abbreviation(end-1),'c')
        %             if chi~=0
        %                 error('We assume that the electrical potential of the cytoplasm is zero');
        %             end
        %         end
        
        nCSD=size(computedSpeciesData,2);
        
        for n=1:nCSD
            if strcmp(model.met(m).abbreviation(1:(end-2)),[computedSpeciesData(n).abbreviation, '['])
                % find the number of species within pseudoisomer group
                p=length(computedSpeciesData(n).basicData(:,1));
                % transform to pH and ionic strength
                % [dGfnp,dHfnp,chi]=calcdGHT(dGzero,dHzero,zi,nH,pHa,is,temp,Legendre)
                [dGf0,dHf0,mf,aveHbound,aveZi,lambda,gpfnsp]=calcdGHT(computedSpeciesData(n).basicData(1:p,1),[],computedSpeciesData(n).basicData(1:p,3),computedSpeciesData(n).basicData(1:p,4),pHr,is,temp,chi,Legendre,LegendreCHI);
                model.met(m).dGft0GroupCont=dGf0;
%                 speciesUncertainty = model.met(m).dGf0GroupContUncertainty*ones(length(mf),1);
%                 speciesUncertainty(~computedSpeciesData(n).gcmSpecies) = speciesUncertainty(~computedSpeciesData(n).gcmSpecies) + 8.9; % Add uncertainty due to pKa estimates. - Hulda
%                 model.met(m).dGft0GroupContUncertainty = mf'*speciesUncertainty;
                model.met(m).dGft0GroupContUncertainty = model.met(m).dGf0GroupContUncertainty;
                model.met(m).mf=mf;
                model.met(m).aveHbound=aveHbound;
                model.met(m).aveZi=aveZi;
                model.met(m).lambda=lambda; %activity coefficients
                model.met(m).dGft0Source='GC';
                model.met(m).gcmSpecies = computedSpeciesData(n).gcmSpecies;
                break;
            end
        end
    end
end

% End addition. - Hulda

exceptions = {'cyclicamp'; 'malylcoA'; 'methionineL'; 'acetoacetate'; 'nicotinamideribonucleotide' ; 'adenosinephosphosulfate'}; % The entries for these metabolites in Alberty's tables contain errors (incorrect nr. of hydrogen atoms relative to charge).

%RTalpha p 49 Alberty 2003
%where alpha is the Debye-Huckel Constant
gibbscoeff = (9.20483*temp)/10^3 - (1.284668*temp^2)/10^5 + (4.95199*temp^3)/10^8;

%Overwrite Group Contribution estimates with values derived from
%equilibrium constants (Alberty's tables)
for m=1:nMet
    albertyMatch=0;
    if ~any(strcmp(model.met(m).albertyAbbreviation,exceptions))
        if strcmp('succ[e]',model.mets{m})
            pause(eps)
        end
        if strcmp('h[e]',model.mets{m})
            pause(eps)
        end
        %set the pH, ionic strength & electrical potential for the metabolite depending on the compartment
        if ~isfield(PHR,model.met(m).abbreviation(end-1))
            error(['Missing pHr for compartment ' model.met(m).abbreviation(end-1)]);
        end
        if ~isfield(IS,model.met(m).abbreviation(end-1))
            error(['Missing ionic strength for compartment ' model.met(m).abbreviation(end-1)]);
        end
        if ~isfield(CHI,model.met(m).abbreviation(end-1))
            error(['Missing chi for compartment ' model.met(m).abbreviation(end-1)]);
        end
        pHr=PHR.(model.met(m).abbreviation(end-1));
        is=IS.(model.met(m).abbreviation(end-1));
        chi=CHI.(model.met(m).abbreviation(end-1));
        
        %     if strcmp(model.met(m).abbreviation(end-1),'c')
        %         if chi~=0
        %             error('We assume that the electrical potential of the cytoplasm is zero');
        %         end
        %     end
        
        nAlb=size(Alberty2006,2);
        
        
        for n=1:nAlb
            if strcmp(model.met(m).albertyAbbreviation,Alberty2006(n).abbreviation)
                albertyMatch=1;
                %find the number of species within pseudoisomer group
                p=max(find(~isnan(Alberty2006(n).basicData(:,1))));
                if isnan(Alberty2006(n).basicData(1,2))
                    %transform to pH and ionic strength
                    %[dGfnp,dHfnp,chi]=calcdGHT(dGzero,dHzero,zi,nH,pHa,is,temp,Legendre)
                    [dGf0,dHf0,mf,aveHbound,aveZi,lambda]=calcdGHT(Alberty2006(n).basicData(1:p,1),[],Alberty2006(n).basicData(1:p,3),Alberty2006(n).basicData(1:p,4),pHr,is,temp,chi,Legendre,LegendreCHI);
                    model.met(m).dGft0Keq=dGf0;
                    model.met(m).dHft0Keq=NaN;
                    model.met(m).dHft0=NaN;
                    model.met(m).mf=mf;
                    model.met(m).aveHbound=aveHbound;
                    model.met(m).aveZi=aveZi;
                    model.met(m).lambda=lambda; %activity coefficients
                    model.met(m).dGft0Source='Keq';
                else
                    %transform to new temperature, pH and ionic strength
                    %[dGfnp,dHfnp,chi]=calcdGHT(dGzero,dHzero,zi,nH,pHa,is,temp
                    %,Legendre)
                    [dGf0,dHf0,mf,aveHbound,aveZi,lambda]=calcdGHT(Alberty2006(n).basicData(1:p,1),Alberty2006(n).basicData(1:p,2),Alberty2006(n).basicData(1:p,3),Alberty2006(n).basicData(1:p,4),pHr,is,temp,chi,Legendre,LegendreCHI);
                    model.met(m).dGft0Keq=dGf0;
                    model.met(m).dHft0Keq=dHf0;
                    model.met(m).dHft0=NaN;
                    model.met(m).mf=mf;
                    model.met(m).aveHbound=aveHbound;
                    model.met(m).aveZi=aveZi;
                    model.met(m).lambda=lambda; %activity coefficients
                    model.met(m).dGft0Source='Keq';
                    if strcmp(model.met(m).albertyAbbreviation,'h2o');
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
            model.met(m).dGft0=model.met(m).dGft0Keq;
            model.met(m).dHft0=model.met(m).dHft0Keq;
        else
            model.met(m).dHft0=NaN;
            model.met(m).dGft0=model.met(m).dGft0GroupCont;
            model.met(m).dGft0Source='GC';
        end
    else
        %put NaN in place of missing Keq data
        model.met(m).albertyAbbreviation=NaN;
        model.met(m).dGft0Keq=NaN;
        model.met(m).dHft0=NaN;
        model.met(m).dHft0Keq=NaN;
        
        if NaNdGf0GCMetBool(m)
            %dummy values if no group contribution data
            model.met(m).dGft0=NaN;
            model.met(m).dHft0=NaN;
            model.met(m).mf=NaN;
            model.met(m).aveHbound=NaN;
            model.met(m).aveZi=NaN;
            model.met(m).lambda=NaN;
            model.met(m).dGft0Source=NaN;
            %print out that there are no data fof this metabolite
            if strcmp(model.met(m).abbreviation(end-2:end),'[c]')
                if printToFile==0
                    fprintf('%s\t%s\t%20s\t%s\n','No standard Gibbs energy from any source for metabolite', int2str(m),model.mets{m},model.met(m).officialName);
                else
                    fprintf(fid2,'%s\t%s\t%s\t%s\n','No standard Gibbs energy from any source for metabolite', int2str(m),model.mets{m},model.met(m).officialName);
                end
            end
        else
            %use group contribution data
            model.met(m).dGft0=model.met(m).dGft0GroupCont;
            % model.met(m).mf=1; Commented out. - Hulda
            model.met(m).dGft0Source='GC';
            
            %print out the reason for doing so
            metAbbr=model.met(m).abbreviation;
            if any(strcmp(model.met(m).abbreviation(1:end-3),GCpriorityMetList))
                %in exceptional cases, use group contribution estimates over estimates
                %from Equilibrium constants. see line 80 for list of adjustedMetList
                if strcmp(metAbbr(end-2:end),'[c]')
                    if printToFile==0
                        fprintf('%s\t%s\t%20s\t%s\n','Transformed g.c. estimate (298.15K, pH 7) for metabolite (exceptional)', int2str(m),model.mets{m},model.met(m).officialName);
                    else
                        fprintf(fid1,'%s\t%s\t%s\t%s\n','Transformed g.c. estimate (298.15K, pH 7) for metabolite (exceptional)', int2str(m),model.mets{m},model.met(m).officialName);
                    end
                end
            else
                if strcmp(metAbbr(end-2:end),'[c]')
                    if printToFile==0
                        fprintf('%s\t%s\t%20s\t%s\n','Transformed g.c. estimate (298.15K, pH 7) for metabolite', int2str(m),model.mets{m},model.met(m).officialName);
                    else
                        fprintf(fid1,'%s\t%s\t%s\t%s\n','Transformed g.c. estimate (298.15K, pH 7) for metabolite', int2str(m),model.mets{m},model.met(m).officialName);
                    end
                end
            end
        end
    end
    
    
    if length(model.met(m).abbreviation)==4 && strcmp(model.met(m).abbreviation(1),'h')
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
            pHterm = gasConstant*temp*log(10^-PHR.(model.met(m).abbreviation(end-1)));
            
            %transformed thermodynamic properties
            if LegendreCHI
                %Legendre transformation for hydrogen ion chemical
                %potential and charge
                model.met(m).dGft0 = - pHterm;
            else
                %Legendre transformation for hydrogen ion chemical
                %potential
                model.met(m).dGft0 = - pHterm + electricalTerm;
            end
            model.met(m).dGft  = 0;
            model.met(m).dGft0Source='Keq';
            
            if LegendreCHI
                %untransformed chemical potential
                model.met(m).dGf0 = - isTerm;
                model.met(m).dGf  = - isTerm + pHterm;
            else
                %untransformed electrochemical potential
                model.met(m).dGf0 = - isTerm + electricalTerm;
                model.met(m).dGf  = - isTerm + electricalTerm + pHterm;
            end
        else
            %Henry et al method of adjusting the proton potential to
            %specific pH
            pHTerm=log(10)*gasConstant*temp*(PHR.(model.met(m).abbreviation(end-1)));
            %ionic strength adjustment eqn 4.4-10 p67 Alberty 2003
            isTerm=-gibbscoeff*(is^.5)/(1 + 1.6*is^.5);
            %potential difference due to difference in charge across
            %the cytoplasmic membrane
            zi=1;
            electricalTerm=(faradayConstant*(chi/1000))*zi;
            model.met(m).dGft0=pHTerm + isTerm + electricalTerm;
            model.met(m).dGft0Source='GC';
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
%         model.met(m).dGft0=0;
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
%             pHterm = gasConstant*temp*log(10^-PHR.(model.met(m).abbreviation(end-1)));
%
%             %Eq 4.4-10 p67 Alberty 2003 with temp dependent gibbscoeff
%             %isTerm = (gibbscoeff*(zi.^2 - nH)*is^0.5)/(1 + 1.6*is^0.5);
%             isTerm = 0; %i.e. zi.^2 - nH ==0
%
%             %standard transformed Gibbs energy of a hydrogen ion
%             model.met(m).dGft0 = - pHterm - isTerm + electricalTerm;
%
%             model.met(m).dGft0Source='Keq';
%         else
%             %Henry et al method of adjusting the proton potential to
%             %specific pH
%             pHTerm=log(10)*gasConstant*temp*(PHR.(model.met(m).abbreviation(end-1)));
%             %ionic strength adjustment eqn 4.4-10 p67 Alberty 2003
%             isTerm=-gibbscoeff*(is^.5)/(1 + 1.6*is^.5);
%             %potential difference due to difference in charge across
%             %the cytoplasmic membrane
%             zi=1;
%             electricalTerm=(faradayConstant*(chi/1000))*zi;
%             model.met(m).dGft0=pHTerm + isTerm + electricalTerm;
%             model.met(m).dGft0Source='GC';
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
%             model.met(m).dGft0=0;
%             %necessary for later when doing stats of reaction directions
%             model.met(m).dGft0Source='Keq';
%         else
%             %Henry et al method of adjusting the proton potential to
%             %specific pH
%             pHTerm=gasConstant*temp*log(10^-cpHc);
%             %ionic strength adjustment eqn 4.4-10 p67 Alberty 2003
%             isTerm=-gibbscoeff*(is^.5)/(1 + 1.6*is^.5);
%             model.met(m).dGft0=pHTerm + isTerm;
%             model.met(m).dGft0Source='GC';
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
%             pHDiffTerm=log(10)*gasConstant*temp*(cpHc-epHc);
%             model.met(m).dGft0= electricalTerm + pHDiffTerm;
%             model.met(m).dGft0Source='Keq';
%         else
%             %Henry et al method of adjusting the proton potential to
%             %specific pH
%             pHTerm=gasConstant*temp*log(10^-epHc);
%             %ionic strength adjustment eqn 4.4-10 p67 Alberty 2003
%             isTerm=-gibbscoeff*(is^.5)/(1 + 1.6*is^.5);
%             %potential difference due to difference in charge across
%             %the cytoplasmic membrane
%             zi=1;
%             electricalTerm=(faradayConstant*(chi/1000))*zi;
%             model.met(m).dGft0=pHTerm + isTerm + electricalTerm;
%             model.met(m).dGft0Source='GC';
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
%             pHDiffTerm=log(10)*gasConstant*temp*(cpHc-ppHc);
%             model.met(m).dGft0=electricalTerm + pHDiffTerm;
%             model.met(m).dGft0Source='Keq';
%         else
%             %Henry et al method of adjusting the proton potential to
%             %specific pH
%             pHTerm=gasConstant*temp*log(10^-ppHc);
%             %ionic strength adjustment eqn 4.4-10 p67 Alberty 2003
%             isTerm=-gibbscoeff*(is^.5)/(1 + 1.6*is^.5);
%             %potential difference due to difference in charge across
%             %the cytoplasmic membrane
%             electricalTerm=(faradayConstant*(chi/1000))*zi;
%             model.met(m).dGft0=pHTerm + isTerm + electricalTerm;
%             model.met(m).dGft0Source='GC';
%         end
%     end
