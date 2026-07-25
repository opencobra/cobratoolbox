function [mapIrrev] = transformToIrreversibleMap(map, rxnlist)
% Converts a map structure from reversible format to irreversible format
% for a list of reaction names
%
% USAGE:
%
%    [mapIrrev] = transformToIrreversibleMap(map, rxnlist)
%
% INPUTS:
%    map:           MATLAB structure of a CellDesigner map (see `transformXML2Map`).
%                   Fields used:
%
%                     * .rxnName - reaction names, matched against `rxnlist`
%    rxnlist:       Cell array of reaction names to transform to irreversible format
%
% OUTPUT:
%    mapIrrev:      `map` with `.rxnReversibility` set to `'false'` for the reactions
%                   listed in `rxnlist`
%
% .. Authors:
%       - MOUSS Rouquaya 24/07/2017
%       - N.Sompairac - Institut Curie, Paris 25/07/2017

    mapIrrev = map;
    index = find(ismember(mapIrrev.rxnName, rxnlist));
    mapIrrev.rxnReversibility(index, 1) = {'false'};

end
