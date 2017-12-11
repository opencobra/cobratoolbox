function [mapRev] = transformToReversibleMap(map, rxnlist)
% Converts a map structure from irreversible format to
% reversible format for a list of reaction names
%
% USAGE:
%
%   [mapRev] = transformToReversibleMap(map, rxnlist)
%
% INPUTS:
%   map:        Map from CellDesigner parsed to MATLAB format
%   rxnlist:    List of reaction names to transform
%
% OUTPUT:
%   mapRev:   Map in reversible format
%
% .. Authors:
%       - MOUSS Rouquaya 24/07/2017
%       - N.Sompairac - Institut Curie, Paris 25/07/2017

    mapRev = map;
    index = find(ismember(mapRev.rxnName, rxnlist));
    mapRev.rxnReversibility(index, 1) = {'true'};

end
