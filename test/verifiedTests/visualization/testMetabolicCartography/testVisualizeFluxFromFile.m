% The COBRAToolbox: testVisualizeFluxFromFile.m
%
% Purpose:
%     - visualizeFluxFromFile reads a CellDesigner map (transformXML2Map), colours and widens
%       its reactions from a flux table file (addFluxFromFileWidthAndColor: width 1, 2, 5, 8
%       or 10 by the flux relative to the largest absolute flux, red shades for positive and
%       indigo shades for negative flux, light grey for zero flux, reactions without flux data
%       unchanged with width 1, molecules of a reaction with flux in its colour and all other
%       molecules white) and writes the result with transformMap2XML to a given file or, by
%       default, to 'VisualizedFluxOnMap.xml' in the current folder. The test writes a small
%       CellDesigner map (species A-E, aliases sa1-sa5, R1: A -> B catalysed by E, R2: B -> C,
%       R3: C -> D, R4: D -> A) and a CSV file in a tempname folder, and reads the written map
%       back. Expected widths and colours follow by hand from the documented bands and shade
%       lists of addFluxFromFileWidthAndColor; widths come back as text because the file holds
%       them as attributes.
%
% Function under test:
%     src/visualization/metabolicCartography/visualizeFluxFromFile.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; hand-written CellDesigner and CSV files in a tempname folder.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testVisualizeFluxFromFile'));
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

% flux table: R1 10, R2 -5, R4 0, RX (not in the map) 3; R3 has no flux data
csvFile = fullfile(tempFolder, 'fluxes.csv');
fileId = fopen(csvFile, 'w');
fprintf(fileId, 'rxnID,flux\nR1,10\nR2,-5\nR4,0\nRX,3\n');
fclose(fileId);

% shades of addFluxFromFileWidthAndColor (lightest to darkest) and its fixed colours
redShades = {'FFffc9c9', 'FFff8787', 'FFfa5252', 'FFc92a2a'};
indigoShades = {'FFbac8ff', 'FF748ffc', 'FF4c6ef5', 'FF364fc7'};
lightGray = 'FFD3D3D3';
white = 'FFFFFFFF';

%% the flux is drawn on the map and the map is written to the given file

outputFile = fullfile(tempFolder, 'withFlux.xml');
visualizeFluxFromFile(mapFile, csvFile, outputFile);
assert(exist(outputFile, 'file') == 2);
[~, outputMap] = transformXML2Map(outputFile);
% relative fluxes 1.0, 0.5, 0 give widths 10, 5, 1; R3 (no data) gets 1; the file holds
% the widths as text attributes, so they come back as text (exact comparison)
assert(isequal(outputMap.rxnName, {'R1'; 'R2'; 'R3'; 'R4'}));
assert(isequal(outputMap.rxnWidth, {'10'; '5'; '1'; '1'}));
% width 10 is the darkest red, width 5 the second indigo shade; zero flux is light grey;
% a reaction without flux data keeps its colour
assert(isequal(outputMap.rxnColor, {redShades{4}; indigoShades{2}; 'ff000000'; lightGray}));
% molecules: sa1 from R1; sa2 from R1 then R2 (file order, the later one wins); sa3 from
% R2; sa4 and sa5 take part in no reaction with flux and are white
assert(isequal(outputMap.molColor, {redShades{4}; indigoShades{2}; indigoShades{2}; white; white}));
% the input map is not changed
[~, inputMap] = transformXML2Map(mapFile);
assert(isequal(inputMap.rxnColor, repmat({'ff000000'}, 4, 1)));
assert(isequal(inputMap.rxnWidth, repmat({'1.0'}, 4, 1)));

%% default output file: 'VisualizedFluxOnMap.xml' in the current folder

% the third argument is omitted, then given empty
cd(tempFolder);
defaultFile = fullfile(tempFolder, 'VisualizedFluxOnMap.xml');
visualizeFluxFromFile(mapFile, csvFile);
assert(exist(defaultFile, 'file') == 2);
[~, defaultMap] = transformXML2Map(defaultFile);
assert(isequal(defaultMap, outputMap));
delete(defaultFile);
visualizeFluxFromFile(mapFile, csvFile, '');
assert(exist(defaultFile, 'file') == 2);
cd(fileDir);

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
