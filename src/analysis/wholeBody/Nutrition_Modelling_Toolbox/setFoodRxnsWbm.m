function [wbm] = setFoodRxnsWbm(wbm, database, resetDietBounds, addPrice)
% Adjusts a WBM so that it can exchange food items and break them down into
% their respective metabolite components. Used to prepare WBMs to accept
% fooditem consumed weights as dietary input.
% Usage:
%   [wbm] = setFoodRxnsWbm(diet, wbm)
% Inputs:
%   diet:   cell array with the databases where food items originated from.
%           the USDA, FRIDA or both databases should be used to add food
%           items on
%   wbm:    A WBM model
%   resetDietBounds : Boolean, indicate if all Diet_EX_ reactions are set
%                     to 0, defaults to true.
%   addPrice:   
% Output:
%  wbm:     An updated WBM model with food exchange and breakdown reactions.
% Example:
%   [wbm] = setFoodRxnsWbm(diet, wbm)
% .. Author - Bram Nap, 04-2025

if nargin<3
    resetDietBounds = true;
end

if nargin <4
    addPrice = {};
end

if resetDietBounds
    % Set all dietary metabolite exchanges to 0
    wbm = changeRxnBounds(wbm, wbm.rxns(contains(wbm.rxns, 'Diet_EX_')), 0, 'b');
end

% If USDA food items are used
if sum(strcmpi(database, 'usda')) > 0
    % Load USDA database
    load('USDA2024_100gFluxValue.mat', 'fluxTableUsda');
    load('USDA2024_100gMacros.mat', 'foodMacroUsda');

    % Check the value for entry "Energy_(KCAL)", nutrient ID 1008
    energyUsda = foodMacroUsda(foodMacroUsda.nutrient_id == 1008,3:end);
    
    % Boolean which food items do not have energy associated with ID 1008
    nanValues = isnan(energyUsda{1,:});

    % Check if nutrient ID 2047 has energy information for NaN values
    energyUsdaAlt = foodMacroUsda(foodMacroUsda.nutrient_id == 2047,3:end);
    % Replace the found NaN values with the values for ID 2047
    energyUsda(1,nanValues) = energyUsdaAlt(1,nanValues);
    
    % Find if there are any left over NaNs
    nanValuesSecond = isnan(energyUsda{1,:});

    % Check if nutrient ID 2048 has energy information
    energyUsdaAlt = foodMacroUsda(foodMacroUsda.nutrient_id == 2048,3:end);
    % Replace the found NaN values with the values for ID 2048
    energyUsda(1,nanValuesSecond) = energyUsdaAlt(1,nanValuesSecond);

    % Find the final NaN values for energy 
    nanValuesFinal = isnan(energyUsda{1,:}); % We might want to remove the 
    % food items associated with this as they can be added "For free" during 
    % the nutrition algorithm and the only reason to model with the food items 
    % at all is i think the nutrition algorithm or to do stuff in that vein.
    
    % Set up the energy table so it can intergrate with the flux table
    energyUsda = [foodMacroUsda(foodMacroUsda.nutrient_id == 1008,2), energyUsda];

    % Obtain the macros for carbohydrates, lipids, protein and sugars
    carbUsda = foodMacroUsda(foodMacroUsda.nutrient_id == 1005,2:end);
    carbUsda{1, carbUsda{1,2:end}<0} = 0; 
    proteinUsda = foodMacroUsda(foodMacroUsda.nutrient_id == 1003,2:end);
    lipidUsda = foodMacroUsda(foodMacroUsda.nutrient_id == 1004,2:end);

    % Find NaNs for lipids
    nanLipids = isnan(lipidUsda{1,2:end});
    
    % Extract and replace the NaNs with lipid macro ID 1085
    lipidUsdaAlt = foodMacroUsda(foodMacroUsda.nutrient_id == 1085,3:end);
    lipidUsda(1,nanLipids) = lipidUsdaAlt(1,nanLipids);
    
    % There are two different sugar macros that do not overlap. We extract
    % them, change the NaNs to 0 and add them together.
    sugar1 = foodMacroUsda(foodMacroUsda.nutrient_id == 1063,3:end);
    sugar1{1,isnan(table2array(sugar1))} = 0;
    sugar2 = foodMacroUsda(foodMacroUsda.nutrient_id == 2000,3:end);
    sugar2{1, isnan(table2array(sugar2))} = 0;   
     
    sugarUsda = [foodMacroUsda(foodMacroUsda.nutrient_id == 1079,2), array2table(table2array(sugar1) + table2array(sugar2), 'VariableNames', sugar1.Properties.VariableNames)];

    % Rename the way macros is named to energy to be able to match with
    % frida
    macros2AddUsda = [energyUsda; carbUsda; proteinUsda; lipidUsda; sugarUsda];
    macros2AddUsda(:,1) = {'energy'; 'carbohydrate'; 'protein'; 'lipid'; 'sugars'};
    
    % Initialise the correct structure to add price as a variable
    pricesUsda = energyUsda;
    % set all the number to 0
    pricesUsda(1, 2:end) = num2cell(zeros([1,size(pricesUsda,2)-1]));
    % Change the first cell to money
    pricesUsda(1,1) = {'money'};

    if ~isempty(addPrice)
        if any(strcmpi(addPrice(:,2), 'usda'))
            addPriceUsda = addPrice(strcmp(addPrice(:,2), 'usda'),:);
            % Find the indexes of the food item IDs in the table and in the
            % addPrice variables that are present in both
            [~, idx1, idx2] = intersect(pricesUsda.Properties.VariableNames, addPriceUsda(:,1));
            % Add the price 
            pricesUsda(1, idx1) = addPriceUsda(idx2, 3);    
        end
    end
    % Add to the macro table that has to be added to the model
    macros2AddUsda = [macros2AddUsda;pricesUsda];

    % Rename first column header to be able to merge with the flux table
    macros2AddUsda.Properties.VariableNames(1) = {'VMHID'};
    % Combine energy table with the flux table
    fluxTableUsda = [fluxTableUsda; macros2AddUsda];

    % Set the usda food items as reactions on the models
    wbm = addFoodSMatrix(wbm, fluxTableUsda, 'usda');
