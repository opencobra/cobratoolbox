function metID = findMetIDsMap(map, metList)

% Finds metabolites Indexes in a map for a given list of names
%
% USAGE:
%
%    metID = findMetIdsMap(map, metList)
%
% INPUTS:
%
%    map:      Map from CD parsed to matlab format
%
%    metList:  List of metabolites names
%
% OUTPUT:
%
%    metID:    List of metabolite indexes corresponding to `metList`
%
% .. Authors:
% .. Mouss Rouquaya 24/07/2017
% .. N.Sompairac - Institut Curie, Paris, 11/10/2017 (Code checking)

    metID = find(ismember(map.specName, metList));

end