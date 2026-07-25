function [dietFlux] = generateInSilicoDiet(toCreateDiet, varargin)
% Build an in silico diet from an input file and compute its metabolite flux
% vector for use as dietary constraints on whole-body models (WBMs)
%
% Macros are additionally computed from the metabolite flux vector and
% retrieved as reported for the food items, so the fraction of the reported
% macros captured by the measured metabolites can be compared. When the
% original diet macros are provided they are included in the comparison,
% together with the percentage of the total energy contributed by
% carbohydrates, lipids and proteins.
%
% USAGE:
%
%    [dietFlux] = generateInSilicoDiet(toCreateDiet, varargin)
%
% INPUTS:
%    toCreateDiet:          Path to the file (read with readtable) describing
%                           the diets to create. The table has the columns
%                           "originalName" (original food names), "databaseID"
%                           (food item ID in its database) and "databaseUsed"
%                           (which database the alternative was found in); each
%                           subsequent column is a diet whose values (in grams)
%                           give the amount of each food item consumed. The
%                           table `.Properties.VariableNames` are used as the
%                           diet names
%
% OPTIONAL INPUTS:
%    varargin:              Name-value pairs:
%
%                             * outputDir - path to the directory where the
%                               results are stored (default: current directory)
%                             * originalDietMacros - path to the file with the
%                               original macros for each diet; should contain
%                               rows for lipids, carbohydrate, protein and
%                               energy (default '')
%                             * analyseMacros - boolean, whether the macro
%                               analysis is performed (default true)
%                             * addStarch - boolean, whether additional starch
%                               is added based on the reported macros
%                               (default false)
%
% OUTPUT:
%    dietFlux:              Table with the dietary flux (mmol/person/day) for
%                           each diet and the dietary reactions to be set
%
% NOTE:
%    The tutorial folder in the COBRA Toolbox provides template files showing
%    how the data should be formatted; see there for guidance.
%
% .. Author: - Bram Nap, 04-2025


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
    else
        metFlux(end+1, 1:2) = {'Diet_EX_pi[d]', 14};
    end
    
    % If choline is present in less than 5.3 mmol/human/day in the diet it
    % will be set to 5.3mmol/human/day as per the highest recommended intake for humans (
    % EFSA Panel on Dietetic Products, Nutrition and Allergies (NDA), 
    % doi.org/10.2903/j.efsa.2016.4484) to make the WBMs feasible.

    if ~isempty(metFlux(strcmpi(metFlux(:,1), 'diet_ex_chol[d]')))
        if metFlux{strcmpi(metFlux(:,1), 'diet_ex_chol[d]'),2} <= 5.3
            metFlux{strcmpi(metFlux(:,1), 'diet_ex_chol[d]'),2} = 5.3;
        end
    else
        metFlux(end+1, 1:2) = {'Diet_EX_chol[d]', 5.3};
    end
    
    % Manual investigations discovered that menaquinone 7 intake has to be
    % at least 0.1 mmol/human/daay for feasibility
    if ~isempty(metFlux(strcmpi(metFlux(:,1), 'diet_ex_mqn7[d]')))
        if metFlux{strcmpi(metFlux(:,1), 'diet_ex_mqn7[d]'),2} <= 0.1
            metFlux{strcmpi(metFlux(:,1), 'diet_ex_mqn7[d]'),2} = 0.1;
        end
    else
        metFlux(end+1, 1:2) = {'Diet_EX_mqn7[d]', 0.1};
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
        dietMacroLabel = outerjoin(dietMacroLabel, macroLabel, "MergeKeys", true, "Keys","Category");
    end
end

% Save the flux diets and the two macro tables.
writetable(dietFlux, strcat(saveDir, filesep, 'fluxDiets.csv'));
writetable(dietMacroMets, strcat(saveDir, filesep, 'macrosCalculatedFromMetabolites.csv'));
writetable(dietMacroLabel, strcat(saveDir, filesep, 'macrosAsReported.csv'));

