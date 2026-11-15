% The COBRAToolbox: testCreateForestPlot.m
%
% Purpose:
%     - createForestPlot draws, in the current axes, one horizontal confidence-interval line
%       per estimate, the estimates as scatter points coloured by significance group
%       (findPvalCategories: FDR < 0.05 red, P < 0.05 blue, P > 0.05 grey), a legend below
%       the plot (shown or hidden), the names as y tick labels, symmetric x limits at 110% of
%       the largest absolute interval bound and a dashed line at zero. The test draws into
%       invisible figures and reads the graphics objects back; expected values come from the
%       inputs and the formulas in the header and code (hand derivation; the Benjamini-
%       Hochberg values of the p-values are worked out below).
%
% Function under test:
%     src/analysis/persephone/createForestPlot.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; hand-built vectors and invisible figures.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testCreateForestPlot'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% three estimates; Benjamini-Hochberg adjusted p-values of [0.001; 0.04; 0.5] are
% [0.003; 0.06; 0.5], so there is one point in each significance group
estimates = [-1; 0.5; 2];
ci = [-2 0; 0.1 0.9; 1 3];
names = {'taxonA'; 'taxonB'; 'taxonC'};
pValues = [0.001; 0.04; 0.5];
red = [0.89 0.145 0.157];
blue = [0 0.4470 0.7410];
grey = [0.804 0.808 0.808];
% graphics coordinates are stored in double, so 1e-12 only absorbs rounding of 1.1 * 3
tol = 1e-12;

%% default call (legend shown): lines, points, legend, labels and limits

fig = figure('Visible', 'off');
createForestPlot(estimates, ci, names, pValues, 'My forest', 'Effect size');
ax = gca;

% one black interval line per estimate at heights 1, 2, 3; they are hidden from the legend
intervalLines = findall(ax, 'Type', 'line');
assert(numel(intervalLines) == 3);
for j = 1:3
    lineJ = intervalLines(arrayfun(@(l) isequal(l.YData, [j j]), intervalLines));
    assert(numel(lineJ) == 1 && isequal(lineJ.XData, ci(j, :)));
    assert(isequal(lineJ.Color, [0 0 0]) && strcmp(lineJ.HandleVisibility, 'off'));
end

% one scatter group per significance group, coloured red, blue and grey
points = flipud(findobj(ax, 'Type', 'scatter'));
assert(numel(points) == 3);
expectedColours = {red, blue, grey};
for i = 1:3
    assert(isequal(points(i).XData, estimates(i)) && isequal(points(i).YData, i));
    assert(isequal(points(i).CData, expectedColours{i}));
    assert(strcmp(points(i).MarkerFaceColor, 'flat'));
end

% legend below the plot, horizontal, with the group names, visible
legendHandle = ax.Legend;
assert(isequal(legendHandle.String, {'FDR < 0.05', 'P < 0.05', 'P > 0.05'}));
assert(strcmp(legendHandle.Location, 'southoutside') && strcmp(legendHandle.Orientation, 'horizontal'));
assert(strcmp(legendHandle.AutoUpdate, 'off') && strcmp(legendHandle.Visible, 'on'));

% labels, ticks and appearance
assert(strcmp(ax.Title.String, 'My forest') && strcmp(ax.Title.Interpreter, 'none'));
assert(strcmp(ax.XLabel.String, 'Effect size') && isempty(ax.YLabel.String));
assert(isequal(ax.YTick, 1:3) && isequal(ax.YTickLabel, names));
assert(strcmp(ax.TickLabelInterpreter, 'none') && strcmp(ax.FontName, 'Arial'));
assert(strcmp(ax.XGrid, 'on') && abs(ax.GridAlpha - 0.1) < tol);
assert(strcmp(ax.TitleHorizontalAlignment, 'left') && strcmp(ax.BoxStyle, 'full'));
assert(strcmp(ax.NextPlot, 'replace'));

% y limits half a step around the points; x limits +-1.1 * max(abs(ci)) = +-3.3
assert(isequal(ax.YLim, [0.5 3.5]));
assert(all(abs(ax.XLim - [-3.3 3.3]) < tol));

% dashed reference line at zero
zeroLine = findobj(ax, 'Type', 'ConstantLine');
assert(numel(zeroLine) == 1 && zeroLine.Value == 0 && strcmp(zeroLine.LineStyle, '--'));
assert(abs(zeroLine.Alpha - 0.2) < tol);
close(fig);

%% hidden legend and no names

% two estimates with large p-values: only the grey group is present
fig = figure('Visible', 'off');
createForestPlot([0.2; -0.4], [-0.5 0.9; -1.2 0.4], {}, [0.3; 0.8], "title", "x", true);
ax = gca;
points = findobj(ax, 'Type', 'scatter');
assert(numel(points) == 1 && isequal(points.XData, [0.2 -0.4]) && isequal(points.YData, [1 2]));
assert(isequal(points.CData, [grey; grey]));
assert(isequal(ax.Legend.String, {'P > 0.05'}) && strcmp(ax.Legend.Visible, 'off'));
% no names: the ticks stay at the points but carry no label
assert(isequal(ax.YTick, [1 2]));
assert(strcmp(ax.YTickLabelMode, 'manual') && all(cellfun(@isempty, cellstr(ax.YTickLabel))));
% +-1.1 * 1.2
assert(all(abs(ax.XLim - [-1.32 1.32]) < tol));
close(fig);

% change the directory
cd(currentDir)
