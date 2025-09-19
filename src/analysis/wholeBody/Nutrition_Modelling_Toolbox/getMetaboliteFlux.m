function [metFlux] = getMetaboliteFlux(diet, varargin)
% This function takes a diet consisting of food items and returns the
% associated flux of metabolites.
%
% USAGE:
%   [metFlux] = getMetaboliteFlux(diet)
%
% INPUT:
%   diet:   an nx2 cell array consisting of n dietary/food components and
%           their corresponding flux in grams (for food items) or mmol (for
%           individual metabolites) per day.
%
% Optional input:
%   databaseType:   Which database should be used, either fdtable or usda.
%                   Corresponds to an inhouse table or the USDA foodData
%                   database. Defaults to usda
%   addStarch:      Boolean wether or not additional starch should be added
%                   to the flux vector when it is not measured in the macros
%
% OUTPUT:
%   metFlux: returns an nx2 cell array containing a list of all n metabolites
%            within the diet and the corresponding flux.
%
% AUTHORS:
%   Bronson R. Weston 2022
%   Bram Nap, 05-2024 - Added on functionality to work with the FoodData
%   central database and add on missing starch functionalities. Removed
%   FdTable functionality.
%   02-2025 added Frida database functionality and mixed database
%   calculations

% Parse inputs
parser = inputParser();
parser.addRequired('diet', @iscell);
parser.addParameter('databaseType', 'usda', @(x)ischar(x)||iscell(x));
parser.addParameter('addStarch', false,@islogical);

parser.parse(diet, varargin{:});

diet = parser.Results.diet;
databaseType = parser.Results.databaseType;
addStarch = parser.Results.addStarch;
%%
% Split, if present, the different databases
usdaItems = diet(strcmp(databaseType,'usda'),:);

fridaItems = diet(strcmp(databaseType,'frida'),:);

%Sum any duplicate entries in diet
if size(unique(usdaItems(:,1)),1) ~= size(usdaItems,1)
    fprintf('The same food ID has been found in the diet. Adding the consumed weights together');
    summedDiet = groupsummary(cell2table(usdaItems),1,"sum");
    usdaItems = [summedDiet{:,1},num2cell(summedDiet{:,3})];
end

if size(unique(string(fridaItems(:,1))),1) ~= size(fridaItems,1)
    fprintf('The same food ID has been found in the diet. Adding the consumed weights together');
    summedDiet = groupsummary(cell2table(fridaItems),1,"sum");
    fridaItems = [summedDiet{:,1},num2cell(summedDiet{:,3})];
end

if ~isempty(usdaItems)
    % Load the flux values per 100g of food items
    foodTableUsda = load('USDA2024_100gFluxValue.mat').fluxTableUsda;
    % Calculate the metabolite flux
    metFluxUsda = generateFluxFromItem(usdaItems, foodTableUsda, addStarch, 'usda');
end

if ~isempty(fridaItems)
    % Load the flux values per 100g of food items
    foodTableFrida = load('frida2024_100gFluxValue.mat').fluxTableFrida;
    % Calculate the metabolite flux, never add additional starch for frida
    metFluxFrida = generateFluxFromItem(fridaItems, foodTableFrida, 0, 'frida');
end

% If metFluxFrida and metFluxUsda are both filled, combine them
if ~isempty(fridaItems) && ~isempty(usdaItems)
    % Obtain indexes of common metabolites
    [~, idFrida, idUsda] = intersect(metFluxFrida(:,1), metFluxUsda(:,1));

    % Obtain the unique metabolites for the databases
    uniqueFrida = metFluxFrida;
    uniqueFrida(idFrida,:) = [];

    uniqueUsda = metFluxUsda;
    uniqueUsda(idUsda,:) = [];

    % Extract the flux values for the common metabolites
    commonValuesFrida = cell2mat(metFluxFrida(idFrida,2));
    commonValuesUsda = cell2mat(metFluxUsda(idUsda,2));

    % Create final flux array by adding to common flux values and appending
    % the uniques
    metFlux = [metFluxFrida(idFrida,1), num2cell(commonValuesUsda + commonValuesFrida)];
    metFlux = [metFlux;uniqueFrida;uniqueUsda];

    % If either usda or frida does not have any items treat the one that does
    % as the final output.
