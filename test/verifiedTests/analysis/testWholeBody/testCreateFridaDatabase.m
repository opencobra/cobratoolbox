% The COBRAToolbox: testCreateFridaDatabase.m
%
% Purpose:
%     - createFridaDatabase(path2Files, varargin) reads a Frida food composition dataset
%       (sheet Data_Table: names, units and ParameterIDs in rows 1-4, one food per row below)
%       and an info file linking Frida parameters to VMH metabolites, and saves the flux table
%       (mmol/100 g per VMH metabolite), the macro table, the food-name dictionary and the info
%       file as .csv and .mat files. This test writes a small dataset and info files into a
%       tempname folder and checks the saved tables against values computed by hand (amount in g
%       / molecular weight in g/mmol, the highest value where two parameters map to the same
%       metabolite, NaN for missing or text values), the skipped and reported info file rows,
%       the name-value options and the error for a missing dataset file.
%
% Function under test:
%     src/analysis/wholeBody/Nutrition_Modelling_Toolbox/createFridaDatabase.m
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
fileDir = fileparts(which('testCreateFridaDatabase'));
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

% the dataset: Danish names, English names, units, ParameterIDs (rows 1-4), then one food per
% row with Danish name, English name and FoodID. Column 4 is a classification without a numeric
% ID (not used); '' is an empty cell (missing value) and 'n/a' a text value (not measured)
dataset = {'Navn', 'Name', 'FoodID', 'Gruppe', 'Vand', 'Glukose', 'Glukose2', 'Fruktose', 'Ukendt'; ...
    '', '', '', 'Food group', 'Water', 'Glucose', 'Glucose (alternative)', 'Fructose', 'Unknown'; ...
    '', '', '', '', 'g', 'mg', 'g', 'mg', 'mg'; ...
    '', '', '', 'Klassifikation', 1, 2, 3, 4, 5; ...
    'Aeble', 'Apple', 101, 'Fruit', 85, 1000, 2, '', 7; ...
    'Banan', 'Banana', 102, 'Fruit', 75, '', '', 500, 'n/a'; ...
    'Broed', 'Bread', 103, 'Cereal', 35, 300, 0.1, 50, 1};
writecell(dataset, fullfile(path2Files, 'FCDB_6.1_Dataset.xlsx'), 'Sheet', 'Data_Table');

% the info file: water (macro only), two glucose parameters (same VMH metabolite), fructose
% (metabolite and macro), a parameter marked 'Not in VMH', and three parameters that are not in
% the dataset: fibre (metabolite with an invalid VMH ID 'fl,hf'), protein (macro) and ash
% (neither, so not reported)
infoHeader = {'nutrientID_frida', 'name_frida', 'unit_frida', 'vmhID', 'molecularMass', 'metBool', 'macroBool'};
infoRows = {1, 'Water', 'g', 'h2o', 18.015, 0, 1; ...
    2, 'Glucose', 'mg', 'glc_D', 180.156, 1, 0; ...
    3, 'Glucose (alternative)', 'g', 'glc_D', 180.156, 1, 0; ...
    4, 'Fructose', 'mg', 'fru', 180.156, 1, 1; ...
    5, 'Unknown', 'mg', 'Not in VMH', '', 1, 0; ...
    6, 'Fibre', 'g', 'fl,hf', '', 1, 0; ...
    7, 'Protein', 'g', 'Not in VMH', '', 0, 1; ...
    8, 'Ash', 'g', '', '', 0, 0};
writecell([infoHeader; infoRows], fullfile(path2Files, 'frida2vmhInfoFile.xlsx'));

% expected flux table in mmol/100 g: glucose = highest of 1000 mg and 2 g (food 101), nothing
% measured (102), highest of 300 mg and 0.1 g (103); fructose 500 mg and 50 mg; molecular
% weight 180.156 g/mol = 0.180156 g/mmol
expectedFlux = [2, NaN, 0.3; NaN, 0.5, 0.05] / 0.180156;
% expected macro table (values as given, per 100 g): water and fructose
expectedMacros = [85, 75, 35; NaN, 500, 50];
foodColumns = {'101', '102', '103'};

%% default options: the dataset is found by its name pattern, files go to fluxMacroTables

