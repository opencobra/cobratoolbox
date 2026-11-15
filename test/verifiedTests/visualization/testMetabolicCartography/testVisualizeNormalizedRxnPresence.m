% The COBRAToolbox: testVisualizeNormalizedRxnPresence.m
%
% Purpose:
%     - visualizeNormalizedRxnPresence reads every .xml file of a folder as a CellDesigner map
%       (transformXML2Map), marks a reaction as present in a map when its line colour is
%       'FFFF4500' (ORANGERED, as visualizeReconstructionsOnMap writes it), returns a table
%       with one logical column per map file, and writes 'normalisedReactionHeatmap.xml' into
%       the folder: the first map with all colours reset (unifyMetabolicMapCD) and each
%       reaction coloured and widened by its presence fraction (number of maps with the
%       reaction over the number of maps) with a colour scheme of rows {fraction, colour,
%       width}: a fraction equal to a row's fraction takes that row, otherwise the row whose
%       fraction is the smallest one not below it (the default scheme has the fractions 1,
%       0.9, 0.7, 0.5, 0.3, 0.1, 0). Where the Parallel Computing Toolbox is licensed the maps
%       are read in a parallel pool that the function opens (with the given number of cores, or
%       all cores) and closes; elsewhere sequentially. The test writes four small CellDesigner
%       maps (species A-E, aliases sa1-sa5, R1: A -> B catalysed by E, R2: B -> C, R3: C -> D,
%       R4: D -> A; present reactions ORANGERED, the others grey) and a text file into a
%       tempname folder, so that the presence fractions 1, 0.75, 0.25 and 0 exercise both exact
%       matches and ranges of the default and of a custom scheme. Expected colours and widths
%       follow by hand from the documented scheme; widths come back as text because the file
%       holds them as attributes.
%
% Function under test:
%     src/visualization/metabolicCartography/visualizeNormalizedRxnPresence.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; hand-written CellDesigner files in a tempname folder. Where
%     the Parallel Computing Toolbox is licensed, one-worker process pools are opened (a few
%     seconds each): one by the function itself and one by the test, so that the default number
%     of cores does not start a pool with every core of the machine. The function closes every
%     pool it finds, so a pool that was open before the test is closed.
%
% Coverage exemptions:
%     Lines 111, 113, 117, 120 (the sequential loop): reached only where the Parallel Computing
%     Toolbox is not licensed; on the reference machine it is, so the parallel branch runs
%     instead (conversely, without the toolbox lines 83-108 are not reached). Making
%     license('test', 'Distrib_Computing_Toolbox') return 0 would need a stand-in for the
%     built-in license, which MATLAB flags with a warning on every call.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Reaction colours written in lower case are not counted as present
%       SEVERITY: limitation
%       TRIGGER: a map in the folder whose present reactions have the line colour 'ffff4500'
%         (lower case, as CellDesigner writes colours when it saves a map) instead of 'FFFF4500'
%       OBSERVED: MATLAB R2025a: no reaction of that map is counted as present (its column of
%         rxnPrsTable is all false), as strcmp with 'FFFF4500' is case-sensitive.
%       EXPECTED: the reactions of that colour counted as present, whatever the case
%       LINES: 101, 117
%     - DEFECT: A colour scheme without a row for the lowest presence fraction stops with an index error
%       SEVERITY: limitation
%       TRIGGER: visualizeNormalizedRxnPresence(mapDir, {1, 'aaaaaa', 10; 0.5, 'bbbbbb', 5}) with
%         a reaction whose presence fraction is below 0.5 and differs from the listed fractions
%         (for example a reaction present in no map)
%       OBSERVED: MATLAB R2025a: error 'Index in position 1 exceeds array bounds. Index must not
%         exceed 2.' at line 150, where the range test reads the fraction of the next row.
%       EXPECTED: an error naming the incomplete scheme, or the colour of its last row
%       LINES: 150
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testVisualizeNormalizedRxnPresence'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% all files are written to a temporary folder removed at the end
tempFolder = tempname;
mkdir(tempFolder);
mapsFolder = fullfile(tempFolder, 'maps');
mkdir(mapsFolder);

% four presence maps as visualizeReconstructionsOnMap writes them (present reactions
% ORANGERED, the others grey): R1 is present in all four, R2 in three, R3 in one, R4 in none
orangeRed = 'FFFF4500';
grey = 'FFDCDCDC';
writeToyMap(fullfile(mapsFolder, 'm1.xml'), {orangeRed; orangeRed; orangeRed; grey});
writeToyMap(fullfile(mapsFolder, 'm2.xml'), {orangeRed; orangeRed; grey; grey});
writeToyMap(fullfile(mapsFolder, 'm3.xml'), {orangeRed; orangeRed; grey; grey});
writeToyMap(fullfile(mapsFolder, 'm4.xml'), {orangeRed; grey; grey; grey});
% a file that is not a map is ignored
fileId = fopen(fullfile(mapsFolder, 'notes.txt'), 'w');
fprintf(fileId, 'not a map\n');
fclose(fileId);
heatmapFile = fullfile(mapsFolder, 'normalisedReactionHeatmap.xml');
% presence of R1-R4 (rows) in m1-m4 (columns)
expectedPresence = logical([1 1 1 1; 1 1 1 0; 1 0 0 0; 0 0 0 0]);

