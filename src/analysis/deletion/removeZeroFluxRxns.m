function modelOut = removeZeroFluxRxns(model, rxns)
% Removes the reactions that cannot have any fluxes .
% This function sets each reaction as the objective function and applies
% FBA to find maximum and minuimum flux that can be carried through that
% reaction, and removes the reactions that cannot have any fluxes.
% notice: the results have functional dependency, not structural. results
% may change due to a change in substrate for a model.
%
% USAGE:
%    new_Model = removeZeroFluxRxns(model, reactions)
%
% INPUTS:
%    model:                 COBRA model structure (must define `.rxns`, `.lb`, `.ub`)
%
%OPTIONAL INPUT
%    reactions:             Cell array of reaction names in the model
%
% OUTPUT:
%    new_model:             Curated model, the model with removed reactions
%                           incapable of having a flux value, and corrected
%                           upper and lower bounds.
%
% .. Author: - Farid Zare  5/31/2019

if ~isstruct(model)
    error('Input model must be structure');
end

if ~isfield(model, 'rxns')
    error('Input model should contain `.rxns` field');
end

if ~isfield(model, 'lb')
    error('Input model should contain `.lb` field');
end

if ~isfield(model, 'ub')
    error('Input model should contain `.ub` field');
end

if nargin < 2
    rxns = model.rxns;
end

modelOut = model;
h = waitbar(0 , 'Working On Model... ');
rxnsLength = length(rxns);

for i = 1 : rxnsLength
    
    str = ['Working On Model...         ' + string(round(i / rxnsLength, 2) * 100) + '%'] ;
    
    if ishandle(h)
        waitbar(i / rxnsLength, h, str);
    else
        warning('The process is terminated by the user');
        break
    end
    
    %Set each reaction as objective and apply FBA
    model = changeObjective(model, rxns(i));
    solMin = optimizeCbModel(model, 'min');
    solMax = optimizeCbModel(model, 'max');
    
    %Set bounds to their feasible values in the network
    rxnID = findRxnIDs(model, rxns(i) );
    modelOut.lb(rxnID) = solMin.f;
    modelOut.ub(rxnID) = solMax.f;
    
end

index = modelOut.ub ==0 & modelOut.lb == 0;
modelOut = removeRxns(modelOut, modelOut.rxns(index));
delete(h)

end
