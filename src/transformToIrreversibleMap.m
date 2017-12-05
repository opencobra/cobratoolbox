function map = transformToIrreversibleMap(map, rxnlist)

% Converts a map structure from irreversible format to
% reversible format for a list of reaction names
%
% USAGE:
%
%   mapIrrev = transformToIrreversibleMap(map, rxnlist)
%
% INPUT:
%
%   map:        Map from CD parsed to matlab format
%
%   rxnlist:    List of reaction names to transform
%
% OUTPUT:
%
%   mapIrrev:    Map with reactions in irreversible format
%
% .. Authors:
% MOUSS Rouquaya 24/07/2017
% N.Sompairac - Institut Curie, Paris 25/07/2017

    index = find(ismember(map.rxnName,rxnlist));
    map.rxnReversibility(index,1) = {'false'};

end