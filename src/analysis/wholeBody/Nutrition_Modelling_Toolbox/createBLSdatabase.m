function createBLSdatabase(path2Files, varargin)
% Create the flux and macro tables used by the nutrition toolbox from the
% German Nutrient Database (Bundeslebensmittelschlüssel, BLS, Max Rubner-
% Institut, https://www.blsdb.de). This function was written for BLS
% version 4.0 (BLS_4_0_Data_2025_EN.xlsx)
%
% USAGE:
%
%    createBLSdatabase(path2Files, varargin)
%
% INPUTS:
%    path2Files:      Character array; directory where the required BLS
%                     input files are stored: the BLS dataset
%                     (BLS_<version>_Data_<year>_EN.xlsx) and the info file
%
% OPTIONAL INPUTS:
%    varargin:        Name-value pairs:
%
%                       * outputDir - char, directory where the results are
%                         saved (default [path2Files filesep 'fluxMacroTables'])
%                       * databaseEdition - char or numeric, four-digit year
%                         of the BLS database edition used. Output files are
%                         named BLS<YEAR>_... (default '2025')
%                       * datasetFile - char, name of the BLS dataset file in
%                         path2Files. If empty, the file matching
%                         BLS_*_Data_*_EN.xlsx is used (default '')
%                       * infoFile - char, name of the info file in
%                         path2Files linking BLS components to VMH
%                         metabolites. It must contain a molecularMass column
%                         (g/mol) with a weight for every metabolite
%                         (default 'bls2vmhInfoFile.xlsx')
%
% NOTE:
%    BLS components are matched to the info file by their component code
%    (e.g., WATER, CHORL). Values reported as '-' are treated as not
%    measured (NaN). Values below the limit of detection or quantification
%    ('<LOD', '<LOQ', '<LOD or <LOQ') and traces ('TR') are set to 0. If
%    multiple BLS components map to the same VMH metabolite in the info
%    file, the highest value of those components is used for each food item.
%
% .. Author: - Bram Nap, 10-2026

% parse the inputs
parser = inputParser();
parser.addRequired('path2Files', @ischar);
parser.addParameter('outputDir', [path2Files, filesep, 'fluxMacroTables'], @ischar);
parser.addParameter('databaseEdition', '2025', @(x) ~isempty(regexp(num2str(x), '^\d{4}$', 'once')));
parser.addParameter('datasetFile', '', @ischar);
parser.addParameter('infoFile', 'bls2vmhInfoFile.xlsx', @ischar);

parser.parse(path2Files, varargin{:});

path2Files = parser.Results.path2Files;
outputDir = parser.Results.outputDir;
databaseEdition = num2str(parser.Results.databaseEdition);
datasetFile = parser.Results.datasetFile;
infoFile = parser.Results.infoFile;

% Prefix for all saved files, e.g., BLS2025
filePrefix = ['BLS', databaseEdition];

%% Step 0 - Set paths and load important files

% Set the output directory to save the transformed food-nutrient tables in
if ~exist(outputDir, 'dir')
    mkdir(outputDir);
end

% Find the BLS dataset file if not given
if isempty(datasetFile)
    datasetFile = dir(fullfile(path2Files, 'BLS_*_Data_*_EN.xlsx'));
    if numel(datasetFile) ~= 1
        error('Could not find a single BLS_*_Data_*_EN.xlsx file in %s. Please give the file name with datasetFile.', path2Files)
    end
    datasetFile = datasetFile.name;
end

% Load the food-component table. The first row holds the column headers,
% each following row is a food item. Each component has three columns:
% "<code> <name> [<unit>/100g]" with the values, "<code> Data origin" and
% "<code> Reference".
dataTable = readcell(fullfile(path2Files, datasetFile));
header = dataTable(1, :);

% Obtain the food item IDs and names
foodRows = 2:size(dataTable, 1);
foodIDs = dataTable(foodRows, strcmp(header, 'BLS Code'));
foodNames = dataTable(foodRows, strcmp(header, 'Food name'));
foodNamesGerman = dataTable(foodRows, strcmp(header, 'Food name (German)'));

% Find the value columns with their component codes and units
tokens = regexp(header, '^(\S+) .*\[(.+)/100\s?g\]$', 'tokens', 'once');
valueCols = find(~cellfun(@isempty, tokens));
componentCodes = cellfun(@(x) x{1}, tokens(valueCols), 'UniformOutput', false);
componentUnits = cellfun(@(x) x{2}, tokens(valueCols), 'UniformOutput', false);

% Obtain the component values per 100 g of food item as a component x food
% matrix. Values below the detection or quantification limit and traces
% are set to 0, not measured values ('-') to NaN.
values = dataTable(foodRows, valueCols);
isValue = cellfun(@(x) isnumeric(x) && isscalar(x), values);
valueMatrix = nan(size(values));
valueMatrix(isValue) = cell2mat(values(isValue));
isText = cellfun(@(x) ischar(x) || isstring(x), values);
belowLimit = isText & ismember(strtrim(string(values)), ["<LOD", "<LOQ", "<LOD or <LOQ", "TR"]);
valueMatrix(belowLimit) = 0;
otherText = isText & ~belowLimit & ~strcmp(strtrim(string(values)), "-");
if any(otherText(:))
    warning('Unknown text values are treated as not measured: %s', strjoin(unique(string(values(otherText)))', ', '))
end
valueMatrix = valueMatrix';

% Load the nutrient infofile. The component code and unit columns are
% found by name as the headers contain German and English text.
nutrientInfoFileBLS = readtable(fullfile(path2Files, infoFile), 'VariableNamingRule', 'preserve');
infoVars = nutrientInfoFileBLS.Properties.VariableNames;
codeColumn = infoVars{contains(infoVars, 'Component code')};
nameColumn = infoVars{strcmp(infoVars, 'Component name')};
unitColumn = infoVars{contains(infoVars, 'Unit')};

% Check that the units of the info file match the units of the dataset
[~, idxInfo, idxData] = intersect(nutrientInfoFileBLS.(codeColumn), componentCodes, 'stable');
unitMismatch = ~strcmp(nutrientInfoFileBLS.(unitColumn)(idxInfo), componentUnits(idxData)');
if any(unitMismatch)
    error('The units in the info file differ from the BLS dataset for: %s', ...
        strjoin(nutrientInfoFileBLS.(codeColumn)(idxInfo(unitMismatch))', ', '))
end

% Report info file components that are not in the dataset
notInDataset = ~ismember(nutrientInfoFileBLS.(codeColumn), componentCodes) & ...
    (nutrientInfoFileBLS.metBool==1 | nutrientInfoFileBLS.macroBool==1);
if any(notInDataset)
    warning('The following info file components are not in the BLS dataset and are skipped: %s', ...
        strjoin(nutrientInfoFileBLS.(codeColumn)(notInDataset)', ', '))
end

%% Step 2 - Create the metabolite table and convert metabolite weights from g/mg/ug to mmol/100g

% Extract all nutrient info that are metabolites with a valid VMH ID
metNutrients = nutrientInfoFileBLS(nutrientInfoFileBLS.metBool==1,:);
[validVmhID, notInVmh] = isValidVmhID(metNutrients.vmhID);
% Warn for entries that are not explicitly marked as Not in VMH
invalidVmhID = ~validVmhID & ~notInVmh;
if any(invalidVmhID)
    warning('The following metabolite components have no valid VMH ID and are skipped: %s', ...
        strjoin(strcat(metNutrients.(nameColumn)(invalidVmhID), ' (', metNutrients.vmhID(invalidVmhID), ')'), '; '))
end
metNutrients = metNutrients(validVmhID,:);

% Find the metabolite components in the food-component table
[~, idx1Met, idx2Met] = intersect(metNutrients.(codeColumn), componentCodes, 'stable');
metNutrients = metNutrients(idx1Met,:);

% Convert the values to mmol/100g with the molecular weights from the info
% file (g/mol, converted to g/mmol). If multiple BLS components map to the
% same VMH metabolite, the highest value of those components is used for
% each food item.
[metIDs, valuesMol, duplicates] = convertNutrientsToMmol(valueMatrix(idx2Met,:), metNutrients.(unitColumn), ...
    metNutrients.vmhID, metNutrients.molecularMass*1e-3);
for i = 1:size(duplicates,1)
    fprintf('%s is measured by %d BLS components, the highest value per food item is used.\n', duplicates{i,1}, duplicates{i,2});
end

% Create the new table with mmol/100g of food item table
foodColumns = cellstr(string(foodIDs))';
fluxTableBLS = [table(metIDs, 'VariableNames', {'VMHID'}), ...
    array2table(valuesMol, 'VariableNames', foodColumns)];

%% Create the macro table
% Extract all the macro info
macroData = nutrientInfoFileBLS(nutrientInfoFileBLS.macroBool==1,:);

% Find the macro components in the food-component table
[~, idx1Macro, idx2Macro] = intersect(macroData.(codeColumn), componentCodes, 'stable');

% Create table with the macros for each food item, named by the component
% names in the info file
foodMacroBLS = [table(macroData.(nameColumn)(idx1Macro), macroData.(codeColumn)(idx1Macro), macroData.(unitColumn)(idx1Macro), ...
    'VariableNames', {'macroName', 'componentCode', 'unit'}), ...
    array2table(valueMatrix(idx2Macro,:), 'VariableNames', foodColumns)];

%% Create food name to food id table
foodIdDictionaryBLS = array2table([string(foodNames), string(foodNamesGerman), string(foodIDs)]);
foodIdDictionaryBLS.Properties.VariableNames = {'foodName', 'foodNameGerman', 'foodId'};

%% Save tables as both csv and .mat files
writetable(fluxTableBLS, [outputDir, filesep, filePrefix, '_100gFluxValue.csv']);
save([outputDir, filesep, filePrefix, '_100gFluxValue.mat'], "fluxTableBLS");

writetable(foodMacroBLS, [outputDir, filesep, filePrefix, '_100gMacros.csv']);
save([outputDir, filesep, filePrefix, '_100gMacros.mat'], "foodMacroBLS");

writetable(foodIdDictionaryBLS, [outputDir, filesep, filePrefix, '_foodIdDictionary.csv']);
save([outputDir, filesep, filePrefix, '_foodIdDictionary.mat'], "foodIdDictionaryBLS");

save([outputDir, filesep, filePrefix, '_infoFile.mat'], 'nutrientInfoFileBLS');
end
