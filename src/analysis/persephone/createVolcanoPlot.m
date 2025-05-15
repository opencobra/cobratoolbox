function createVolcanoPlot(estimates, pValues, names, plotTitle, xTitle, yTitle)
% createVolcanoPlot generates a volcano plot to visualize the relationship 
% between regression estimates and p-values.
%
% USAGE:
%   createVolcanoPlot(estimates, pValues, names, plotTitle, xTitle, yTitle)
%
% INPUTS:
%   estimates - [vector] Regression estimates for each data point (e.g., effect sizes or log fold changes).
%   pValues   - [vector] p-values corresponding to each estimate.
%   names     - [cell array] Labels or names for each data point.
%   plotTitle - [string] Title of the plot.
%   xTitle    - [string] Label for the x-axis (e.g., "Effect Size" or "Log Fold Change").
%   yTitle    - [string] Label for the y-axis (e.g., "-log10(p-value)").
%
% OUTPUTS:
%   None      - This function generates a volcano plot in the current figure.
%
% EXAMPLE:
%   createVolcanoPlot(estimates, pValues, {'Metabolite1', 'Metabolite2'}, ...
%                     'Volcano Plot', 'Log Fold Change', '-log10(p-value)')
%
% .. Author:
%       - Tim Hensen, November 2024

% Categorise the p-values and define the category-associated colours
[groupsToPlot, colours] = findPvalCategories(pValues);

hold on
% Generate line plots
for i = 1:width(groupsToPlot)

    % Collect x and y coordinates
    xcoords = estimates(groupsToPlot{:,i}); 
    ycoords = -log10(pValues(groupsToPlot{:,i}));

    % Draw scatter plot
    s = scatter(xcoords, ycoords);

    % Add colours
    s.MarkerFaceColor = 'flat';
    s.CData = repmat(colours{i},length(xcoords),1);
end

% Add a legend using the category names
legendNames = groupsToPlot.Properties.VariableNames;
L = legend(legendNames);
L.Location = 'southoutside';
L.Orientation ='horizontal';
L.AutoUpdate = 'off';

% Add grid lines to the plot for better readability
grid on
ax=gca;
ax.GridAlpha = 0.1;
ax.FontName = 'Arial';
ax.TitleHorizontalAlignment='left';

% Add plot title and axis labels with specified strings
title(plotTitle,'Interpreter','none','fontWeight','normal')
xlabel(xTitle,'Interpreter','none')
ylabel(yTitle,'Interpreter','none')

% Adjust x-axis limits to be symmetric around zero with a 10% margin for visualization
maxValue = max(abs([max(estimates) min(estimates)]));%print
maxValue = maxValue + (maxValue * 0.1);%print
minValue = maxValue *-1;%print
xlim([minValue,maxValue])

% Add reference lines at estimate = 0 and p-value threshold (p = 0.05)
xline(0,'--k', 'Alpha',0.7);
threshold = -log10(0.05);
yline(threshold,'--k','Alpha',0.7)

% Annotate the threshold line with the p-value cutoff label
xcoord = max(xlim)*0.99;
ycoord = threshold + max(ylim)*0.02;
t = text(xcoord,ycoord,'p=0.05','FontName','Arial','HorizontalAlignment','right');

% Increase fontsize to 12
t.FontSize = t.FontSize* 1.2;

% Add metabolite names to figure. Align the positive estimates to the right
% and the negative estimates to the left.

% Label data points with names, aligning based on the estimate sign
rows = {pValues<0.05 & estimates<0, pValues<0.05 & estimates>0};
alignment = {'left','right'};
for i = 1:length(rows)
    % Filter names for points that pass significance and align left or right
    namesToInclude = names(rows{i});

    % Get coordinates
    xcoordNames = estimates(rows{i});
    ycoordNames = -log10(pValues(rows{i}));

    % Add small offsets to labels based on alignment
    if i==1
        xcoordNames = xcoordNames + sum(abs(xlim))*0.01;
    else
        xcoordNames = xcoordNames - sum(abs(xlim))*0.01;
    end

    % Add text annotations for significant data points
    textHandles = text(xcoordNames,ycoordNames,namesToInclude,'HorizontalAlignment',alignment{i},'FontName','Arial','FontSize',8,'Interpreter','none');
    
    if 0 % DEBUGGING histidine position
        % Find altered metabolite positions
        metaboliteNames = get(textHandles, 'string');
        index = matches(metaboliteNames, 'L-histidine');
        % Add hardcode new position
        newPosition = [-0.297905859248534,2.449562899394475,0];
        set(textHandles(index), 'Position', newPosition);
    end
end
end