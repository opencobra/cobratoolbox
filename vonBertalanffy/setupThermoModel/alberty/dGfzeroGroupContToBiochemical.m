function model=dGfzeroGroupContToBiochemical(model,temp,PHR,IS,CHI,compartments,NaNdGf0GCMetBool,Legendre)
%transform group contribution estimate of metabolite standard transformed Gibbs energy
%
%convert group contribution data biochemical standard transformed Gibbs
%energy of formation, at specified pH and ionic strength
%
%INPUT
% model
% model.met(m).dGf0GroupCont                (kJ mol^-1)
% model.met(m).dGf0GroupContUncertainty     (kJ mol^-1)    
% temp              temperature
% PHR.*             real pH in compartment defined by letter *
% IS.*              ionic strength (0 - 0.35M) in compartment defined by letter *
% CHI.*             electrical potential (mV) in compartment defined by letter *
% compartments      2 x # cell array of distinct compartment letters and
%                   compartment names
% NaNdGf0GCMetBool  m x 1 boolean vector with 1 when no group contribution
%                   data is available for a metabolite
%
%OPTIONAL INPUT
% Legendre          {(1),0} Legendre Transformation for specifc pH and electrical potential?
%
%OUTPUT
% model.met(m).dGf0GroupCont              group contribution estimate(kJ mol^-1)
% model.met(m).dGft0GroupCont             group contribution estimate +/-Legendre transform (kJ mol^-1)
% model.met(m).dGft0GroupContUncertainty  error on group contribution estimate +/- Legendre transform (kJ mol^-1)
% model.met(m).aveHbound                average number of H+ bound
% model.met(m).aveZi                    average charge
%
%
%at the moment, the charges of the metabolites are for pH 7 only so
%strictly it should be pH 7 only
%
% iAF1260 Supplemental Note:
% "All delta_f_G_est_0 calculated for the reconstruction using the
% group contribution method are based upon the standard condition of
% aqueous solution with pH equal to 7, temperature equal to 298.15 K,
% zero ionic strength and 1M concentrations of all species except H+,
% and water. In the cases where multiple charged forms of a molecule
% exist at pH 7, the most abundant form is used."
% Same as Janowski et al Biophysical Journal 95:1487-1499 (2008)
%
% Ronan M.T. Fleming

if ~exist('Legendre','var')
    Legendre=1;
end
%stamp model
model.Legendre=Legendre;
%The values of the standard transformed Gibbs energy of formation for:
%real pH in the range 5 to 9
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

%temperature dependent coefficient in the calculation of ionic strenghth
%effect
%RTalpha p 49 Alberty 2003
%where alpha is the Debye-Huckel Constant
gibbscoeff = (9.20483*temp)/10^3 - (1.284668*temp^2)/10^5 + (4.95199*temp^3)/10^8;

[nMet,nRxn]=size(model.S);
RT=model.gasConstant*model.temp;
F=model.faradayConstant;
for m=1:nMet
    if strcmp(model.met(m).abbreviation,'damval[c]');
        pause(eps)
    end
    %ignore for metabolites with no group contribution estimates
    if ~NaNdGf0GCMetBool(m)
        %set the standard chemical potential of H+ ion to zero
        for p=1:length(compartments)
            if strcmp(model.met(m).abbreviation,['h[' compartments{p,1} ']']);
                model.met(m).dGf0GroupCont=0;
            end
        end

        %Energies are expressed in kJ mol^-1
        dGzero=model.met(m).dGf0GroupCont;
        uncertainty=model.met(m).dGf0GroupContUncertainty;

        %get number of H atoms from formula (at pHc 7)
        %%%%%%%%%adapt these for InChI strings ?
        formula=model.met(m).formulaMarvin;
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
        model.met(m).aveHbound=nH;

        %     if strcmp(model.met(m).abbreviation,'h[c]')
        %         model.met(m).abbreviation
        %     end
        %set the charge of a metabolite species
        model.met(m).aveZi=model.met(m).chargeMarvin;

        %set the pH, ionic strength & electrical potential for the metabolite depending on the compartment
        pHr=PHR.(model.met(m).abbreviation(end-1));
        is=IS.(model.met(m).abbreviation(end-1));
        chi=CHI.(model.met(m).abbreviation(end-1));

        if ~isnan(dGzero)
            %get charge (at pHr 7)
            zi=model.met(m).chargeMarvin;
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
        model.met(m).dGft0GroupCont=dGzerot;
        model.met(m).dGft0GroupContUncertainty=uncertainty;
        %activity coefficient
        model.met(m).lambda=lambda;
        model.met(m).mf=mf;
    else
        %dummy values if none available
        model.met(m).dGft0GroupCont=NaN;
        model.met(m).dGft0GroupContUncertainty=NaN;
        model.met(m).mf=NaN;
    end
end


    
    
    
    
    
    