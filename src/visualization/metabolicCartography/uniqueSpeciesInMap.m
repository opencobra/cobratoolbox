function uniqueSpecies = uniqueSpeciesInMap(mapMicroMap)
% Identifies unique metabolites and other species in a CellDesigner map structure
%
% USAGE:
%
%    uniqueSpecies = uniqueSpeciesInMap(mapMicroMap)
%
% INPUT:
%    mapMicroMap:      MATLAB structure of a CellDesigner map (see `transformXML2Map`).
%                      Fields used:
%
%                        * .specName - species names, split into metabolites (names
%                          containing a `[...]` compartment tag) and non-metabolites
%
% OUTPUT:
%    uniqueSpecies:    Structure with fields:
%
%                        * .mets - unique metabolite names, with compartment tags removed
%                        * .nonMets - unique non-metabolite species names
%
% .. Authors:
%       Cyrille Thinnes, University of Galway, 25/10/2024

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

