% The COBRAToolbox: testRemoveMapReactions.m
%
% Purpose:
%     - removeMapReactions(xmlStruct, map, rxnRemoveList, printLevel) removes the reactions
%       named in rxnRemoveList (matched against map.rxnName) from a CellDesigner map (the map
%       structure and the xml2struct structure returned by transformXML2Map), together with
%       the species that take part only in removed reactions, the aliases of those species and
%       the aliases that take part only in removed reactions; the map matrices sID, sAlias and
%       idAlias are rebuilt with getMapMatrices. Names not in the map are flagged in
%       rxnNotInMap (and printed when printLevel > 0).
%     - The map is read from the CellDesigner file that ships with the test suite
%       (test/verifiedTests/visualization/testMetabolicCartography/testCD/glycolysisAndTCA.xml:
%       115 aliases, 67 species, 40 reactions); the test creates no file. Expected values are
%       derived from the input map: the entries to remove are located from the input matrices
%       (a species or alias is removed when all its reactions are removed) and checked against
%       the names read in the file; every other entry must be unchanged.
%
% Function under test:
%     src/visualization/metabolicCartography/removeMapReactions.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver; the input map is read from a CellDesigner file
%     shipped with the test suite.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: A name listed twice is reported as not present in the map
%       SEVERITY: cosmetic
%       TRIGGER: removeMapReactions(xmlStruct, map, {'ACYP', 'ACYP'}) on the map of
%         glycolysisAndTCA.xml, which contains ACYP
%       OBSERVED: (R2025a, 2026-11-25) rxnNotInMap = [false; true] and 'ACYP not present in the
%         map' is printed (ismember returns only the first position of ACYP in the list, so the
%         second position is counted as missing); ACYP is removed. The input is skipped below.
%       EXPECTED: rxnNotInMap = [false; false] and no message, as ACYP is in the map
%       LINES: 46, 51
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-25.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testRemoveMapReactions'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% read the shipped map once (read only)
[xmlStruct, map] = transformXML2Map(fullfile(fileDir, 'testCD', 'glycolysisAndTCA.xml'));
xmlModel = xmlStruct.sbml.model;
aliasesIn = xmlModel.annotation.celldesigner_colon_extension.celldesigner_colon_listOfSpeciesAliases.celldesigner_colon_speciesAlias;

% the fields of the map per entity, for the content checks
mapFields = fieldnames(map);
molFields = mapFields(strncmp(mapFields, 'mol', 3));
specFields = mapFields(strncmp(mapFields, 'spec', 4));
rxnFields = mapFields(strncmp(mapFields, 'rxn', 3));
compartFields = mapFields(strncmp(mapFields, 'compart', 7));

%% a reaction whose species all take part in other reactions: only its own alias goes

% ACYP (13dpg + h2o -> 3pg + pi + h); default printLevel, one name not in the map
[xmlOut, mapOut, rxnNotInMap] = removeMapReactions(xmlStruct, map, {'ACYP', 'notThere'});

% the second name is flagged (and printed), the first is found
assert(isequal(rxnNotInMap, [false; true]));

% expected entries, derived from the input matrices: the reaction, no species (each takes part
% in another reaction) and the aliases that take part in no other reaction
keepRxn = ~strcmp(map.rxnName, 'ACYP');
assert(nnz(~keepRxn) == 1);
assert(~any(any(map.sID(:, ~keepRxn), 2) & ~any(map.sID(:, keepRxn), 2)));
keepMol = ~(any(map.sAlias(:, ~keepRxn), 2) & ~any(map.sAlias(:, keepRxn), 2));
% that is the single alias sa37 (one of the twelve aliases of h[c], drawn only for ACYP)
assert(isequal(map.molAlias(~keepMol), {'sa37'}));
assert(strcmp(map.specName{strcmp(map.specID, map.molID{~keepMol})}, 'h[c]'));

% every reaction field loses the reaction, every alias field the alias; species and
% compartment fields are unchanged
for i = 1:numel(rxnFields)
    assert(isequal(mapOut.(rxnFields{i}), map.(rxnFields{i})(keepRxn)));
end
for i = 1:numel(molFields)
    assert(isequal(mapOut.(molFields{i}), map.(molFields{i})(keepMol)));
end
for i = 1:numel([specFields; compartFields])
    field = [specFields; compartFields];
    assert(isequal(mapOut.(field{i}), map.(field{i})));
end

