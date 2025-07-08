function generateStackedBarPlot_PhylumMARScoverage(input_relAbundances_preMapping, input_relAbundances_postMapping, saveDir, varargin)
% Generates stacked bar plots from mean relative abundances of phyla pre- &
% post-mapping to a model-database in MARS.
%
% INPUTS:
%   input_relAbundances_preMapping:     [chars/string] Path to table which contains phyla taxa and their
%                                       mean relative abundances across samples pre-mapped to a model-database 
%                                       (original dataset). This spreadsheet is a standard output generated in MARS.
%   input_relAbundances_postMapping:    [chars/string] Path to table which contains phyla taxa and their
%                                       mean relative abundances across samples post-mapped to a model-database 
%                                       (filtered dataset). This spreadsheet is a standard output generated in MARS.
%   saveDir:                            [chars/string] Path to the
%                                       directory where the stacked bar plot should be saved.
%   mappingDatabase_name:               [chars/string] The name of the model-database used for
%                                       mapping in MARS, which will be displayed in the title of the graph.
%                                       Defaults to ''.
%
% AUTHOR:   
%   - Jonas Widder, 12/2024 & 01/2025

% Define default parameters if not defined
parser = inputParser();
parser.addRequired('input_relAbundances_preMapping', @(x) ischar(x) | isstring(x));
parser.addRequired('input_relAbundances_postMapping', @(x) ischar(x) | isstring(x));
parser.addRequired('saveDir', @(x) ischar(x) | isstring(x));
parser.addParameter('mappingDatabase_name', '', @(x) ischar(x) | isstring(x));

% Parse required and optional inputs
parser.parse(input_relAbundances_preMapping, input_relAbundances_postMapping, saveDir, varargin{:});

input_relAbundances_preMapping = parser.Results.input_relAbundances_preMapping;
input_relAbundances_postMapping = parser.Results.input_relAbundances_postMapping;
saveDir = parser.Results.saveDir;
mappingDatabase_name = parser.Results.mappingDatabase_name;

% Step 1: Load & preprocess input tables
inputTable_relAbundances_preMapping = readtable(input_relAbundances_preMapping);
inputTable_relAbundances_postMapping = readtable(input_relAbundances_postMapping);

mean_relAbundances_preMapping = inputTable_relAbundances_preMapping(:, ["Taxon", "mean"]);
mean_relAbundances_postMapping = inputTable_relAbundances_postMapping(:, ["Taxon", "mean"]);


% Step 2: Merge all taxa with low relative abundance (>1%) to "Others" for both pre- and post-mapping data
% Extract values lower than 0.01 from the "mean" column
lowRelativeAbundances_mask_preMapping = mean_relAbundances_preMapping.mean < 0.01;

% Remove rows with these values as they will not be uniquely listed in the barplot
mean_relAbundances_preMapping_filtered = mean_relAbundances_preMapping(~lowRelativeAbundances_mask_preMapping, :);

% Sum the extracted values
sum_lowRelativeAbundances_preMapping = sum(mean_relAbundances_preMapping.mean(lowRelativeAbundances_mask_preMapping));

% Create a cell array with the new row data with other taxa
otherTaxa_preMapping = {'Others', sum_lowRelativeAbundances_preMapping};

% Concatenate the new row with other taxa to the existing table
mean_relAbundances_preMapping_filtered = [mean_relAbundances_preMapping_filtered; otherTaxa_preMapping];

% Extract values lower than 0.01 from the "mean" column
lowRelativeAbundances_mask_postMapping = mean_relAbundances_postMapping.mean < 0.01;

% Remove rows with these values as they will not be uniquely listed in the barplot
mean_relAbundances_postMapping_filtered = mean_relAbundances_postMapping(~lowRelativeAbundances_mask_postMapping, :);

% Sum the extracted values
sum_lowRelativeAbundances_postMapping = sum(mean_relAbundances_postMapping.mean(lowRelativeAbundances_mask_postMapping));

