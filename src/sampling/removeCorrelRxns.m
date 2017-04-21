function [selRxns,rxnSets,rxnList,Rfilt] = removeCorrelRxns(model,R,correlCutoff)
% Removes fully or almost fully correlated reactions
%
% USAGE:
%
%    [selRxns, rxnSets, rxnList, Rfilt] = removeCorrelRxns(model, R, correlCutoff)
%
% INPUTS:
%    model:         COBRA model structure
%    R:             Correl coefficient matrix
%
% OPTIONAL INPUT:
%    correlCutoff:  Cutoff level for fully correlated `rxns` (Default 0.99999)
%
% OUTPUTS:
%    selRxns:       true/false vector that allow selecting non-redundant data
%    rxnSets:       Correlated reaction sets
%    rxnList:       Reaction list with correlated reactions concatenated
%    Rfilt:         Filtered `R`
%
% .. Author: - Markus Herrgard 3/21/07

if (nargin < 3)
    correlCutoff = 1-1e-5;
end

% Filter out correlated reactions
rxns = model.rxns;
nRxns = length(rxns);
selRxns = false(nRxns,1);
alreadyIncluded = false(nRxns,1);
selNaN = isnan(diag(R));
alreadyIncluded(selNaN) = true;
newRxnCnt = 0;
for rxnID = 1:nRxns
    if ~alreadyIncluded(rxnID)
        selRxns(rxnID) = true;
        alreadyIncluded(rxnID) = true;
        newRxnCnt = newRxnCnt + 1;
        correlRxns = find(abs(R(rxnID,:)) >= correlCutoff);
        rxnSets{newRxnCnt} = rxns(correlRxns);
        if (~isempty(correlRxns))
            alreadyIncluded(correlRxns) = true;
        end
    end
end

rxnSets = columnVector(rxnSets);
Rfilt = R(selRxns,selRxns);

for i = 1:length(rxnSets)
    setSize = length(rxnSets{i});
    if (setSize > 1)
        tmpString = [];
        for j = 1:setSize
            if (j == 1)
                divider = '';
            else
                divider = '/';
            end
            tmpString = [tmpString divider rxnSets{i}{j}];
        end
        rxnList{i} = tmpString;
    else
        try
            rxnList{i} = rxnSets{i}{1};
        catch
           rxnSets{i}
        end
    end
end

rxnList = columnVector(rxnList);
