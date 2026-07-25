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

parser.parse(foods2Check, foodNames, varargin{:});

foods2Check = parser.Results.foods2Check;
addStarch = parser.Results.addStarch;
macroType = parser.Results.macroType;

% Obtain the fieldnames of foods2Check
namesStruct = fieldnames(foods2Check);

% Initialise the storage structures
allFluxes = struct();
allMacros = struct();

for i = 1:size(namesStruct,1)
    
    % Obtain the table with suggested VMH food items
    foodItems = foods2Check.(cell2mat(namesStruct(i)));
    % Remove empty cells
    foodItems(strcmp(foodItems, '')) = [];
        
    for j = 1:size(foodItems,1)
        
        % For each food item obtain the flux and macro distibution
        metFlux = getMetaboliteFlux(foodItems(j,[2 4]), 'databaseType',foodItems(j,3), "addStarch",addStarch);
        if strcmp(macroType, 'metabolites')
            macroSamp = getDietComposition(metFlux, "macroType", macroType);
        else
            macroSamp = getDietComposition(foodItems(j,[2 4]), "macroType", foodItems(j,3));
        end
        
        % Obtain the kcal of the food item and store as macro
        energy = getDietEnergy(foodItems(j, [2 4]), 'databaseType', foodItems(j,3));
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