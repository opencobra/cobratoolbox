function map = transformToReversibleMap(map, rxnlist)

    % Converts a map structure from irreversible format to
    % reversible format for a list of reaction names
    %
    % USAGE:
    %
    %   mapRev = transformToReversibleMap(map)
    %
    % INPUT:
    %
    %   map:   Map from CD parsed to matlab format
    %
    % OUTPUT:
    %
    %   map:   Map in reversible format
    %
    % .. Authors:
    % MOUSS Rouquaya Date : 24/07/2017
    % N.Sompairac - Institut Curie, Paris 25/07/2017 (Code checking)

    index = find(ismember(map.rxnName,rxnlist));
    map.rxnReversibility(index,1) = {'true'};

end

