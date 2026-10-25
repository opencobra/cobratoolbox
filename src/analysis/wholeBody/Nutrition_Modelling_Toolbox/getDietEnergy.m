function [calories] = getDietEnergy(diet, varargin)
% Compute the number of calories in a diet given as an n x 2 cell array of
% diet components and serving sizes, or as a metabolite flux list
%
% USAGE:
%
%    [calories] = getDietEnergy(diet, varargin)
%
% INPUTS:
%    diet:            An n x 2 cell array of diet components with the grams of
%                     food eaten, or the dietary flux names with their flux
%                     values
%
% OPTIONAL INPUTS:
%    varargin:        Name-value pairs:
%
%                       * databaseType - char or cell array selecting how the
%                         calories are obtained: 'metabolites' (from the flux
%                         values), 'usda', 'frida' or 'bls' for all food
%                         items, or a cell array with the database of each
%                         food item (default 'usda')
%                       * foodMacroUsda - table, pre-loaded foodMacroUsda from
%                         USDA<YEAR>_100gMacros.mat (default [], loaded from
%                         file when needed)
%                       * foodMacroFrida - table, pre-loaded foodMacroFrida
%                         from frida<YEAR>_100gMacros.mat (default [], loaded
%                         from file when needed)
%                       * nutrientVmhTable - table, pre-loaded nutrientVmhTable
%                         from usda<YEAR>_infoFile.mat (default [], loaded from
%                         file when needed)
%                       * nutrientInfoFileFrida - table, pre-loaded
%                         nutrientInfoFileFrida from frida<YEAR>_infoFile.mat
%                         (default [], loaded from file when needed)
%                       * usdaEdition - char or numeric, four-digit year of
%                         the USDA database edition loaded from file. If empty
%                         the latest available edition is used (default '')
%                       * fridaEdition - char or numeric, four-digit year of
%                         the Frida database edition loaded from file. If
%                         empty the latest available edition is used
%                         (default '')
%                       * foodMacroBLS - table, pre-loaded foodMacroBLS from
%                         BLS<YEAR>_100gMacros.mat (default [], loaded from
%                         file when needed)
%                       * nutrientInfoFileBLS - table, pre-loaded
%                         nutrientInfoFileBLS from BLS<YEAR>_infoFile.mat
%                         (default [], loaded from file when needed)
%                       * blsEdition - char or numeric, four-digit year of
%                         the BLS database edition loaded from file. If empty
%                         the latest available edition is used (default '')
%                       * metaboliteWeights - table with the variables VMHID,
%                         formula and molecularWeight (g/mol, as given by
%                         getMolecularMass) for the VMH metabolites. When not
%                         given, the formulas are obtained with
%                         loadVMHDatabase and the weights are calculated
%                         (default [])
%
% OUTPUT:
%    calories:        Total amount of calories from the input
%
% .. Authors:
% ..    - Bronson Weston, 2022
% ..    - Bram Nap, 05-2024 - added functionality for calculating from
% ..      metabolites and from the USDA FoodData database; removed the fdTable
% ..      functionality and added Frida database functionality

% Parse results
parser = inputParser();
parser.addRequired('diet', @iscell);
parser.addParameter('databaseType', 'usda',@(x)ischar(x)||iscell(x));
parser.addParameter('foodMacroUsda', [], @(x)istable(x)||isempty(x));
parser.addParameter('foodMacroFrida', [], @(x)istable(x)||isempty(x));
parser.addParameter('nutrientVmhTable', [], @(x)istable(x)||isempty(x));
parser.addParameter('nutrientInfoFileFrida', [], @(x)istable(x)||isempty(x));
parser.addParameter('metaboliteWeights', [], @(x)istable(x)||isempty(x));
parser.addParameter('usdaEdition', '', @(x)ischar(x)||isstring(x)||isnumeric(x));
parser.addParameter('fridaEdition', '', @(x)ischar(x)||isstring(x)||isnumeric(x));
parser.addParameter('foodMacroBLS', [], @(x)istable(x)||isempty(x));
parser.addParameter('nutrientInfoFileBLS', [], @(x)istable(x)||isempty(x));
parser.addParameter('blsEdition', '', @(x)ischar(x)||isstring(x)||isnumeric(x));

