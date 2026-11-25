% The COBRAToolbox: testRemoveMapSpecies.m
%
% Purpose:
%     - removeMapSpecies(xmlStruct, map, specRemoveList, specRemoveType, printLevel) removes
%       the species named in specRemoveList (matched against map.specName) and, when
%       specRemoveType is given, every species of that map.specType from a CellDesigner map
%       (the map structure and the xml2struct structure returned by transformXML2Map),
%       together with every reaction in which a removed species takes part, the aliases of the
%       removed species and the aliases that take part only in removed reactions. The map
%       matrices are not rebuilt: their rows and columns of the removed entries are dropped.
%       Names not in the map are flagged in specNotInMap (and printed when printLevel > 0).
%     - The map is read from the CellDesigner file that ships with the test suite
%       (test/verifiedTests/visualization/testMetabolicCartography/testCD/glycolysisAndTCA.xml:
%       115 aliases, 67 species, 40 reactions); the test creates no file. Expected values are
%       derived from the input map matrices and checked against the names read in the file;
%       every other entry must be unchanged, and the matrices of the output must equal those
%       getMapMatrices rebuilds from the output's reaction lists.
%
% Function under test:
%     src/visualization/metabolicCartography/removeMapSpecies.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver; the input map is read from a CellDesigner file
%     shipped with the test suite.
%
% Coverage exemptions:
%     Lines 187-192: dead code, inside "if 0" (line 186).
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: A name listed twice is reported as not present in the map
%       SEVERITY: cosmetic
%       TRIGGER: removeMapSpecies(xmlStruct, map, {'itp[c]', 'itp[c]'}) on the map of
%         glycolysisAndTCA.xml, which contains itp[c]
%       OBSERVED: (R2025a, 2026-11-25) specNotInMap = [false; true] and 'itp[c] not present in
%         the map' is printed (ismember returns only the first position of itp[c] in the list,
%         so the second position is counted as missing); itp[c] is removed. The input is
%         skipped below.
%       EXPECTED: specNotInMap = [false; false] and no message, as itp[c] is in the map
%       LINES: 63, 68
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-25.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testRemoveMapSpecies'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% read the shipped map once (read only)
[xmlStruct, map] = transformXML2Map(fullfile(fileDir, 'testCD', 'glycolysisAndTCA.xml'));
xmlModel = xmlStruct.sbml.model;
aliasesIn = xmlModel.annotation.celldesigner_colon_extension.celldesigner_colon_listOfSpeciesAliases.celldesigner_colon_speciesAlias;

% the fields of the map per entity, for the content checks (the matrices are checked apart)
mapFields = fieldnames(map);
molFields = mapFields(strncmp(mapFields, 'mol', 3));
specFields = mapFields(strncmp(mapFields, 'spec', 4));
rxnFields = mapFields(strncmp(mapFields, 'rxn', 3));
compartFields = mapFields(strncmp(mapFields, 'compart', 7));

% expected entries for a set of removed species (logical over map.specID), derived from the
% input matrices: the reactions of those species, the aliases of those species and the aliases
% that take part only in those reactions
expectedRxn = @(removedSpec) any(map.sID(removedSpec, :), 1)';
expectedMol = @(removedSpec) any(map.idAlias(removedSpec, :), 1)' ...
    | (any(map.sAlias(:, expectedRxn(removedSpec)), 2) & ~any(map.sAlias(:, ~expectedRxn(removedSpec)), 2));

%% one species: its reaction and the aliases drawn only for that reaction go with it

% itp[c] takes part in r0354 only; default specRemoveType (none) and printLevel (1)
[xmlOut, mapOut, specNotInMap] = removeMapSpecies(xmlStruct, map, {'itp[c]'});
assert(isequal(specNotInMap, false));

removedSpec = strcmp(map.specName, 'itp[c]');
removedRxn = expectedRxn(removedSpec);
removedMol = expectedMol(removedSpec);
% the reaction r0354; the alias sa1 of itp[c], sa2 (an alias of h[c] drawn only for r0354) and
% sa3, the only alias of idp[c]. idp[c] takes part in r0354 only: it loses its alias but is
% kept as a species, since it is not in the list
assert(isequal(map.rxnName(removedRxn), {'r0354'}));
assert(isequal(sort(map.molAlias(removedMol)), {'sa1'; 'sa2'; 'sa3'}));
assert(isequal(map.specName(ismember(map.specID, map.molID(removedMol))), {'itp[c]'; 'h[c]'; 'idp[c]'}));

for i = 1:numel(rxnFields)
    assert(isequal(mapOut.(rxnFields{i}), map.(rxnFields{i})(~removedRxn)));
end
for i = 1:numel(specFields)
    assert(isequal(mapOut.(specFields{i}), map.(specFields{i})(~removedSpec)));
end
for i = 1:numel(molFields)
    assert(isequal(mapOut.(molFields{i}), map.(molFields{i})(~removedMol)));
end
for i = 1:numel(compartFields)
    assert(isequal(mapOut.(compartFields{i}), map.(compartFields{i})));
