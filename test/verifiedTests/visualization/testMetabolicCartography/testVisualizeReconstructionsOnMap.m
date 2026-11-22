% The COBRAToolbox: testVisualizeReconstructionsOnMap.m
%
% Purpose:
%     - visualizeReconstructionsOnMap reads a CellDesigner map (transformXML2Map), resets its
%       colours (unifyMetabolicMapCD: reactions grey 'FFDCDCDC' of width 1, molecules white)
%       and, for every .mat file of a folder that holds a variable 'model', colours the map
%       reactions named in model.rxns ORANGERED ('FFFF4500') with width 5
%       (changeRxnColorAndWidth) and their molecules POWDERBLUE ('FFB0E0E6') (addColourNode),
%       then writes the map to 'MicroMap_<file name>.xml' in the current folder
%       (transformMap2XML); a .mat file without 'model' is skipped with a warning, and a folder
%       without .mat files is an error. Where the Parallel Computing Toolbox is licensed the
%       files are processed in a parallel pool that the function opens (with the given number
%       of cores, or all cores) and closes; elsewhere sequentially. The test writes a small
%       CellDesigner map (species A-E, aliases sa1-sa5, R1: A -> B catalysed by E, R2: B -> C,
%       R3: C -> D, R4: D -> A) and three .mat files in a tempname folder and reads the written
%       maps back. Expected colours are the CSS named colours of createColorsMap with the
%       opaque alpha 'FF'; widths come back as text because the file holds them as attributes.
%
% Function under test:
%     src/visualization/metabolicCartography/visualizeReconstructionsOnMap.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model (the .mat files hold a struct with the field rxns only),
%     no solver; hand-written CellDesigner file in a tempname folder. Where the Parallel
%     Computing Toolbox is licensed, one-worker process pools are opened (a few seconds each):
%     one by the function itself and one by the test, so that the default number of cores does
%     not start a pool with every core of the machine. The function closes every pool it
%     finds, so a pool that was open before the test is closed.
%
% Coverage exemptions:
%     Lines 84, 86, 89, 90, 91, 93, 94, 98, 99, 102, 103, 106, 109 (the sequential loop):
%     reached only where the Parallel Computing Toolbox is not licensed; on the reference
%     machine it is, so the parallel branch runs instead (conversely, without the toolbox
%     lines 41-81 are not reached). Making license('test', 'Distrib_Computing_Toolbox') return
%     0 would need a stand-in for the built-in license, which MATLAB flags with a warning on
%     every call.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testVisualizeReconstructionsOnMap'));
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

% three .mat files: reconstruction A has R1, R3 and a reaction that is not in the map,
% reconstruction B has R2, and the third file holds no variable 'model'
modelFolder = fullfile(tempFolder, 'models');
mkdir(modelFolder);
model = struct('rxns', {{'R1'; 'R3'; 'notInMap'}});
save(fullfile(modelFolder, 'modelA.mat'), 'model');
model = struct('rxns', {{'R2'}});
save(fullfile(modelFolder, 'modelB.mat'), 'model');
notAModel = 'no model in this file';
save(fullfile(modelFolder, 'other.mat'), 'notAModel');
clear model notAModel

orangeRed = 'FFFF4500';   % CSS orangered #FF4500
powderBlue = 'FFB0E0E6';  % CSS powderblue #B0E0E6
grey = 'FFDCDCDC';
white = 'FFFFFFFF';

%% one map per reconstruction in the current folder; a file without 'model' is skipped

% with one core: where the toolbox is licensed the function opens a one-worker pool and
% closes it again; elsewhere it loops sequentially. The warning for other.mat is printed
outputFolder = fullfile(tempFolder, 'outputOneCore');
mkdir(outputFolder);
cd(outputFolder);
visualizeReconstructionsOnMap(mapFile, modelFolder, 1);
cd(fileDir);
written = dir(fullfile(outputFolder, '*.xml'));
assert(isequal(sort({written.name}), {'MicroMap_modelA.xml', 'MicroMap_modelB.xml'}));
% all values are text, so the comparisons are exact. Reconstruction A: R1 and R3 are
% ORANGERED of width 5, R2 and R4 grey of width 1; its molecules are sa1, sa2 and the
% modifier sa5 (R1) and sa3, sa4 (R3), so every molecule is POWDERBLUE
[~, mapA] = transformXML2Map(fullfile(outputFolder, 'MicroMap_modelA.xml'));
assert(isequal(mapA.rxnName, {'R1'; 'R2'; 'R3'; 'R4'}));
assert(isequal(mapA.rxnColor, {orangeRed; grey; orangeRed; grey}));
assert(isequal(mapA.rxnWidth, {'5'; '1'; '5'; '1'}));
assert(isequal(mapA.molColor, repmat({powderBlue}, 5, 1)));
% reconstruction B: only R2 and its molecules sa2, sa3; the others are white (unified)
[~, mapB] = transformXML2Map(fullfile(outputFolder, 'MicroMap_modelB.xml'));
assert(isequal(mapB.rxnColor, {grey; orangeRed; grey; grey}));
assert(isequal(mapB.rxnWidth, {'1'; '5'; '1'; '1'}));
assert(isequal(mapB.molColor, {white; powderBlue; powderBlue; white; white}));
% the input map is unchanged and no pool is left open
[~, inputMap] = transformXML2Map(mapFile);
assert(isequal(inputMap.rxnColor, repmat({'ff000000'}, 4, 1)));
assert(isempty(getParallelPool()));

%% default number of cores

% where the toolbox is licensed a one-worker pool is opened first (any pool found is closed
% before, as the function would do): the default number of cores is then read but no pool
% with every core of the machine is started, and the function uses and closes the open pool.
% The pool is opened from the output folder, so that the relative output names resolve there
outputFolder = fullfile(tempFolder, 'outputDefaultCores');
mkdir(outputFolder);
cd(outputFolder);
if isParallelToolboxAvailable()
    closeParallelPool();
    openParallelPool(1);
end
visualizeReconstructionsOnMap(mapFile, modelFolder);
cd(fileDir);
written = dir(fullfile(outputFolder, '*.xml'));
assert(isequal(sort({written.name}), {'MicroMap_modelA.xml', 'MicroMap_modelB.xml'}));
[~, mapADefault] = transformXML2Map(fullfile(outputFolder, 'MicroMap_modelA.xml'));
assert(isequal(mapADefault, mapA));
assert(isempty(getParallelPool()));

%% a folder without .mat files is an error

emptyFolder = fullfile(tempFolder, 'empty');
mkdir(emptyFolder);
assert(verifyCobraFunctionError('visualizeReconstructionsOnMap', 'inputs', {mapFile, emptyFolder}, ...
    'testMessage', 'No .mat files found in the specified folder.'));

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