parser.parse(diet, varargin{:});

diet = parser.Results.diet;
databaseType = parser.Results.databaseType;
foodMacroUsda = parser.Results.foodMacroUsda;
foodMacroFrida = parser.Results.foodMacroFrida;
nutrientVmhTable = parser.Results.nutrientVmhTable;
nutrientInfoFileFrida = parser.Results.nutrientInfoFileFrida;
metaboliteWeights = parser.Results.metaboliteWeights;
usdaEdition = parser.Results.usdaEdition;
fridaEdition = parser.Results.fridaEdition;
foodMacroBLS = parser.Results.foodMacroBLS;
nutrientInfoFileBLS = parser.Results.nutrientInfoFileBLS;
blsEdition = parser.Results.blsEdition;

if ischar(databaseType) && strcmp(databaseType, 'metabolites')
    % Load metabolite category tables if not given as input
    if isempty(nutrientVmhTable)
        load(getNutritionDatabaseFile('usda', 'infoFile', usdaEdition), "nutrientVmhTable")
    end
    if isempty(nutrientInfoFileFrida)
        load(getNutritionDatabaseFile('frida', 'infoFile', fridaEdition), "nutrientInfoFileFrida");
    end
    if isempty(nutrientInfoFileBLS)
        load(getNutritionDatabaseFile('bls', 'infoFile', blsEdition), "nutrientInfoFileBLS");
    end
    nutrientVmhTable = nutrientVmhTable(nutrientVmhTable.metBool ==1,:);
    nutrientInfoFileFrida = nutrientInfoFileFrida(nutrientInfoFileFrida.metBool==1,:);
    nutrientInfoFileBLS = nutrientInfoFileBLS(nutrientInfoFileBLS.metBool==1,:);

    % Combine the three and extract the unique values
    metInfo = [nutrientVmhTable.vmhID,nutrientVmhTable.macroCategory;
        nutrientInfoFileFrida.vmhID, nutrientInfoFileFrida.macroCategory;
        nutrientInfoFileBLS.vmhID, nutrientInfoFileBLS.macroCategory];
    [~, uniqueIdx] = unique(metInfo(:,1));
    metInfo = metInfo(uniqueIdx, :);

    % Use the same category names for the info files (Fibre/Fiber,
    % Protein/Proteins)
    metInfo(:,2) = strrep(metInfo(:,2), 'Fibre', 'Fiber');
    metInfo(strcmp(metInfo(:,2), 'Protein'),2) = {'Proteins'};

    % Remove not in VMH from metInfo
    metInfo(~isValidVmhID(metInfo(:,1)),:) = [];

    if isempty(metaboliteWeights)
        % Obtain the metabolite information from the VMH database
        vmhDatabase = loadVMHDatabase;
        metaboliteData = cell2table(vmhDatabase.metabolites);

        % Extract the metabolite formulas of metabolites. Metabolites that
        % are not in the VMH database get no weight (NaN).
        [found, metidx] = ismember(metInfo(:,1), metaboliteData.Var1);
        formulas = repmat({''}, size(metInfo,1), 1);
        formulas(found) = metaboliteData.Var4(metidx(found));

        % Obtain the molecular mass from the formulas in grams/mol
        mws = nan(size(metInfo,1), 1);
        mws(found) = getMolecularMass(formulas(found));
    else
        % Obtain the formulas and pre-calculated molecular masses in grams/mol
        [found, metidx] = ismember(metInfo(:,1), metaboliteWeights.VMHID);
        formulas = repmat({''}, size(metInfo,1), 1);
        formulas(found) = metaboliteWeights.formula(metidx(found));
        mws = nan(size(metInfo,1), 1);
        mws(found) = metaboliteWeights.molecularWeight(metidx(found));
    end

    % Add molecular weights for cobalt and nickel. Assign each ion
    % independently so that a diet containing only one of them (or neither)
    % does not cause a size-mismatch error.
    cobalt = 58.93319;
    nickel = 58.693;

    mws(strcmp(formulas, 'Co')) = cobalt;
    mws(strcmp(formulas, 'Ni')) = nickel;

    for i=1:size(diet,1)

        % Set the amount of calories/g for each metabolite category
        met = diet{i,1};
        met = strrep(met, 'Diet_EX_','');
        met = strrep(met, '[d]','');

        energyCatIdx = strcmp(metInfo(:,1), met);
        if any(energyCatIdx)
            category = metInfo{energyCatIdx,2};
        else
            category = 'Other';
        end

        if strcmp(category, 'Lipids')
            cal = 9; %kcal/g
        elseif strcmp(category, 'Carbohydrates')
            cal = 4; %kcal/g
        elseif strcmp(category, 'Sugar')
            cal = 4; %kcal/g
        elseif strcmp(category,'Proteins')
            cal = 4; %kcal/g
        elseif strcmp(category,'Starch')
            cal = 4; %kcal/g
        elseif strcmp(category,'Fiber')
            cal = 4; %kcal/g
        elseif strcmp(category,'Alcohol')
            cal = 7; %kcal/g
        elseif strcmp(category,'Other')
            cal=0;
        else
            cal = 0;
        end

        % Calculate the amount of calories of the metabolite by converting
        % it to g from mmol and subsequently to kcal. Metabolites without
        % calories are skipped so that a missing weight does not matter.
        if cal == 0
            diet{i,3} = 0;
            continue
        end
        metWeight = diet{i,2}*mws(strcmp(metInfo(:,1),met))/1000; % mmol * (g/mol)
        if isnan(metWeight)
            warning('No molecular weight is available for %s, its calories are not counted.', met)
            metWeight = 0;
        end
        totalCal = metWeight * cal; % g *kcal/g
        diet{i,3} = totalCal;
    end
    % Save the result
    calories = sum(cell2mat(diet(:,3)));