end

% if Frida food items are used
if sum(strcmpi(database, 'frida')) > 0
    % Load Frida database
    load('frida2024_100gFluxValue.mat','fluxTableFrida');
    load('frida2024_100gMacros.mat','foodMacroFrida');
    
    % Find the various macros associated with each food item
    energyFrida = foodMacroFrida(strcmp(foodMacroFrida.macroName, 'Energy, labelling (kcal)'),:);
    carbFrida = foodMacroFrida(strcmp(foodMacroFrida.macroName, 'Carbohydrate by difference'),:);
    proteinFrida = foodMacroFrida(strcmp(foodMacroFrida.macroName, 'Protein'),:);
    lipidFrida = foodMacroFrida(strcmp(foodMacroFrida.macroName, 'Fat'),:);
    sugarFrida = foodMacroFrida(strcmp(foodMacroFrida.macroName, 'Sum sugars'),:);
    
    % Add all macros together for easy manipulation
    macro2AddFrida = [energyFrida; carbFrida; proteinFrida; lipidFrida; sugarFrida];

    % Rename the way kcal is named to energy to be able to match with usda
    macro2AddFrida(:,1) = {'energy'; 'carbohydrate'; 'protein'; 'lipid'; 'sugars'};
    
    % Initialise the correct structure to add price as a variable
    pricesFrida = energyFrida;
    % set all the number to 0
    pricesFrida(1, 2:end) = num2cell(zeros([1,size(pricesFrida,2)-1]));
    % Change the first cell to money
    pricesFrida(1,1) = {'money'};

    if ~isempty(addPrice)
        if any(strcmpi(addPrice(:,2), 'frida'))
            addPriceFrida = addPrice(strcmp(addPrice(:,2), 'frida'),:);
            % Find the indexes of the food item IDs in the table and in the
            % addPrice variables that are present in both
            [~, idx1, idx2] = intersect(pricesFrida.Properties.VariableNames, addPriceFrida(:,1));
            % Add the price 
            pricesFrida(1, idx1) = addPriceFrida(idx2, 3);    
        end
    end
    % Add to the macro table that has to be added to the model
    macro2AddFrida = [macro2AddFrida;pricesFrida];
    
    % Rename first column header to be able to merge with the flux table
    macro2AddFrida.Properties.VariableNames(1) = {'VMHID'};
    % Add the calories to the flux table
    fluxTableFrida = [fluxTableFrida;macro2AddFrida];

    % Set the frida food items as reactions on the models
    wbm = addFoodSMatrix(wbm, fluxTableFrida, 'frida');
end
end

function foodWBM = addFoodSMatrix(model, foodFluxTable, foodSource)
% Code that creates and 
% Usage:
%   [wbm] = setFoodRxnsWbm(diet, wbm)
% Inputs:
%   diet:   Table with the food items that are consumed to see if either
%           the USDA, FRIDA or both databases should be used to add food
%           items on
%   wbm:    A WBM model
% Output:
%  wbm:     An updated WBM model with food exchange and breakdown reactions.
% Example:
%   [wbm] = setFoodRxnsWbm(diet, wbm)
% .. Author - Bram Nap, 05-2024