elseif ~isempty(fridaItems) && isempty(usdaItems)
    metFlux = metFluxFrida;
else
    metFlux = metFluxUsda;
end

end

function metFlux = generateFluxFromItem(foodItems, foodTable, addStarch, database)
% Function to calculte the flux value from food items based on a database
%
% USAGE:
%   metFlux = generateFluxFromItem(foodItems, foodTable, addStarch)
%
% INPUT:
%   foodItems:  an nx2 cell array consisting of n dietary/food components and
%               their corresponding flux in grams (for food items) or mmol (for
%               individual metabolites) per day.
%   foodTable:  Table with column headers food items and the rows
%               metabolite. we assume it to be /100g of fooditem
%   addStarch:  Boolean, indicate if additional starch has to be added
%               based on macronutrient composition.
%   database:   Character: Database to be used for adding on additional starch
%
% OUTPUT:
%   metFlux: returns an nx2 cell array containing a list of all n metabolites
%            within the diet and the corresponding flux.
%
% AUTHORS:
%   Bram Nap, 02-2025

% obtain the food and metabolite names
foodTableItems = foodTable.Properties.VariableNames;
foodMetabolites= foodTable.VMHID;

%Convert Table into Numerical Matrix
sMatrix=table2array(foodTable(1:length(foodMetabolites),2:end));
% convert values into /1g of food item
sMatrix = sMatrix/100;
% NaNs set to 0
sMatrix(isnan(sMatrix))=0;
%Convert Diet flux values from string to numeric if necessary
for i=1:length(foodItems(:,2))
    if ischar(foodItems{i,2})
        foodItems{i,2}=str2num(foodItems{i,2});
    elseif double(foodItems{i,2})<0
        error(['diet position' num2str(i) 'has invalid flux input'])
    end
    if ~ischar(foodItems{i,1})
        foodItems{i,1} = num2str(foodItems{i,1});
    end
end

foodOnly = foodItems(:,1);
%If no food items are present, return
if isempty(foodOnly)
    metFlux=foodOnly;
    return
end

% Obtain the indexes of all the food items corresponding to their
% location in the matrix
ind=zeros(1,length(foodOnly));
for i=1:length(foodOnly)
    ind(i)=find(strcmp(foodTableItems, foodOnly(i)));
end

%Calculate flux for all food items. ind-1 because the first when finding
%the indexes the first column header was included which is not present in
%the sMatrix.
metFlux=[foodTable.VMHID,num2cell(sMatrix(:,ind-1)*cell2mat(foodItems(:,2)))];

% Adjust metabolite names so it can be used to contrains WBMs
metFlux(:,1)=strcat('Diet_EX_',metFlux(:,1));
metFlux(:,1)=strcat(metFlux(:,1),'[d]');

if addStarch
    % Find the base starch flux value from the computed diet
    initialStarch = metFlux{strcmp(metFlux(:,1), 'Diet_EX_starch1200[d]'),2};
    % Find how much starch has to be added that was not previously
    % given or measured
    starch2add = addExtraStarch(foodItems, database);
    if iscell(starch2add)
        % Convert to mmols and add to the initial starch flux value
        starch2addAdj = cell2mat(starch2add(:,2)) /194.4814 .* cell2mat(foodItems(:,2));
        starch2addAdj = sum(starch2addAdj);
        totStarchAdd = starch2addAdj + initialStarch;
        metFlux{strcmp(metFlux(:,1), 'Diet_EX_starch1200[d]'),2} = totStarchAdd;
    end
end
end

