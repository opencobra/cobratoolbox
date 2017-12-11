function [mapIrrev] = transformToIrreversibleMap(map, rxnlist)
% Converts a map structure from irreversible format to
% reversible format for a list of reaction names
%
% USAGE:
%
%   [mapIrrev] = transformToIrreversibleMap(map, rxnlist)
%
% INPUTS:
%   map:        Map from CellDesigner parsed to MATLAB format
%   rxnlist:    List of reaction names to transform
%
% OUTPUT:
%   mapIrrev:    Map with reactions in irreversible format
%
% .. Authors:
%       - MOUSS Rouquaya 24/07/2017
%       - N.Sompairac - Institut Curie, Paris 25/07/2017

    mapIrrev = map;
    index = find(ismember(mapIrrev.rxnName, rxnlist));
    mapIrrev.rxnReversibility(index, 1) = {'false'};

end