% Find which metabolites in the food table are not in the model dietary
% compartment and remove them from the food table. Do not include the
% macros in the comparison.
[~,ia] = setdiff(strcat(foodFluxTable.VMHID(1:end-6),'[d]'), model.mets);
foodFluxTable(ia,:) = [];

% Create rxn IDs for the exchange of food items
foodRxn = strcat('Food_EX_', foodFluxTable.Properties.VariableNames(2:end), '_', foodSource)';

% Create the food items as metabolites by setting [f] behind the identifier
foodItemMetabolites = strcat(foodFluxTable.Properties.VariableNames(2:end), '[f]')';
% Add the metabolites measured in the food below the food item matrix to
% create the row identifiers for the to be added S-matrix
metabolitesFromFood = [foodItemMetabolites; strcat(foodFluxTable.VMHID, '[d]')];

% Initialise the S-matrix for the exchange reactions
exchangeRxns = zeros([size(metabolitesFromFood,1), size(foodItemMetabolites,1)]);

% As the first column for the exchange reaction corresponds to the first
% row for the food metabolite we can easily fill in the S-matrix for the
% exchange reactions
for i = 1:size(foodItemMetabolites,1)
    exchangeRxns(i,i) = -1;
end

% Initialise part of the S-matrix to break down food items into their
% metabolite components. Divide by 100 to obtain per 1 gram of food item
breakdownRxnsMatrix = table2array(foodFluxTable(:,2:end))/100;

% Set all the NaNs to 0 to ensure the S-matrix can be used
breakdownRxnsMatrix(isnan(breakdownRxnsMatrix)) = 0;

% Split from the exchange S-matrix only the rows that regard food items and
% put that on top of the break down matrix. This will create a reaction in
% which the food item [f] is broken down into dietary metabolites [d]
breakdownRxnsMatrix = [exchangeRxns(1:size(foodItemMetabolites,1),:) ; breakdownRxnsMatrix];

% Combine the exchange and breakdown matrix
sMatrix = [exchangeRxns, breakdownRxnsMatrix];

% Create the lower bounds, all 0 as we do not exchange any food items and
% the breakdown of food should by irreversible [f]->[d]
lbEx = zeros(size(exchangeRxns,2),1);
lbBreak = zeros(size(breakdownRxnsMatrix,2),1);
lb = [lbEx;lbBreak];

% Create the upper bounds, Exchange reactions are 0 as we do not exchange
% any food items and the breakdown reactions are set to unlimited
ubEx = zeros(size(exchangeRxns,2),1);
ubBreak = zeros(size(breakdownRxnsMatrix,2),1) + 1000000;
ub = [ubEx;ubBreak];

% If the energy[d] and its exhcange reaction are not yet added in the
% model then none of the macros have been added to the model
if ~any(strcmp(model.mets, 'energy[d]'))
    % Create exchange reaction S matrix vector for dietary macros[d]
    indFirstMacro = find(strcmp(metabolitesFromFood, 'energy[d]'));
    for i = 1:(size(metabolitesFromFood,1) - indFirstMacro+1)
        macroExchange = zeros(size(sMatrix,1),1);
        macroExchange(indFirstMacro + (i-1), 1) = -1;
        % Add exchange reaction for macros (e.g., energy[d] ->)
        sMatrix = [sMatrix, macroExchange];
    end
    % Create the final food item reactions
    rxnIDs = [foodRxn; strcat('Breakdown_', foodFluxTable.Properties.VariableNames(2:end),'_', foodSource)'; {'Diet_EX_energy[d]';'Diet_EX_carbohydrate[d]';'Diet_EX_protein[d]';'Diet_EX_lipid[d]';'Diet_EX_sugars[d]'; 'Diet_EX_money[d]'}];

    % Add the novel metabolites to the model
    foodWBM = addMultipleMetabolites(model, [foodItemMetabolites; {'energy[d]'; 'carbohydrate[d]'; 'protein[d]'; 'lipid[d]'; 'sugars[d]'; 'money[d]'}]);
    
    % Add lb of 0 for exchange of dietary macros
    lb = [lb;0;0;0;0;0;0];
    % Add ub of 1000000 for exchange of dietary macros
    ub = [ub;1000000;1000000;1000000;1000000;1000000;1000000];
else
    % If the energy[d] metabolite is already present only add the new food
    % reactions and metabolites
    rxnIDs = [foodRxn; strcat('Breakdown_', foodFluxTable.Properties.VariableNames(2:end),'_', foodSource)'];
    foodWBM = addMultipleMetabolites(model, foodItemMetabolites);
end
% Add the new reactions to the model
foodWBM = addMultipleReactions(foodWBM, rxnIDs, metabolitesFromFood, sMatrix, 'lb', lb, 'ub', ub);
end
