function [dietComposition] = getDietComposition(input, varargin)
% Take a diet (or a whole-body model) and identify the food macros
%
% USAGE:
%
%    [dietComposition] = getDietComposition(input, varargin)
%
% INPUT:
%    input:              Either a whole-body metabolic model (struct) or a
%                        diet given as an n x 2 cell array of items and amounts
%
% OPTIONAL INPUTS:
%    varargin:           Name-value pairs:
%
%                          * macroType - which data are used to compute the
%                            macros; accepted values are 'metabolites',
%                            'usda', 'frida' and 'bls' for all items, or a
%                            cell array with the database of each food item
%                            (default 'metabolites')
%                          * foodMacroUsda - table, pre-loaded foodMacroUsda
%                            from USDA<YEAR>_100gMacros.mat (default [], loaded
%                            from file when needed)
%                          * foodMacroFrida - table, pre-loaded foodMacroFrida
%                            from frida<YEAR>_100gMacros.mat (default [], loaded
%                            from file when needed)
%                          * nutrientVmhTable - table, pre-loaded
%                            nutrientVmhTable from usda<YEAR>_infoFile.mat
%                            (default [], loaded from file when needed)
%                          * nutrientInfoFileFrida - table, pre-loaded
%                            nutrientInfoFileFrida from frida<YEAR>_infoFile.mat
%                            (default [], loaded from file when needed)
%                          * usdaEdition - char or numeric, four-digit year of
%                            the USDA database edition loaded from file. If
%                            empty the latest available edition is used
%                            (default '')
%                          * fridaEdition - char or numeric, four-digit year
%                            of the Frida database edition loaded from file.
%                            If empty the latest available edition is used
%                            (default '')
%                          * foodMacroBLS - table, pre-loaded foodMacroBLS from
%                            BLS<YEAR>_100gMacros.mat (default [], loaded
%                            from file when needed)
%                          * nutrientInfoFileBLS - table, pre-loaded
%                            nutrientInfoFileBLS from BLS<YEAR>_infoFile.mat
%                            (default [], loaded from file when needed)
%                          * blsEdition - char or numeric, four-digit year of
%                            the BLS database edition loaded from file. If
%                            empty the latest available edition is used
%                            (default '')
%                          * metaboliteWeights - table with the variables
%                            VMHID, formula and molecularWeight (g/mol, as
%                            given by getMolecularMass) for the VMH
%                            metabolites. When not given, the formulas are
%                            obtained with loadVMHDatabase and the weights are
%                            calculated (default [])
%
% OUTPUT:
%    dietComposition:    Table with the breakdown of the diet macros, giving
%                        the macro categories and their mass in grams
%
% .. Authors:
% ..    - Bronson R. Weston, 2021-2022
% ..    - Bram Nap, 05-2024 - added functionality for computing composition
% ..      from metabolites and from the USDA FoodData Central reported macros;
% ..      removed the fdTable functionality

parser = inputParser();
parser.addRequired('input', @iscell);
parser.addParameter('macroType', 'metabolites', @(x)ischar(x)||iscell(x));
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

parser.parse(input, varargin{:});

