function model = dGfzeroGroupContToBiochemical(model, Legendre)
% Transforms group contribution estimate of metabolite standard transformed Gibbs energy.
% Converts group contribution data biochemical standard transformed Gibbs
% energy of formation, at specified pH and ionic strength.
%
% USAGE:
%
%    model = dGfzeroGroupContToBiochemical(model, Legendre)
%
% INPUT:
%    model:       structure with fields:
%
%                   * model.mets{m}
%                   * model.metCharges(m)
%                   * model.metFormulas{m}
%                   * model.T - temperature
%                   * model.faradayConstant - Faraday constant
%                   * model.gasConstant - Universal Gas Constant
%                   * model.ph(p) - real pH in compartment defined by letter p
%                   * model.is(p) - ionic strength (0 - 0.35M) in compartment defined by letter *
%                   * model.chi(p) - electrical potential (mV) in compartment defined by letter *
%                   * model.cellCompartments - `1 x #` cell array of distinct compartment letters
%                   * model.NaNdfG0GCMetBool - `m x 1` boolean vector with 1 when no group contribution data is available for a metabolite generated in old `SetupThermoModel.m` only
%
% OPTIONAL INPUT:
%    Legendre:    {(1), 0} Legendre Transformation for specifc pH and electrical potential?
%
% OUTPUT:
%    model:       structure with fields:
%
%                   * model.NaNdfG0GCMetBool - `m x 1` boolean vector with 1 when no group contribution data is available for a metabolite
%                   * model.dfG0GroupCont(m) - group contribution estimate (kJ mol^-1)
%                   * model.dfG0GroupContUncertainty(m) - error on group contribution estimate (kJ mol^-1)
%                   * model.dfGt0GroupCont(m) - group contribution estimate +/-Legendre transform (kJ mol^-1)
%                   * model.dfGt0GroupContUncertainty(m) - error on group contribution estimate +/- Legendre transform (kJ mol^-1)
%                   * model.aveHbound(m) - average number of H+ bound
%                   * model.aveZi(m) - average charge
%                   * model.mf(m) - mole fraction of each species within a pseudoisomer group
%                   * model.lambda(m) - activity coefficient
%
% NOTE:
%
%    At the moment, the charges of the metabolites are for pH 7 only so strictly it should be pH 7 only
%
% iAF1260 Supplemental Note:
% "All delta_f_G_est_0 calculated for the reconstruction using the
% group contribution method are based upon the standard condition of
% aqueous solution with pH equal to 7, temperature equal to 298.15 K,
% zero ionic strength and 1M concentrations of all species except H+,
% and water. In the cases where multiple charged forms of a molecule
% exist at pH 7, the most abundant form is used."
% Same as `Janowski et al Biophysical Journal 95:1487-1499 (2008)`
%
% .. Author:
%       - Ronan M.T. Fleming
%       - Lemmer El Assal, 2016/10/14 Adaptation to old COBRA model structure

if ~exist('Legendre','var')
    Legendre=1;
end
%stamp model
model.Legendre=Legendre;
%The values of the standard transformed Gibbs energy of formation for:
%real pH in the range 5 to 9
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

%temperature dependent coefficient in the calculation of ionic strenghth
%effect
%RTalpha p 49 Alberty 2003
%where alpha is the Debye-Huckel Constant
gibbscoeff = (9.20483*model.T)/10^3 - (1.284668*model.T^2)/10^5 + (4.95199*model.T^3)/10^8;

[nMet,nRxn]=size(model.S);
RT=model.gasConstant*model.T;
F=model.faradayConstant;



%% taken from old setupThermoModel.m -Lemmer
% We generate model.dfG0GroupCont(m), model.dfG0GroupContUncertainty(m),
% and model.NaNdfG0GCMetBool here
%metGroupCont=createGroupContributionStruct(model.gcmOutputFile);%'gc_data_webGCM.txt');
model.NaNdfG0GCMetBool=false(nMet,1);
nMetGroupCont=length(model.metGroupCont);
metGroupContAbbr=cell(nMetGroupCont,1);
if strcmp(model.metGroupCont(1).abbreviation(end),']')
    %check if metabolite abbreviation in model matches any in group
    %contribution data
    for m=1:nMet
        bool=strcmp(model.mets{m},metGroupContAbbr);
        if ~any(bool)
            %mark as missing
            model.NaNdfG0GCMetBool(m)=1;
            model.dfG0GroupCont(m)=NaN;
            model.dfG0GroupContUncertainty(m)=NaN;
        else
            if nnz(bool)>1
                error([metAbbr ': duplicated abbreviation[*] in group contribution data']);
            else
                model.dfG0GroupCont(m)=metGroupCont(bool).delta_G_formation*(8.314472/1.987);
                model.dfG0GroupContUncertainty(m)=metGroupCont(bool).delta_G_formation_uncertainty*(8.314472/1.987);
            end
        end
    end
end

%% modification ends here -Lemmer
% Why is nMet == 1670?

