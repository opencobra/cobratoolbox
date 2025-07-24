function [dietComposition] = getDietComposition(input, varargin)
% This function takes a diet (or a model) and identifies the food macros
%
% USAGE:
%   [Macros,Categories] = getDietComposition(input)
%
% INPUT:
%   input: either a whole-body metabolic model or a diet
%
% OPTIONAL INPUT
%   macroType:  Which type of data is used to calculate macros. Currently
%               accepted is fdtable, metabolites and usda
%
% OUTPUT:
%   dietComposition: A table containing the breakdown of the diet macros
%
% AUTHORS:
%   Bronson R. Weston 2021-2022
%   Bram Nap 05-2024 - added additional functionilty for getting
%   composition when the input are metabolites and when the USDA fooddata
%   central database reported macros are wanting to be used. Removed
%   fdTable functionality.

parser = inputParser();
parser.addRequired('input', @iscell);
parser.addParameter('macroType', 'metabolites', @(x)ischar(x)||iscell(x));

parser.parse(input, varargin{:});

input = parser.Results.input;
macroType = parser.Results.macroType;
%%

%Returns macros in grams
if isstruct(input) %If input is a model
    model=input;
    foodRxns=find(contains(model.rxns,'Food_EX_'));
    foodRxns=foodRxns(model.lb(foodRxns)<0);
    foodFlux=[];
    foodItems={};
    if length(foodRxns)>0
        foodItems = regexprep(model.rxns(foodRxns),'Food_EX_','');
        foodItems = regexprep(foodItems,'\[d\]','');
        foodFlux = -1*(model.ub(foodRxns)+model.lb(foodRxns))/2;
    end
    input=[foodItems,num2cell(foodFlux)];
    macroType = 'metabolites';
end

if strcmpi(macroType, 'metabolites')
    % Load metabolite category tables
    load('frida2024_infoFile.mat', "nutrientInfoFileFrida");
    nutrientVmhTable = nutrientVmhTable(nutrientVmhTable.metBool ==1,:);
    nutrientInfoFileFrida = nutrientInfoFileFrida(nutrientInfoFileFrida.metBool==1,:);
    % Combine the two and extract the unique values
    metInfo = [nutrientVmhTable.vmhID,nutrientVmhTable.macroCategory;
        nutrientInfoFileFrida.vmhID, nutrientInfoFileFrida.macroCategory];
    
    [~, uniqueIdx] = unique(metInfo(:,1));

    metInfo = metInfo(uniqueIdx, :);

    % Convert the metabolite names so they can be identified
    input(:,1) = strrep(input(:,1), 'Diet_EX_', '');
    input(:,1) = strrep(input(:,1), '[d]', '');

    % Find the macro they are associated with with the combTable
    [~,idx] = ismember(input(:,1), metInfo(:,1));

    % Obtain the metabolite information from the VMH database
    vmhDatabase = loadVMHDatabase;
    metaboliteData = cell2table(vmhDatabase.metabolites);

    % Extract the metabolite formalas of metabolites
    [~, metidx] = ismember(input(:,1), metaboliteData.Var1);
    formulas = metaboliteData.Var4(metidx);

    % Obtain the molecular mass from the formulas in gram/mol
    mws = getMolecularMass(formulas);

    % Add molecular weights for cobalt and nickel
    cobalt = 58.93319/1000;
    nickel = 58.693/1000;

    [~,~,spefidx] = intersect({'Co', 'Ni'}, formulas, 'stable');
    mws(spefidx) = [cobalt, nickel];

    % Calculate the amount of grams based on the molecular weights and flux
    % value
    molMass = cell2mat(input(:,2)).*mws; % mmol/mol/g = mg
    molMass = molMass/1000; % convert to g
    % Store for usage later
    metaboliteCategories = metInfo(:,2);
    mets = input(:,1);
    Macros=zeros(10,1);