% the rebuilt matrices equal the input matrices without that column and row, and the field
% list is unchanged
assert(isequal(mapOut.sID, map.sID(:, keepRxn)));
assert(isequal(mapOut.sAlias, map.sAlias(keepMol, keepRxn)));
assert(isequal(mapOut.idAlias, map.idAlias(:, keepMol)));
assert(isequal(fieldnames(mapOut), mapFields));

% the XML structure loses the same reaction and alias and keeps every species
xmlOutModel = xmlOut.sbml.model;
assert(isequal(xmlOutModel.listOfReactions.reaction, xmlModel.listOfReactions.reaction(keepRxn)));
assert(isequal(xmlOutModel.listOfSpecies.species, xmlModel.listOfSpecies.species));
aliasesOut = xmlOutModel.annotation.celldesigner_colon_extension.celldesigner_colon_listOfSpeciesAliases.celldesigner_colon_speciesAlias;
assert(isequal(aliasesOut, aliasesIn(keepMol)));

%% a reaction with a species found in no other reaction: the species and its alias go too

% GLCter (glc_D[c] -> glc_D[r]); glc_D[r] takes part in GLCter only. printLevel 0
[xmlOut, mapOut, rxnNotInMap] = removeMapReactions(xmlStruct, map, {'GLCter'}, 0);
assert(isequal(rxnNotInMap, false));

keepRxn = ~strcmp(map.rxnName, 'GLCter');
keepSpec = ~(any(map.sID(:, ~keepRxn), 2) & ~any(map.sID(:, keepRxn), 2));
% the species removed with the reaction: glc_D[r] (s4815)
assert(isequal(map.specID(~keepSpec), {'s4815'}) && strcmp(map.specName{~keepSpec}, 'glc_D[r]'));
% aliases: those of the removed species and those found in no other reaction (sa5, the only
% alias of glc_D[r])
keepMol = ~((any(map.sAlias(:, ~keepRxn), 2) & ~any(map.sAlias(:, keepRxn), 2)) ...
    | any(map.idAlias(~keepSpec, :), 1)');
assert(isequal(map.molAlias(~keepMol), {'sa5'}));

for i = 1:numel(rxnFields)
    assert(isequal(mapOut.(rxnFields{i}), map.(rxnFields{i})(keepRxn)));
end
for i = 1:numel(molFields)
    assert(isequal(mapOut.(molFields{i}), map.(molFields{i})(keepMol)));
end
for i = 1:numel(specFields)
    assert(isequal(mapOut.(specFields{i}), map.(specFields{i})(keepSpec)));
end
assert(isequal(mapOut.sID, map.sID(keepSpec, keepRxn)));
assert(isequal(mapOut.sAlias, map.sAlias(keepMol, keepRxn)));
assert(isequal(mapOut.idAlias, map.idAlias(keepSpec, keepMol)));

% the XML structure loses the reaction, the species and the alias
xmlOutModel = xmlOut.sbml.model;
assert(isequal(xmlOutModel.listOfReactions.reaction, xmlModel.listOfReactions.reaction(keepRxn)));
assert(isequal(xmlOutModel.listOfSpecies.species, xmlModel.listOfSpecies.species(keepSpec)));
aliasesOut = xmlOutModel.annotation.celldesigner_colon_extension.celldesigner_colon_listOfSpeciesAliases.celldesigner_colon_speciesAlias;
assert(isequal(aliasesOut, aliasesIn(keepMol)));

%% several reactions at once give the same result as removing them one after the other

[xmlBoth, mapBoth] = removeMapReactions(xmlStruct, map, {'GLCter'; 'ACYP'}, 0);
[xmlStep, mapStep] = removeMapReactions(xmlStruct, map, {'GLCter'}, 0);
[xmlStep, mapStep] = removeMapReactions(xmlStep, mapStep, {'ACYP'}, 0);
assert(isequal(mapBoth, mapStep));
assert(isequal(xmlBoth, xmlStep));
assert(numel(mapBoth.rxnName) == 38 && numel(mapBoth.specID) == 66 && numel(mapBoth.molAlias) == 113);

%% nothing to remove: an empty list, or names not in the map

[xmlOut, mapOut, rxnNotInMap] = removeMapReactions(xmlStruct, map, {}, 0);
assert(isempty(rxnNotInMap));
assert(isequal(mapOut, map));
assert(isequal(xmlOut, xmlStruct));

% printLevel 0: flagged, not printed
[xmlOut, mapOut, rxnNotInMap] = removeMapReactions(xmlStruct, map, {'notThere'; 'alsoNot'}, 0);
assert(isequal(rxnNotInMap, [true; true]));
assert(isequal(mapOut, map));
assert(isequal(xmlOut, xmlStruct));

% change the directory
cd(currentDir)
