% The COBRAToolbox: testPlotQuantitativeFluxCoupling.m
%
% Purpose:
%     - plotQuantitativeFluxCoupling draws the output table of quantitativeFluxCoupling: one
%       panel per grid point (in the order of first appearance), with the feasible region of
%       rxn2 between its minimum and maximum as a function of rxn1 (a patch and two lines),
%       titles "point = <label>", axis labels from UserData.rxnPair (default rxn1/rxn2), a
%       legend on the first panel only, colWrap panels per row and a default figure size of
%       300 x 260 pixels per panel. Rows with NaN are dropped; a panel without valid rows has
%       no patch or line. This test builds the table by hand and checks the drawn objects, the
%       layout, the options and the input validation. Expected coordinates are the table rows.
%
% Function under test:
%     src/analysis/ecosystem/plotQuantitativeFluxCoupling.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; the input table is hand-built. Figures are invisible and
%     closed at the end.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-13.
%     - Cosmetic defect recorded after the independent review (T027/T028), 2026-11-17.
%     - Help text of plotQuantitativeFluxCoupling corrected to match the code (feature 20261120-151023-doc-matches-code), 2026-11-20.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testPlotQuantitativeFluxCoupling'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% draw without showing figures; the setting is restored at the end
figureVisibility = get(0, 'DefaultFigureVisible');
set(0, 'DefaultFigureVisible', 'off');

% three points: p1 has three x values, p2 has one row with NaN (dropped) and two valid rows,
% p3 has only NaN rows (an empty panel)
rxn1 = [0; 1; 2; 0; 1; 2; 0; 1; 2; 0; 1; 2; 0; 0];
rxn2 = [4; 5; 6; 0; 1; 2; 3; NaN; 5; 1; 1; 1; NaN; NaN];
fvaType = {'maximum'; 'maximum'; 'maximum'; 'minimum'; 'minimum'; 'minimum'; ...
    'maximum'; 'maximum'; 'maximum'; 'minimum'; 'minimum'; 'minimum'; 'maximum'; 'minimum'};
pointLabel = [repmat({'p1'}, 3, 1); repmat({'p1'}, 3, 1); repmat({'p2'}, 6, 1); {'p3'; 'p3'}];
qfca = table(rxn1, rxn2, fvaType, pointLabel, 'VariableNames', {'rxn1', 'rxn2', 'FVA', 'point'});

%% default options: one panel per point, four panels per row, default size and labels

fig = plotQuantitativeFluxCoupling(qfca);
assert(isa(fig, 'matlab.ui.Figure'));
% three panels in one row, placed at [100 100], 260 pixels high. The width is not asserted
% here: with fewer panels than colWrap it is 300 * 3 = 900, 300 times the number of panels,
% as the header documents; the colWrap section below checks the width with more panels
% than colWrap
assert(isequal(fig.Position([1, 2, 4]), [100, 100, 260]));
axesList = findobj(fig, 'Type', 'axes');
assert(numel(axesList) == 3);
titles = arrayfun(@(a) a.Title.String, axesList, 'UniformOutput', false);
axP1 = axesList(strcmp(titles, 'point = p1'));
axP2 = axesList(strcmp(titles, 'point = p2'));
axP3 = axesList(strcmp(titles, 'point = p3'));
assert(numel(axP1) == 1 && numel(axP2) == 1 && numel(axP3) == 1);
% without UserData.rxnPair the axes are labelled rxn1 and rxn2
assert(strcmp(axP1.XLabel.String, 'rxn1') && strcmp(axP1.YLabel.String, 'rxn2'));
assert(strcmp(axP1.XGrid, 'on') && strcmp(axP1.YGrid, 'on') && strcmp(axP1.Box, 'on'));
% panels are placed left to right in the order of first appearance
assert(axP1.Position(1) < axP2.Position(1) && axP2.Position(1) < axP3.Position(1));

