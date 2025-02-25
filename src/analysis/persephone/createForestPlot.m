function createForestPlot(estimates, ci, names, pValues, plotTitle, xTitle, hideLegend)
% createForestPlot generates a forest plot to display confidence intervals for estimates.
%
% USAGE:
%   createForestPlot(estimates, ci, names, pValues, plotTitle, xTitle, hideLegend)
%
% INPUTS:
%   estimates   - Vector of estimates (e.g., effect sizes or log fold changes).
%   ci          - Matrix of confidence intervals [n x 2] with lower and upper bounds in columns.
%   names       - Cell array of labels for each data point.
%   pValues     - Vector of p-values corresponding to each estimate.
%   plotTitle   - String, title of the plot.
%   xTitle      - String, label for the x-axis (typically "Effect Size" or "Log Fold Change").
%   hideLegend  - Logical, if true, hides the legend (default is false).
%
% .. Author:
%       - Tim Hensen       November, 2024

if nargin < 7
    hideLegend = false; % Default value for hideLegend if not provided
end

hold on

% Plot confidence intervals as horizontal lines for each data point
for j = 1:length(estimates)
    l = line([ci(j, 1), ci(j, 2)], [j, j], 'Color', 'black');
    l.HandleVisibility = 'off'; % Hide individual lines from the legend
end

% Categorize p-values and assign colors for each category
[groupsToPlot, colours] = findPvalCategories(pValues);

% Define y-axis positions for each estimate
speciesTicks = 1:length(estimates);

% Plot estimates with significance-based coloring
for i = 1:width(groupsToPlot)
    % Extract coordinates for current group
    xcoords = estimates(groupsToPlot{:, i}); 
    ycoords = speciesTicks(groupsToPlot{:, i});

    % Create scatter plot for current group with designated colors
    s = scatter(xcoords, ycoords);
    s.MarkerFaceColor = 'flat';
    s.CData = repmat(colours{i}, length(xcoords), 1); % Assign color based on category
end

hold off

% Add legend based on significance categories
legendNames = groupsToPlot.Properties.VariableNames;
L = legend(legendNames);
L.Location = 'southoutside';
L.Orientation = 'horizontal';
L.AutoUpdate = 'off';

% Toggle legend visibility based on hideLegend parameter
if hideLegend
    legend('hide')
else
    legend('show');
end

% Customize plot appearance
grid on
ax = gca;
ax.TickLabelInterpreter = 'none';
ax.FontName = 'Arial';
ax.TitleHorizontalAlignment = 'left';
ax.BoxStyle = 'full';
ax.GridAlpha = 0.1;

% Add plot title and x-axis label
title(plotTitle, 'Interpreter', 'none')
xlabel(xTitle, 'Interpreter', 'none')
ylabel('') % No y-axis label since names are provided

% Set y-axis ticks and labels
yticks(speciesTicks)
if ~isempty(names)
    yticklabels(names) % Display names if provided
else
    yticklabels({})
end

% Adjust y-axis limits for better visualization
ylim([0.5, length(speciesTicks) + 0.5])

% Set symmetric x-axis limits around zero, with a 10% margin
maxValue = max(max(abs(ci))); % Find largest confidence interval value
maxValue = maxValue + (maxValue * 0.1); % Add 10% margin
minValue = -maxValue;
xlim([minValue, maxValue])

% Add vertical line at zero for reference
xline(0, 'Alpha', 0.2, 'LineStyle', '--');
end
