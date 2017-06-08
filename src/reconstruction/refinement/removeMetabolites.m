function model = removeMetabolites(model, metaboliteList, removeRxnFlag)
% Removes metabolites from a model
%
% USAGE:
%
%    model = removeMetabolites(model, metaboliteList, removeRxnFlag)
%
% INPUTS:
%    model:             COBRA model structure
%    metaboliteList:    List of metabolites to be removed
%
% OPTIONAL INPUT:
%    removeRxnFlag:     Remove reactions with no metabolites (Default = true)
%
% OUTPUT:
%    model:             COBRA model with removed metabolites
%
% .. Authors:
%       - Markus Herrgard 6/5/07
%       - Uri David Akavia 1/18/14
%       - Fatima Liliana Monteiro 17/11/16 add an if condition to remove metabolites just from fields with same length
%       - Thomas Pfau, added automatic Field Update.
if (nargin < 3)
    removeRxnFlag = true;
end

[nMets, nRxns] = size(model.S);
if isfield(model, 'genes')
    nGenes = length(model.genes);
else
    nGenes = 0;
end

selMets = ~ismember(model.mets,metaboliteList);

% Construct new model
modelOut = removeRelevantModelFields(model, ~selMets, 'mets', numel(model.mets));


if removeRxnFlag
    %if S is empty..
    if(isempty(modelOut.S))
        return
    end
    rxnRemoveList = modelOut.rxns(~any(modelOut.S ~= 0));
    if (~isempty(rxnRemoveList))
        modelOut = removeRxns(modelOut,rxnRemoveList,false,false);
    end
end
%return the modified model
model = modelOut;