if analyseMacros
    % Extract macro information for the metabolites and the labels
    lipids = [dietMacroLabel{strcmpi(dietMacroLabel.Category, 'lipids'),2:end}', dietMacroMets{strcmpi(dietMacroMets.Category, 'lipids'),2:end}'];
    carbohydrates = [dietMacroLabel{strcmpi(dietMacroLabel.Category, 'carbohydrates'),2:end}', dietMacroMets{strcmpi(dietMacroMets.Category, 'carbohydrates'),2:end}'];
    protein = [dietMacroLabel{strcmpi(dietMacroLabel.Category, 'proteins'),2:end}', dietMacroMets{strcmpi(dietMacroMets.Category, 'proteins'),2:end}'];
    sugars = [dietMacroLabel{strcmpi(dietMacroLabel.Category, 'sugar'),2:end}', dietMacroMets{strcmpi(dietMacroMets.Category, 'sugar'),2:end}'];
    energy = [dietMacroLabel{strcmpi(dietMacroLabel.Category, 'energy'),2:end}', dietMacroMets{strcmpi(dietMacroMets.Category, 'energy'),2:end}'];

    % Set the legend labels
    legendLabel = {'{\it in silico} macros', 'Metabolite coverage'};

    % If the original macro composition is provided add as well
    if ~isempty(originalDietMacros)
        lipids = [originalDietMacros{strcmpi(originalDietMacros.Macros, 'totallipid(g)'),2:end}', lipids];
        carbohydrates = [originalDietMacros{strcmpi(originalDietMacros.Macros, 'totalcarbohydrate(g)'),2:end}', carbohydrates];
        protein = [originalDietMacros{strcmpi(originalDietMacros.Macros, 'totalprotein(g)'),2:end}', protein];
        sugars = [originalDietMacros{strcmpi(originalDietMacros.Macros, 'totalsugar(g)'),2:end}', sugars];
        energy = [originalDietMacros{strcmpi(originalDietMacros.Macros, 'totalenergy(kcal)'),2:end}', energy];

        % Add a new label to the legend
        legendLabel = [{'Original macros'}, legendLabel];
    end

    % Make figure
    % Set the tiled layout - 5 horizontal barcharts
    fig = figure('Position',[571,171,809,682]);
    
    tiledlayout(5,1);
    % Initialise the axis for the figure
    ax1 = nexttile;
    % Create the bar chart
    bar(categorical(dietMacroLabel.Properties.VariableNames(2:end)), lipids);
    % Add the title
    title(ax1, 'Comparison of lipids between the original and in silico diets')
    % Add axis
    ylabel(ax1, 'Lipids (g)')
    % Add figure label
    text(0.025,ax1.YAxis.Limits(2)+0.1*ax1.YAxis.Limits(2), 'A)')

    ax2 = nexttile;
    bar(categorical(dietMacroLabel.Properties.VariableNames(2:end)), carbohydrates);
    title(ax2, 'Comparison of carbohydrates between the original and in silico diets')
    ylabel(ax2, 'Carbohydrates (g)')
    text(0.025,ax2.YAxis.Limits(2)+0.2*ax2.YAxis.Limits(2), 'B)')

    ax3 = nexttile;
    bar(categorical(dietMacroLabel.Properties.VariableNames(2:end)), protein);
    title(ax3, 'Comparison of protein between the original and in silico diets')
    ylabel(ax3, 'Protein (g)')
    text(0.025,ax3.YAxis.Limits(2)+0.1*ax3.YAxis.Limits(2), 'C)')

    ax4 = nexttile;
    bar(categorical(dietMacroLabel.Properties.VariableNames(2:end)), sugars);
    title(ax4, 'Comparison of sugars between the original and in silico diets')
    ylabel(ax4, 'Sugar (g)')
    text(0.025,ax4.YAxis.Limits(2)+0.1*ax4.YAxis.Limits(2), 'D)')

    ax5 = nexttile;
    bar(categorical(dietMacroLabel.Properties.VariableNames(2:end)), energy);
    title(ax5, 'Comparison of energy between the original and in silico diets')
    ylabel(ax5, 'Energy (kcal)')
    text(0.025,ax5.YAxis.Limits(2)+0.1*ax5.YAxis.Limits(2), 'E)')

    % Add a single legend as it is the same for all plots and adjust the
    % position.
    lgnd = legend(legendLabel, 'Orientation','horizontal');

    lgnd.Position(1) = 0.25;
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
