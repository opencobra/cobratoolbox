function [model, metsUnmapped, rxnsUpdated] = mediaConstraints(model, uptakeRates, uptakeInChi, uptakeNames)
    %this function finds the highest uptake rate for each metabolite in the
    %uptakeRatesTable and sets this value as a lower boudary in the
    %exchange reaction for that metabolite. If maximum uptake rate is higer
    %than 0 (metabolite is only secreted by the cells) then lower boundary
    %is set to 0
    %
    % Inputs:
    %   model - Cobra model
    %   uptakesRatesTable - Table consisting of 'Chemical_Name', 'InChICode',
    %                       and numeric columns with the experimental data 
    %                       (uptake/secretion rates in mmol/gDW/h )
    % Output:
    %   model -  Cobra model with constrained uptake rates
    %
    % 20190617 Agnieszka Wegrzyn
    
    model_temp = model;
    mediaInformation = uptakeInChi;
    EXrxns_all = model_temp.rxns(findExcRxns(model_temp));
    EXrxns = EXrxns_all(contains(EXrxns_all, 'EX_'));
    EXmets = findMetsFromRxns(model_temp, model_temp.rxns(findExcRxns(model_temp)));
    Rates = uptakeRates;
    rxnsUpdated = [];
    metsUnmapped = [];
    for i=1:length(mediaInformation)
        mets_temp = model_temp.mets(ismember(model_temp.metInChIString, mediaInformation(i)));
        
        if ~isempty(mets_temp)
            rxn_temp = EXrxns(ismember(EXrxns, findRxnsFromMets(model_temp,mets_temp(ismember(mets_temp, EXmets)))));
            model_temp = changeRxnBounds(model_temp, rxn_temp, min(min(Rates(i,:)),0)*1e4,'l');
            rxnsUpdated = [rxnsUpdated; rxn_temp];
        else
            metsUnmapped = [metsUnmapped; uptakeNames(i)];
        end
    end
    
model = model_temp;
    
end