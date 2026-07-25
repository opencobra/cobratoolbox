function [listRxns] = findRxnsPerTypeInMap(map, rxnType)
% Finds reaction names based on the type of reactions in the map. Useful
% to look for transport, catalysis or simple state_transition.
%
% USAGE:
%
%    [listRxns] = findRxnsPerTypeInMap(map, rxnType)
%
% INPUTS:
%    map:           Map from CellDesigner parsed to MATLAB format, with fields:
%
%                     * .rxnType - Cell array of reaction type strings
%                       (e.g. `TRANSPORT`, `STATE_TRANSITION`)
%                     * .rxnName - Cell array of reaction names
%    rxnType:       Reaction type as a string
%
% OUTPUT:
%    listRxns:      List of reactions indexes (1st column) and
%                   reaction names (2nd column)
%
% .. Author: - N.Sompairac - Institut Curie, Paris, 20/10/2017

    index = find(strcmp(map.rxnType, rxnType));
    listRxns(:,1) = num2cell(index);
    listRxns(:,2) = map.rxnName(index,1);

end

