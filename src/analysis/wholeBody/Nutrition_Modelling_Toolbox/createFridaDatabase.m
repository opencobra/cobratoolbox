function createFridaDatabase(path2Files, varargin)
% Create the flux and macro tables used by the nutrition toolbox from the
% Frida database (frida.fooddata.dk, National Food Institute, Technical
% University of Denmark). This function was written for the Frida Food
% Composition Database version 6.1 (FCDB_6.1_Dataset.xlsx)
%
% USAGE:
%
%    createFridaDatabase(path2Files, varargin)
%
% INPUTS:
%    path2Files:      Character array; directory where the required Frida
%                     input files are stored: the Frida dataset
%                     (FCDB_<version>_Dataset.xlsx) and the info file
%
% OPTIONAL INPUTS:
%    varargin:        Name-value pairs:
%
%                       * outputDir - char, directory where the results are
%                         saved (default [path2Files filesep 'fluxMacroTables'])
%                       * databaseEdition - char or numeric, four-digit year
%                         of the Frida database edition used. Output files
%                         are named frida<YEAR>_... (default '2024')
%                       * datasetFile - char, name of the Frida dataset file
%                         in path2Files. If empty, the file matching
%                         FCDB_*_Dataset.xlsx is used (default '')
%                       * infoFile - char, name of the info file in
%                         path2Files linking Frida parameters to VMH
%                         metabolites. It must contain a molecularMass column
%                         (g/mol) with a weight for every metabolite
%                         (default 'frida2vmhInfoFile.xlsx')
%
% NOTE:
%    Frida parameters are matched to the info file by their ParameterID
%    (nutrientID_frida). If multiple Frida parameters map to the same VMH
%    metabolite in the info file, the highest value of those parameters is
%    used for each food item.
%
% .. Author: - Bram Nap, 02-2025

% parse the inputs
parser = inputParser();
parser.addRequired('path2Files', @ischar);
parser.addParameter('outputDir', [path2Files, filesep, 'fluxMacroTables'], @ischar);
parser.addParameter('databaseEdition', '2024', @(x) ~isempty(regexp(num2str(x), '^\d{4}$', 'once')));
parser.addParameter('datasetFile', '', @ischar);
parser.addParameter('infoFile', 'frida2vmhInfoFile.xlsx', @ischar);

parser.parse(path2Files, varargin{:});

path2Files = parser.Results.path2Files;
outputDir = parser.Results.outputDir;
databaseEdition = num2str(parser.Results.databaseEdition);
datasetFile = parser.Results.datasetFile;
infoFile = parser.Results.infoFile;

% Prefix for all saved files, e.g., frida2024
filePrefix = ['frida', databaseEdition];

%% Step 0 - Set paths and load important files

% Set the output directory to save the transformed food-nutrient tables in
if ~exist(outputDir, 'dir')
    mkdir(outputDir);
end

% Find the Frida dataset file if not given
if isempty(datasetFile)
    datasetFile = dir(fullfile(path2Files, 'FCDB_*_Dataset.xlsx'));
    if numel(datasetFile) ~= 1
        error('Could not find a single FCDB_*_Dataset.xlsx file in %s. Please give the file name with datasetFile.', path2Files)
    end
    datasetFile = datasetFile.name;
end

% Load the food-parameter table. The first three rows hold the Danish
% parameter names, English parameter names and units, the fourth row the
% ParameterIDs. From row five onwards each row is a food item with its
% Danish name, English name and FoodID in the first three columns.
dataTable = readcell(fullfile(path2Files, datasetFile), 'Sheet', 'Data_Table');

% Obtain the parameter IDs. Columns without a numeric ID (e.g., food
% classifications) are not used.
parameterIDs = dataTable(4, 4:end);
isParameter = cellfun(@(x) isnumeric(x) && isscalar(x), parameterIDs);
parameterCols = find(isParameter) + 3;
parameterIDs = cell2mat(dataTable(4, parameterCols));

% Obtain the food item IDs and names
foodRows = 5:size(dataTable, 1);
foodIDs = cell2mat(dataTable(foodRows, 3));
foodNames = dataTable(foodRows, 2);

% Obtain the parameter values per 100 g of food item as a parameter x food
% matrix. Missing values are set to NaN.
values = dataTable(foodRows, parameterCols);
isValue = cellfun(@(x) isnumeric(x) && isscalar(x), values);
valueMatrix = nan(size(values));
valueMatrix(isValue) = cell2mat(values(isValue));
valueMatrix = valueMatrix';

