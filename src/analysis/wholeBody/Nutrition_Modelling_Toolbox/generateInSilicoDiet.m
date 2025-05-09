function [dietFlux] = generateInSilicoDiet(toCreateDiet, varargin)
% Code to take the input and creates a in silico diet. It calculates the
% metabolite flux vector that can be set as dietary constraints on the
% WBMs. Additionaly it calculates the macros from the metabolite flux
% vector and retrieves the macros as reported for the various food items.
% This way a comparison can be made to see how much of measured metabolites
% reflect the reported macros. If the macros for the original diets are
% given, they are taken along in the comparison. A calculation on the % of
% how much carbohydrates/lipids/proteins are contributing to the total
% energy of the diet.
% Usage:
%   [dietFlux] = generateInSilicoDiet(toCreateDiet, varargin)
% Inputs:
%   toCreateDiet:       Path to the file with the diets that need to be
%                       created. consist of column "originalName" where the
%                       orignal food names are set. "databaseID" the ID of
%                       the fooditem in their database. "databaseUsed"
%                       which database was used to find that database
%                       alternative. Each column after is a diet where the
%                       values in gram show the food items consumed for
%                       each diet.   
% Optional input:
%   outputDir:          Path to the directory where the results should be
%                       stored. Defaults to ''.
%   originalDietMacros: Path to the file with the original macros for each
%                       diet. Should contain the rows lipids,
%                       carbohydrate, protein and energy. Defaults to ''.
%   analyseMacros:      Boolean, indicates if analysis on macros should be
%                       performed. Defaults to true.
%   addStarch:          Boolean, indicates if additional starch should be
%                       added based on the reported macros. Defaults to
%                       false.
% Output:
%  dietFlux:            Table, contains the dietary flux in mmol/person/day
%                       for each diet and the dietary reactions that have
%                       to be set.
% Example:
%   [vmhFood] = calculateFoodScore(originalFood, 'outputDir', outputDir)
% Note:
%   The tutorial folder on the COBRA toolbox provides various template
%   files with the structure of how the data should be formatted. Please
%   look there for guidance.
% .. Author - Bram Nap, 04-2025


% Parse the inputs
parser = inputParser();
parser.addRequired('toCreateDiet', @ischar);
parser.addParameter('outputDir', pwd,@ischar);
parser.addParameter('originalDietMacros', '',@ischar);
parser.addParameter('analyseMacros', true, @islogical);
parser.addParameter('addStarch', false, @islogical);

parser.parse(toCreateDiet, varargin{:});

toCreateDiet = parser.Results.toCreateDiet;
outputDir = parser.Results.outputDir;
originalDietMacros = parser.Results.originalDietMacros;
analyseMacros = parser.Results.analyseMacros;
addStarch = parser.Results.addStarch;

%%
% Load in the diets to analyse
toCreateDiet = readtable(toCreateDiet);

% if given load the original diets
if ~isempty(originalDietMacros)
    originalDietMacros = readtable(originalDietMacros);
end

% Initialise the save directory for the in silico diets and analyses
saveDir = strcat(outputDir, filesep, 'inSilicoDiet');
% Make the directory if it does not exist yet
if ~exist(saveDir,"dir")
    mkdir(saveDir);
end

