function createUSDAdatabase(path2Files, varargin)
% Creates the files used in the nutrition toolbox from the USDA fooddata
% central database. This can be downloaded from https://fdc.nal.usda.gov/download-datasets.html
% This function was created based on the april 2024 Full Download of All
% Data Types
%
% Usage:
%   createUSDAdatabase(path2Files, varargin)
%
% Inputs
%   path2Files:         Path to the directory where all the USDA fooddata
%                       files are stored. As well as the
%                       usdaNutrientVmhTransl file found in the cobra
%                       toolbox
%
% Optional inputs:
%   brandedFoods:       Boolean, if the food source table of the branded
%                       foods should be created. Defaults to false. Warning
%                       putting this to true could take days of running the
%                       code as it will have to convert almost 2 million
%                       items
%   outputDir:          Path to the directory where the individual food
%                       source databases should be stored. Defaults to
%                       [path2files , filesep, foodSourceNutrientTables]
%   finalDatabaseDir:   Path to the directory where the final flux and
%                       macro databases should be stored. Defaults to
%                       [path2files, filesep, fluxMacroTables]
%   foodSource2Use:     Cell array of with food source tables are to be
%                       used to create the final flux and macro databases.
%                       Defaults to {'sr_legacy_food';'foundation_food';'survey_fndds_food'}
%
% Example:
%   createUSDAdatabase(path2Files)
%
% .. Author - Bram nap 09-2024