end
assert(isequal(fieldnames(mapOut), mapFields));
assert(isequal(mapOut.sID, map.sID(~removedSpec, ~removedRxn)));
assert(isequal(mapOut.sAlias, map.sAlias(~removedMol, ~removedRxn)));
assert(isequal(mapOut.idAlias, map.idAlias(~removedSpec, ~removedMol)));
% idp[c] is left without an alias
assert(~any(mapOut.idAlias(strcmp(mapOut.specName, 'idp[c]'), :)));

% the XML structure loses the same reaction, species and aliases
xmlOutModel = xmlOut.sbml.model;
assert(isequal(xmlOutModel.listOfReactions.reaction, xmlModel.listOfReactions.reaction(~removedRxn)));
assert(isequal(xmlOutModel.listOfSpecies.species, xmlModel.listOfSpecies.species(~removedSpec)));
aliasesOut = xmlOutModel.annotation.celldesigner_colon_extension.celldesigner_colon_listOfSpeciesAliases.celldesigner_colon_speciesAlias;
assert(isequal(aliasesOut, aliasesIn(~removedMol)));

%% a single character array is a list of one species

[xmlOutChar, mapOutChar, specNotInMap] = removeMapSpecies(xmlStruct, map, 'itp[c]');
assert(isequal(specNotInMap, false));
assert(isequal(mapOutChar, mapOut));
assert(isequal(xmlOutChar, xmlOut));

%% a species in many reactions: the matrices stay consistent with the reaction lists

% h[c] (12 aliases) takes part in 15 reactions
[~, mapOut, specNotInMap] = removeMapSpecies(xmlStruct, map, {'h[c]'}, [], 0);
assert(isequal(specNotInMap, false));
removedSpec = strcmp(map.specName, 'h[c]');
removedRxn = expectedRxn(removedSpec);
removedMol = expectedMol(removedSpec);
assert(nnz(removedRxn) == 15 && nnz(removedMol) == 39);
assert(isequal(mapOut.rxnName, map.rxnName(~removedRxn)));
assert(isequal(mapOut.specName, map.specName(~removedSpec)));
assert(isequal(mapOut.molAlias, map.molAlias(~removedMol)));
% the matrices that are carried over equal those rebuilt from the remaining reactions
rebuilt = getMapMatrices(rmfield(mapOut, {'sID', 'sAlias', 'idAlias'}));
assert(isequal(full(rebuilt.sID), full(mapOut.sID)));
assert(isequal(full(rebuilt.sAlias), full(mapOut.sAlias)));
assert(isequal(full(rebuilt.idAlias), full(mapOut.idAlias)));

%% a species type: every species of that type is removed as well

% the three species of type UNKNOWN are the pathway labels, in no reaction; the list is empty
[xmlOut, mapOut, specNotInMap] = removeMapSpecies(xmlStruct, map, {}, 'UNKNOWN', 0);
assert(isempty(specNotInMap));
removedSpec = strcmp(map.specType, 'UNKNOWN');
assert(isequal(sort(map.specName(removedSpec)), sort({'Glycolysis'; 'Pyruvate metabolism '; 'Citric acid cycle'})));
assert(~any(expectedRxn(removedSpec)));
removedMol = expectedMol(removedSpec);
assert(isequal(sort(map.molAlias(removedMol)), sort({'sa10'; 'sa54'; 'sa113'})));
assert(isequal(mapOut.rxnName, map.rxnName));
assert(isequal(mapOut.specName, map.specName(~removedSpec)));
assert(isequal(mapOut.molAlias, map.molAlias(~removedMol)));
assert(isequal(mapOut.idAlias, map.idAlias(~removedSpec, ~removedMol)));
assert(numel(xmlOut.sbml.model.listOfSpecies.species) == 64);
assert(numel(xmlOut.sbml.model.listOfReactions.reaction) == 40);

% a list and a type together remove the union
[~, mapOut] = removeMapSpecies(xmlStruct, map, {'itp[c]'}, 'UNKNOWN', 0);
removedSpec = strcmp(map.specType, 'UNKNOWN') | strcmp(map.specName, 'itp[c]');
assert(isequal(mapOut.specName, map.specName(~removedSpec)));
assert(isequal(mapOut.rxnName, map.rxnName(~expectedRxn(removedSpec))));
assert(isequal(mapOut.molAlias, map.molAlias(~expectedMol(removedSpec))));

%% nothing to remove: an empty list, or names not in the map

[xmlOut, mapOut, specNotInMap] = removeMapSpecies(xmlStruct, map, {}, [], 0);
assert(isempty(specNotInMap));
assert(isequal(mapOut, map));
assert(isequal(xmlOut, xmlStruct));

% default printLevel: the missing name is printed; nothing is removed
[xmlOut, mapOut, specNotInMap] = removeMapSpecies(xmlStruct, map, {'notThere'});
assert(isequal(specNotInMap, true));
assert(isequal(mapOut, map));
assert(isequal(xmlOut, xmlStruct));

% change the directory
cd(currentDir)
