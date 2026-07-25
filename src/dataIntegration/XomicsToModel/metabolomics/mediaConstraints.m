function [model, metsUnmapped, rxnsUpdated] = mediaConstraints(model, uptakeRates, uptakeInChi, uptakeNames)
    % Find the highest uptake rate for each metabolite in the uptake data and set
    % it as a lower bound on the exchange reaction for that metabolite. If the
    % maximum uptake rate is higher than 0 (the metabolite is only secreted by the
    % cells) then the lower bound is set to 0
    %
    % USAGE:
    %
    %    [model, metsUnmapped, rxnsUpdated] = mediaConstraints(model, uptakeRates, uptakeInChi, uptakeNames)
    %
    % INPUTS:
    %    model:    COBRA model
    %    uptakeRates:    numeric uptake/secretion rates (mmol/gDW/h) for each measured metabolite
    %    uptakeInChi:    InChI codes identifying the measured metabolites
    %    uptakeNames:    chemical names of the measured metabolites
    %
    % OUTPUTS:
    %    model:    COBRA model with constrained uptake rates
    %    metsUnmapped:    metabolites that could not be mapped to the model
    %    rxnsUpdated:    exchange reactions whose bounds were updated
    %
    % .. Author: - 20190617 Agnieszka Wegrzyn
    
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