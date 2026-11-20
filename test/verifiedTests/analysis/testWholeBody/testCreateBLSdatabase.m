% The COBRAToolbox: testCreateBLSdatabase.m
%
% Purpose:
%     - createBLSdatabase(path2Files, varargin) reads a German Nutrient Database (BLS) dataset
%       (one header row with "<code> <name> [<unit>/100g]" value columns, one food per row) and
%       an info file linking BLS components to VMH metabolites, and saves the flux table
%       (mmol/100 g per VMH metabolite), the macro table, the food-name dictionary and the info
%       file as .csv and .mat files. This test writes a small dataset and info files into a
%       tempname folder and checks the saved tables against values computed by hand (amount in g
%       / molecular weight in g/mmol, the highest value where two components map to the same
%       metabolite, '-' and unknown text as NaN, '<LOD', '<LOQ', '<LOD or <LOQ' and 'TR' as 0),
%       the reported info file rows and text values, the name-value options and the errors for a
%       missing dataset file and for units that differ from the dataset.
%
% Function under test:
%     src/analysis/wholeBody/Nutrition_Modelling_Toolbox/createBLSdatabase.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; hand-built .xlsx files in a temporary folder.
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
fileDir = fileparts(which('testCreateBLSdatabase'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% relative tolerance: one product and one division of numbers read exactly from the files
tol = 1e-12;

% all input and output files go to a temporary folder
path2Files = tempname;
mkdir(path2Files);

% the dataset: food code and names, then value columns "<code> <name> [<unit>/100g]" (the
% "Data origin" and "Reference" columns are not value columns; '/100 g' with a blank is
% accepted). '' is an empty cell (not measured)
dataset = {'BLS Code', 'Food name', 'Food name (German)', 'WATER Water [g/100g]', ...
    'WATER Data origin', 'WATER Reference', 'GCAL Glucose [mg/100g]', 'GCAL Data origin', ...
    'GCAL Reference', 'GLUS Glucose total [g/100 g]', 'FRUS Fructose [mg/100g]', 'XYZ Unknown [mg/100g]'; ...
    'B100', 'Apple', 'Apfel', 85, 'calculated', 'ref1', '<LOD', 'analysed', 'ref2', 2, '-', 'weird'; ...
    'B200', 'Banana', 'Banane', 'TR', 'analysed', 'ref1', 1000, 'analysed', 'ref2', ' <LOQ', 500, '<LOD or <LOQ'; ...
    'B300', 'Bread', 'Brot', 35, 'analysed', 'ref1', 300, 'analysed', 'ref2', 0.1, 50, ''};
writecell(dataset, fullfile(path2Files, 'BLS_4_0_Data_2025_EN.xlsx'));

% the info file (code and unit columns are found by name): water (macro only), two glucose
% components (same VMH metabolite), fructose (metabolite and macro), a component marked 'Not in
% VMH', and three components that are not in the dataset: fibre (metabolite with an invalid VMH
% ID 'fl,hf'), protein (macro) and ash (neither, so not reported)
infoHeader = {'Komponente / Component code', 'Component name', 'Einheit / Unit', 'vmhID', ...
    'molecularMass', 'metBool', 'macroBool'};
infoRows = {'WATER', 'Water', 'g', 'h2o', 18.015, 0, 1; ...
    'GCAL', 'Glucose', 'mg', 'glc_D', 180.156, 1, 0; ...
    'GLUS', 'Glucose total', 'g', 'glc_D', 180.156, 1, 0; ...
    'FRUS', 'Fructose', 'mg', 'fru', 180.156, 1, 1; ...
    'XYZ', 'Unknown', 'mg', 'Not in VMH', '', 1, 0; ...
    'FIB', 'Fibre', 'g', 'fl,hf', '', 1, 0; ...
    'PROT', 'Protein', 'g', 'Not in VMH', '', 0, 1; ...
    'ASH', 'Ash', 'g', '', '', 0, 0};
writecell([infoHeader; infoRows], fullfile(path2Files, 'bls2vmhInfoFile.xlsx'));

% expected flux table in mmol/100 g: glucose = highest of <LOD (0) and 2 g (B100), 1000 mg and
% <LOQ (0) (B200), 300 mg and 0.1 g (B300); fructose '-' (NaN), 500 mg, 50 mg; molecular weight
% 180.156 g/mol = 0.180156 g/mmol
expectedFlux = [2, 1, 0.3; NaN, 0.5, 0.05] / 0.180156;
% expected macro table (values as given, per 100 g): water (TR = 0) and fructose
expectedMacros = [85, 0, 35; NaN, 500, 50];
foodColumns = {'B100', 'B200', 'B300'};

%% default options: the dataset is found by its name pattern, files go to fluxMacroTables

lastwarn('');
createBLSdatabase(path2Files);
% the last warning reports the metabolite with an invalid VMH ID (the text value 'weird' and the
% components that are not in the dataset are reported before it, see the next section)
assert(strcmp(lastwarn, 'The following metabolite components have no valid VMH ID and are skipped: Fibre (fl,hf)'));

outputDir = fullfile(path2Files, 'fluxMacroTables');
for fileType = {'100gFluxValue', '100gMacros', 'foodIdDictionary'}
    assert(isfile(fullfile(outputDir, ['BLS2025_' fileType{1} '.csv'])));
end

% flux table: one row per VMH metabolite, one column per BLS code
loaded = load(fullfile(outputDir, 'BLS2025_100gFluxValue.mat'));
fluxTable = loaded.fluxTableBLS;
assert(isequal(fluxTable.Properties.VariableNames, [{'VMHID'}, foodColumns]));
assert(isequal(fluxTable.VMHID, {'glc_D'; 'fru'}));
fluxValues = fluxTable{:, 2:end};
assert(isequal(isnan(fluxValues), isnan(expectedFlux)));
assert(max(abs(fluxValues(~isnan(fluxValues)) - expectedFlux(~isnan(expectedFlux))) ./ expectedFlux(~isnan(expectedFlux))) < tol);

% macro table: name, code and unit from the info file, values unchanged (exact)
loaded = load(fullfile(outputDir, 'BLS2025_100gMacros.mat'));
macroTable = loaded.foodMacroBLS;
assert(isequal(macroTable.Properties.VariableNames, [{'macroName', 'componentCode', 'unit'}, foodColumns]));
assert(isequal(macroTable.macroName, {'Water'; 'Fructose'}));
assert(isequal(macroTable.componentCode, {'WATER'; 'FRUS'}));
assert(isequal(macroTable.unit, {'g'; 'mg'}));
assert(isequaln(macroTable{:, 4:end}, expectedMacros));

% food dictionary: English and German names and BLS codes as strings
loaded = load(fullfile(outputDir, 'BLS2025_foodIdDictionary.mat'));
dictionary = loaded.foodIdDictionaryBLS;
assert(isequal(dictionary.Properties.VariableNames, {'foodName', 'foodNameGerman', 'foodId'}));
assert(isequal(dictionary.foodName, ["Apple"; "Banana"; "Bread"]));
assert(isequal(dictionary.foodNameGerman, ["Apfel"; "Banane"; "Brot"]));
assert(isequal(dictionary.foodId, ["B100"; "B200"; "B300"]));

% the info file is saved as read, all eight rows with the original column names
loaded = load(fullfile(outputDir, 'BLS2025_infoFile.mat'));
assert(height(loaded.nutrientInfoFileBLS) == 8);
assert(isequal(loaded.nutrientInfoFileBLS.Properties.VariableNames, infoHeader));

%% name-value options: dataset and info file names, output folder and numeric edition

copyfile(fullfile(path2Files, 'BLS_4_0_Data_2025_EN.xlsx'), fullfile(path2Files, 'myBLS.xlsx'));
% an info file without the fibre row: only the protein row is reported (not in the dataset)
writecell([infoHeader; infoRows([1:5, 7:8], :)], fullfile(path2Files, 'info2.xlsx'));
customDir = fullfile(path2Files, 'custom');
lastwarn('');
createBLSdatabase(path2Files, 'outputDir', customDir, 'databaseEdition', 2024, ...
    'datasetFile', 'myBLS.xlsx', 'infoFile', 'info2.xlsx');
assert(strcmp(lastwarn, 'The following info file components are not in the BLS dataset and are skipped: PROT'));
loaded = load(fullfile(customDir, 'BLS2024_100gFluxValue.mat'));
% the same dataset gives the same flux table
assert(isequaln(loaded.fluxTableBLS{:, 2:end}, fluxValues));
loaded = load(fullfile(customDir, 'BLS2024_infoFile.mat'));
assert(height(loaded.nutrientInfoFileBLS) == 7);

%% a text value that is not a detection limit is reported and treated as not measured

% a dataset whose only text value is 'weird' (XYZ, B100); an info file with the matching rows
writecell(dataset(:, [1:3, 12]), fullfile(path2Files, 'textBLS.xlsx'));
writecell([infoHeader; infoRows(5, :)], fullfile(path2Files, 'info3.xlsx'));
lastwarn('');
createBLSdatabase(path2Files, 'outputDir', customDir, 'datasetFile', 'textBLS.xlsx', 'infoFile', 'info3.xlsx');
assert(strcmp(lastwarn, 'Unknown text values are treated as not measured: weird'));
% the macro table holds no component, the flux table no metabolite (XYZ is not in the VMH)
loaded = load(fullfile(customDir, 'BLS2025_100gFluxValue.mat'));
assert(height(loaded.fluxTableBLS) == 0);

%% errors: units that differ from the dataset, and no dataset file

% the info file gives g for GCAL, the dataset mg
infoWrongUnit = infoRows;
infoWrongUnit{2, 3} = 'g';
writecell([infoHeader; infoWrongUnit], fullfile(path2Files, 'infoWrongUnit.xlsx'));
assert(verifyCobraFunctionError('createBLSdatabase', 'inputs', {path2Files, 'outputDir', customDir, ...
    'infoFile', 'infoWrongUnit.xlsx'}, ...
    'testMessage', 'The units in the info file differ from the BLS dataset for: GCAL'));

emptyFolder = fullfile(path2Files, 'empty');
mkdir(emptyFolder);
assert(verifyCobraFunctionError('createBLSdatabase', 'inputs', {emptyFolder}, ...
    'testMessage', sprintf('Could not find a single BLS_*_Data_*_EN.xlsx file in %s. Please give the file name with datasetFile.', emptyFolder)));

% remove the temporary files and restore the directory
rmdir(path2Files, 's');
cd(currentDir)