% p1: the feasible region is the polygon maximum (left to right) then minimum (right to left);
% exact, the coordinates are copied from the table
patchP1 = findobj(axP1, 'Type', 'patch');
assert(numel(patchP1) == 1);
assert(isequal(patchP1.XData(:), [0; 1; 2; 2; 1; 0]));
assert(isequal(patchP1.YData(:), [4; 5; 6; 2; 1; 0]));
assert(isequal(patchP1.FaceColor, [0.55 0.71 0.86]));
assert(strcmp(patchP1.EdgeColor, 'none') && patchP1.FaceAlpha == 0.6);
linesP1 = findobj(axP1, 'Type', 'line');
assert(numel(linesP1) == 2);
lineColors = vertcat(linesP1.Color);
maxLine = linesP1(ismember(lineColors, [0.8 0.33 0.1], 'rows'));
minLine = linesP1(ismember(lineColors, [0 0.45 0.74], 'rows'));
assert(isequal(maxLine.YData(:), [4; 5; 6]) && isequal(minLine.YData(:), [0; 1; 2]));

% p2: the row x = 1 has a NaN maximum and is dropped from all three series
patchP2 = findobj(axP2, 'Type', 'patch');
assert(isequal(patchP2.XData(:), [0; 2; 2; 0]));
assert(isequal(patchP2.YData(:), [3; 5; 1; 1]));

% p3: no valid row, so the panel has no patch and no line but keeps its title and labels
assert(isempty(findobj(axP3, 'Type', 'patch')) && isempty(findobj(axP3, 'Type', 'line')));

% the legend is drawn on the first panel only
legends = findobj(fig, 'Type', 'legend');
assert(numel(legends) == 1);
assert(isequal(legends.String, {'feasible region', 'maximum', 'minimum'}));
assert(legends.Axes == axP1);
close(fig);

%% colWrap, faceColor, figureSize and the reaction pair stored in UserData

qfca.Properties.UserData.rxnPair = {'org1_EX_A', 'org2_EX_A'};
fig = plotQuantitativeFluxCoupling(qfca, 'colWrap', 2, 'faceColor', [1 0 0]);
% two panels per row, so two rows: 2 x 300 by 2 x 260 pixels
assert(isequal(fig.Position, [100, 100, 600, 520]));
axesList = findobj(fig, 'Type', 'axes');
titles = arrayfun(@(a) a.Title.String, axesList, 'UniformOutput', false);
axP1 = axesList(strcmp(titles, 'point = p1'));
axP3 = axesList(strcmp(titles, 'point = p3'));
% p3 starts the second row: same column as p1, lower on the figure
assert(abs(axP3.Position(1) - axP1.Position(1)) < 1e-12 && axP3.Position(2) < axP1.Position(2));
assert(strcmp(axP1.XLabel.String, 'org1_EX_A') && strcmp(axP1.YLabel.String, 'org2_EX_A'));
assert(strcmp(axP1.XLabel.Interpreter, 'none'));
assert(isequal(findobj(axP1, 'Type', 'patch').FaceColor, [1 0 0]));
close(fig);

% an explicit figure size replaces the default
fig = plotQuantitativeFluxCoupling(qfca, 'figureSize', [500 400]);
assert(isequal(fig.Position, [100, 100, 500, 400]));
close(fig);

%% input validation by the parser

assert(verifyCobraFunctionError('plotQuantitativeFluxCoupling', 'inputs', {qfca(:, 1:3)}));
assert(verifyCobraFunctionError('plotQuantitativeFluxCoupling', 'inputs', {struct('rxn1', 1)}));
assert(verifyCobraFunctionError('plotQuantitativeFluxCoupling', 'inputs', {qfca, 'colWrap', 0}));
assert(verifyCobraFunctionError('plotQuantitativeFluxCoupling', 'inputs', {qfca, 'faceColor', [1 0]}));
assert(verifyCobraFunctionError('plotQuantitativeFluxCoupling', 'inputs', {qfca, 'figureSize', 5}));

% close the figures and restore the settings
close all
set(0, 'DefaultFigureVisible', figureVisibility);

% change the directory
cd(currentDir)