input = parser.Results.input;
macroType = parser.Results.macroType;
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
    % Load metabolite category tables if not given as input
    if isempty(nutrientInfoFileFrida)
        load(getNutritionDatabaseFile('frida', 'infoFile', fridaEdition), "nutrientInfoFileFrida");
    end
    if isempty(nutrientVmhTable)
        load(getNutritionDatabaseFile('usda', 'infoFile', usdaEdition), "nutrientVmhTable");
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

    % Convert the metabolite names so they can be identified
    input(:,1) = strrep(input(:,1), 'Diet_EX_', '');
    input(:,1) = strrep(input(:,1), '[d]', '');

    % Find the macro they are associated with with the combTable
    [~,idx] = ismember(input(:,1), metInfo(:,1));

    if isempty(metaboliteWeights)
        % Obtain the metabolite information from the VMH database
        vmhDatabase = loadVMHDatabase;
        metaboliteData = cell2table(vmhDatabase.metabolites);

        % Extract the metabolite formalas of metabolites. Metabolites that
        % are not in the VMH database get no weight (NaN).
        [found, metidx] = ismember(input(:,1), metaboliteData.Var1);
        formulas = repmat({''}, size(input,1), 1);
        formulas(found) = metaboliteData.Var4(metidx(found));

        % Obtain the molecular mass from the formulas in gram/mol
        mws = nan(size(input,1), 1);
        mws(found) = getMolecularMass(formulas(found));
    else
        % Obtain the formulas and pre-calculated molecular masses in gram/mol
        [found, metidx] = ismember(input(:,1), metaboliteWeights.VMHID);
        formulas = repmat({''}, size(input,1), 1);
        formulas(found) = metaboliteWeights.formula(metidx(found));
        mws = nan(size(input,1), 1);
        mws(found) = metaboliteWeights.molecularWeight(metidx(found));
    end

    % Add molecular weights for cobalt and nickel. Assign each ion
    % independently so that a diet containing only one of them (or neither)
    % does not cause a size-mismatch error.
    % in gram/mol as the other molecular masses
    cobalt = 58.93319;
    nickel = 58.693;

    mws(strcmp(formulas, 'Co')) = cobalt;
    mws(strcmp(formulas, 'Ni')) = nickel;

    % Calculate the amount of grams based on the molecular weights and flux
    % value
    % For metabolites that are not in the VMH database, use the molecular
    % weights (average, g/mol) of the Frida and BLS info files if available
    if any(isnan(mws))
        infoWeights = cell(0, 2);
        for infoTable = {nutrientInfoFileFrida, nutrientInfoFileBLS}
            if any(strcmp(infoTable{1}.Properties.VariableNames, 'molecularMass'))
                infoWeights = [infoWeights; infoTable{1}.vmhID, num2cell(infoTable{1}.molecularMass)]; %#ok<AGROW>
            end
        end
        [inInfo, infoIdx] = ismember(input(:,1), infoWeights(:,1));
        fillWeight = isnan(mws) & inInfo;
        mws(fillWeight) = cell2mat(infoWeights(infoIdx(fillWeight), 2));
    end

    molMass = cell2mat(input(:,2)).*mws; % mmol/mol/g = mg
    molMass = molMass/1000; % convert to g
    % Metabolites without a molecular weight are not counted
    noWeight = isnan(molMass) & cell2mat(input(:,2)) ~= 0;
    if any(noWeight)
        warning('No molecular weight is available for %s, their mass is not counted.', strjoin(input(noWeight,1)', ', '))
    end
    molMass(isnan(molMass)) = 0;
    % Store for usage later
    metaboliteCategories = metInfo(:,2);
    mets = input(:,1);
    Macros=zeros(10,1);

else
    % Temp variable - later to fix to allow for a diet containing both food
    % items and metabolites.
    molMass = {};

    % Obtain the database of each food item. A single database name applies
    % to all food items.
    if ischar(macroType) || isstring(macroType)
        macroType = repmat(cellstr(macroType), size(input,1), 1);
    end
    macroType = lower(cellstr(macroType(:)));
    unknownDatabase = ~ismember(macroType, {'usda', 'frida', 'bls'});
    if any(unknownDatabase)
        error('Unknown macroType(s): %s. Please use metabolites, usda, frida or bls.', strjoin(unique(macroType(unknownDatabase))', ', '))
    end

    % Obtain the items per database
    usdaItems = input(strcmp(macroType,'usda'),:);
    fridaItems = input(strcmp(macroType,'frida'),:);
    blsItems = input(strcmp(macroType,'bls'),:);

    %Sum any duplicate entries in diet
    if size(unique(string(blsItems(:,1))),1) ~= size(blsItems,1)
        fprintf('The same food ID has been found in the diet. Adding the consumed weights together');
        summedDiet = groupsummary(cell2table(blsItems),1,"sum");
        blsItems = [summedDiet{:,1},num2cell(summedDiet{:,3})];
    end

    %Sum any duplicate entries in diet
    if size(unique(string(usdaItems(:,1))),1) ~= size(usdaItems,1)
        fprintf('The same food ID has been found in the diet. Adding the consumed weights together');
        summedDiet = groupsummary(cell2table(usdaItems),1,"sum");
        usdaItems = [summedDiet{:,1},num2cell(summedDiet{:,3})];
    end

    %Sum any duplicate entries in diet
    if size(unique(string(fridaItems(:,1))),1) ~= size(fridaItems,1)
        fprintf('The same food ID has been found in the diet. Adding the consumed weights together');
        summedDiet = groupsummary(cell2table(fridaItems),1,"sum");
        fridaItems = [summedDiet{:,1},num2cell(summedDiet{:,3})];
    end

    if ~isempty(usdaItems)
        % When the predefined macros are wanted from the USDA FoodData
        % database
        % Load the macros database if not given as input
        if isempty(foodMacroUsda)
            load(getNutritionDatabaseFile('usda', '100gMacros', usdaEdition), "foodMacroUsda");
        end

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
        % Load the macroDatabase if not given as input
        if isempty(foodMacroFrida)
            load(getNutritionDatabaseFile('frida', '100gMacros', fridaEdition), "foodMacroFrida");
        end
        
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

    if ~isempty(blsItems)
        % Load the macroDatabase if not given as input
        if isempty(foodMacroBLS)
            load(getNutritionDatabaseFile('bls', '100gMacros', blsEdition), "foodMacroBLS");
        end

        for k = 1:size(blsItems,1)
            % Obtain the macros of the food item and convert NaNs to 0
            macrosBLS = foodMacroBLS.(string(blsItems{k,1}));
            macrosBLS(isnan(macrosBLS)) = 0;
            % Divide by 100 to get per 1 g of fooditem and multiply by the
            % amount of food eaten
            macrosBLS = (macrosBLS/100) * cell2mat(blsItems(k,2));
            % Add all macros from the input together
            if k == 1
                totMacrosBLS = macrosBLS;
            else
                totMacrosBLS = totMacrosBLS + macrosBLS;
            end
        end
        % Assign macros to their categories as used in the script by their
        % BLS component codes
        macroBLS = @(code) totMacrosBLS(strcmp(foodMacroBLS.componentCode, code));
        macroTableBLS = [macroBLS('ASH'), macroBLS('CHO'), macroBLS('PROT625'), macroBLS('FAT'), 0, ...
            macroBLS('WATER'), macroBLS('ALC'), macroBLS('STARCH'), macroBLS('FIBT'), macroBLS('SUGAR')]';
    end

    % Combine the macro tables of the databases
    Macros = zeros(10,1);
    if ~isempty(usdaItems)
        Macros = Macros + macroTableUsda;
    end
    if ~isempty(fridaItems)
        Macros = Macros + macroTableFrida;
    end
    if ~isempty(blsItems)
        Macros = Macros + macroTableBLS;
    end
end

%Identify food item categories

Categories={'Vitamins/Minerals/Elements','Carbohydrates','Proteins','Lipids','Other', 'Water', 'Alcohol', 'Starch', 'Fiber', 'Sugar'};

for i=1:length(molMass)
    if strcmp(macroType, 'metabolites')
        molMassInd=find(strcmp(metInfo(:,1),mets{i}));
        if ~isempty(molMassInd)
            cat=metaboliteCategories{molMassInd};
        else
            % Metabolite is not in the categorisation tables. Default to
            % 'Other' rather than silently inheriting the previous
            % iteration's category (which made the result order-dependent).
            cat = 'Other';
        end
    else
        cat = 'Other';
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
