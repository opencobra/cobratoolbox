function [mets, id] = findMetsFromCompartInMap(map, compartment)
% Finds all the metabolites and their names in the map structure for
% a compartment of interest.
%
% USAGE:
%
%    [mets, id] = findMetsFromCompartInMap(map, compartment)
%
% INPUTS:
%    map:               Map from CellDesigner parsed to matlab format, with fields:
%
%                          * .specName - Cell array of metabolite (species) names
%    compartment:       Compartment of interest (e.g.: '[m]','[n]','[e]',etc.)
%
% OUTPUTS:
%    mets:              List of metabolites names
%    id:                Metabolites indexes
%
% .. Authors:
%       - MOUSS Rouquaya 24/07/2017
%       - J.Modamio BLCSB, Belval, Luxembourg.
%       - N.Sompairac - Institut Curie, Paris, 11/10/2017

    index = strfind(map.specName, compartment);
    id = find(~cellfun(@isempty, index));
    mets = map.specName(id);

end
