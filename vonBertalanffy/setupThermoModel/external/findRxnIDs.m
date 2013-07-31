function rxnID = findRxnIDs(model,rxnList)
%findRxnIDs Find reaction numbers in a model
%
% rxnID = findRxnIDs(model,rxnList)
%
%INPUTS
% model     COBRA model strcture
% rxnList   List of reactions
%
%OUTPUT
% rxnID     IDs for reactions corresponding to rxnList
%
% Markus Herrgard 4/21/06

if (iscell(rxnList))
    [tmp,rxnID] = ismember(rxnList,model.rxns);    
else
    rxnID = find(strcmp(model.rxns,rxnList));
    if (isempty(rxnID))
        rxnID = 0;
    end
    if (length(rxnID) > 1)
        rxnID = rxnID(1);
    end
end