function createFridaDatabase(path2Files, varargin)
% Creation of flux tables and macro tables to be used in the nutrition
% toolbox for the Frida database. Food data (frida.fooddata.dk), 
% National Food Institute, Technical University of Denmark.
%
% Usage:
%   createUSDAdatabase(path2Files, varargin)
%
% Inputs
%   path2Files: Character array; The directory where the the required input
%   files for Frida are stored
%
% Optional inputs:
%   outputDir: Character array; THe directory where the results should be
%   saved
%
% Example:
%   createUSDAdatabase(path2Files)
%
% .. Author - Bram nap 02-2025

% parse the inputs
parser = inputParser();
parser.addRequired('path2Files', @ischar);
parser.addParameter('outputDir', [path2Files, filesep, 'fluxMacroTables'], @ischar);

parser.parse(path2Files, varargin{:});

path2Files = parser.Results.path2Files;
outputDir = parser.Results.outputDir;

%% Step 0 - Set paths and load important files

% Set the output directory to save the transformed food-nutrient tables in
if ~exist(outputDir, 'dir')
    mkdir(outputDir);
end

% Load the main database
allFiles = dir(path2Files);
allFiles = {allFiles.name};

foodNNutrient = readtable(strcat(path2Files, filesep, allFiles{contains(allFiles,'fridaFoodNutrients_')}), 'preserveVariableNames',true);

% Load the nutrient infofile
nutrientInfoFileFrida = readtable([path2Files, filesep, 'frida2vmhInfoFile.xlsx']);

%% Step 2 - Create the metabolite table and convert metabolite weights from g/mg/ug to mmol/100g

% Extract all nutrient info that are metabolites
metNutrients = nutrientInfoFileFrida(nutrientInfoFileFrida.metBool==1,:);

% Find the index of the metabolite nutrient IDs in the food-nutrient tables
[~, ~, idx2Met] = intersect(metNutrients.name_frida, foodNNutrient.Properties.VariableNames, 'stable');

% Create table with food-nutrient information with only VMH metabolites
foodMetaboliteTable = foodNNutrient(:,idx2Met);
foodMetaboliteTable = rows2vars(foodMetaboliteTable);

% Extract the food IDs and relpace the column headers
columnHeaders = ['VMHID'; string(foodNNutrient.FoodID)];
foodMetaboliteTable.Properties.VariableNames = cellstr(columnHeaders);

% Replace the nutrient names with VMH metabolite IDs.
foodMetaboliteTable.VMHID = metNutrients.vmhID;

% Remove metabolites that are not in the VMH
foodMetaboliteTable(strcmp(foodMetaboliteTable.VMHID, 'Not in VMH'),:) = [];
metNutrients(strcmp(metNutrients.vmhID, 'Not in VMH'),:) = [];

% Obtain the units of each measured metabolite
unitMetabolite = metNutrients.unit_frida;

% Convert units to values for conversions factors to grams
unitMetabolite = strrep(unitMetabolite, 'ug', '1e6');
unitMetabolite = strrep(unitMetabolite, 'mg', '1e3');
unitMetabolite = strrep(unitMetabolite, 'g', '1');

unitMetabolite = str2double(unitMetabolite);

% Obtain the measures weight values for all VMH metabolites for the food
% items
metWeights = foodMetaboliteTable{:, 2:end};

% Convert all measured values to grams
valuesGrams = bsxfun(@rdivide,metWeights,unitMetabolite(:));

% Obtain the metabolite information from the VMH database
vmhDatabase = loadVMHDatabase;
metaboliteData = cell2table(vmhDatabase.metabolites);

% For the NaN values that the Frida database did not give a molecular
% weight for, calculate it by the assumed VMH metabolite
for i = 1:height(metNutrients)
    if isnan(metNutrients.molecularMass(i))
        formula = metaboliteData.Var4(strcmp(metaboliteData.Var1, metNutrients.vmhID(i)));
        metNutrients.molecularMass(i) = getMolecularMass(formula);
    end
end

% Extract the molecular weights
mws = metNutrients.molecularMass;

% convert to gram/mmol
mws = mws*1e-3;

% Calculate the mmol values for each metabolite
valuesMol =  bsxfun(@rdivide,valuesGrams,mws(:));

% Create the new table with mmol/100g of food item table
fluxTableFrida = foodMetaboliteTable;
fluxTableFrida(:, 2:end) = array2table(valuesMol);

%% Create the macro table
% Extract all the macro info
macroData = nutrientInfoFileFrida(nutrientInfoFileFrida.macroBool==1,:);

% Find the index of the macro nutrient IDs in the food-nutrient tables
[~, ~, idx2Macro] = intersect(macroData.name_frida, foodNNutrient.Properties.VariableNames, 'stable');

% Create table with food-nutrient information with only macros
foodMacroFrida = foodNNutrient(:,idx2Macro);
foodMacroFrida = rows2vars(foodMacroFrida);

% Extract the food IDs and relpace the column headers
columnHeaders = ['macroName'; string(foodNNutrient.FoodID)];
foodMacroFrida.Properties.VariableNames = cellstr(columnHeaders);

%% Create food name to food id table
foodIdDictionaryFrida = array2table([foodNNutrient.FoodName,string(foodNNutrient.FoodID)]);
foodIdDictionaryFrida.Properties.VariableNames = {'foodName', 'foodId'};

%% Save tables as both csv and .mat files
writetable(fluxTableFrida, [outputDir, filesep, 'frida2024_100gFluxValue.csv']);
save([outputDir, filesep, 'frida2024_100gFluxValue.mat'], "fluxTableFrida");

writetable(foodMacroFrida, [outputDir, filesep, 'frida2024_100gMacros.csv']);
save([outputDir, filesep, 'frida2024_100gMacros.mat'], "foodMacroFrida");

writetable(foodIdDictionaryFrida, [outputDir, filesep, 'frida2024_foodIdDictionary.csv']);
save([outputDir, filesep, 'frida2024_foodIdDictionary.mat'], "foodIdDictionaryFrida");

save([outputDir, filesep, 'frida2024_infoFile.mat'], 'nutrientInfoFileFrida');
end