lastwarn('');
createFridaDatabase(path2Files);
% the last warning reports the metabolite with an invalid VMH ID (the parameters that are not in
% the dataset are reported first, see the next section)
assert(strcmp(lastwarn, 'The following metabolite parameters have no valid VMH ID and are skipped: Fibre (fl,hf)'));

outputDir = fullfile(path2Files, 'fluxMacroTables');
for fileType = {'100gFluxValue', '100gMacros', 'foodIdDictionary'}
    assert(isfile(fullfile(outputDir, ['frida2024_' fileType{1} '.csv'])));
end

% flux table: one row per VMH metabolite, one column per FoodID
loaded = load(fullfile(outputDir, 'frida2024_100gFluxValue.mat'));
fluxTable = loaded.fluxTableFrida;
assert(isequal(fluxTable.Properties.VariableNames, [{'VMHID'}, foodColumns]));
assert(isequal(fluxTable.VMHID, {'glc_D'; 'fru'}));
fluxValues = fluxTable{:, 2:end};
assert(isequal(isnan(fluxValues), isnan(expectedFlux)));
assert(max(abs(fluxValues(~isnan(fluxValues)) - expectedFlux(~isnan(expectedFlux))) ./ expectedFlux(~isnan(expectedFlux))) < tol);

% macro table: the macro parameters found in the dataset, values unchanged (exact)
loaded = load(fullfile(outputDir, 'frida2024_100gMacros.mat'));
macroTable = loaded.foodMacroFrida;
assert(isequal(macroTable.Properties.VariableNames, [{'macroName'}, foodColumns]));
assert(isequal(macroTable.macroName, {'Water'; 'Fructose'}));
assert(isequaln(macroTable{:, 2:end}, expectedMacros));

% food dictionary: English names and FoodIDs as strings
loaded = load(fullfile(outputDir, 'frida2024_foodIdDictionary.mat'));
dictionary = loaded.foodIdDictionaryFrida;
assert(isequal(dictionary.Properties.VariableNames, {'foodName', 'foodId'}));
assert(isequal(dictionary.foodName, ["Apple"; "Banana"; "Bread"]));
assert(isequal(dictionary.foodId, ["101"; "102"; "103"]));

% the info file is saved as read, all eight rows
loaded = load(fullfile(outputDir, 'frida2024_infoFile.mat'));
assert(height(loaded.nutrientInfoFileFrida) == 8);
assert(isequal(loaded.nutrientInfoFileFrida.nutrientID_frida, (1:8)'));

%% name-value options: dataset and info file names, output folder and numeric edition

copyfile(fullfile(path2Files, 'FCDB_6.1_Dataset.xlsx'), fullfile(path2Files, 'myFrida.xlsx'));
% an info file without the fibre row: only the protein row is reported (not in the dataset)
writecell([infoHeader; infoRows([1:5, 7:8], :)], fullfile(path2Files, 'info2.xlsx'));
customDir = fullfile(path2Files, 'custom');
lastwarn('');
createFridaDatabase(path2Files, 'outputDir', customDir, 'databaseEdition', 2023, ...
    'datasetFile', 'myFrida.xlsx', 'infoFile', 'info2.xlsx');
assert(strcmp(lastwarn, 'The following info file parameters are not in the Frida dataset and are skipped: Protein (7)'));
loaded = load(fullfile(customDir, 'frida2023_100gFluxValue.mat'));
% the same dataset gives the same flux table
assert(isequaln(loaded.fluxTableFrida{:, 2:end}, fluxValues));
loaded = load(fullfile(customDir, 'frida2023_infoFile.mat'));
assert(height(loaded.nutrientInfoFileFrida) == 7);

%% error: no dataset file matching FCDB_*_Dataset.xlsx

emptyFolder = fullfile(path2Files, 'empty');
mkdir(emptyFolder);
assert(verifyCobraFunctionError('createFridaDatabase', 'inputs', {emptyFolder}, ...
    'testMessage', sprintf('Could not find a single FCDB_*_Dataset.xlsx file in %s. Please give the file name with datasetFile.', emptyFolder)));

% remove the temporary files and restore the directory
rmdir(path2Files, 's');
cd(currentDir)
