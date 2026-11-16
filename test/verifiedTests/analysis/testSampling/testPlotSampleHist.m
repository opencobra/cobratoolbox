% The COBRAToolbox: testPlotSampleHist.m
%
% Purpose:
%     - plotSampleHist draws, in a new figure, one subplot per reaction with the smoothed and
%       normalised flux histogram of each sample, optionally with marker lines and labels
%       (add2Plot). This test uses hand-written samples of two createModel models and checks
%       the drawn objects against values worked out from the inputs: the reactions kept (only
%       those present in every model), the bin centres linspace(min, max, nBins), the
%       normalisation of each histogram to 1, the look-up of each reaction by name in each
%       model, the rescaling of a constant flux, the axis limits widened for add2Plot, the
%       labels, the legend and the figure size for two rows of subplots.
%
% Function under test:
%     src/analysis/sampling/plotSampleHist.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - createModel models, hand-written samples, invisible figures, no solver.
%
% Coverage exemptions:
%     Lines 131-138, 159-164: unreachable by any input (dead code). Reactions absent from any
%     model are removed at lines 91-106, and findRxnIDs returns 0, not an empty array, for an
%     absent name, so isempty(id) at lines 130 and 158 is never true.
%     Lines 207-215, 218-219, 221: interactive paging with input(), reached only when there are
%     more reactions than perScreen (GUI / keyboard interaction).
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The subplot grid is transposed for perScreen = [nY, nX]
%       SEVERITY: cosmetic
%       TRIGGER: perScreen = [1 2] (documented as [nY, nX], one row of two plots)
%       OBSERVED: line 171 calls subplot(nX, nY, ...), so the plots are drawn in two rows of one
%       (read from the code; the layout is not asserted below)
%       EXPECTED: subplot(nY, nX, ...), one row of two plots
%       LINES: 171
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testPlotSampleHist'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox or
% particular operating system, so none is listed; the call is the standard opening of a COBRA
% test and the place where a requirement would be added later
prepareTest();

% figures are created invisible; the default is restored at the end
defaultVisibility = get(0, 'DefaultFigureVisible');
set(0, 'DefaultFigureVisible', 'off');

% model 1 has r1, r2, r3; model 2 has r2 and r1 (in that order) and no r3
model1 = createModel({'r1', 'r2', 'r3'}, {'r1', 'r2', 'r3'}, {'A -> B', 'B -> C', 'C -> '}, 'printLevel', 0);
model2 = createModel({'r2', 'r1'}, {'r2', 'r1'}, {'B -> C', 'A -> B'}, 'printLevel', 0);
% 50 points: r1 runs from 0.1 to 5, r2 cycles through 0..4, r3 is constant (5)
fluxR1 = (1:50) / 10;
fluxR2 = mod(0:49, 5);
samples1 = [fluxR1; fluxR2; 5 * ones(1, 50)];
% the same fluxes in the row order of model 2: identical histograms prove the name look-up
samples2 = [fluxR2; fluxR1];

% bin centres must be reproduced to rounding (linspace of the same end points)
tol = 1e-12;

%% defaults: one sample, nBins = round(50 / 25) = 2, default legend

figuresBefore = findall(0, 'Type', 'figure');
plotSampleHist({'r1', 'r2'}, {samples1}, {model1});
newFigure = setdiff(findall(0, 'Type', 'figure'), figuresBefore);
assert(numel(newFigure) == 1);
axesHandles = findobj(newFigure, 'Type', 'axes');
assert(numel(axesHandles) == 2);
for i = 1:2
    label = get(get(axesHandles(i), 'XLabel'), 'String');
    lineHandle = findobj(axesHandles(i), 'Type', 'line');
    assert(numel(lineHandle) == 1);
    % the reaction is named in the first line of the label
    if strcmp(label{1}, 'Flux of r1 ')
        expectedBins = linspace(0.1, 5, 2);
    else
        assert(strcmp(label{1}, 'Flux of r2 '));
        expectedBins = linspace(0, 4, 2);
    end
    assert(strcmp(label{2}, '(mmol/gDW/h)'));
    assert(max(abs(get(lineHandle, 'XData') - expectedBins)) < tol);
    % each histogram is normalised to a total frequency of 1
    assert(abs(sum(get(lineHandle, 'YData')) - 1) < tol);
end
legendHandle = findobj(newFigure, 'Type', 'legend');
assert(numel(legendHandle) == 1 && isequal(get(legendHandle, 'String'), {'Model 1'}));
close(newFigure);

