% The COBRAToolbox: testPlotEcosystemGrid.m
%
% Purpose:
%     - plotEcosystemGrid draws the abundance-growth grid of a two-member ecosystem (x = fraction
%       of the first member, y = community growth) and colors the points by feasibility,
%       cluster, community growth, member fraction, the qualitative state of a reaction or
%       given values. It returns the axes, the plotted points and the color values. This test
%       builds an ecosystem structure by hand and checks, for every coloring, the returned
%       points and colors, the analyzed points (eco.qualPointIndex, else the feasible points,
%       else all points), the colormaps (tab20, tab20c, a MATLAB colormap name, an RGB matrix)
%       and their resampling for categorical colorings, color limits, colorbar ticks and labels,
%       the legend of 'qualState', axis labels and title, drawing into given axes, saving a png
%       and the input errors. Expected values follow from the hand-built input and the
%       documented rules.
%
% Function under test:
%     src/analysis/ecosystem/plotEcosystemGrid.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; a hand-built ecosystem structure. Figures are invisible and
%     closed at the end; the png is written to a temporary folder that is removed.
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
fileDir = fileparts(which('testPlotEcosystemGrid'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% draw without showing figures; the setting is restored and the new figures closed at the end
figureVisibility = get(0, 'DefaultFigureVisible');
set(0, 'DefaultFigureVisible', 'off');
figuresBefore = findall(0, 'Type', 'figure');

% five grid points [fraction of org_A, community growth]; point 4 is unfeasible, so the
% analyzed points are 1, 2, 3 and 5
points = [0.2 0.1; 0.4 0.2; 0.6 0.3; 0.8 0.0; 0.5 0.5];
eco = struct('points', points, 'feasiblePoints', logical([1; 1; 1; 0; 1]), 'qualPointIndex', [], ...
    'prefixes', {{'org_A'; 'orgB'}}, 'rxn2cluster', {{'r1'; 'r2'}}, ...
    'qualVectors', [1 0; 2 3; 1 3; 4 -2], 'clusters', [1; 2; 1; 3], 'k', 3);
analyzed = [1; 2; 3; 5];
% the tab20 and tab20c colormaps as written in the function (matplotlib)
tab20 = [31 119 180; 174 199 232; 255 127 14; 255 187 120; 44 160 44; 152 223 138; 214 39 40; ...
    255 152 150; 148 103 189; 197 176 213; 140 86 75; 196 156 148; 227 119 194; 247 182 210; ...
    127 127 127; 199 199 199; 188 189 34; 219 219 141; 23 190 207; 158 218 229] / 255;
tab20c = [49 130 189; 107 174 214; 158 202 225; 198 219 239; 230 85 13; 253 141 60; 253 174 107; ...
    253 208 162; 49 163 84; 116 196 118; 161 217 155; 199 233 192; 117 107 177; 158 154 200; ...
    188 189 220; 218 218 235; 99 99 99; 150 150 150; 189 189 189; 217 217 217] / 255;
% colors are copied, not computed, so equality is exact; tol covers the parula resampling
tol = 1e-12;

%% default: all grid points, no coloring, default labels and a new 650 x 600 figure

[ax, plottedPoints, plottedColors] = plotEcosystemGrid(eco);
assert(isgraphics(ax, 'axes'));
assert(isequal(plottedPoints, points) && isempty(plottedColors));
fig = ancestor(ax, 'figure');
assert(isequal(fig.Position, [100, 100, 650, 600]));
markers = findobj(ax, 'Type', 'scatter');
assert(numel(markers) == 1 && isequal(markers.XData(:), points(:, 1)) && isequal(markers.YData(:), points(:, 2)));
assert(markers.SizeData == 60);
% the underscore of the prefix is escaped for the TeX interpreter
assert(strcmp(ax.XLabel.String, 'f_{org\_A}') && strcmp(ax.YLabel.String, '\mu_{com} [h^{-1}]'));
assert(isempty(ax.Title.String) && strcmp(ax.Box, 'on'));
% no colorbar is drawn for 'none'
assert(isempty(findobj(fig, 'Type', 'colorbar')));

%% feasible: all points, colors 1 (unfeasible) and 2 (feasible), tab20 resampled to 2 colors

[ax, plottedPoints, plottedColors] = plotEcosystemGrid(eco, 'toPlot', 'feasible', 'markerSize', 20, ...
    'xlabel', 'x', 'ylabel', 'y', 'title', 'grid');
assert(isequal(plottedPoints, points) && isequal(plottedColors, [2; 2; 2; 1; 2]));
% matplotlib get_cmap('tab20', 2) keeps the first and the last of the 20 colors
assert(isequal(colormap(ax), tab20([1 20], :)));
assert(isequal(ax.CLim, [0.5 2.5]));
cb = findobj(ancestor(ax, 'figure'), 'Type', 'colorbar');
assert(isequal(cb.Ticks(:), [1; 2]) && isequal(cb.TickLabels(:), {'unfeasible'; 'feasible'}));
assert(findobj(ax, 'Type', 'scatter').SizeData == 20);
assert(strcmp(ax.XLabel.String, 'x') && strcmp(ax.YLabel.String, 'y') && strcmp(ax.Title.String, 'grid'));
% without a feasibility analysis the coloring is refused
ecoNoFeasible = eco;
ecoNoFeasible.feasiblePoints = [];
assert(verifyCobraFunctionError('plotEcosystemGrid', 'inputs', {ecoNoFeasible, 'toPlot', 'feasible'}, ...
    'testMessage', 'Points feasibility analysis has not been run! Required for plot!'));

%% cluster: analyzed points colored by eco.clusters, k = max(eco.k, clusters), tab20c

[ax, plottedPoints, plottedColors] = plotEcosystemGrid(eco, 'toPlot', 'cluster', 'colormap', 'tab20c');
assert(isequal(plottedPoints, points(analyzed, :)) && isequal(plottedColors, eco.clusters));
% three colors: rows floor([0 0.5 1] * 20) + 1, the last capped at 20
assert(isequal(colormap(ax), tab20c([1 11 20], :)));
assert(isequal(ax.CLim, [0.5 3.5]));
cb = findobj(ancestor(ax, 'figure'), 'Type', 'colorbar');
assert(isequal(cb.TickLabels(:), {'c1'; 'c2'; 'c3'}));
% labels given as an option replace eco.clusters; k is still at least eco.k = 3
[ax, ~, plottedColors] = plotEcosystemGrid(eco, 'toPlot', 'cluster', 'clusters', [2 2 1 1], 'showColorbar', false);
assert(isequal(plottedColors, [2; 2; 1; 1]) && isequal(ax.CLim, [0.5 3.5]));
assert(isempty(findobj(ancestor(ax, 'figure'), 'Type', 'colorbar')));
% a colormap with 256 rows (a MATLAB colormap name) is sampled at round(linspace(1, 256, k))
ecoNoK = eco;
ecoNoK.k = [];
ax = plotEcosystemGrid(ecoNoK, 'toPlot', 'cluster', 'clusters', [1 2 1 2], 'colormap', 'parula');
parulaColors = parula(256);
assert(max(max(abs(colormap(ax) - parulaColors([1 256], :)))) < tol);
assert(isequal(ax.CLim, [0.5 2.5]));
% errors: no cluster labels anywhere, and a label count that differs from the analyzed points
ecoNoClusters = eco;
ecoNoClusters.clusters = [];
assert(verifyCobraFunctionError('plotEcosystemGrid', 'inputs', {ecoNoClusters, 'toPlot', 'cluster'}, ...
    'testMessage', 'Clusters have not been computed. Run clusterEcosystemPoints first.'));
assert(verifyCobraFunctionError('plotEcosystemGrid', 'inputs', {eco, 'toPlot', 'cluster', 'clusters', [1 2]}, ...
    'testMessage', 'The number of cluster labels differs from the number of analyzed points.'));

%% communityGrowth: continuous colors = growth of the analyzed points; RGB matrix colormap

rgbMap = [0 0 0; 0.5 0.5 0.5; 1 1 1];
[ax, plottedPoints, plottedColors] = plotEcosystemGrid(eco, 'toPlot', 'communityGrowth', 'colormap', rgbMap);
assert(isequal(plottedPoints, points(analyzed, :)) && isequal(plottedColors, points(analyzed, 2)));
assert(isequal(colormap(ax), rgbMap));
cb = findobj(ancestor(ax, 'figure'), 'Type', 'colorbar');
assert(strcmp(cb.Label.String, 'community growth'));
% eco.qualPointIndex, when set, defines the analyzed points
ecoIndex = eco;
ecoIndex.qualPointIndex = [5; 1];
[~, plottedPoints, plottedColors] = plotEcosystemGrid(ecoIndex, 'toPlot', 'communityGrowth', 'showColorbar', 0);
assert(isequal(plottedPoints, points([5 1], :)) && isequal(plottedColors, [0.5; 0.1]));
% without feasibility and point index, every grid point is analyzed
ecoAll = rmfield(eco, 'qualPointIndex');
ecoAll.feasiblePoints = [];
[~, plottedPoints] = plotEcosystemGrid(ecoAll, 'toPlot', 'communityGrowth');
assert(isequal(plottedPoints, points));

%% memberFraction: fraction of the first member by default, 1 - f for the second

[ax, ~, plottedColors] = plotEcosystemGrid(eco, 'toPlot', 'memberFraction');
assert(isequal(plottedColors, points(analyzed, 1)));
assert(isequal(colormap(ax), tab20));
cb = findobj(ancestor(ax, 'figure'), 'Type', 'colorbar');
assert(strcmp(cb.Label.String, 'org_A fraction'));
[~, ~, plottedColors] = plotEcosystemGrid(eco, 'toPlot', 'memberFraction', 'fracPrefix', 'orgB');
% 1 - f is computed in floating point, so a tolerance of a few eps is used
assert(max(abs(plottedColors - (1 - points(analyzed, 1)))) < tol);
assert(verifyCobraFunctionError('plotEcosystemGrid', 'inputs', {eco, 'toPlot', 'memberFraction', 'fracPrefix', 'orgC'}, ...
    'testMessage', 'Missing valid member prefix: fracPrefix'));

%% qualState: one scatter per state present, legend with the state labels, title = reaction

[ax, plottedPoints, plottedColors] = plotEcosystemGrid(eco, 'toPlot', 'qualState', 'rxn', 'r2');
assert(isequal(plottedPoints, points(analyzed, :)) && isequal(plottedColors, [0; 3; 3; -2]));
% states -2, 0 and 3 are present, drawn in the order of the codes -3 ... 5
markers = flipud(findobj(ax, 'Type', 'scatter'));
assert(numel(markers) == 3);
assert(isequal(markers(1).XData(:), 0.5) && isequal(markers(3).XData(:), [0.4; 0.6]));
assert(isequal(markers(1).CData, [0.84 0.15 0.16]) && isequal(markers(3).CData, [0.03 0.19 0.42]));
lgd = findobj(ancestor(ax, 'figure'), 'Type', 'legend');
assert(isequal(lgd.String, {'--', '0', '+'}));
assert(strcmp(ax.Title.String, 'r2') && strcmp(ax.Title.Interpreter, 'none'));
% without colorbar no legend is drawn; a given title is kept
ax = plotEcosystemGrid(eco, 'toPlot', 'qualState', 'rxn', 'r1', 'showColorbar', false, 'title', 'state of r1');
assert(isempty(findobj(ancestor(ax, 'figure'), 'Type', 'legend')));
assert(strcmp(ax.Title.String, 'state of r1'));
assert(verifyCobraFunctionError('plotEcosystemGrid', 'inputs', {eco, 'toPlot', 'qualState', 'rxn', 'r3'}, ...
    'testMessage', 'Reaction r3 is not in eco.rxn2cluster.'));

%% values: user values, one per analyzed point, drawn into given axes and saved as png

existingFigure = figure();
existingAxes = axes(existingFigure);
tmpDir = tempname;
mkdir(tmpDir);
saveName = fullfile(tmpDir, 'grid');
[ax, ~, plottedColors] = plotEcosystemGrid(eco, 'toPlot', 'values', 'values', [4 3 2 1], ...
    'axes', existingAxes, 'saveFile', saveName);
assert(ax == existingAxes && isequal(plottedColors, [4; 3; 2; 1]));
assert(isequal(findobj(ax, 'Type', 'scatter').CData, [4; 3; 2; 1]));
cb = findobj(existingFigure, 'Type', 'colorbar');
assert(isempty(cb.Label.String));
assert(exist([saveName '.png'], 'file') == 2);
rmdir(tmpDir, 's');
assert(verifyCobraFunctionError('plotEcosystemGrid', 'inputs', {eco, 'toPlot', 'values', 'values', [1 2]}, ...
    'testMessage', 'values must have one element per analyzed point (4).'));

%% input errors: no grid points, and invalid options rejected by the parser

ecoNoPoints = eco;
ecoNoPoints.points = [];
assert(verifyCobraFunctionError('plotEcosystemGrid', 'inputs', {ecoNoPoints}, ...
    'testMessage', 'Grid points are not set yet! Run buildEcosystemGrid first.'));
assert(verifyCobraFunctionError('plotEcosystemGrid', 'inputs', {rmfield(eco, 'points')}));
assert(verifyCobraFunctionError('plotEcosystemGrid', 'inputs', {eco, 'toPlot', 'density'}));
assert(verifyCobraFunctionError('plotEcosystemGrid', 'inputs', {eco, 'colormap', [1 0]}));
assert(verifyCobraFunctionError('plotEcosystemGrid', 'inputs', {eco, 'markerSize', 0}));

% close the figures of this test and restore the settings
close(setdiff(findall(0, 'Type', 'figure'), figuresBefore));
set(0, 'DefaultFigureVisible', figureVisibility);

% change the directory
cd(currentDir)
