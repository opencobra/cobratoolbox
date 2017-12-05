function [mets, ID] = findMetFromCompartMap(map, compartment)

% Finds all the metabolites and their names in the map structure for
% a compartment of interest.
%
% USAGE:
%
%    [mets, ID] = findMetFromCompartMap(map, Compartment)
%
% INPUTS:
%
%    map:               Map from CD parsed to matlab format
%
%    compartment:       Compartment of interest (e.g.: '[m]','[n]','[e]',etc.)
%
% OUTPUT:
%
%    mets:              List of metabolites names
%
%    ID:                Metabolites indexes
%
% .. Authors: MOUSS Rouquaya 24/07/2017
% .. Modifications added J.Modamio BLCSB, Belval, Luxembourg.
% .. Improvements N.Sompairac - Institut Curie, Paris, 11/10/2017

    index = strfind(map.specName, compartment);
    ID = find(~cellfun(@isempty, index));
    mets = map.specName(ID);
    
end