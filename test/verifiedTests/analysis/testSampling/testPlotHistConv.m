% The COBRAToolbox: testPlotHistConv.m
%
% Purpose:
%     - plotHistConv clears the current figure and draws, for each requested reaction found
%       in model.rxns, one subplot with the normalised 20-bin histograms of growing
%       sub-samples (sub-sample i = every 10th of the first i * floor(nSamples /
%       nSubSamples) points), axis limits spanning all bin centres and the highest
%       frequency, and the reaction name as title. The test builds samples whose every 10th
%       column holds evenly spaced values, so the bin centres and frequencies follow by hand
%       from the rule of hist (nBin equal bins between the minimum and the maximum, centres
%       at the bin middles): each value falls in its own bin.
%
% Function under test:
%     src/analysis/sampling/plotHistConv.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - a three-reaction createModel model (only model.rxns is read) and a hand-built
%     sample matrix; no solver.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testPlotHistConv'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% figures are created invisible; the default is restored at the end
defaultVisibility = get(0, 'DefaultFigureVisible');
set(0, 'DefaultFigureVisible', 'off');

model = createModel({'R1'; 'R2'; 'R3'}, {'one'; 'two'; 'three'}, {' -> A'; 'A -> B'; 'B -> '}, ...
    [], zeros(3, 1), 10 * ones(3, 1));

% 200 samples, 2 sub-samples of size 100: sub-sample 1 uses columns 1:10:100 (10 points),
% sub-sample 2 columns 1:10:200 (20 points). The other columns are never read; they hold
% values far outside the plotted range so that reading them would change the axes.
sample = 1000 * ones(3, 200);
sample(1, 1:10:200) = 0:19;
sample(3, 1:10:200) = 2 * (0:19) - 5;

% bin geometry worked out by hand: a sub-sample with minimum lo and maximum hi has 20 bins
% of width w = (hi - lo) / 20 and centres lo + w / 2 ... hi - w / 2. Values spaced more than
% w apart fall in distinct bins, so every non-empty bin holds one value: the normalised
% frequency is 1/10 for sub-sample 1 and 1/20 for sub-sample 2.
% R1: sub-sample 1 is 0..9 (w = 0.45), sub-sample 2 is 0..19 (w = 0.95)
% R3: sub-sample 1 is -5..13 (w = 0.9), sub-sample 2 is -5..33 (w = 1.9)
expectedXLim.R1 = [0 + 0.45 / 2, 19 - 0.95 / 2];
expectedXLim.R3 = [-5 + 0.9 / 2, 33 - 1.9 / 2];
% tolerance: bin centres are sums of a few binary fractions, exact to well below 1e-12
tol = 1e-12;

%% reactions not in the model are skipped; one subplot per reaction, previous content cleared

figureHandle = figure;
title(axes(figureHandle), 'previous content');
plotHistConv(model, sample, {'R1', 'R3', 'notInModel'}, 2);
axesHandles = findobj(figureHandle, 'Type', 'axes');
% two reactions found: a 1 x 2 grid (ceil(sqrt(2)) = 2 columns); the earlier axes are gone
assert(numel(axesHandles) == 2);
titles = arrayfun(@(a) get(get(a, 'Title'), 'String'), axesHandles, 'UniformOutput', false);
assert(isempty(setxor(titles, {'R1'; 'R3'})));
% R1 is the first subplot (left), R3 the second (right), on the same row
positions = cell2mat(get(axesHandles, 'Position'));
leftIsR1 = strcmp(titles, 'R1');
assert(positions(leftIsR1, 1) < positions(~leftIsR1, 1));
assert(abs(positions(1, 2) - positions(2, 2)) < tol);

%% each subplot holds one normalised histogram per sub-sample and the axes span them

for i = 1:numel(axesHandles)
    lineHandles = findobj(axesHandles(i), 'Type', 'line');
    assert(numel(lineHandles) == 2);
    % 20 bins per histogram; the frequencies of each histogram sum to 1
    yData = get(lineHandles, 'YData');
    assert(all(cellfun(@numel, yData) == 20));
    assert(all(abs(cellfun(@sum, yData) - 1) < tol));
    % the highest frequencies are 1/10 (10 points) and 1/20 (20 points)
    assert(all(abs(sort(cellfun(@max, yData)) - [1 / 20; 1 / 10]) < tol));
    % x limits: the smallest and largest bin centres; y limits: 0 to the highest frequency
    assert(all(abs(xlim(axesHandles(i)) - expectedXLim.(titles{i})) < tol));
    assert(all(abs(ylim(axesHandles(i)) - [0 1 / 10]) < tol));
end
close(figureHandle);

%% no requested reaction in the model: the figure is cleared and nothing is drawn

figureHandle = figure;
axes(figureHandle);
plotHistConv(model, sample, {'notInModel'}, 2);
assert(isempty(findobj(figureHandle, 'Type', 'axes')));
close(figureHandle);

% restore the figure default and the directory
set(0, 'DefaultFigureVisible', defaultVisibility);
cd(currentDir)
