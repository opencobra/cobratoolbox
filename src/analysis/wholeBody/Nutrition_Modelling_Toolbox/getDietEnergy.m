function [calories] = getDietEnergy(diet, varargin)
% Given a nx2 cell array of diet components and serving sizes or metabolite
% list, computes how many calories are in the diet.
%
% Usage:
%   [calories] = getDietEnergy(diet, varargin)
%
% Inputs:
%   diet:       A nx2 array of diet components and the grams of food eaten
%               or the dietary flux names with the flux values
%
% Optional inputs:
%   databaseType:   Character or cell array. Which method should be used to
%                   obtain calories. Options are metabolite (based on flux
%                   values) or database (cell array with 'usda' or 'frida' for
%                   each food item to be checked)
%
% Output:
%   calories:   Amount of calories from the input
%
% Example:
%
%
% .. Authors    Bronson Weston - 2022
%               Bram Nap, 05-2024 - Added functionality for calculating
%               from metabolites and from the USDA fooddata database.
%               Removed fdTable functionality added Frida datbase functionality.

% Parse results
parser = inputParser();
parser.addRequired('diet', @iscell);
parser.addParameter('databaseType', 'usda',@(x)ischar(x)||iscell(x));

parser.parse(diet, varargin{:});

diet = parser.Results.diet;
databaseType = parser.Results.databaseType;

if strcmp(databaseType, 'metabolites')
    % Load metabolite category tables
    load("usda2vmhInfoFile.mat", "usda2vmhInfoFile");
    load('frida2024_infoFile.mat', "nutrientInfoFileFrida");
    usda2vmhInfoFile = usda2vmhInfoFile(usda2vmhInfoFile.metBool ==1,:);
    nutrientInfoFileFrida = nutrientInfoFileFrida(nutrientInfoFileFrida.metBool==1,:);

    % Combine the two and extract the unique values
    metInfo = [usda2vmhInfoFile.vmhID,usda2vmhInfoFile.macroCategory;
        nutrientInfoFileFrida.vmhID, nutrientInfoFileFrida.macroCategory];
    [~, uniqueIdx] = unique(metInfo(:,1));
    metInfo = metInfo(uniqueIdx, :);

    % Remove not in VMH from metInfo
    metInfo(strcmpi(metInfo(:,1), 'not in vmh'),:) = [];

    % Obtain the metabolite information from the VMH database
    vmhDatabase = loadVMHDatabase;
    metaboliteData = cell2table(vmhDatabase.metabolites);

    % Extract the metabolite formalas of metabolites
    [~, metidx] = ismember(metInfo(:,1), metaboliteData.Var1);
    formulas = metaboliteData.Var4(metidx);

    % Obtain the molecular mass from the formulas in gram/mol
    mws = getMolecularMass(formulas);

    % Add molecular weights for cobalt and nickel
    cobalt = 58.93319;
    nickel = 58.693;

    [~,~,spefidx] = intersect({'Co', 'Ni'}, formulas, 'stable');
    mws(spefidx) = [cobalt, nickel];

    for i=1:size(diet,1)

        % Set the amount of calories/g for each metabolite category
        met = diet{i,1};
        met = strrep(met, 'Diet_EX_','');
        met = strrep(met, '[d]','');

        category = metInfo{strcmp(metInfo(:,1),met),2};

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
        % it to g from mmol and subsequently to kcal.
        metWeight = diet{i,2}*mws(strcmp(metInfo(:,1),met))/1000; % mmol * (g/mol)
        totalCal = metWeight * cal; % g *kcal/g
        diet{i,3} = totalCal;
    end
    % Save the result
    calories = sum(cell2mat(diet(:,3)));

else
    % Obtain the items per database
    usdaItems = diet(strcmp(databaseType,'usda'),:);
    fridaItems = diet(strcmp(databaseType,'frida'),:);

    %Sum any duplicate entries in diet
    if size(unique(usdaItems(:,1)),1) ~= size(usdaItems,1)
        fprintf('The same food ID has been found in the diet. Adding the consumed weights together');
        summedDiet = groupsummary(cell2table(usdaItems),1,"sum");
        usdaItems = [summedDiet{:,1},num2cell(summedDiet{:,3})];
    end

    %Sum any duplicate entries in diet
    if size(unique(fridaItems(:,1)),1) ~= size(fridaItems,1)
        fprintf('The same food ID has been found in the diet. Adding the consumed weights together');
        summedDiet = groupsummary(cell2table(fridaItems),1,"sum");
        fridaItems = [summedDiet{:,1},num2cell(summedDiet{:,3})];
    end

    % Initialise energy variable
    energy = 0;

    if ~isempty(usdaItems)
        % Load the macro table from the USDA fooddata central database
        load("USDA2024_100gMacros.mat", "foodMacroUsda");
        % initalise the energy variable
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
            % food item and mulitply by the amount of food eaten
            spefCal = (totCal/100) * usdaItems{i,2};
            % Caculate the total amount of calories from the input
            energy = energy + spefCal;
        end
    end
    if ~isempty(fridaItems)
        % Load the frida macro database
        load("frida2024_100gMacros.mat","foodMacroFrida");

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
            % food item and mulitply by the amount of food eaten
            spefCal = (totCal/100) * fridaItems{i,2};
            % Caculate the total amount of calories from the input
            energy = energy + spefCal;
        end
    end
    calories = energy;
end

