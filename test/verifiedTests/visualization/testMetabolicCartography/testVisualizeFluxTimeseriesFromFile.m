% The COBRAToolbox: testVisualizeFluxTimeseriesFromFile.m
%
% Purpose:
%     - visualizeFluxTimeseriesFromFile reads a CellDesigner map (transformXML2Map) and a flux
%       table file whose first column holds reaction IDs and whose other columns hold one flux
%       vector per time point, draws each time point on a copy of the map (addFluxWidthAndColor:
%       width 1, 2, 5, 8 or 10 by the flux relative to the largest absolute flux of that time
%       point, red shades for positive and indigo shades for negative flux, light grey for zero
%       flux, reactions without flux data unchanged with width 1, molecules of a reaction with
%       flux in its colour, all other molecules white) and writes one file per time point named
%       '<base>_<map name>_<time point>.xml', where the time point name loses the characters
%       that are not word characters, blanks or hyphens and blanks become underscores; the
%       default base is 'VisualizedFluxOnMap' in the current folder. Where the Parallel
%       Computing Toolbox is licensed the time points are processed in a parallel pool that the
%       function opens (with the given number of cores, or all cores) and closes; elsewhere
%       sequentially. The test writes a small CellDesigner map (species A-E, aliases sa1-sa5,
%       R1: A -> B catalysed by E, R2: B -> C, R3: C -> D, R4: D -> A) and a two-time-point CSV
%       file in a tempname folder and reads the written maps back. Expected widths and colours
%       follow by hand from the documented bands and shade lists of addFluxWidthAndColor; widths
%       come back as text because the file holds them as attributes.
%
% Function under test:
%     src/visualization/metabolicCartography/visualizeFluxTimeseriesFromFile.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; hand-written CellDesigner and CSV files in a tempname folder.
%     Where the Parallel Computing Toolbox is licensed, one-worker process pools are opened
%     (a few seconds each): one by the function itself and one by the test, so that the
%     default number of cores does not start a pool with every core of the machine. The
%     function closes every pool it finds, so a pool that was open before the test is closed.
%
% Coverage exemptions:
%     Lines 93, 95, 98, 101, 104, 105, 108, 109, 111, 114, 117 (the sequential loop): reached
%     only where the Parallel Computing Toolbox is not licensed; on the reference machine it
%     is, so the parallel branch runs instead (conversely, without the toolbox lines 51-90 are
%     not reached). Making license('test', 'Distrib_Computing_Toolbox') return 0 would need a
%     stand-in for the built-in license, which MATLAB flags with a warning on every call.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testVisualizeFluxTimeseriesFromFile'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% all files are written to a temporary folder removed at the end
tempFolder = tempname;
mkdir(tempFolder);
mapFile = fullfile(tempFolder, 'toyMap.xml');
writeToyMap(mapFile, repmat({'ff000000'}, 4, 1));

% flux table with two time points whose names hold characters ('=' and a blank) that are
% not allowed in file names; R4 has no flux data
csvFile = fullfile(tempFolder, 'timeseries.csv');
fileId = fopen(csvFile, 'w');
fprintf(fileId, 'rxnID,t=0 h,t=1 h\nR1,10,0\nR2,-5,2\nR3,1,0\n');
fclose(fileId);

% shades of addFluxWidthAndColor (lightest to darkest) and its fixed colours
redShades = {'FFffc9c9', 'FFff8787', 'FFfa5252', 'FFc92a2a'};
indigoShades = {'FFbac8ff', 'FF748ffc', 'FF4c6ef5', 'FF364fc7'};
lightGray = 'FFD3D3D3';
white = 'FFFFFFFF';

% t=0 h: fluxes 10, -5, 1 (largest 10) give relative fluxes 1, 0.5, 0.1 and widths 10, 5, 2
% (darkest red, second indigo shade, lightest red); R4 keeps its colour with width 1.
% Molecules take the colour of their reactions in table order, so sa2 (R1 then R2) is indigo
% and sa3 (R2 then R3) the lightest red; sa5 (modifier) stays white
expectedWidth0 = {'10'; '5'; '2'; '1'};
expectedColor0 = {redShades{4}; indigoShades{2}; redShades{1}; 'ff000000'};
expectedMolColor0 = {redShades{4}; indigoShades{2}; redShades{1}; redShades{1}; white};
% t=1 h: fluxes 0, 2, 0 (largest 2): R2 has width 10 and the darkest red, R1 and R3 carry
% zero flux (light grey, width 1); only the molecules of R2 (sa2, sa3) are coloured
expectedWidth1 = {'1'; '10'; '1'; '1'};
expectedColor1 = {lightGray; redShades{4}; lightGray; 'ff000000'};
expectedMolColor1 = {white; redShades{4}; redShades{4}; white; white};

%% one map per time point, named from the base, the map name and the sanitised time point

% with one core: where the toolbox is licensed the function opens a one-worker pool and
% closes it again; elsewhere it loops sequentially
outputBase = fullfile(tempFolder, 'series');
visualizeFluxTimeseriesFromFile(mapFile, csvFile, outputBase, 1);
file0 = [outputBase '_toyMap_t0_h.xml'];
file1 = [outputBase '_toyMap_t1_h.xml'];
assert(exist(file0, 'file') == 2 && exist(file1, 'file') == 2);
% exactly these two files are written next to the map
written = dir(fullfile(tempFolder, 'series_*.xml'));
assert(numel(written) == 2);
% all values are text or integer matrices, so the comparisons are exact
[~, map0] = transformXML2Map(file0);
assert(isequal(map0.rxnName, {'R1'; 'R2'; 'R3'; 'R4'}));
assert(isequal(map0.rxnWidth, expectedWidth0));
assert(isequal(map0.rxnColor, expectedColor0));
assert(isequal(map0.molColor, expectedMolColor0));
[~, map1] = transformXML2Map(file1);
assert(isequal(map1.rxnWidth, expectedWidth1));
assert(isequal(map1.rxnColor, expectedColor1));
assert(isequal(map1.molColor, expectedMolColor1));
% the input map is unchanged and no pool is left open
[~, inputMap] = transformXML2Map(mapFile);
assert(isequal(inputMap.rxnColor, repmat({'ff000000'}, 4, 1)));
assert(isempty(getParallelPool()));

%% default base name in the current folder and default number of cores

% where the toolbox is licensed a one-worker pool is opened first (any pool found is closed
% before, as the function would do): the default number of cores is then read but no pool
% with every core of the machine is started, and the function uses and closes the open pool.
% The pool is opened from the temporary folder, so that relative output names resolve there
cd(tempFolder);
if isParallelToolboxAvailable()
    closeParallelPool();
    openParallelPool(1);
end
visualizeFluxTimeseriesFromFile(mapFile, csvFile);
cd(fileDir);
defaultFile0 = fullfile(tempFolder, 'VisualizedFluxOnMap_toyMap_t0_h.xml');
defaultFile1 = fullfile(tempFolder, 'VisualizedFluxOnMap_toyMap_t1_h.xml');
assert(exist(defaultFile0, 'file') == 2 && exist(defaultFile1, 'file') == 2);
[~, defaultMap0] = transformXML2Map(defaultFile0);
assert(isequal(defaultMap0, map0));
[~, defaultMap1] = transformXML2Map(defaultFile1);
assert(isequal(defaultMap1, map1));
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
