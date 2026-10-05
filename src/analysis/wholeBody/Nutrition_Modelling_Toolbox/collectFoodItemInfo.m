function [allFluxes, allMacros] = collectFoodItemInfo(foods2Check, foodNames, varargin)
% Collect the macro and flux values for the VMH food suggestions found by
% vmhFoodFinder
%
% USAGE:
%
%    [allFluxes, allMacros] = collectFoodItemInfo(foods2Check, foodNames, varargin)
%
% INPUTS:
%    foods2Check:     Structure with one field per original food item, each
%                     holding a table whose first column lists the suggested
%                     VMH food items and whose second column holds the amount
%                     of food eaten
%    foodNames:       Names of the original food items associated with the
%                     fields of foods2Check (passed to the input parser)
%
% OPTIONAL INPUTS:
%    varargin:        Name-value pairs:
%
%                       * addStarch - boolean indicating if additional starch
%                         should be added based on the VMH food macros
%                         (default false)
%                       * macroType - char selecting how macros are computed:
%                         'metabolites' from the calculated flux vectors or
%                         'usda' from the USDA FoodData database
%                         (default 'metabolites')
%                       * databaseType - char selecting which database is
%                         used; currently only 'usda' (USDA FoodData) is
%                         supported (default 'usda')
%                       * usdaEdition - char or numeric, four-digit year of
%                         the USDA database edition to use. If empty the
%                         latest available edition is used (default '')
%                       * fridaEdition - char or numeric, four-digit year of
%                         the Frida database edition to use. If empty the
%                         latest available edition is used (default '')
%                       * blsEdition - char or numeric, four-digit year of
%                         the BLS database edition to use. If empty the
%                         latest available edition is used (default '')
%
% OUTPUTS:
%    allFluxes:       Structure with one field per food item, each holding a
%                     table of flux values for every suggested VMH food item
%    allMacros:       Structure with one field per food item, each holding a
%                     table of macros for every suggested VMH food item
%
% .. Author: - Bram Nap, 05-2024

% Parse inputs
parser = inputParser();
parser.addRequired('foods2Check', @isstruct);
parser.addParameter('addStarch', false, @islogical);
parser.addParameter('databaseType', 'usda', @ischar);
parser.addParameter('macroType', 'metabolites', @ischar);
parser.addParameter('usdaEdition', '', @(x)ischar(x)||isstring(x)||isnumeric(x));
parser.addParameter('fridaEdition', '', @(x)ischar(x)||isstring(x)||isnumeric(x));
parser.addParameter('blsEdition', '', @(x)ischar(x)||isstring(x)||isnumeric(x));

parser.parse(foods2Check, foodNames, varargin{:});

foods2Check = parser.Results.foods2Check;
addStarch = parser.Results.addStarch;
macroType = parser.Results.macroType;
usdaEdition = parser.Results.usdaEdition;
fridaEdition = parser.Results.fridaEdition;
blsEdition = parser.Results.blsEdition;

% Find which databases the suggested food items come from
databasesUsed = {};
namesStruct = fieldnames(foods2Check);
for i = 1:numel(namesStruct)
    databasesUsed = [databasesUsed; lower(foods2Check.(namesStruct{i})(:,3))]; %#ok<AGROW>
end
databasesUsed = unique(databasesUsed);

% Load the food databases once so they do not have to be reloaded by
% getMetaboliteFlux, getDietComposition and getDietEnergy for every food
% item. Only the databases of the suggested food items are loaded.
[fluxTableUsda, fluxTableFrida, fluxTableBLS, foodMacroUsda, foodMacroFrida, foodMacroBLS] = deal([]);
if ismember('usda', databasesUsed)
    fluxTableUsda = load(getNutritionDatabaseFile('usda', '100gFluxValue', usdaEdition)).fluxTableUsda;
    foodMacroUsda = load(getNutritionDatabaseFile('usda', '100gMacros', usdaEdition)).foodMacroUsda;
end
if ismember('frida', databasesUsed)
    fluxTableFrida = load(getNutritionDatabaseFile('frida', '100gFluxValue', fridaEdition)).fluxTableFrida;
    foodMacroFrida = load(getNutritionDatabaseFile('frida', '100gMacros', fridaEdition)).foodMacroFrida;
end
if ismember('bls', databasesUsed)
    fluxTableBLS = load(getNutritionDatabaseFile('bls', '100gFluxValue', blsEdition)).fluxTableBLS;
    foodMacroBLS = load(getNutritionDatabaseFile('bls', '100gMacros', blsEdition)).foodMacroBLS;
