function createForestPlot(estimates, ci, names, pValues, plotTitle, xTitle, hideLegend)
% Generate a forest plot displaying confidence intervals for a set of estimates
%
% Points are coloured by significance category (FDR < 0.05, P < 0.05,
% P > 0.05) and drawn against their confidence intervals.
%
% USAGE:
%
%    createForestPlot(estimates, ci, names, pValues, plotTitle, xTitle, hideLegend)
%
% INPUTS:
%    estimates:    vector of estimates (e.g. effect sizes or log fold changes)
%    ci:           n x 2 matrix of confidence intervals, lower and upper
%                  bounds in the two columns
%    names:        cell array of labels, one per data point
%    pValues:      vector of p-values corresponding to each estimate
%    plotTitle:    char/string, title of the plot
%    xTitle:       char/string, label for the x-axis (e.g. "Effect Size" or
%                  "Log Fold Change")
%
% OPTIONAL INPUT:
%    hideLegend:    logical, if true the legend is hidden (default false)
%
% .. Author: - Tim Hensen, November 2024

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
