function [metList, stoichiometries] = findMetsFromRxns(model, reactions)
% Get all Metabolites from a set of reactions.
%
% USAGE:
%
%    [metList, stoichiometries] = findMetsFromRxns(model, reactions)
%    [metList] = findMetsFromRxns(model, reactions)
%
% INPUTS:
%    model:             COBRA model structure
%    reactions:         Reaction IDs (Cell Array) or positions (Double array) to 
%                       find the corresponding metabolites for
%
% OUTPUT:
%    metList:           If only one output is requested, returns an ordered set of all
%                       metabolites involved in the provided reactions.
%                       Otherwise, this is a Cell Array of cell arrays
%                       containing the metabolites involved in each of the
%                       provided reactions.
%    stoichiometries:   this is a Cell array of double arrays of the
%                       stoichiometric coefficients corresponding to the
%                       reactions in the order of provided reaction ids.
%                       If reactions not in the model are provided, those
%                       will be represented by empty arrays.
% .. Author: - Thomas Pfau Jan 2018

if ~isnumeric(reactions)
    rxnInd = findRxnIDs(model, reactions);
else
    rxnInd = reactions;
end

rxnNotInModel = (rxnInd == 0);
if any(rxnNotInModel)
    warning('The following reactions are not in the model:\n%s',strjoin(reactions(rxnNotInModel),'; '));
end

rxnInd = rxnInd(~rxnNotInModel);
reactionStoich = model.S(:,rxnInd);

%if only metabolites are requested
if nargout < 2
    metList = model.mets(sum(abs(reactionStoich),2) > 0);
    return
else
    %Initialize the outputs.
    metList = cell(numel(reactions),1);
    stoichiometries = cell(numel(reactions,1));
    %Init the relevant reactions.
    relMetList = cell(numel(rxnInd),1);
    relStoichiometries = cell(numel(rxnInd),1);
    for i = 1:numel(rxnInd)
        relpos = reactionStoich(:,i) ~= 0;
        relMetList{i} = model.mets(relpos);
        relStoichiometries{i} = reactionStoich(relpos,i);
    end
    metList(~rxnNotInModel) = relMetList;
    metList(rxnNotInModel) = {{}};
    stoichiometries(~rxnNotInModel) = relStoichiometries;
end

