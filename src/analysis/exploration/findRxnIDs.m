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
[~,rxnID] = ismember(rxnList,model.rxns);

%TODO, must be a faster way to do this
% if length(rxnID)~=1
%     [bool,LOCB] = ismember(model.rxns,rxnList);
%     rxnID2 = find(bool);
%     if length(rxnID2)~=length(rxnList)
%         [~,rxnID2] = ismember(rxnList,model.rxns(bool));
%     end
% end