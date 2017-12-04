function [listRxns] = findRxnsPerType(map, rxnType)

    % Finds reaction names based on the type of reactions in the map. Useful
    % to look for transport, catalysis or simple state_transition.
    %
    % USAGE:
    %
    %    map = findTransRxns(map,rxnType) 
    %
    % INPUTS:
    %
    %    map:           Map from CD parsed to matlab format
    %
    %    rxnType:       Reaction type as a String 
    %
    % OUTPUT:
    %
    %    listRxns:      List of reactions indexes (1st column) and
    %                   reaction names (2nd column)
    %
    % .. Authors:
    % N.Sompairac - Institut Curie, Paris, 20/10/2017

    index = find(strcmp(map.rxnType, rxnType));
    listRxns(:,1) = num2cell(index);
    listRxns(:,2) = map.rxnName(index,1);

end