end
if strcmp(macroType, 'metabolites')
    % Only needed when the macros are calculated from the metabolites
    nutrientVmhTable = load(getNutritionDatabaseFile('usda', 'infoFile', usdaEdition)).nutrientVmhTable;
    nutrientInfoFileFrida = load(getNutritionDatabaseFile('frida', 'infoFile', fridaEdition)).nutrientInfoFileFrida;
    nutrientInfoFileBLS = load(getNutritionDatabaseFile('bls', 'infoFile', blsEdition)).nutrientInfoFileBLS;

    % Calculate the molecular weights once for the metabolites in the flux
    % tables. Passing the full VMH database to getDietComposition and
    % recalculating the weights for every food item is very slow.
    fluxMets = {};
    for t = {fluxTableUsda, fluxTableFrida, fluxTableBLS}
        if ~isempty(t{1})
            fluxMets = [fluxMets; t{1}.VMHID]; %#ok<AGROW>
        end
    end
    vmhDatabase = loadVMHDatabase;
    vmhMets = vmhDatabase.metabolites;
    vmhMets = vmhMets(ismember(vmhMets(:,1), fluxMets), :);
    metaboliteWeights = table(vmhMets(:,1), vmhMets(:,4), getMolecularMass(vmhMets(:,4)), ...
        'VariableNames', {'VMHID', 'formula', 'molecularWeight'});
end

% Obtain the fieldnames of foods2Check
namesStruct = fieldnames(foods2Check);

% Initialise the storage structures
allFluxes = struct();
allMacros = struct();

for i = 1:size(namesStruct,1)
    
    % Obtain the table with suggested VMH food items
    foodItems = foods2Check.(cell2mat(namesStruct(i)));
    % Remove empty cells
    foodItems(strcmp(foodItems(:,2), ''),:) = [];
        
    for j = 1:size(foodItems,1)
        
        % For each food item obtain the flux and macro distibution
        metFlux = getMetaboliteFlux(foodItems(j,[2 4]), 'databaseType',foodItems(j,3), "addStarch",addStarch, ...
            'fluxTableUsda', fluxTableUsda, 'fluxTableFrida', fluxTableFrida, 'fluxTableBLS', fluxTableBLS, 'foodMacroUsda', foodMacroUsda);
        if strcmp(macroType, 'metabolites')
            macroSamp = getDietComposition(metFlux, "macroType", macroType, ...
                'nutrientVmhTable', nutrientVmhTable, 'nutrientInfoFileFrida', nutrientInfoFileFrida, ...
                'nutrientInfoFileBLS', nutrientInfoFileBLS, 'metaboliteWeights', metaboliteWeights);
        else
            macroSamp = getDietComposition(foodItems(j,[2 4]), "macroType", foodItems(j,3), ...
                'foodMacroUsda', foodMacroUsda, 'foodMacroFrida', foodMacroFrida, 'foodMacroBLS', foodMacroBLS);
        end

        % Obtain the kcal of the food item and store as macro
        energy = getDietEnergy(foodItems(j, [2 4]), 'databaseType', foodItems(j,3), ...
            'foodMacroUsda', foodMacroUsda, 'foodMacroFrida', foodMacroFrida, 'foodMacroBLS', foodMacroBLS);
        % energy = getDietEnergy(metFlux, 'databaseType', 'metabolites');
        macroSamp(end+1, :) = {'Energy (kcal)', energy};
        % Give variablenames to metFlux table
        metFlux = cell2table(metFlux,"VariableNames", {'VMHID', 'Value'});
        
        % Store and merge tables for that are suggested for the same
        % original food item
        if j == 1
            fluxes = metFlux;
            macros = macroSamp;
        else
            fluxes = outerjoin(fluxes, metFlux, "MergeKeys", true, "Keys","VMHID");
            macros = outerjoin(macros, macroSamp, "MergeKeys", true, "Keys","Category");
        end
    end
    
    % Flip the flux and macro tables and store the final table in the
    % relevant structure
    fluxes = rows2vars(fluxes,"VariableNamesSource","VMHID", "VariableNamingRule", 'preserve');
    fluxes.Properties.VariableNames(1) = "FoodItem";
    fluxes(:,1) = foodItems(:,1);
    allFluxes.(cell2mat(namesStruct(i))) = fluxes;

    macros = rows2vars(macros,"VariableNamesSource","Category", "VariableNamingRule", 'preserve');
    macros.Properties.VariableNames(1) = "FoodItem";
    macros(:,1) = foodItems(:,1);
    sortedNames = sort(macros.Properties.VariableNames(2:end));
    macrosSort = [macros(:,1) macros(:,sortedNames)];
    allMacros.(cell2mat(namesStruct(i))) = macrosSort;
end
end