% Load the nutrient infofile
nutrientInfoFileFrida = readtable(fullfile(path2Files, infoFile));

% Report info file parameters that are not in the dataset
notInDataset = ~ismember(nutrientInfoFileFrida.nutrientID_frida, parameterIDs);
if any(notInDataset & (nutrientInfoFileFrida.metBool==1 | nutrientInfoFileFrida.macroBool==1))
    rows = notInDataset & (nutrientInfoFileFrida.metBool==1 | nutrientInfoFileFrida.macroBool==1);
    warning('The following info file parameters are not in the Frida dataset and are skipped: %s', ...
        strjoin(strcat(nutrientInfoFileFrida.name_frida(rows), ' (', string(nutrientInfoFileFrida.nutrientID_frida(rows)), ')'), '; '))
end

%% Step 2 - Create the metabolite table and convert metabolite weights from g/mg/ug to mmol/100g

% Extract all nutrient info that are metabolites with a valid VMH ID
metNutrients = nutrientInfoFileFrida(nutrientInfoFileFrida.metBool==1,:);
[validVmhID, notInVmh] = isValidVmhID(metNutrients.vmhID);
% Warn for entries that are not explicitly marked as Not in VMH
invalidVmhID = ~validVmhID & ~notInVmh;
if any(invalidVmhID)
    warning('The following metabolite parameters have no valid VMH ID and are skipped: %s', ...
        strjoin(strcat(metNutrients.name_frida(invalidVmhID), ' (', metNutrients.vmhID(invalidVmhID), ')'), '; '))
end
metNutrients = metNutrients(validVmhID,:);

% Find the metabolite parameters in the food-parameter table
[~, idx1Met, idx2Met] = intersect(metNutrients.nutrientID_frida, parameterIDs, 'stable');
metNutrients = metNutrients(idx1Met,:);

% Convert the values to mmol/100g with the molecular weights from the info
% file (g/mol, converted to g/mmol). If multiple Frida parameters map to
% the same VMH metabolite, the highest value of those parameters is used
% for each food item.
[metIDs, valuesMol, duplicates] = convertNutrientsToMmol(valueMatrix(idx2Met,:), metNutrients.unit_frida, ...
    metNutrients.vmhID, metNutrients.molecularMass*1e-3);
for i = 1:size(duplicates,1)
    fprintf('%s is measured by %d Frida parameters, the highest value per food item is used.\n', duplicates{i,1}, duplicates{i,2});
end

% Create the new table with mmol/100g of food item table
foodColumns = cellstr(string(foodIDs))';
fluxTableFrida = [table(metIDs, 'VariableNames', {'VMHID'}), ...
    array2table(valuesMol, 'VariableNames', foodColumns)];

%% Create the macro table
% Extract all the macro info
macroData = nutrientInfoFileFrida(nutrientInfoFileFrida.macroBool==1,:);

% Find the macro parameters in the food-parameter table
[~, idx1Macro, idx2Macro] = intersect(macroData.nutrientID_frida, parameterIDs, 'stable');

% Create table with the macros for each food item, named by the parameter
% names in the info file
foodMacroFrida = [table(macroData.name_frida(idx1Macro), 'VariableNames', {'macroName'}), ...
    array2table(valueMatrix(idx2Macro,:), 'VariableNames', foodColumns)];

%% Create food name to food id table
foodIdDictionaryFrida = array2table([string(foodNames), string(foodIDs)]);
foodIdDictionaryFrida.Properties.VariableNames = {'foodName', 'foodId'};

%% Save tables as both csv and .mat files
writetable(fluxTableFrida, [outputDir, filesep, filePrefix, '_100gFluxValue.csv']);
save([outputDir, filesep, filePrefix, '_100gFluxValue.mat'], "fluxTableFrida");

writetable(foodMacroFrida, [outputDir, filesep, filePrefix, '_100gMacros.csv']);
save([outputDir, filesep, filePrefix, '_100gMacros.mat'], "foodMacroFrida");

writetable(foodIdDictionaryFrida, [outputDir, filesep, filePrefix, '_foodIdDictionary.csv']);
save([outputDir, filesep, filePrefix, '_foodIdDictionary.mat'], "foodIdDictionaryFrida");

save([outputDir, filesep, filePrefix, '_infoFile.mat'], 'nutrientInfoFileFrida');
end
