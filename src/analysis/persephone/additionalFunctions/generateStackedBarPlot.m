function generateStackedBarPlot(input_relAbundances, saveDir)
% Generates stacked bar plots from relative abundances of taxa for single or multiple samples.
%
% INPUTS:
%   input_relAbundances:    [table] Contains taxa and their relative abundances for
%                           all samples. Requires column 'Taxon' and one or more
%                           sample columns.
%   saveDir:                [chars/string] Path to the directory where the
%                           stacked bar plot should be saved.
%
% AUTHOR:   
%   - Jonas Widder, 12/2024 & 01/2025

% Define default parameters if not defined
parser = inputParser();
parser.addRequired('input_relAbundances', @istable);
parser.addRequired('saveDir', @(x) ischar(x) | isstring(x));

% Parse required inputs
parser.parse(input_relAbundances, saveDir);

input_relAbundances = parser.Results.input_relAbundances;
saveDir = parser.Results.saveDir;

% Step 1: Preprocess input table
taxa = input_relAbundances.Taxon;
sample_columns = input_relAbundances.Properties.VariableNames(2:end);
abundances = table2array(input_relAbundances(:, sample_columns));

% Step 2: Merge all taxa with low relative abundance (<1%) to "Others" for each sample
lowRelativeAbundances_mask = abundances < 0.01;
filtered_abundances = abundances;
filtered_abundances(lowRelativeAbundances_mask) = 0;

others_abundances = sum(abundances .* lowRelativeAbundances_mask);
filtered_abundances = [filtered_abundances; others_abundances];
taxa = [taxa; {'Others'}];

% Step 3: Sort abundances for easier visual representation
[sorted_abundances, sort_idx] = sort(sum(filtered_abundances, 2), 'descend');
filtered_abundances = filtered_abundances(sort_idx, :);
taxa = taxa(sort_idx);

% Step 4: Create the stacked bar plot
fig = figure('Position', [100, 100, 1000, 600]);
b = bar(filtered_abundances', 'stacked');
xlim([0.5, length(sample_columns)+0.5])
ylim([0, 1])

% Define color-blind friendly color scheme
num_taxa = length(taxa);
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
    % Create an interpolated color scheme
    x = linspace(0, 1, size(colors, 1));
    xi = linspace(0, 1, num_taxa);
    interpolated_colors = interp1(x, colors, xi, 'pchip');
else
    interpolated_colors = colors(1:num_taxa, :);
end

% Apply unique colors to each bar
for i = 1:num_taxa
    b(i).FaceColor = interpolated_colors(i,:);
end

% Customize the plot
ylabel('Relative Abundance')
title('Relative Abundance of Taxa Across Samples')

% Improve x-axis labeling
ax = gca;
ax.XTick = 1:length(sample_columns);
ax.XTickLabel = sample_columns;
ax.XTickLabelRotation = 45;
ax.TickLabelInterpreter = 'none';  % Prevent interpretation of underscores

% Adjust figure size and position
fig.Position(4) = 700;  % Increase figure height to accommodate x-tick labels
outerpos = ax.OuterPosition;
ti = ax.TightInset;
left = outerpos(1) + ti(1);
bottom = outerpos(2) + ti(2) + 0.08;  % Increase bottom margin for x-tick labels
ax_width = outerpos(3) - ti(1) - ti(3) - 0.05;
ax_height = outerpos(4) - ti(2) - ti(4) - 0.1;
ax.Position = [left bottom ax_width ax_height];

% Adjust x-axis label positions
ax.XTickLabel = {};  % Remove original x-tick labels
x_positions = 1:length(sample_columns);
text(x_positions, repmat(-0.03, 1, length(sample_columns)), sample_columns, ...
    'HorizontalAlignment', 'right', 'VerticalAlignment', 'top', ...
    'Rotation', 45, 'Interpreter', 'none', 'FontSize', 8, 'FontName', 'Arial');

% Create legend
if num_taxa > 20
    legend(taxa, 'Location', 'eastoutside', 'NumColumns', 2, 'FontName', 'Arial');
else
    legend(taxa, 'Location', 'eastoutside', 'FontName', 'Arial');
end

% Adjust figure size to accommodate legend and x-labels
ax.FontName = 'Arial';

% Save figure
figurePath = fullfile(saveDir, 'RelativeAbundance_stackedBarPlot');
savefig(fig, figurePath)
saveas(fig, [figurePath '.svg'])

end