function [starch2Add] = addExtraStarch(foodItem, database)
% An optional function that will found out how much starch is missing from
% a food item if it is not measured. It calculates the amount of starch
% missing by starch = carbohydrates - sugars - fibers. If one of the three
% marcros (carbohydrates, sugars or fibers) is not measured the added
% starch will be 0 as we cannot calculate the amount of missing starch.
%
% USAGE:
%   [starch2Add] = addExtraStarch(foodItem)
% Input:
%   foodItem:   An array or table (n x m) where the first column is the
%               food IDs as found in the USDA FoodData database
% Output:
%   starch2Add: A nx2 cell array that contains the amount of added starch
%               in grams per 1 gram of each food ID
% Example:
%   [starch2Add] = addExtraStarch(foodItem)
% .. Author - Bram Nap, 05-2024

% Load the macro table as macroTable
if strcmpi(database, 'usda')
    load("USDA2024_100gMacros.mat", "foodMacroUsda");

    % Initialise the output structure and store the food item IDs in the first
    % column
    starch2Add = cell(size(foodItem,1), 2);
    starch2Add(:,1) = foodItem(:,1);

    for i = 1:size(foodItem,1)
        % Obtain the single food item ID
        food = foodItem(i);
        % Obtain the specific measured macro composition
        macrosSpef =  [foodMacroUsda.nutrient_id ,foodMacroUsda.(food{1})];
        % Check if starch is measured. Done by looking at nutrient ID 1009
        if ~isnan(macrosSpef(macrosSpef == 1009 ,2))
            % If starch is measured set the to add starch for the item to 0
            starch2AddItem = 0;
        else
            % If starch is not measure obtain the total carbohydrates of the
            % food, Done by looking at nutrient ID 1005
            totCarb = macrosSpef(macrosSpef == 1005 ,2);

            if totCarb > 0
                % Check if the sugars are measured by looking at nutrient ID
                % 1063 or nutrient ID 2000. Due to an update in the USDA
                % FoodDacata database both IDs were used for total sugars by
                % different food items
                if ~isnan(macrosSpef(macrosSpef == 1063 ,2))
                    sugars = macrosSpef(macrosSpef == 1063 ,2);
                elseif ~isnan(macrosSpef(macrosSpef == 2000 ,2))
                    sugars = macrosSpef(macrosSpef == 2000 ,2);
                else
                    % If neither 1063 or 2000 have a value, we assume that the
                    % total sugars are not measured and set it to NaN
                    sugars = NaN;
                end

                % Check if the fibers are measured by looking at nutrient ID
                % 1079 or nutrient ID 2033. Due to an update in the USDA
                % FoodDacata database both IDs were used for total sugars by
                % different food items
                if ~isnan(macrosSpef(macrosSpef == 1079 ,2))
                    fiber = macrosSpef(macrosSpef == 1079 ,2);
                elseif ~isnan(macrosSpef(macrosSpef == 2033 ,2))
                    fiber = macrosSpef(macrosSpef == 2033 ,2);
                else
                    % If neither 1079 or 2033 have a value, we assume that the
                    % total fibers are not measured and set it to NaN
                    fiber = NaN;
                end

                % If carbohydrates, fibers and sugars are measured we calculate
                % the total missing starch
                if ~isnan(totCarb) && ~isnan(fiber) && ~isnan(sugars)
                    starch2AddItem = totCarb - sugars - fiber;
                else
                    % If any macro is not measured we put the starch to add to
                    % 0 as we cannot make an estimation
                    starch2AddItem = 0;
                end
            else
                % If the carbohydrate content is < 0 there cannot be any starch
                % that has to be added
                starch2AddItem = 0;
            end

            % Sanity check in case the subtraction produces a negative number,
            % set it to 0
            if starch2AddItem < 0
                starch2AddItem = 0;
            end
        end
        % Add the starch to be added to the food item it was tested for. Divide
        % the amount by 100 to have it per 1 gram of the food item
        starch2Add{i,2} = starch2AddItem/100;
    end
else
    fprintf('Used incorrect database for to find additional starch. Use usda. Frida database has information on starch content already')
    starch2Add = 'incorrect database';
end

end