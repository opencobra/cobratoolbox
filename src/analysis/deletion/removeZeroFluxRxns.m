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
%    model:                      COBRA model structure (must define `.c`, `.lb`, `.ub`, `.S`, `.rxns`, `.mets`)
%
%OPTIONAL INPUT
%    reactions:                Cell array of reaction names in the model
%
% OUTPUT:
%    new_model:             Curated model, the model with removed reactions
%                                     incapable of having a flux value, and corrected
%                                     upper and lower bounds.
%
% .. Author: - Farid Zare  5/31/2019
%...Further modifications suggested by: -Thomas Pfau 6/1/2019

checkModel = verifyModel(model,'FBAOnly',true,'simpleCheck', true);

if ~checkModel
    error('The input model is invalid. Please check the model with ''verifyModel(model)'' and correct all indicated errors');
end

if nargin < 2
    rxns = model.rxns;
end

modelOut = model;

[minFlux, maxFlux] = fluxVariability(modelOut, 0, 'max', rxns);

%Set bounds to their feasible values in the network
modelOut.lb = minFlux;
modelOut.ub = maxFlux;

%Difining a threshold
feasTol = getCobraSolverParams('LP','feasTol');
index = abs(modelOut.ub) < feasTol & abs(modelOut.lb) < feasTol;

%Remove reactions with fluxes in range of threshold
modelOut = removeRxns(modelOut, modelOut.rxns(index));

end
