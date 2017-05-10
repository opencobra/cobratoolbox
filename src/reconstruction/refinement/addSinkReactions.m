function [model,rxnsInModel] = addSinkReactions(model,metabolites,lb,ub)
% Adds a sink reaction for the list of metabolites
%
% USAGE:
%
%    [model] = addSinkReactions(model, metabolites, lb, ub)
%
% INPUTS:
%    model:         COBRA model structure
%    metabolites:   Cell array of metabolite abreviations as they appear in `model.mets`
%
% OPTIONAL INPUTS:
%    lb:            Lower bounds of reactions
%    ub:            Upper bounds of reactions
%
% OUTPUTS:
%    model:         COBRA model structure containing sink reactions
%    rxnsInModel:   Vector, contains -1 if the reaction did not exist
%                   previously, otherwise it contains the reaction ID of
%                   an identical reaction already present in the model
%
% .. Author: - Ines Thiele 05/06/08

nMets = length(metabolites);
if nargin < 3
    lb = ones(nMets,1)*min(model.lb);
    ub = ones(nMets,1)*max(model.ub);
end

if size(lb,2)==2
    ub = lb(:,2);
    lb = lb(:,1);
end

rxnsInModel=-ones(length(metabolites),1);
for i = 1 : nMets
    rxnName = strcat('sink_',metabolites{i});
    [model,rxnIDs] = addReaction(model,rxnName,metabolites(i),-1,1,lb(i),ub(i),0,'Sink', [], [], [], 0); % ignore duplicates
    if ~isempty(rxnIDs)
       rxnsInModel(i)=rxnIDs;
    end
    model.rxnNames(strcmp(model.rxns,rxnName)) = {rxnName};
end