else
    % Temp variable - later to fix to allow for a diet containing both food
    % items and metabolites.
    molMass = {};

    % Obtain the items per database
    usdaItems = input(strcmp(macroType,'usda'),:);
    fridaItems = input(strcmp(macroType,'frida'),:);

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

    if ~isempty(usdaItems)
        % When the predefined macros are wanted from the USDA FoodData
        % database
        % Load the macros database
        load("USDA2024_100gMacros.mat","foodMacroUsda");

        for k = 1:size(usdaItems,1)
            % For each food item find the food ID (should be the in column 1 in
            % the input)
            foodNumberUsda = string(usdaItems{k,1});
            % Obtain the macros and convert NaNs to 0
            macrosUsda = foodMacroUsda.(foodNumberUsda);
            macrosUsda(isnan(macrosUsda)) = 0;
            % Divide by 100 to get per 1 g of fooditem and multiply by the
            % amount of food eaten
            macrosUsda = (macrosUsda/100) * cell2mat(usdaItems(k,2));
            % Add all macros from the input together
            if k == 1
                totMacrosUsda = macrosUsda;
            else
                totMacrosUsda = totMacrosUsda + macrosUsda;
            end
        end

        % Assign macros to their categories as used in the script
        Vitamins = totMacrosUsda(foodMacroUsda.nutrient_id == 1007);
        Carbs = totMacrosUsda(foodMacroUsda.nutrient_id == 1005);
        Proteins = totMacrosUsda(foodMacroUsda.nutrient_id == 1003);
        % For lipids if 1004 is not 0 (presumed NaN) take 1085. Adding does
        % not work as in cases we will get 2x the amount of fat. If no fat
        % 1085 will also be 0.
        if totMacrosUsda(foodMacroUsda.nutrient_id == 1004) ~= 0
            Lipids = totMacrosUsda(foodMacroUsda.nutrient_id == 1004);
        else
            Lipids = totMacrosUsda(foodMacroUsda.nutrient_id == 1085);
        end
        Other = 0;
        Water = totMacrosUsda(foodMacroUsda.nutrient_id == 1051);
        Sugars = totMacrosUsda(foodMacroUsda.nutrient_id == 1063) + totMacrosUsda(foodMacroUsda.nutrient_id == 2000);
        Starch = totMacrosUsda(foodMacroUsda.nutrient_id == 1009);
        Alcohol = totMacrosUsda(foodMacroUsda.nutrient_id == 1018);
        Fiber = totMacrosUsda(foodMacroUsda.nutrient_id == 1079) + totMacrosUsda(foodMacroUsda.nutrient_id == 2033);

        % Create the full macro table
        macroTableUsda = [Vitamins, Carbs, Proteins, Lipids, Other, Water, Alcohol, Starch, Fiber, Sugars]';
    end

    if ~isempty(fridaItems)
        % Load the macroDatabase
        load("frida2024_100gMacros.mat","foodMacroFrida");
        
        for k = 1:size(fridaItems,1)
            % For each food item find the food ID (should be the in column 1 in
            % the input)
            foodNumberFrida = string(fridaItems{k,1});
            % Obtain the macros and convert NaNs to 0
            macrosFrida = foodMacroFrida.(foodNumberFrida);
            macrosFrida(isnan(macrosFrida)) = 0;
            % Divide by 100 to get per 1 g of fooditem and multiply by the
            % amount of food eaten
            macrosFrida = (macrosFrida/100) * cell2mat(fridaItems(k,2));
            % Add all macros from the input together
            if k == 1
                totMacrosFrida = macrosFrida;
            else
                totMacrosFrida = totMacrosFrida + macrosFrida;
            end
        end
        % Assign macros to their categories as used in the script
        Vitamins = totMacrosFrida(strcmp(foodMacroFrida.macroName,'Ash'));
        Carbs = totMacrosFrida(strcmp(foodMacroFrida.macroName,'Carbohydrate by difference'));
        Proteins = totMacrosFrida(strcmp(foodMacroFrida.macroName,'Protein'));
        Lipids = totMacrosFrida(strcmp(foodMacroFrida.macroName,'Fat'));
        Other = 0;
        Water = totMacrosFrida(strcmp(foodMacroFrida.macroName,'Water'));
        Sugars = totMacrosFrida(strcmp(foodMacroFrida.macroName,'Sum sugars'));
        Starch = totMacrosFrida(strcmp(foodMacroFrida.macroName,'Starch/Glycogen'));
        Alcohol = totMacrosFrida(strcmp(foodMacroFrida.macroName,'Alcohol'));
        Fiber = totMacrosFrida(strcmp(foodMacroFrida.macroName,'Dietary fibre'));

        % Create the full macro table
        macroTableFrida = [Vitamins, Carbs, Proteins, Lipids, Other, Water, Alcohol, Starch, Fiber, Sugars]';
    end

    if ~isempty(fridaItems) && ~isempty(usdaItems)
    % if both databases present combine the macro table
    Macros = macroTableFrida + macroTableUsda;
    elseif ~isempty(fridaItems) && isempty(usdaItems)
        Macros = macroTableFrida;
    else
        Macros = macroTableUsda;
    end
end

%Identify food item categories

Categories={'Vitamins/Minerals/Elements','Carbohydrates','Proteins','Lipids','Other', 'Water', 'Alcohol', 'Starch', 'Fiber', 'Sugar'};

for i=1:length(molMass)
    if strcmp(macroType, 'metabolites')
        molMassInd=find(strcmp(metInfo(:,1),mets{i}));
        cat=metaboliteCategories{molMassInd};
    end

    switch cat
        case 'Lipids'
            Macros(4)=Macros(4)+molMass(i);
        case 'Sugar'
            Macros(2)=Macros(2)+molMass(i);
            Macros(10)=Macros(10)+molMass(i);
        case 'Fiber'
            Macros(2)=Macros(2)+molMass(i);
            Macros(9)=Macros(9)+molMass(i);
        case 'Starch'
            Macros(2)=Macros(2)+molMass(i);
            Macros(8)=Macros(8)+molMass(i);
        case 'Carbohydrates'
            Macros(2)=Macros(2)+molMass(i);
        case 'Proteins'
            Macros(3)=Macros(3)+molMass(i);
        case 'Minerals and trace elements'
            Macros(1)=Macros(1)+molMass(i);
        case 'Vitamins'
            Macros(1)=Macros(1)+molMass(i);
        case 'Other'
            Macros(5)=Macros(5)+molMass(i);
        case 'Water'
            Macros(6)=Macros(6)+molMass(i);
        case 'Alcohol'
            Macros(7)=Macros(7)+molMass(i);
    end
end

% Create the output variable
dietComposition=table(Categories.',Macros,'VariableNames',{'Category', 'Mass (g)'});
end