% Calculate the metabolite composition of the diets
for i = 4:size(toCreateDiet,2)
    % Obtain the diet specific values
    diet2Make = toCreateDiet(:, [1:3, i]);

    % Calculate the diet flux vector
    metFlux = getMetaboliteFlux(table2cell(diet2Make(:,[2 4])), 'databaseType',diet2Make.databaseUsed, "addStarch",addStarch);

    % Calculate the macros from the metabolite flux vector and from the
    % measured/reported (label) macros
    macroMets = getDietComposition(metFlux, "macroType", 'metabolites');
    macroMets.Properties.VariableNames(2) = toCreateDiet.Properties.VariableNames(i);
    macroLabel = getDietComposition(table2cell(diet2Make(:,[2 4])), "macroType", diet2Make.databaseUsed);
    macroLabel.Properties.VariableNames(2) = toCreateDiet.Properties.VariableNames(i);

    % Obtain the energy based on the food items and based on the
    % metabolites from the diet
    energyLabel = getDietEnergy(table2cell(diet2Make(:,[2 4])), 'databaseType', diet2Make.databaseUsed);
    energyMets = getDietEnergy(metFlux, 'databaseType', 'metabolites');

    % Add energy to macro tables
    macroMets(end+1,:) = {'Energy', energyMets};
    macroLabel(end+1,:) = {'Energy', energyLabel};

    % If phosphate is 0 set to 10 mmol/human/day this is
    % required as without phosphate (pi) WBMs will not be feasible.
    % If phosphate is not in the diet, it will be added automatically by
    % setDietConstraints. (Crook, Hally and Panteli, 2001. PMID:11448586)
    if ~isempty(metFlux(strcmpi(metFlux(:,1), 'diet_ex_pi[d]')))
        if metFlux{strcmpi(metFlux(:,1), 'diet_ex_pi[d]'),2} == 0
            metFlux{strcmpi(metFlux(:,1), 'diet_ex_pi[d]'),2} = 14;
        end
    end

    % Convert the dietary flux vector to a table
    metFlux = cell2table(metFlux,"VariableNames", [{'VMHID'}; toCreateDiet.Properties.VariableNames(i)]);
    metFlux.(toCreateDiet.Properties.VariableNames{i}) = string(metFlux.(toCreateDiet.Properties.VariableNames{i}));

    % Merge tables togehter
    if i == 4
        dietFlux = metFlux;
        dietMacroMets = macroMets;
        dietMacroLabel = macroLabel;
    else
        dietFlux = outerjoin(dietFlux, metFlux, "MergeKeys", true, "Keys","VMHID");
        dietMacroMets = outerjoin(dietMacroMets, macroMets, "MergeKeys", true, "Keys","Category");
        dietMacroLabel = outerjoin(dietMacroLabel, macroMets, "MergeKeys", true, "Keys","Category");
    end
end

% Save the flux diets and the two macro tables.
writetable(dietFlux, strcat(saveDir, filesep, 'fluxDiets.csv'));
writetable(dietMacroMets, strcat(saveDir, filesep, 'macrosCalculatedFromMetabolites.csv'));
writetable(dietMacroLabel, strcat(saveDir, filesep, 'macrosAsReported.csv'));

