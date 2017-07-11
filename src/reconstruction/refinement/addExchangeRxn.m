function [newModel, AddedExchRxn] = addExchangeRxn(model, metList, lb, ub)
% Adds exchange reactions
%
% USAGE:
%
%    newModel = addExchangeRxn(model, metList, lb, ub)
%
% INPUTS:
%    model:       Cobra model structure
%    metList:     List of metabolites
%
% OPTIONAL INPUTS:
%    lb:          Array of lower bounds
%    ub:          Array of upper bounds
%
% OUTPUT:
%    newModel:    COBRA model with added exchange reactions
%
% .. Author: - Ines Thiele 02/2009

if nargin < 3
    lb = ones(length(metList),1)*min(model.lb);
end
if nargin < 4
    ub = ones(length(metList),1)*max(model.ub);
end
Revs = zeros(length(metList),1);
Revs(lb<0) = 1;

newModel = model;
AddedExchRxn = '';

% check duplicate here to save time (avoid checking duplicate by calling ismember in addReaction)
metOrd = findMetIDs(newModel, metList);  % met Id for metList
% duplicate if there are exchange reactions with -1 stoichiometry involving any mets in metList
duplicate = find(sum(newModel.S ~= 0, 1) == 1 & any(newModel.S == -1, 1) & any(newModel.S(metOrd, :), 1));
if ~isempty(duplicate)
    % metWtExchRxn(j) is the met order already having exchange rxns duplicate(j) 
    [metWtExchRxn, ~] = find(newModel.S(:, duplicate));
    % get the order of metWtExchRxn in metId
    [~, ord] = ismember(metWtExchRxn, metOrd);
    % remove them from the list
    metList(ord) = [];
    lb(ord) = [];
    ub(ord) = [];
    % for the same behavior as addReaction with duplicate
    for j = 1:numel(duplicate)
        warning(['Model already has the same reaction you tried to add: ', newModel.rxns{duplicate(j)}]);
    end
end

for i = 1 : length(metList)
    [newModel,rxnIDexists] = addReaction(newModel,strcat('EX_',metList{i}),...
        'metaboliteList',metList(i),'stoichCoeffList',-1,...
        'lowerBound',lb(i), 'upperBound',ub(i), 'subSystem', 'Exchange', 'checkDuplicate', false);
    AddedExchRxn=[AddedExchRxn;strcat('EX_',metList(i))];
end
