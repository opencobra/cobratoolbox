function [rxnID, rxnIDref] = findRxnsInMap(map, rxnList)
% Finds reaction indices in a CellDesigner map from a list of names
%
% USAGE:
%
%    [rxnID, rxnIDref] = findRxnIDs(map, rxnList)
%
% INPUTS:
%    map:           Map from CellDesigner parsed to MATLAB format
%    rxnList:       List of reaction names
%
% OUTPUTS:
%    rxnIDref:      ID reference for reactions
%    rxnID:         List of reactions indices
%
% .. Authors:
%       - Mouss Rouquaya LSCB, Belval, Luxembourg. Date: - 24.07.2017
%       - N.Sompairac - Institut Curie, Paris, 11/10/2017

    if (iscell(rxnList))
        [~, rxnID] = ismember(rxnList, map.rxnName);
        rxnIDref = map.rxnID(rxnID);
    else
        rxnID = find(strcmp(map.rxnName, rxnList));
        if (isempty(rxnID))
            rxnID = 0;
            rxnIDref = {};
        end
        if (length(rxnID) > 1)
            rxnID = rxnID(1);
            rxnIDref = map.rxnID(rxnID);
        end
    end
end
