% The COBRAToolbox: testPlotQualitativeStateOverlap.m
%
% Purpose:
%     - plotQualitativeStateOverlap encodes, for each analyzed grid point of one or more
%       scenarios, the qualitative states of a list of reactions as
%       code = sum_i (state_i + 4) * base^(i - 1), gives each distinct code found in any
%       scenario one color shared by all panels, and draws one panel per scenario with a
%       colorbar describing the state combinations. It returns the figure, the sorted codes and
%       their descriptions. This test builds two scenarios by hand (with the reactions in
%       different column orders) and checks the codes, the descriptions (reactions listed from
%       the last to the first), the color index of every point, the resampled colormaps
%       (tab20c, tab20, a MATLAB colormap name, an RGB matrix), the figure and panel layout,
%       titles and labels, a single scenario given as a structure, the base option, saving a
%       png and the input errors. Expected codes are computed by hand from the documented
%       formula and the label table of qualitativeStateLabels.
%
% Function under test:
%     src/analysis/ecosystem/plotQualitativeStateOverlap.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; hand-built ecosystem structures. Figures are invisible and
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
fileDir = fileparts(which('testPlotQualitativeStateOverlap'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% draw without showing figures; the setting is restored and the new figures closed at the end
figureVisibility = get(0, 'DefaultFigureVisible');
set(0, 'DefaultFigureVisible', 'off');
figuresBefore = findall(0, 'Type', 'figure');

% scenario 1: points 1, 2 and 4 analyzed, reactions r1 r2 r3
eco1 = struct('name', 'scen_1', 'prefixes', {{'org_A'; 'orgB'}}, 'rxn2cluster', {{'r1'; 'r2'; 'r3'}}, ...
    'points', [0.2 0.1; 0.4 0.3; 0.6 0.2; 0.8 0.4], 'qualPointIndex', [1; 2; 4], ...
    'qualVectors', [0 1 5; 1 1 5; -1 0 5]);
% scenario 2: points 1 and 3 analyzed, reactions stored as r2 r1
eco2 = struct('name', 'scen2', 'prefixes', {{'org_A'; 'orgB'}}, 'rxn2cluster', {{'r2'; 'r1'}}, ...
    'points', [0.1 0.6; 0.3 0.5; 0.5 0.7], 'qualPointIndex', [1; 3], ...
    'qualVectors', [1 0; 3 2]);
rxns = {'r1', 'r2'};
% codes with base 10: (r1 + 4) + 10 * (r2 + 4)
% scenario 1: (0, 1) -> 54, (1, 1) -> 55, (-1, 0) -> 43; scenario 2: (0, 1) -> 54, (2, 3) -> 76
expectedCodes = [43; 54; 55; 76];
% descriptions list the reactions from the last to the first; labels from qualitativeStateLabels
expectedLabels = {'r2 0, r1 -0'; 'r2 0+, r1 0'; 'r2 0+, r1 0+'; 'r2 +, r1 ++'};
tab20 = [31 119 180; 174 199 232; 255 127 14; 255 187 120; 44 160 44; 152 223 138; 214 39 40; ...
    255 152 150; 148 103 189; 197 176 213; 140 86 75; 196 156 148; 227 119 194; 247 182 210; ...
    127 127 127; 199 199 199; 188 189 34; 219 219 141; 23 190 207; 158 218 229] / 255;
tab20c = [49 130 189; 107 174 214; 158 202 225; 198 219 239; 230 85 13; 253 141 60; 253 174 107; ...
    253 208 162; 49 163 84; 116 196 118; 161 217 155; 199 233 192; 117 107 177; 158 154 200; ...
    188 189 220; 218 218 235; 99 99 99; 150 150 150; 189 189 189; 217 217 217] / 255;
% positions are computed in floating point; tol covers the rounding of a few operations
tol = 1e-12;

%% two scenarios with default options

[fig, stateCodes, stateLabels] = plotQualitativeStateOverlap({eco1, eco2}, rxns);
% codes are integers, so the comparison is exact
assert(isequal(stateCodes, expectedCodes) && isequal(stateLabels, expectedLabels));
% figure width: 300 per panel + 80 + label width (7 * 12 characters + 60)
assert(isa(fig, 'matlab.ui.Figure') && isequal(fig.Position, [100, 100, 2 * 300 + 80 + 144, 450]));
axesList = flipud(findobj(fig, 'Type', 'axes'));
assert(numel(axesList) == 2);
assert(strcmp(axesList(1).Title.String, 'scen_1') && strcmp(axesList(2).Title.String, 'scen2'));
assert(strcmp(axesList(1).Title.Interpreter, 'none'));
assert(strcmp(axesList(1).XLabel.String, 'f_{org\_A}') && strcmp(axesList(2).XLabel.String, 'f_{org\_A}'));
assert(strcmp(axesList(1).YLabel.String, '\mu_{com} [h^{-1}]') && isempty(axesList(2).YLabel.String));
% panel layout: plots take 1 - (80 + 144) / 824 of the width, with a gap of 0.04
panelWidth = (1 - 224 / 824 - 0.04) / 2;
assert(abs(axesList(1).Position(1) - 0.07) < tol && abs(axesList(1).Position(3) - (panelWidth - 0.01)) < tol);
assert(abs(axesList(2).Position(1) - (0.07 + panelWidth + 0.04)) < tol);
% each point is colored by the index of its code among the sorted codes
scatter1 = findobj(axesList(1), 'Type', 'scatter');
scatter2 = findobj(axesList(2), 'Type', 'scatter');
assert(isequal(scatter1.XData(:), [0.2; 0.4; 0.8]) && isequal(scatter1.CData(:), [2; 3; 1]));
assert(isequal(scatter2.XData(:), [0.1; 0.5]) && isequal(scatter2.CData(:), [2; 4]));
assert(scatter1.SizeData == 30);
% tab20c resampled to four colors: rows floor([0 1/3 2/3 1] * 20) + 1, the last capped at 20
assert(isequal(colormap(axesList(1)), tab20c([1 7 14 20], :)) && isequal(colormap(axesList(2)), tab20c([1 7 14 20], :)));
assert(isequal(axesList(1).CLim, [0.5 4.5]) && strcmp(axesList(1).Box, 'on'));
% the panels share their limits and the y axis starts at 0
assert(isequal(axesList(1).XLim, axesList(2).XLim) && axesList(1).YLim(1) == 0);
assert(isequal(axesList(1).YLim, axesList(2).YLim));
% one colorbar, right of the last panel, with one tick per state combination
cb = findobj(fig, 'Type', 'colorbar');
assert(isscalar(cb) && isequal(cb.Ticks(:), (1:4)') && isequal(cb.TickLabels(:), expectedLabels));
assert(strcmp(cb.TickLabelInterpreter, 'none'));
assert(abs(cb.Position(1) - (axesList(2).Position(1) + axesList(2).Position(3) + 0.015)) < tol);

%% one scenario as a structure, a single reaction given as text, options

tmpDir = tempname;
mkdir(tmpDir);
saveName = fullfile(tmpDir, 'overlap');
[fig, stateCodes, stateLabels] = plotQualitativeStateOverlap(eco1, 'r2', 'titles', {'first'}, ...
    'colormap', 'tab20', 'markerSize', 12, 'xlabel', 'x', 'ylabel', 'y', 'showColorbar', false, ...
    'saveFile', saveName);
% codes r2 + 4: 1 -> 5, 1 -> 5, 0 -> 4
assert(isequal(stateCodes, [4; 5]) && isequal(stateLabels, {'r2 0'; 'r2 0+'}));
% without colorbar the figure is 300 + 80 wide and holds one panel without gap
assert(isequal(fig.Position, [100, 100, 380, 450]));
assert(isempty(findobj(fig, 'Type', 'colorbar')));
ax = findobj(fig, 'Type', 'axes');
assert(abs(ax.Position(3) - (1 - 80 / 380 - 0.01)) < tol);
assert(strcmp(ax.Title.String, 'first') && strcmp(ax.XLabel.String, 'x') && strcmp(ax.YLabel.String, 'y'));
assert(findobj(ax, 'Type', 'scatter').SizeData == 12);
% tab20 resampled to two colors: the first and the last
assert(isequal(colormap(ax), tab20([1 20], :)));
assert(exist([saveName '.png'], 'file') == 2);
rmdir(tmpDir, 's');

%% base, an RGB matrix colormap and a MATLAB colormap name

% base 20: (r1 + 4) + 20 * (r2 + 4); scenario 1 -> 104, 105, 83; scenario 2 -> 104, 146
rgbMap = [0 0 0; 1 1 1];
[fig, stateCodes, stateLabels] = plotQualitativeStateOverlap({eco1, eco2}, rxns, 'base', 20, 'colormap', rgbMap);
assert(isequal(stateCodes, [83; 104; 105; 146]) && isequal(stateLabels, expectedLabels));
% two base colors resampled to four: rows floor([0 1/3 2/3 1] * 2) + 1, the last capped at 2
axesList = findobj(fig, 'Type', 'axes');
assert(isequal(colormap(axesList(1)), rgbMap([1 1 2 2], :)) && isequal(colormap(axesList(2)), rgbMap([1 1 2 2], :)));
fig = plotQualitativeStateOverlap({eco1, eco2}, rxns, 'colormap', 'parula');
parulaColors = parula(256);
% four of 256 colors: rows floor([0 1/3 2/3 1] * 256) + 1, the last capped at 256
axesList = findobj(fig, 'Type', 'axes');
assert(max(max(abs(colormap(axesList(1)) - parulaColors([1 86 171 256], :)))) < tol);

%% input errors

assert(verifyCobraFunctionError('plotQualitativeStateOverlap', 'inputs', {{eco1, eco2}, {'r1', 'r3'}}, ...
    'testMessage', 'Reactions not found in scenario scen2: r3'));
assert(verifyCobraFunctionError('plotQualitativeStateOverlap', 'inputs', {{eco1}, {'r1'}, 'base', 5}));
assert(verifyCobraFunctionError('plotQualitativeStateOverlap', 'inputs', {'eco', {'r1'}}));
assert(verifyCobraFunctionError('plotQualitativeStateOverlap', 'inputs', {{eco1}, {1}}));

% close the figures of this test and restore the settings
close(setdiff(findall(0, 'Type', 'figure'), figuresBefore));
set(0, 'DefaultFigureVisible', figureVisibility);

% change the directory
cd(currentDir)