%% presence table and heatmap with the default colour scheme

% with one core: where the toolbox is licensed the function opens a one-worker pool and
% closes it again; elsewhere it loops sequentially. The empty second argument selects the
% default scheme
rxnPrsTable = visualizeNormalizedRxnPresence(mapsFolder, [], 1);
% one logical column per map file, in the order of the folder listing
assert(isequal(rxnPrsTable.Properties.VariableNames, {'m1.xml', 'm2.xml', 'm3.xml', 'm4.xml'}));
assert(isequal(rxnPrsTable{:, :}, expectedPresence));
% fractions 1 (exact match of the first row) and 0 (exact match of the last row), 0.75 in
% (0.7, 0.9] and 0.25 in (0.1, 0.3]; the colours carry the alpha 'FF' of the map and the
% widths are text in the file, so the comparisons are exact
assert(exist(heatmapFile, 'file') == 2);
[~, heatmapMap] = transformXML2Map(heatmapFile);
assert(isequal(heatmapMap.rxnName, {'R1'; 'R2'; 'R3'; 'R4'}));
assert(isequal(heatmapMap.rxnColor, {'FFfbcaf3'; 'FFf6a077'; 'FF103f60'; 'FFD3D3D3'}));
assert(isequal(heatmapMap.rxnWidth, {'10'; '8'; '3'; '1'}));
% the molecule colours are reset to white
assert(isequal(heatmapMap.molColor, repmat({'FFFFFFFF'}, 5, 1)));
% the input maps are unchanged and no pool is left open
[~, inputMap] = transformXML2Map(fullfile(mapsFolder, 'm4.xml'));
assert(isequal(inputMap.rxnColor, {orangeRed; grey; grey; grey}));
assert(isempty(getParallelPool()));

%% custom colour scheme and default number of cores

% the heatmap of the previous section is an XML file in the folder and would be read as a
% fifth map, so it is removed first. Where the toolbox is licensed a one-worker pool is
% opened first (any pool found is closed before, as the function would do): the default
% number of cores is then read but no pool with every core of the machine is started, and
% the function uses and closes the open pool
delete(heatmapFile);
if isParallelToolboxAvailable()
    closeParallelPool();
    openParallelPool(1);
end
customScheme = {1, 'aaaaaa', 9; 0.5, 'bbbbbb', 4; 0, 'cccccc', 2};
rxnPrsTable = visualizeNormalizedRxnPresence(mapsFolder, customScheme);
assert(isequal(rxnPrsTable{:, :}, expectedPresence));
% 1 and 0 match rows exactly; 0.75 lies in (0.5, 1] and 0.25 in (0, 0.5]
[~, heatmapMap] = transformXML2Map(heatmapFile);
assert(isequal(heatmapMap.rxnColor, {'FFaaaaaa'; 'FFaaaaaa'; 'FFbbbbbb'; 'FFcccccc'}));
assert(isequal(heatmapMap.rxnWidth, {'9'; '9'; '4'; '2'}));
assert(isempty(getParallelPool()));

% remove the temporary folder
rmdir(tempFolder, 's');

% change the directory
cd(currentDir)

%% local functions

function writeToyMap(fileName, rxnColors)
% Write a CellDesigner map (SBML level 2): compartment aliases ca1, ca2; species s1 A, s2 B,
% s3 C, s4 D (simple molecules) and s5 E (protein); aliases sa1-sa5 (one per species, in ca1);
% reactions re1 R1: A -> B catalysed by E, re2 R2: B -> C, re3 R3: C -> D, re4 R4: D -> A,
% with the line colours rxnColors (one per reaction) and width 1.
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
    reactionXml = @(id, name, reactant, reactantAlias, product, productAlias, modifier, color) ...
        ['<reaction metaid="' id '" id="' id '" name="' name '" reversible="false"><annotation>' ...
        '<celldesigner:extension><celldesigner:reactionType>STATE_TRANSITION</celldesigner:reactionType>' ...
        '<celldesigner:baseReactants><celldesigner:baseReactant species="' reactant '" alias="' ...
        reactantAlias '"/></celldesigner:baseReactants><celldesigner:baseProducts>' ...
        '<celldesigner:baseProduct species="' product '" alias="' productAlias '"/></celldesigner:baseProducts>' ...
        modifier{1} '<celldesigner:line width="1.0" color="' color '"/></celldesigner:extension></annotation>' ...
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
        reactionXml('re1', 'R1', 's1', 'sa1', 's2', 'sa2', catalysis, rxnColors{1})
        reactionXml('re2', 'R2', 's2', 'sa2', 's3', 'sa3', {'', ''}, rxnColors{2})
        reactionXml('re3', 'R3', 's3', 'sa3', 's4', 'sa4', {'', ''}, rxnColors{3})
        reactionXml('re4', 'R4', 's4', 'sa4', 's1', 'sa1', {'', ''}, rxnColors{4})
        '</listOfReactions></model></sbml>'};
    fileId = fopen(fileName, 'w');
    fprintf(fileId, '%s\n', xmlLines{:});
    fclose(fileId);
end
