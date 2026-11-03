% The COBRAToolbox: testRemoveMapMol.m
%
% Purpose:
%     - removeMapMol removes a list of molecule aliases from a CellDesigner map (the map
%       structure and the xml2struct structure returned by transformXML2Map). A species is
%       removed when all its aliases are removed, a reaction when it involves a removed species;
%       the map matrices sID, sAlias and idAlias are rebuilt. A single character array is
%       accepted as a list of one alias; aliases not in the map are flagged in specNotInMap (and
%       printed when printLevel > 0).
%       Characterization test that PINS the current behaviour (feature
%       20261103-105830-tier2-safe-batch, Constitution Principle III characterization mode);
%       it must not change the function under test.
%     - The map is read from the CellDesigner file that ships with the test suite
%       (test/verifiedTests/visualization/testMetabolicCartography/testCD/glycolysisAndTCA.xml:
%       115 aliases, 67 species, 40 reactions); the test creates no file. Expected values are
%       derived from the input map: the removed entries are located by name and every other
%       entry must be unchanged. Only the three aliases that take part in no reaction (sa10,
%       sa54 and sa113, the pathway labels "Glycolysis", "Pyruvate metabolism " and
%       "Citric acid cycle") are removed, because every removal that removes a reaction hits the
%       first defect below.
%
% Function under test:
%     src/visualization/metabolicCartography/removeMapMol.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver; the input map is read from a CellDesigner file
%     shipped with the test suite.
%
% Coverage exemptions:
%     - Lines 82 and 89: the else branches of "if 1" are dead code.
%     - Lines 103-105: removing reactions. Every alias of the shipped map whose removal removes a
%       reaction triggers the first defect below, so that input is skipped.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Aliases of a removed reaction are removed even when kept reactions use them
%       SEVERITY: wrong-result
%       TRIGGER: removeMapMol(xmlStruct, map, {'sa5'}) on the map of glycolysisAndTCA.xml (sa5 is
%         the only alias of glc_D[r]); every alias of that map whose removal removes a reaction
%         behaves alike
%       OBSERVED: reaction GLCter is removed together with all its aliases, including sa4, the
%         only alias of species s4427 (glc_D [c]), which kept reactions still reference; s4427 is
%         left without any alias
%       EXPECTED: only the aliases involved exclusively in removed reactions are removed, as the
%         comment at lines 98-99 states ('inclusive' is used instead of 'exclusive')
%       LINES: 96, 100
%     - DEFECT: Reactions keep a removed alias of a species that has other aliases
%       SEVERITY: limitation
%       TRIGGER: removeMapMol(xmlStruct, map, {'sa2'}) on the map of glycolysisAndTCA.xml (sa2 is
%         one of the 12 aliases of h[c])
%       OBSERVED: the alias is removed but the reaction that uses it is kept and still lists sa2
%         among its reactant or product aliases
%       EXPECTED: the reaction removed, or its reference to the alias removed ("also removing
%         the corresponding reaction if necessary")
%       LINES: 80, 87
%
% Authors:
%     - Generated for feature 20261103-105830-tier2-safe-batch, 2026-11-03.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testRemoveMapMol'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% read the shipped map once (read only)
[xmlStruct, map] = transformXML2Map(fullfile(fileDir, 'testCD', 'glycolysisAndTCA.xml'));

% the fields of the map per entity, for the content checks
mapFields = fieldnames(map);
molFields = mapFields(strncmp(mapFields, 'mol', 3));
specFields = mapFields(strncmp(mapFields, 'spec', 4));
rxnFields = mapFields(strncmp(mapFields, 'rxn', 3)  | strncmp(mapFields, 'compart', 7));

%% an alias that takes part in no reaction is removed with its species

[xmlOut, mapOut, specNotInMap] = removeMapMol(xmlStruct, map, {'sa10'});

% the alias was found
assert(isequal(specNotInMap, false));

% the removed alias and its species (its only alias), located by name
keepMol = ~strcmp(map.molAlias, 'sa10');
keepSpec = ~strcmp(map.specID, map.molID{~keepMol});
assert(nnz(~keepMol) == 1 && nnz(~keepSpec) == 1);
assert(strcmp(map.specName{~keepSpec}, 'Glycolysis'));

% every alias and species field loses exactly that entry; reaction and compartment fields are
% unchanged
for i = 1:numel(molFields)
    assert(isequal(mapOut.(molFields{i}), map.(molFields{i})(keepMol)));
end
for i = 1:numel(specFields)
    assert(isequal(mapOut.(specFields{i}), map.(specFields{i})(keepSpec)));
end
for i = 1:numel(rxnFields)
    assert(isequal(mapOut.(rxnFields{i}), map.(rxnFields{i})));
end

% the rebuilt matrices equal the input matrices without that row and column
assert(isequal(mapOut.sID, map.sID(keepSpec, :)));
assert(isequal(mapOut.sAlias, map.sAlias(keepMol, :)));
assert(isequal(mapOut.idAlias, map.idAlias(keepSpec, keepMol)));
assert(isequal(sort(fieldnames(mapOut)), sort(mapFields)));

% the XML structure loses the same species and alias and keeps every reaction
xmlModel = xmlStruct.sbml.model;
xmlOutModel = xmlOut.sbml.model;
assert(isequal(xmlOutModel.listOfReactions.reaction, xmlModel.listOfReactions.reaction));
assert(isequal(xmlOutModel.listOfSpecies.species, xmlModel.listOfSpecies.species(keepSpec)));
aliasesIn = xmlModel.annotation.celldesigner_colon_extension.celldesigner_colon_listOfSpeciesAliases.celldesigner_colon_speciesAlias;
aliasesOut = xmlOutModel.annotation.celldesigner_colon_extension.celldesigner_colon_listOfSpeciesAliases.celldesigner_colon_speciesAlias;
assert(isequal(aliasesOut, aliasesIn(keepMol)));

%% a single character array is a list of one alias

[xmlOutCell, mapOutCell] = removeMapMol(xmlStruct, map, {'sa10'});
[xmlOutChar, mapOutChar, specNotInMap] = removeMapMol(xmlStruct, map, 'sa10');
assert(isequal(mapOutChar, mapOutCell));
assert(isequal(xmlOutChar, xmlOutCell));
assert(isequal(specNotInMap, false));

%% several aliases are removed together

labels = {'sa10', 'sa54', 'sa113'};
[xmlOut, mapOut, specNotInMap] = removeMapMol(xmlStruct, map, labels, 0);

assert(isequal(specNotInMap, false(3, 1)));
keepMol = ~ismember(map.molAlias, labels);
keepSpec = ~ismember(map.specID, map.molID(~keepMol));
% three label aliases and their three species, no reaction
assert(isequal(sort(map.specName(~keepSpec)), sort({'Glycolysis'; 'Pyruvate metabolism '; 'Citric acid cycle'})));
assert(isequal(mapOut.molAlias, map.molAlias(keepMol)));
assert(isequal(mapOut.specName, map.specName(keepSpec)));
assert(isequal(mapOut.rxnName, map.rxnName));
assert(isequal(size(mapOut.sID), [64 40]));
assert(isequal(size(mapOut.sAlias), [112 40]));
assert(isequal(size(mapOut.idAlias), [64 112]));
assert(isequal(mapOut.sID, map.sID(keepSpec, :)));
assert(isequal(mapOut.idAlias, map.idAlias(keepSpec, keepMol)));
assert(numel(xmlOut.sbml.model.listOfSpecies.species) == 64);
assert(numel(xmlOut.sbml.model.listOfReactions.reaction) == 40);

%% aliases that are not in the map are flagged and otherwise ignored

% printLevel 0: no message; the alias that is present is removed as before
[xmlOutMixed, mapOutMixed, specNotInMap] = removeMapMol(xmlStruct, map, {'notThere', 'sa10', 'alsoNot'}, 0);
assert(isequal(specNotInMap, [true; false; true]));
[xmlOutSingle, mapOutSingle] = removeMapMol(xmlStruct, map, {'sa10'});
assert(isequal(mapOutMixed, mapOutSingle));
assert(isequal(xmlOutMixed, xmlOutSingle));

% default printLevel 1: the missing alias is printed; nothing is removed
[xmlOut, mapOut, specNotInMap] = removeMapMol(xmlStruct, map, {'notThere'});
assert(isequal(specNotInMap, true));
assert(isequal(mapOut, map));
assert(isequal(xmlOut, xmlStruct));

%% an empty list removes nothing

[xmlOut, mapOut, specNotInMap] = removeMapMol(xmlStruct, map, {});
assert(isempty(specNotInMap));
assert(isequal(mapOut, map));
assert(isequal(xmlOut, xmlStruct));

% an empty character array is an empty list as well
[xmlOut, mapOut, specNotInMap] = removeMapMol(xmlStruct, map, '');
assert(isempty(specNotInMap));
assert(isequal(mapOut, map));
assert(isequal(xmlOut, xmlStruct));

% change the directory
cd(currentDir)