else
    % Obtain the database of each food item. A single database name applies
    % to all food items.
    if ischar(databaseType) || isstring(databaseType)
        databaseType = repmat(cellstr(databaseType), size(diet,1), 1);
    end
    databaseType = lower(cellstr(databaseType(:)));
    unknownDatabase = ~ismember(databaseType, {'usda', 'frida', 'bls'});
    if any(unknownDatabase)
        error('Unknown database(s): %s. Please use usda, frida, bls or metabolites.', strjoin(unique(databaseType(unknownDatabase))', ', '))
    end

    % Obtain the items per database
    usdaItems = diet(strcmp(databaseType,'usda'),:);
    fridaItems = diet(strcmp(databaseType,'frida'),:);
    blsItems = diet(strcmp(databaseType,'bls'),:);

    %Sum any duplicate entries in the diet
    if size(unique(string(blsItems(:,1))),1) ~= size(blsItems,1)
        fprintf('The same food ID has been found in the diet. Adding the consumed weights together');
        summedDiet = groupsummary(cell2table(blsItems),1,"sum");
        blsItems = [summedDiet{:,1},num2cell(summedDiet{:,3})];
    end

    %Sum any duplicate entries in the diet
    if size(unique(string(usdaItems(:,1))),1) ~= size(usdaItems,1)
        fprintf('The same food ID has been found in the diet. Adding the consumed weights together');
        summedDiet = groupsummary(cell2table(usdaItems),1,"sum");
        usdaItems = [summedDiet{:,1},num2cell(summedDiet{:,3})];
    end

    %Sum any duplicate entries in the diet
    if size(unique(string(fridaItems(:,1))),1) ~= size(fridaItems,1)
        fprintf('The same food ID has been found in the diet. Adding the consumed weights together');
        summedDiet = groupsummary(cell2table(fridaItems),1,"sum");
        fridaItems = [summedDiet{:,1},num2cell(summedDiet{:,3})];
    end

    % Initialise energy variable
    energy = 0;

    if ~isempty(usdaItems)
        % Load the macro table from the USDA fooddata central database if
        % not given as input
        if isempty(foodMacroUsda)
            load(getNutritionDatabaseFile('usda', '100gMacros', usdaEdition), "foodMacroUsda");
        end
        % initialise the energy variable
        energy = 0;
        for i = 1:size(usdaItems,1)
            % Obtain the kcal for the food item
            macrosItem = foodMacroUsda.(string(usdaItems{i,1}));

            % Check the value for entry "Energy_(KCAL)", nutrient ID 1008
            idx = foodMacroUsda.nutrient_id == 1008;

            totCal = macrosItem(idx);
            if isnan(totCal)
                % If it cannot be found with the first try, try other macros
                % with the same information. Nutrient IDs 2047 or 2048
                idx = foodMacroUsda.nutrient_id == 2047;
                totCal = macrosItem(idx);
                if isnan(totCal)
                    idx = foodMacroUsda.nutrient_id == 2048;
                    totCal = macrosItem(idx);
                end
            end
            % If the calories for a fooditem as NaN set it to 0 and warn the
            % user
            if isnan(totCal)
                totCal = 0;
                warning(strcat('The following USDA food ID does not seem to have a KCAL assocatiated with it. Please take note:', string(usdaItems{i,1})));
            end
            % Divide the calories for each food item by 100 to get it /1g of
            % food item and multiply by the amount of food eaten
            spefCal = (totCal/100) * usdaItems{i,2};
            % Calculate the total amount of calories from the input
            energy = energy + spefCal;
        end
    end
    if ~isempty(fridaItems)
        % Load the frida macro database if not given as input
        if isempty(foodMacroFrida)
            load(getNutritionDatabaseFile('frida', '100gMacros', fridaEdition), "foodMacroFrida");
        end

        for i = 1:size(fridaItems,1)
            % Obtain the kcal for the food item
            macrosItemFrida = foodMacroFrida.(string(fridaItems{i,1}));
            idx = strcmp(foodMacroFrida.macroName, 'Energy, labelling (kcal)');
            totCal = macrosItemFrida(idx);

            % If the calories for a fooditem as NaN set it to 0 and warn the
            % user
            if isnan(totCal)
                totCal = 0;
                warning(strcat('The following FRIDA food ID does not seem to have a KCAL assocatiated with it. Please take note:', string(fridaItems{i,1})));
            end
            
            % Divide the calories for each food item by 100 to get it /1g of
            % food item and multiply by the amount of food eaten
            spefCal = (totCal/100) * fridaItems{i,2};
            % Calculate the total amount of calories from the input
            energy = energy + spefCal;
        end
    end
    if ~isempty(blsItems)
        % Load the BLS macro database if not given as input
        if isempty(foodMacroBLS)
            load(getNutritionDatabaseFile('bls', '100gMacros', blsEdition), "foodMacroBLS");
        end

        % Energy in kcal, component code ENERCC
        idx = strcmp(foodMacroBLS.componentCode, 'ENERCC');
        for i = 1:size(blsItems,1)
            % Obtain the kcal for the food item
            totCal = foodMacroBLS.(string(blsItems{i,1}))(idx);

            % If the calories for a fooditem as NaN set it to 0 and warn the
            % user
            if isnan(totCal)
                totCal = 0;
                warning(strcat('The following BLS food ID does not seem to have a KCAL assocatiated with it. Please take note:', string(blsItems{i,1})));
            end

            % Divide the calories for each food item by 100 to get it /1g of
            % food item and multiply by the amount of food eaten
            energy = energy + (totCal/100) * blsItems{i,2};
        end
    end
    calories = energy;
end

