function [newModel, AddedExchRxn] = addExchangeRxn(model, metList, lb, ub)
% Adds exchange reactions
%
% USAGE:
%
%    [newModel, AddedExchRxn] = addExchangeRxn(model, metList, lb, ub)
%
% INPUTS:
%    model:       Cobra model structure with fields:
%
%                   * .mets - `m x 1` metabolite identifiers, used to find
%                     entries of `metList` missing from the model
%                   * .lb - `n x 1` reaction lower bounds, used to build
%                     the default lower bound when `lb` is not supplied
%                   * .ub - `n x 1` reaction upper bounds, used to build
%                     the default upper bound when `ub` is not supplied
%    metList:     List of metabolites
%
% OPTIONAL INPUTS:
%    lb:          Array of lower bounds
%    ub:          Array of upper bounds
%
% OUTPUTS:
%    newModel:        COBRA model with added exchange reactions
%    AddedExchRxn:    List of exchange reaction identifiers that were added
%
% .. Author: - Ines Thiele 02/2009
%            - Thomas Pfau, June 2018 - Change to use addMultipleReactions

if ~iscell(metList) 
    if ischar(metList)
        metList = {metList};
    else
        error('metList must either be a cell array of metabolite names or the name of a metabolite as a char');
    end
end
if nargin < 3
    lb = ones(length(metList),1)*min(model.lb);
end
if nargin < 4
    ub = ones(length(metList),1)*max(model.ub);
end

missingMets = setdiff(metList,model.mets);
if ~isempty(missingMets)
    warning('The following Metabolites have been added to the model, as they were not in the model before:\n%s', strjoin(missingMets,'\n'));
    model = addMultipleMetabolites(model,missingMets);
end


Revs = zeros(length(metList),1);
Revs(lb<0) = 1;

newModel = model;
AddedExchRxn = '';

% check duplicate here to save time (avoid checking duplicate by calling ismember in addReaction)
metOrd = findMetIDs(newModel, metList);  % met Id for metList
% duplicate if there are exchange reactions with -1 stoichiometry involving any mets in metList
duplicate = find(sum(newModel.S ~= 0, 1) == 1 & any(newModel.S == -1, 1) & any(newModel.S(metOrd(metOrd~=0), :), 1));
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


%Set the Exchanger Names that are added
AddedExchRxn = strcat('EX_',metList);
%Set the stoichiometry ( met[x] <=>)
stoich = -speye(numel(metList));
%Set the subSystem to "Exchange"
subSystems = repmat({{'Exchange'}},numel(metList),1);
%Add all Exchangers
newModel = addMultipleReactions(newModel,AddedExchRxn,metList,stoich,'lb',lb,'ub',ub,'subSystems',subSystems);

