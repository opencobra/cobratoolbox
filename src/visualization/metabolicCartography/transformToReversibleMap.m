function [mapRev] = transformToReversibleMap(map, rxnlist)
% Converts a map structure from irreversible format to reversible format
% for a list of reaction names
%
% USAGE:
%
%    [mapRev] = transformToReversibleMap(map, rxnlist)
%
% INPUTS:
%    map:           MATLAB structure of a CellDesigner map (see `transformXML2Map`).
%                   Fields used:
%
%                     * .rxnName - reaction names, matched against `rxnlist`
%    rxnlist:       Cell array of reaction names to transform to reversible format
%
% OUTPUT:
%    mapRev:        `map` with `.rxnReversibility` set to `'true'` for the reactions
%                   listed in `rxnlist`
%
% .. Authors:
%       - MOUSS Rouquaya 24/07/2017
%       - N.Sompairac - Institut Curie, Paris 25/07/2017

    mapRev = map;
    index = find(ismember(mapRev.rxnName, rxnlist));
    mapRev.rxnReversibility(index, 1) = {'true'};

end
