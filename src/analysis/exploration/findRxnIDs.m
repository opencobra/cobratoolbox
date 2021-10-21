function rxnID = findRxnIDs(model, rxnList)
% Finds reaction indices in a model
%
% USAGE:
%
%    rxnID = findRxnIDs(model, rxnList)
%
% INPUTS:
%    model:      COBRA model structure
%    rxnList:    cell array of reaction abbreviations
%
% OUTPUT:
%    rxnID:      indices for reactions corresponding to rxnList

% .. Author: -  Ronan Fleming

if ~iscell(rxnList)
    rxnList = cellstr(rxnList);
end
try
    [~,rxnID] = ismember(rxnList,model.rxns);
catch
    model.rxns = cellfun(@num2str,model.rxns,'UniformOutput',false);
    [~,rxnID] = ismember(rxnList,model.rxns);
    warning('Some model.rxns are double rather than char. Had to convert model.rxns to a cell array of character vectors.')
end