% parse the inputs
parser = inputParser();
parser.addRequired('path2Files', @ischar);
parser.addParameter('brandedFoods', false, @islogical);
parser.addParameter('outputDir', [path2Files , filesep, 'foodSourceNutrientTables'], @ischar);
parser.addParameter('finalDatabaseDir', [path2Files, filesep, 'fluxMacroTables'], @ischar);
parser.addParameter('foodSource2Use', {'sr_legacy_food';'foundation_food';'survey_fndds_food'}', @iscell);

parser.parse(path2Files, varargin{:});

path2Files = parser.Results.path2Files;
brandedFoods = parser.Results.brandedFoods;
outputDir = parser.Results.outputDir;
finalDatabaseDir = parser.Results.finalDatabaseDir;
foodSource2Use = parser.Results.foodSource2Use;
%% Step 0 - Set paths and load important files
% Set the path where files are stored
% path2Files = 'D:\OneDrive - National University of Ireland, Galway\ViennaDiet\databases\updated_USDA\RequiredFiles';

% Load the main databases
% All the food descriptors
allFoods = readtable([path2Files, filesep, 'food.csv']);
% Nutrient descriptors
% nutrients = readtable([path2Files,filesep, 'nutrient.csv']);
% Nutrient values for each food item
foodNutrients = readtable([path2Files, filesep, 'food_nutrient.csv']);

%% Step 1 - create the indiviual food-nutrient databases for each food source for easy inspection

% Remove branded food items from sources as it is almost 2 million items
% long. It requires a different code set-up and takes a long time to run.
if ~brandedFoods
    foodSource2Use(strcmp(foodSource2Use, 'branded_food')) = [];
    foodSource2Use(strcmp(foodSource2Use, 'branded_food')) = [];
end

% Set the output directory to save the transformed food-nutrient tables in
if ~exist(outputDir, 'dir')
    mkdir(outputDir);
end

% Create a file for each food source with all their food items and
% nutrients
for i = 1:max(size(foodSource2Use))
    disp(strcat('Currently creating the individual database for ', foodSource2Use{i}));
    % Obtain the food entries for the specific food source
    spefFoods = allFoods(strcmp(allFoods.data_type, foodSource2Use(i)), :);
    for j = 1:size(spefFoods.fdc_id,1)
        % Obtain the food fdc ID
        foodId = spefFoods.fdc_id(j);
        % Obtain the nutrients and the values
        spefFoodNutrients = foodNutrients(foodNutrients.fdc_id == foodId, 3:4);
        % Set the column name to the fdc ID
        spefFoodNutrients.Properties.VariableNames(2) = string(foodId);
        if j == 1
            % First iteration create the final table
            totTable = spefFoodNutrients;
        else
            % Subsequent iterations merge the new food table with the final
            % table
            totTable = outerjoin(totTable, spefFoodNutrients, 'MergeKeys',true);
        end
    end
    % Save the table
    writetable(totTable, [outputDir, filesep, foodSource2Use{i}, 'NutrientsCombined.csv']);
end

% If people want to produce the branded food database
if brandedFoods
    % Initialise variable for food items with duplicate nutrient entries
    % that will cause issues
    itemsWithDuplc = {};
    % Obtain the food item information
    brandedNames = allFoods(contains(allFoods.data_type, 'branded'), :);
    % Set k to 0 - used to start the formation of a new table after each
    % safe
    k = 0;
    for i = 1:size(brandedNames.fdc_id)
        % Obtain the food name and fdc ID
        foodid = brandedNames.fdc_id(i);
        foodName = brandedNames.description(i);
        
        % Obtain the food item nutrients and set fdc ID as column header
        spefFoodNutrients = foodsnutrients(foodsnutrients.fdc_id == foodid, 3:4);
        spefFoodNutrients.Properties.VariableNames(2) = string(foodid);
        
        % If it is the first instance after a save create a new table
        if i == 1+50000*k
            totTable = spefFoodNutrients;
            % If there are 50.000 items stored in the table, save it. MATLAB
            % cannot save tables large enough to have all the food items, which
            % is why we break it up. 50.000 as it is a compromise between speed
            % and low number of files
        elseif rem(i/50000,1) == 0
            filename = strcat('brandedfood_', string(i), '.mat');
            save(filename, "totTable");
            totTable = spefFoodNutrients;
            k = k+1;
            % If the the last food item is reached - save it
        elseif i == size(brandedNames,1)
            filename = strcat('brandedfood_', string(i), '.mat');
            save(filename, "totTable");
            % If there are duplicated nutrient entries, skip and store the name
            % in a variable
        elseif size(spefFoodNutrients,1) > size(unique(spefFoodNutrients.nutrient_id),1)
            itemsWithDuplc{end+1,1} = cell2mat(foodName);
            % If the other statements do not apply - add the single food item
            % table to the total table
        else
            totTable = outerjoin(totTable, spefFoodNutrients, 'MergeKeys', true);
        end
    end
end

%% Step 2 - Combine desired individual databases split them in metabolites and macro tables

% Load the tables that you want to be combined for analysis
for i = 2:max(size(foodSource2Use))
    if i == 2
        table1 = readtable([outputDir, filesep, foodSource2Use{1}, 'NutrientsCombined.csv'], "PreserveVariableNames", true, 'ReadVariableNames',true);
        table2 = readtable([outputDir, filesep, foodSource2Use{2}, 'NutrientsCombined.csv'], "PreserveVariableNames", true, 'ReadVariableNames',true);
        totTable = outerjoin(table1, table2, "MergeKeys", true);
    else
        tablei = readtable([outputDir, filesep, foodSource2Use{i}, 'NutrientsCombined.csv'], "PreserveVariableNames", true, 'ReadVariableNames',true);
        totTable = outerjoin(totTable, tablei, "MergeKeys", true);
    end
end

% Load the table with information on nutrient IDs, names and vmh
% associations
nutrientVmhTable = readtable([path2Files, filesep, 'usda2vmhInfoFile.xlsx']);

% Extract all nutrient info that are metabolites
metVmhTable = nutrientVmhTable(nutrientVmhTable.metBool==1,:);

% Find the index of the metabolite nutrient IDs in the food-nutrient tables
[~, idx1Met, idx2Met] = intersect(metVmhTable.nutrientID_usda, totTable.nutrient_id, 'stable');

% Create table with food-nutrient information with only VMH metabolites
foodVMHMetaboliteTable = totTable(idx2Met,:);
foodVMHMetaboliteTable.VMHID = metVmhTable.vmhID(idx1Met);
% Move the VMH ID column to the second position
foodVMHMetaboliteTable = foodVMHMetaboliteTable(:,[1 end 2:end-1]);

% Extract all the macro info
macroTable = nutrientVmhTable(nutrientVmhTable.macroBool==1,:);

% Find the index of the macro nutrient IDs in the food-nutrient tables
[~, idx1Macro, idx2Macro] = intersect(macroTable.nutrientID_usda, totTable.nutrient_id, 'stable');

% Create table with food-nutrient information with only VMH metabolites
foodMacroUsda = totTable(idx2Macro,:);
foodMacroUsda.nutrientName = macroTable.name_usda(idx1Macro);

% Obtain the macro numes as macro name (unit) for easy reference
macroNames = strcat(macroTable.name_usda(idx1Macro), '_(', macroTable.unit_usda(idx1Macro), ')');
foodMacroUsda.nutrientName = macroNames;

% Move the nutrientName column to the second position
foodMacroUsda = foodMacroUsda(:,[1 end 2:end-1]);
%% Step 3 - Convert metabolite weights from g/mg/ug to mmol

% Obtain the units of each measured metabolite
unitMetabolite = nutrientVmhTable.unit_usda(idx1Met);

% Convert units to values for conversions factors to grams
unitMetabolite = strrep(unitMetabolite, 'UG', '1e6');
unitMetabolite = strrep(unitMetabolite, 'MG', '1e3');
unitMetabolite = strrep(unitMetabolite, 'G', '1');

unitMetabolite = str2double(unitMetabolite);

% Obtain the measures weight values for all VMH metabolites for the food
% items
foodValues = foodVMHMetaboliteTable{:, 3:end};

% Convert all measured values to grams
valuesGrams = bsxfun(@rdivide,foodValues,unitMetabolite(:));

% Obtain the metabolite information from the VMH database
vmhDatabase = loadVMHDatabase;
metaboliteData = cell2table(vmhDatabase.metabolites);

% Extract the metabolite formalas of metabolites found in the USDA database
[~, metidx] = ismember(foodVMHMetaboliteTable.VMHID, metaboliteData.Var1,'legacy');

formulas = metaboliteData.Var4(metidx);

% Obtain the molecular mass from the formulas in gram/mol
mws = getMolecularMass(formulas);
% convert to gram/mmol
mws = mws*1e-3;

% Add molecular weights for cobalt and nickel
cobalt = 58.93319/1000;
nickel = 58.693/1000;

[~,~,spefidx] = intersect({'Co', 'Ni'}, formulas, 'stable');
mws(spefidx) = [cobalt, nickel];

% Calculate the mmol values for each metabolite
valuesMol =  bsxfun(@rdivide,valuesGrams,mws(:));

% Create the new table with mmol/100g of food item table
fluxTableUsda = foodVMHMetaboliteTable;

fluxTableUsda(:, 3:end) = array2table(valuesMol);
fluxTableUsda.nutrient_id = [];

%% Save tables as both csv and .mat files

if ~exist(finalDatabaseDir, 'dir')
    mkdir(finalDatabaseDir);
end

writetable(fluxTableUsda, [finalDatabaseDir, filesep, 'USDA2024_100gFluxValue.csv']);
save([finalDatabaseDir, filesep, 'USDA2024_100gFluxValue.mat'], "fluxTableUsda");

writetable(foodMacroUsda, [finalDatabaseDir, filesep, 'USDA2024_100gMacros.csv']);
save([finalDatabaseDir, filesep, 'USDA2024_100gMacros.mat'], "foodMacroUsda");

% Save the infofile
save([outputDir, filesep, 'usda2024_infoFile.mat'], 'nutrientVmhTable');

% Change the ; in the foodnames to a , and save as .mat file
allFoods.description = strrep(allFoods.description, ';', ',');
allFoods.description = strrep(allFoods.description, '''', ' ');
allFoods.description = strrep(allFoods.description, "'", '');

save([outputDir, filesep, 'USDAFoodItems.mat'], 'allFoods');

end