for m=1:nMet
    if strcmp(model.mets{m},'damval[c]');
        pause(eps)
    end
    %ignore for metabolites with no group contribution estimates
    if ~model.NaNdfG0GCMetBool(m)
        %set the standard chemical potential of H+ ion to zero
        for p=1:length(model.cellCompartments)
            %if strcmp(model.mets(m),['h[' compartments{p,1} ']']);
            if strcmp(model.mets{m},['h[' model.cellCompartments(p) ']']);
                model.dGf0GroupCont(m)=0; % never executed???
            end
        end

        %Energies are expressed in kJ mol^-1
        midx=find(strcmp(model.mets{m}(1:end-3),{model.metGroupCont.abbreviation}));
        if(midx)
            midx=midx(1);
            dGzero=model.metGroupCont(midx).delta_G_formation; %dfG0GroupCont(m);
            uncertainty=model.metGroupCont(midx).delta_G_formation_uncertainty; %dfG0GroupContUncertainty(m);
        else
            dGzero = NaN;
            uncertainty = NaN;
        end

        %get number of H atoms from formula (at pHc 7)
        %%%%%%%%%adapt these for InChI strings ?
        %formula=model.met(m).formulaMarvin;
        formula=model.metFormulas{m};
%         start=strfind(formula,'H');
%         if ~isempty(start)
%             start=start+1;
%             if start>length(formula)
%                 %ion, only one atom
%                 endd=1;
%             else
%                 %molecule
%                 p=0;
%                 while ~isempty(str2num(formula(start+p)))
%                     if (length(formula)-start-p)==0
%                         break;
%                     end
%                     p=p+1;
%                 end
%                 endd=start+p-1;
%             end
%             if endd<start
%                 %deal with entirely text formulas, e.g. HCN
%                 nH=1;
%             else
%                 nH=str2num(formula(start:endd));
%             end
%         else
%             %no hydrogens
%             nH=0;
%         end

        nH = numAtomsOfElementInFormula(formula,'H'); % Inserted instead of preceding if statement. - Hulda
        if isnan(nH)
            error('No nH for metabolite');
        end

        %set the number of protons in a metabolite species
        %model.met(m).aveHbound=nH;
        model.aveHbound(m)=nH;

        %     if strcmp(model.mets(m),'h[c]')
        %         model.mets(m)
        %     end
        %set the charge of a metabolite species
        %model.met(m).aveZi=model.met(m).chargeMarvin;
        model.aveZi(m)=model.metCharges(m);

        %set the pH, ionic strength & electrical potential for the metabolite depending on the compartment
        %pHr=PHR.(model.mets(m)(end-1));
        %is=IS.(model.mets(m)(end-1));
        %chi=CHI.(model.mets(m)(end-1));

        pHr=model.ph(find(strcmp(model.cellCompartments,model.metComps(m))));
        is=model.is(find(strcmp(model.cellCompartments,model.metComps(m))));
        chi=model.chi(find(strcmp(model.cellCompartments,model.metComps(m))));

        if ~isnan(dGzero)
            %get charge (at pHr 7)
            %zi=model.met(m).chargeMarvin;
            zi=model.metCharges(m);
            if isnan(zi)
                error('No zi for metabolite');
            end

            if Legendre
                %note the use of real pH which depends on the metabolite
                %compartment
                pHterm = nH*RT*log(10^-pHr);
                isterm = gibbscoeff*((zi^2) - nH)*(is^.5)/(1 + 1.6*is^.5);
                %Legendre Transformation for Electrical Potential
                if 1
                    electricalTerm=(F*(chi/1000))*zi;
                else
                    electricalTerm = 0;
                end
            else
                %no Legendre transformation for pH
                pHterm = 0;
                isterm = gibbscoeff*(zi^2)*(is^.5)/(1 + 1.6*is^.5);
                %Legendre Transformation for Electrical Potential
                if 1
                    electricalTerm=(F*(chi/1000))*zi;
                else
                    electricalTerm = 0;
                end
            end
            %adjust to standard transformed Gibbs energy
            dGzerot=dGzero - pHterm - isterm + electricalTerm;

            %activity coefficient
            lambda=exp(-(isterm/RT));
            mf=1;
        else
            dGzerot=NaN;
            uncertainty=NaN;
            lambda=NaN;
            mf = NaN;
        end

        if isempty(dGzerot)
            error('Missing dGzerot for metabolite');
        end
        if isempty(uncertainty)
            error('Missing uncertainty for metabolite');
        end
        %transformed values are in kJ
        model.dfGt0GroupCont(m)=dGzerot;
        model.dfGt0GroupContUncertainty(m)=uncertainty;
        %activity coefficient
        model.lambda{m,1} = lambda; %model.lambda(m)=lambda;
        model.mf{m,1} = mf; %model.mf(m)=mf;
    else
        %dummy values if none available
        model.dfGt0GroupCont(m)=NaN;
        model.dfGt0GroupContUncertainty(m)=NaN;
        model.mf{m,1} = NaN; %model.mf(m)=NaN;
    end
end