if analyseMacros
    % Extract macro information for the metabolites and the labels
    lipids = [dietMacroMets{strcmpi(dietMacroMets.Category, 'lipids'),2:end}', dietMacroLabel{strcmpi(dietMacroLabel.Category, 'lipids'),2:end}'];
    carbohydrates = [dietMacroMets{strcmpi(dietMacroMets.Category, 'carbohydrates'),2:end}', dietMacroLabel{strcmpi(dietMacroLabel.Category, 'carbohydrates'),2:end}'];
    protein = [dietMacroMets{strcmpi(dietMacroMets.Category, 'proteins'),2:end}', dietMacroLabel{strcmpi(dietMacroLabel.Category, 'proteins'),2:end}'];
    sugars = [dietMacroMets{strcmpi(dietMacroMets.Category, 'sugar'),2:end}', dietMacroLabel{strcmpi(dietMacroLabel.Category, 'sugar'),2:end}'];
    energy = [dietMacroMets{strcmpi(dietMacroMets.Category, 'energy'),2:end}', dietMacroLabel{strcmpi(dietMacroLabel.Category, 'energy'),2:end}'];

    % Set the legend labels
    legendLabel = {'Metabolite-derived Macros', 'Measured Macros'};

    % If the original macro composition is provided add as well
    if ~isempty(originalDietMacros)
        lipids = [lipids, originalDietMacros{strcmpi(originalDietMacros.Macros, 'totallipid(g)'),2:end}'];
        carbohydrates = [carbohydrates,originalDietMacros{strcmpi(originalDietMacros.Macros, 'totalcarbohydrate(g)'),2:end}'];
        protein = [protein, originalDietMacros{strcmpi(originalDietMacros.Macros, 'totalprotein(g)'),2:end}'];
        sugars = [sugars, originalDietMacros{strcmpi(originalDietMacros.Macros, 'totalsugar(g)'),2:end}'];
        energy = [energy, originalDietMacros{strcmpi(originalDietMacros.Macros, 'totalenergy(kcal)'),2:end}'];

        % Add a new label to the legend
        legendLabel = [legendLabel, {'Original Macros'}];
    end

    % Make figure
    % Set the tiled layout - 5 horizontal barcharts
    fig = tiledlayout(5,1);
    % Initialise the axis for the figure
    ax1 = nexttile;
    % Create the bar chart
    bar(dietMacroLabel.Properties.VariableNames(2:end), lipids);
    % Add the title
    title(ax1, 'Comparison of lipids between the original and in silico diets')
    % Add axis
    ylabel(ax1, 'Total lipids (g)')

    ax2 = nexttile;
    bar(dietMacroLabel.Properties.VariableNames(2:end), carbohydrates);
    title(ax2, 'Comparison of carbohydrates between the original and in silico diets')
    ylabel(ax2, 'Total carbohydrates (g)')

    ax3 = nexttile;
    bar(dietMacroLabel.Properties.VariableNames(2:end), protein);
    title(ax3, 'Comparison of protein between the original and in silico diets')
    ylabel(ax3, 'Total protein (g)')

    ax4 = nexttile;
    bar(dietMacroLabel.Properties.VariableNames(2:end), sugars);
    title(ax4, 'Comparison of sugars between the original and in silico diets')
    ylabel(ax4, 'Total sugar (g)')

    ax5 = nexttile;
    bar(dietMacroLabel.Properties.VariableNames(2:end), energy);
    title(ax5, 'Comparison of energy between the original and in silico diets')
    ylabel(ax5, 'Total energy (kcal)')
    
    % Add a single legend as it is the same for all plots and adjust the
    % position.
    lgnd = legend(legendLabel, 'Orientation','horizontal');

    lgnd.Position(1) = 0.39;
    lgnd.Position(2) = 0.05;

    % Save figure
    exportgraphics(fig, strcat(outputDir, filesep, 'macroComparison.png'));

    % Calculate the % energy generated from the varous macros
    energyLipidFrac = (lipids*7)./energy;
    energyCarbFrac = (carbohydrates*4)./energy;
    energyProteinFrac = (protein*4)./energy;

    % Store the energy fractions in a table
    finalEnergyFrac = array2table([energyLipidFrac,energyCarbFrac, energyProteinFrac, energy]);

    % Add column with the diet names to the energy fraction table
    allDietNames = toCreateDiet.Properties.VariableNames(4:end)';
    finalEnergyFrac = [cell2table(allDietNames), finalEnergyFrac];

    % Initialise and set the column headers
    if ~isempty(originalDietMacros)
        columnHeaders = {'dietName',...
            'metLipidFraction', 'labelLipidFraction','originalLipidFraction',...
            'metCarbFraction','labelCarbFraction','originalCarbFraction', ...
            'metProteinFraction','labelProteinFraction','originalProteinFraction',...
            'metTotalEnergy', 'labelTotalEnergy', 'originalTotalEnergy'};
    else
        columnHeaders = {'dietName',...
            'metLipidFraction', 'labelLipidFraction',...
            'metCarbFraction','labelCarbFraction', ...
            'metProteinFraction','labelProteinFraction',...
            'metTotalEnergy', 'labelTotalEnergy'};
    end
    % Save the final table
    finalEnergyFrac.Properties.VariableNames = columnHeaders;
    writetable(finalEnergyFrac, strcat([saveDir, filesep, 'energyFractionPerMacro.csv']));

end
end
