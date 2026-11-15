% The COBRAToolbox: testCreateVolcanoPlot.m
%
% Purpose:
%     - createVolcanoPlot draws, in the current axes, the estimates against -log10(p) as
%       scatter points coloured by significance group (findPvalCategories: FDR < 0.05 red,
%       P < 0.05 blue, P > 0.05 grey), a legend below the plot, symmetric x limits at 110% of
%       the largest absolute estimate, dashed reference lines at estimate 0 and p = 0.05 with
%       the label 'p=0.05', and the names of the points with p < 0.05 (left-aligned for
%       negative, right-aligned for positive estimates, shifted by 1% of the x range). The
%       test draws into invisible figures and reads the graphics objects back; expected
%       values come from the inputs and the formulas in the code (hand derivation; the
%       Benjamini-Hochberg values of the p-values are worked out below).
%
% Function under test:
%     src/analysis/persephone/createVolcanoPlot.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; hand-built vectors and invisible figures.
%
% Coverage exemptions:
%     Lines 110-111, 113-114: dead code, inside 'if 0' (a debugging block that no input can reach).
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testCreateVolcanoPlot'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% four points; Benjamini-Hochberg adjusted values of [0.001; 0.04; 0.5; 0.01] are
% [0.004; 0.0533; 0.5; 0.02]: points 1 and 4 are FDR < 0.05, point 2 is P < 0.05 and
% point 3 is P > 0.05
estimates = [-1; 0.5; 2; -0.2];
pValues = [0.001; 0.04; 0.5; 0.01];
names = {'metA'; 'metB'; 'metC'; 'metD'};
red = [0.89 0.145 0.157];
blue = [0 0.4470 0.7410];
grey = [0.804 0.808 0.808];
% graphics coordinates are stored in double; 1e-12 absorbs the rounding of the products below
tol = 1e-12;

%% points, legend and labels

fig = figure('Visible', 'off');
createVolcanoPlot(estimates, pValues, names, 'My volcano', 'Log fold change', '-log10(p)');
ax = gca;

% one scatter group per significance group, in the order red, blue, grey
points = flipud(findobj(ax, 'Type', 'scatter'));
assert(numel(points) == 3);
groupMembers = {[1; 4], 2, 3};
expectedColours = {red, blue, grey};
for i = 1:3
    members = groupMembers{i};
    assert(isequal(points(i).XData(:), estimates(members)));
    assert(all(abs(points(i).YData(:) + log10(pValues(members))) < tol));
    assert(isequal(points(i).CData, repmat(expectedColours{i}, numel(members), 1)));
end

% legend below the plot with the group names
assert(isequal(ax.Legend.String, {'FDR < 0.05', 'P < 0.05', 'P > 0.05'}));
assert(strcmp(ax.Legend.Location, 'southoutside') && strcmp(ax.Legend.Orientation, 'horizontal'));
assert(strcmp(ax.Legend.AutoUpdate, 'off'));

% title and axis labels, grid and font
assert(strcmp(ax.Title.String, 'My volcano') && strcmp(ax.Title.FontWeight, 'normal'));
assert(strcmp(ax.XLabel.String, 'Log fold change') && strcmp(ax.YLabel.String, '-log10(p)'));
assert(strcmp(ax.XGrid, 'on') && abs(ax.GridAlpha - 0.1) < tol && strcmp(ax.FontName, 'Arial'));
assert(strcmp(ax.TitleHorizontalAlignment, 'left'));

% x limits: max(abs([2 -1])) * 1.1 = 2.2 on both sides
assert(all(abs(ax.XLim - [-2.2 2.2]) < tol));

% reference lines: x = 0 and y = -log10(0.05), dashed and black
xLine = findobj(ax, 'Type', 'ConstantLine', 'InterceptAxis', 'x');
yLine = findobj(ax, 'Type', 'ConstantLine', 'InterceptAxis', 'y');
assert(numel(xLine) == 1 && xLine.Value == 0 && strcmp(xLine.LineStyle, '--'));
assert(numel(yLine) == 1 && abs(yLine.Value + log10(0.05)) < tol && strcmp(yLine.LineStyle, '--'));

% the threshold label sits at 99% of the right x limit, above the line, in font size 1.2 x
% the default
% a text object made from a single name keeps it in a 1x1 cell, so the strings are read with
% char(string(...))
texts = findobj(ax, 'Type', 'text');
textStrings = arrayfun(@(t) char(string(t.String)), texts, 'UniformOutput', false);
thresholdLabel = texts(strcmp(textStrings, 'p=0.05'));
assert(numel(thresholdLabel) == 1);
assert(abs(thresholdLabel.Position(1) - 2.2 * 0.99) < tol);
assert(thresholdLabel.Position(2) > -log10(0.05));
assert(strcmp(thresholdLabel.HorizontalAlignment, 'right'));
assert(abs(thresholdLabel.FontSize - 1.2 * get(groot, 'DefaultTextFontSize')) < tol);

% names of the points with p < 0.05: metA and metD (negative, left-aligned, shifted right by
% 1% of the x range 4.4) and metB (positive, right-aligned, shifted left); metC has p > 0.05
labels = texts(~strcmp(textStrings, 'p=0.05'));
labelStrings = textStrings(~strcmp(textStrings, 'p=0.05'));
assert(isequal(sort(labelStrings), {'metA'; 'metB'; 'metD'}));
shift = 4.4 * 0.01;
expectedLabels = {'metA', -1 + shift, 3, 'left'; 'metD', -0.2 + shift, 2, 'left'; ...
    'metB', 0.5 - shift, -log10(0.04), 'right'};
for i = 1:size(expectedLabels, 1)
    label = labels(strcmp(labelStrings, expectedLabels{i, 1}));
    assert(abs(label.Position(1) - expectedLabels{i, 2}) < tol);
    assert(abs(label.Position(2) - expectedLabels{i, 3}) < tol);
    assert(strcmp(label.HorizontalAlignment, expectedLabels{i, 4}));
    assert(label.FontSize == 8 && strcmp(label.Interpreter, 'none'));
end
close(fig);

%% no significant point: one grey group and no names

fig = figure('Visible', 'off');
createVolcanoPlot([0.3; -0.6], [0.2; 0.7], {'x1'; 'x2'}, "t", "x", "y");
ax = gca;
points = findobj(ax, 'Type', 'scatter');
assert(numel(points) == 1 && isequal(points.CData, [grey; grey]));
assert(isequal(ax.Legend.String, {'P > 0.05'}));
% x limits: 0.6 * 1.1
assert(all(abs(ax.XLim - [-0.66 0.66]) < tol));
texts = findobj(ax, 'Type', 'text');
assert(numel(texts) == 1 && strcmp(texts.String, 'p=0.05'));
close(fig);

% change the directory
cd(currentDir)
