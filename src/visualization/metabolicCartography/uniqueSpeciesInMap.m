function uniqueSpecies = uniqueSpeciesInMap(mapMicroMap)
% uniqueSpeciesInMap - Identifies unique metabolites and other species in a CellDesigner map structure
%
% USAGE:
%
%    uniqueSpecies = uniqueSpeciesInMap(mapMicroMap)
%
% INPUT:
%    mapMicroMap:    Structure containing species from a CellDesigner map
%                    mapMicroMap.specName contains species names
%
% OUTPUT:
%    uniqueSpecies:  Structure with fields:
%                    - mets: Unique metabolites (names without compartment tags)
%                    - nonMets: Unique non-metabolite species
%
% .. Authors:
%       Cyrille Thinnes, University of Galway, 25/10/2024

% Extract species names
specNames = mapMicroMap.specName;

% Identify metabolites with compartment tags
metabolites = specNames(contains(specNames, '[') & contains(specNames, ']'));

% Remove compartment tags for metabolites
metsNoCompartment = regexprep(metabolites, '\[.*?\]', '');

% Find unique metabolites
uniqueMets = unique(metsNoCompartment);

% Identify non-metabolite species (without compartment tags)
nonMetabolites = specNames(~contains(specNames, '[') & ~contains(specNames, ']'));

% Find unique non-metabolite species
uniqueNonMets = unique(nonMetabolites);

% Compile results into the output structure uniqueSpecies
uniqueSpecies.mets = uniqueMets;
uniqueSpecies.nonMets = uniqueNonMets;

end

