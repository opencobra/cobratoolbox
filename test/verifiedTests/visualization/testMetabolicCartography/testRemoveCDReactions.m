% The COBRAToolbox: testRemoveCDReactions.m
%
% Purpose:
%     - removeCDReactions reads a CellDesigner map with transformXML2Map, removes the reactions
%       named in a list, removes the species and species aliases that take part (as reactant
%       or product) only in removed reactions, prints a message for each listed name that is
%       not in the map (unless printLevel is 0) and writes the reduced map to
%       '<input name>_subset.xml'. The test writes a small CellDesigner file in a tempname
%       folder (species A, B, C, D, E; aliases sa1-sa5; R1: A -> B catalysed by E, R2: B -> C,
%       R3: C -> D), reduces it and reads the written file back. Expected reactions, species
%       and aliases follow by hand from the documentation: a species is removed when every
%       reaction it takes part in is removed.
%
% Function under test:
%     src/visualization/metabolicCartography/removeCDReactions.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; hand-written CellDesigner file in a tempname folder.
%
% Coverage exemptions:
%     Lines 27, 29, 31, 32, 33: unreachable (dead code) - they are inside 'if 0', which is never
%     true.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: A name listed twice is reported as not present in the map
%       SEVERITY: cosmetic
%       TRIGGER: removeCDReactions(fileName, {'R3', 'R3'}) on a map that contains R3
%       OBSERVED: MATLAB R2025a prints 'R3 not present in the map' (ismember returns only the
%         first position of R3 in the list, so the second position is counted as missing);
%         R3 is removed.
%       EXPECTED: no message, as R3 is in the map
%       LINES: 46, 51
%     - DEFECT: A species that only modifies removed reactions is kept
%       SEVERITY: limitation
%       TRIGGER: removeCDReactions(fileName, {'R1'}) where species E (alias sa5) is only the
%         catalyst (modifier) of R1
%       OBSERVED: MATLAB R2025a: R1, species A and alias sa1 are removed; species E and alias
%         sa5 stay in the written map although no remaining reaction uses them (map.sID and
%         map.sAlias hold reactants and products only, not modifiers).
%       EXPECTED: E and sa5 removed with R1, as for reactants and products
%       LINES: 62, 65
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testRemoveCDReactions'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% all files are written to a temporary folder removed at the end
tempFolder = tempname;
mkdir(tempFolder);
mapFile = fullfile(tempFolder, 'toyMap.xml');
subsetFile = fullfile(tempFolder, 'toyMap_subset.xml');
writeToyMap(mapFile);

%% a reaction is removed with the species and alias used only by it; unknown names are reported

% R3 (C -> D) is removed: D (s4, sa4) takes part only in R3 and is removed; C (s3, sa3) is
% also used by R2 and is kept. RX is not in the map: the default printLevel (1) prints a
% message for it, and nothing else changes because of it
removeCDReactions(mapFile, {'R3', 'RX'});
[subsetXml, subsetMap] = transformXML2Map(subsetFile);
assert(isequal(subsetMap.rxnName, {'R1'; 'R2'}));
assert(isequal(subsetMap.specID, {'s1'; 's2'; 's3'; 's5'}));
assert(isequal(subsetMap.molAlias, {'sa1'; 'sa2'; 'sa3'; 'sa5'}));
% the remaining reactions keep their content
assert(isequal(subsetMap.rxnBaseReactantAlias, {{'sa1'}; {'sa2'}}));
assert(isequal(subsetMap.rxnBaseProductAlias, {{'sa2'}; {'sa3'}}));
assert(isequal(subsetMap.rxnModAlias{1}, {'sa5'}));
% the input file is not changed
[~, inputMap] = transformXML2Map(mapFile);
assert(isequal(inputMap.rxnName, {'R1'; 'R2'; 'R3'}));
clear subsetXml

%% printLevel 0, and a removed reaction whose species are all used elsewhere

% R2 (B -> C) is removed: B is also used by R1 and C by R3, so no species or alias is
% removed. RX is not in the map and printLevel 0 prints nothing for it
delete(subsetFile);
removeCDReactions(mapFile, {'RX', 'R2'}, 0);
[~, subsetMap] = transformXML2Map(subsetFile);
assert(isequal(subsetMap.rxnName, {'R1'; 'R3'}));
assert(isequal(subsetMap.specID, {'s1'; 's2'; 's3'; 's4'; 's5'}));
assert(isequal(subsetMap.molAlias, {'sa1'; 'sa2'; 'sa3'; 'sa4'; 'sa5'}));

%% only names that are not in the map: the written map equals the input map

delete(subsetFile);
removeCDReactions(mapFile, {'RX'}, 0);
[~, subsetMap] = transformXML2Map(subsetFile);
% all fields are text or integer matrices, so the comparison is exact
assert(isequal(subsetMap, inputMap));

% remove the temporary folder
rmdir(tempFolder, 's');

% change the directory
cd(currentDir)