%% two samples and models, a reaction missing from model 2, perScreen [1 2], add2Plot

add2Plot(1).line = 50;
add2Plot(1).label = 'measured';
add2Plot(2).line = 1;
add2Plot(2).label = 'fva';
figuresBefore = findall(0, 'Type', 'figure');
plotSampleHist({'r1', 'r2', 'r3'}, {samples1, samples2}, {model1, model2}, 10, [1 2], {'m1', 'm2'}, add2Plot);
newFigure = setdiff(findall(0, 'Type', 'figure'), figuresBefore);
axesHandles = findobj(newFigure, 'Type', 'axes');
% r3 is not in model 2, so only r1 and r2 are plotted
assert(numel(axesHandles) == 2);
for i = 1:2
    label = get(get(axesHandles(i), 'XLabel'), 'String');
    isR1 = strcmp(label{1}, 'Flux of r1 ');
    % two histograms (one per sample, drawn with '-') and two dashed marker lines
    dataLines = findobj(axesHandles(i), 'Type', 'line', 'LineStyle', '-');
    markerLines = findobj(axesHandles(i), 'Type', 'line', 'LineStyle', '--');
    assert(numel(dataLines) == 2 && numel(markerLines) == 2);
    if isR1
        expectedBins = linspace(0.1, 5, 10);
    else
        expectedBins = linspace(0, 4, 10);
    end
    assert(max(abs(get(dataLines(1), 'XData') - expectedBins)) < tol);
    % the same fluxes in both samples give the same histogram: model 2 finds r1 in its row 2
    assert(isequal(get(dataLines(1), 'YData'), get(dataLines(2), 'YData')));
    % marker lines at x = 50 and x = 1, with their labels
    assert(isequal(sort(cellfun(@(x) x(1), get(markerLines, 'XData'))), [1; 50]));
    textHandles = findobj(axesHandles(i), 'Type', 'text');
    assert(isequal(sort(get(textHandles, 'String')), {'fva'; 'measured'}));
    % the x axis is widened to 1.1 times the largest marker line (55)
    xLimits = get(axesHandles(i), 'XLim');
    assert(abs(xLimits(2) - 55) < tol);
    assert(abs(xLimits(1) - expectedBins(1)) < tol);
end
legendHandle = findobj(newFigure, 'Type', 'legend');
legendText = get(legendHandle, 'String');
assert(isequal(legendText(1:2), {'m1', 'm2'}));
close(newFigure);

%% one common model, a matrix of samples, three reactions (two rows) and a constant flux

figuresBefore = findall(0, 'Type', 'figure');
plotSampleHist({'r1', 'r2', 'r3'}, samples1, model1, 4);
newFigure = setdiff(findall(0, 'Type', 'figure'), figuresBefore);
axesHandles = findobj(newFigure, 'Type', 'axes');
assert(numel(axesHandles) == 3);
for i = 1:3
    label = get(get(axesHandles(i), 'XLabel'), 'String');
    if strcmp(label{1}, 'Flux of r3 ')
        % r3 is constant (5): the range is widened by 8 * eps * 5 on each side
        lineHandle = findobj(axesHandles(i), 'Type', 'line');
        bins = get(lineHandle, 'XData');
        assert(numel(bins) == 4 && bins(1) < 5 && bins(end) > 5);
        assert(abs((bins(end) - bins(1)) - 16 * eps * 5) < 4 * eps * 5);
    end
end
% three reactions: nX = 2, nY = 2, so the figure is 420 + 420 / (3 / 2) = 700 points high
set(newFigure, 'Units', 'points');
assert(max(abs(get(newFigure, 'Position') - [10 10 560 700])) < 1e-6);
close(newFigure);

%% one reaction given as a string, empty model names, scalar perScreen

figuresBefore = findall(0, 'Type', 'figure');
plotSampleHist('r2', {samples1}, {model1}, 3, 5, [], []);
newFigure = setdiff(findall(0, 'Type', 'figure'), figuresBefore);
axesHandles = findobj(newFigure, 'Type', 'axes');
assert(numel(axesHandles) == 1);
label = get(get(axesHandles, 'XLabel'), 'String');
assert(strcmp(label{1}, 'Flux of r2 '));
assert(max(abs(get(findobj(axesHandles, 'Type', 'line'), 'XData') - linspace(0, 4, 3))) < tol);
assert(isequal(get(findobj(newFigure, 'Type', 'legend'), 'String'), {'Model 1'}));
close(newFigure);

% restore the figure default and the directory
set(0, 'DefaultFigureVisible', defaultVisibility);
cd(currentDir)
