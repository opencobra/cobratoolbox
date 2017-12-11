function [rxns, id] = findRxnsFromCompartInMap(map, compartment)
% Finds all the reactions and their names in the map structure for
% a compartment of interest.
%
% USAGE:
%
%    [rxns, id] = findRxnFromCompartMap(map, Compartment)
%
% INPUTS:
%    map:               Map from CellDesigner parsed to matlab format
%    compartment:       Compartment of interest (e.g.: '[m]','[n]','[e]',etc.)
%
% OUTPUTS:
%    rxns:              List of reaction names
%    id:                Reactions indexes
%
% .. Authors:
%       - N.Sompairac - Institut Curie, Paris, 7/12/2017

    index = strfind(map.rxnName, compartment);
    id = find(~cellfun(@isempty, index));
    rxns = map.rxnName(id);

end