%% local functions

function writeToyMap(fileName)
% Write a CellDesigner map (SBML level 2): compartment aliases ca1, ca2; species s1 A, s2 B,
% s3 C, s4 D (simple molecules) and s5 E (protein); aliases sa1-sa5 (one per species, in ca1);
% reactions re1 R1: A -> B catalysed by E, re2 R2: B -> C, re3 R3: C -> D, all black, width 1.
    aliasXml = @(id, species) ['<celldesigner:speciesAlias id="' id '" species="' species ...
        '" compartmentAlias="ca1"><celldesigner:bounds x="10.0" y="20.0" w="80.0" h="30.0"/>' ...
        '<celldesigner:usualView><celldesigner:paint color="ffccff66" scheme="Color"/>' ...
        '</celldesigner:usualView></celldesigner:speciesAlias>'];
    speciesXml = @(id, name, class) ['<species metaid="' id '" id="' id '" name="' name ...
        '" compartment="c1"><annotation><celldesigner:extension><celldesigner:speciesIdentity>' ...
        '<celldesigner:class>' class '</celldesigner:class><celldesigner:name>' name ...
        '</celldesigner:name></celldesigner:speciesIdentity></celldesigner:extension></annotation></species>'];
    referenceXml = @(tag, species, alias) ['<' tag ' species="' species '"><annotation>' ...
        '<celldesigner:extension><celldesigner:alias>' alias '</celldesigner:alias>' ...
        '</celldesigner:extension></annotation></' tag '>'];
    reactionXml = @(id, name, reactant, reactantAlias, product, productAlias, modifier) ...
        ['<reaction metaid="' id '" id="' id '" name="' name '" reversible="false"><annotation>' ...
        '<celldesigner:extension><celldesigner:reactionType>STATE_TRANSITION</celldesigner:reactionType>' ...
        '<celldesigner:baseReactants><celldesigner:baseReactant species="' reactant '" alias="' ...
        reactantAlias '"/></celldesigner:baseReactants><celldesigner:baseProducts>' ...
        '<celldesigner:baseProduct species="' product '" alias="' productAlias '"/></celldesigner:baseProducts>' ...
        modifier{1} '<celldesigner:line width="1.0" color="ff000000"/></celldesigner:extension></annotation>' ...
        '<listOfReactants>' referenceXml('speciesReference', reactant, reactantAlias) '</listOfReactants>' ...
        '<listOfProducts>' referenceXml('speciesReference', product, productAlias) '</listOfProducts>' ...
        modifier{2} '</reaction>'];
    catalysis = {['<celldesigner:listOfModification><celldesigner:modification type="CATALYSIS" ' ...
        'modifiers="s5" aliases="sa5"><celldesigner:line width="1.0" color="ff000000"/>' ...
        '</celldesigner:modification></celldesigner:listOfModification>'], ...
        ['<listOfModifiers>' referenceXml('modifierSpeciesReference', 's5', 'sa5') '</listOfModifiers>']};
    xmlLines = {
        '<?xml version="1.0" encoding="UTF-8"?>'
        ['<sbml xmlns="http://www.sbml.org/sbml/level2/version4" ' ...
         'xmlns:celldesigner="http://www.sbml.org/2001/ns/celldesigner" level="2" version="4">']
        '<model metaid="toy" id="toy"><annotation><celldesigner:extension>'
        '<celldesigner:listOfCompartmentAliases>'
        '<celldesigner:compartmentAlias id="ca1" compartment="c1"/>'
        '<celldesigner:compartmentAlias id="ca2" compartment="c2"/>'
        '</celldesigner:listOfCompartmentAliases>'
        '<celldesigner:listOfSpeciesAliases>'
        aliasXml('sa1', 's1')
        aliasXml('sa2', 's2')
        aliasXml('sa3', 's3')
        aliasXml('sa4', 's4')
        aliasXml('sa5', 's5')
        '</celldesigner:listOfSpeciesAliases>'
        '</celldesigner:extension></annotation>'
        '<listOfSpecies>'
        speciesXml('s1', 'A', 'SIMPLE_MOLECULE')
        speciesXml('s2', 'B', 'SIMPLE_MOLECULE')
        speciesXml('s3', 'C', 'SIMPLE_MOLECULE')
        speciesXml('s4', 'D', 'SIMPLE_MOLECULE')
        speciesXml('s5', 'E', 'PROTEIN')
        '</listOfSpecies>'
        '<listOfReactions>'
        reactionXml('re1', 'R1', 's1', 'sa1', 's2', 'sa2', catalysis)
        reactionXml('re2', 'R2', 's2', 'sa2', 's3', 'sa3', {'', ''})
        reactionXml('re3', 'R3', 's3', 'sa3', 's4', 'sa4', {'', ''})
        '</listOfReactions></model></sbml>'};
    fileId = fopen(fileName, 'w');
    fprintf(fileId, '%s\n', xmlLines{:});
    fclose(fileId);
end