% Create a cell array with the new row data with other taxa
otherTaxa_postMapping = {'Others', sum_lowRelativeAbundances_postMapping};

% Concatenate the new row with other taxa to the existing table
mean_relAbundances_postMapping_filtered = [mean_relAbundances_postMapping_filtered; otherTaxa_postMapping];


% Step 3: Sort mean relative abundances for easier visual representation
mean_relAbundances_preMapping_sorted = sortrows(mean_relAbundances_preMapping_filtered, 'mean', 'descend');


% Step 4: Extract preprocessed relative abundances pre- & post-mapped from the tables &
% visualize in a stacked barplot, one bar per condition
taxa_pre = mean_relAbundances_preMapping_sorted.Taxon;
abundances_pre = mean_relAbundances_preMapping_sorted.mean;

% Create a map for post-mapping data
postMap = containers.Map(mean_relAbundances_postMapping_filtered.Taxon, mean_relAbundances_postMapping_filtered.mean);

% Prepare data for plotting by assigning post-mapped relative abudances to
% according taxa from pre-mapping to share the same order & colors in the bars
abundances_post = zeros(size(abundances_pre));
for i = 1:length(taxa_pre)
    if isKey(postMap, taxa_pre{i})
        abundances_post(i) = postMap(taxa_pre{i});
    end
end

% Define how many colors need to be generated
num_taxa = length(taxa_pre);

% Create a colormap with unique color-bliend friendly colors (based on Wong's 8colors palette)
colors = [
    0.00 0.45 0.70;  % Blue
    0.90 0.60 0.00;  % Orange
    0.00 0.62 0.45;  % Bluish green
    0.80 0.40 0.00;  % Vermilion
    0.35 0.70 0.90;  % Sky blue
    0.95 0.90 0.25;  % Yellow
    0.80 0.60 0.70   % Reddish purple
];

if num_taxa > 7
    % Create an interpolated color scheme to expand number of color-blind
    % friendly colors
    x = linspace(0, 1, size(base_colors, 1));
    xi = linspace(0, 1, num_colors);
    interpolated_colors = interp1(x, base_colors, xi, 'pchip');
else
    interpolated_colors = colors;
end

% Create the stacked bar plot
fig = figure('Position', [100, 100, 800, 600]);
b = bar([abundances_pre'; abundances_post'], 0.9, 'stacked');
xlim([0.5, 2.5])
ylim([0, 1])

% Apply unique colors to each bar
for i = 1:num_taxa
    b(i).FaceColor = interpolated_colors(i,:);
end

% Customize the plot
ylabel('Mean Relative Abundance')
title('Phylum Mean Relative Abundance pre & post Mapping', mappingDatabase_name, 'Interpreter', 'none')
xticklabels({'pre-mapping', 'post-mapping'})

% Create slimmer legend if needed (in case very many taxa)
if num_taxa > 20
    [~, objh] = legend(taxa_pre, 'Location', 'eastoutside');
    % Find all text objects within the legend
    text_objects = findobj(objh, 'Type', 'text');
    % Set the font size for all text objects
    set(text_objects, 'FontSize', 8);
else
    legend(taxa_pre, 'Location', 'eastoutside');
end

% Adjust figure size to accommodate legend
ax = gca;
ax.FontName = 'Arial';
outerpos = ax.OuterPosition;
ti = ax.TightInset;
left = outerpos(1) + ti(1);
bottom = outerpos(2) + ti(2);
ax_width = outerpos(3) - ti(1) - ti(3) - 0.1;
ax_height = outerpos(4) - ti(2) - ti(4);
ax.Position = [left bottom ax_width ax_height];

% Step : Save figure
figurePath = string(fullfile(saveDir, 'PhylumAbundanceMappingCoverage_stackedBarPlot.png'));
exportgraphics(fig, figurePath, 'Resolution', 300)


end