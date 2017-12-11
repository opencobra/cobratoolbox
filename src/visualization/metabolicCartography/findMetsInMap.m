function [metID] = findMetsInMap(map, metList)
% Finds metabolites indices in a CellDesigner map for a given list of names
%
% USAGE:
%
%    [metID] = findMetIdsMap(map, metList)
%
% INPUTS:
%    map:       Map from CellDesigner parsed to MATLAB format
%    metList:   List of metabolites names
%
% OUTPUT:
%    metID:     List of metabolite indices corresponding to `metList`
%
% .. Authors:
%       - Mouss Rouquaya 24/07/2017
%       - N.Sompairac - Institut Curie, Paris, 11/10/2017 (Code checking)

    metID = find(ismember(map.specName, metList));

end
