% The COBRAToolbox: testPlotThermoKernelWeights.m
%
% Purpose:
%     - plotThermoKernelWeights draws a bar chart (log scale) of the histogram of thermoKernel
%       weights on metabolites and reactions (negative = incentive, positive = penalty), with a
%       subtitle counting incentivised, unweighted and penalised entries; when the output-model
%       booleans are given it adds the histograms of the incentivised metabolites and reactions
%       omitted from the output model. The test checks, on hand-built integer weights, the bar
%       series, their colours and heights, the subtitle counts, the legend and the axes, for the
%       two-argument and four-argument calls. Expected counts are counted by hand: integer data
%       with a small range are binned by histcounts on unit bins centred on the integers
%       (edges -1.5:1:3.5 here).
%
% Function under test:
%     src/dataIntegration/XomicsToModel/thermoKernel/plotThermoKernelWeights.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; hand-built vectors. Figures are created invisible and
%     closed.
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
fileDir = fileparts(which('testPlotThermoKernelWeights'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% draw figures invisibly; the default is restored at the end
defaultVisible = get(0, 'DefaultFigureVisible');
set(0, 'DefaultFigureVisible', 'off');

% weights: metabolites -1, 0, 0, 2 and reactions -1, -1, 0, 3, 3. Bins (centres -1 ... 3):
% metabolites [1 2 0 1 0], reactions [2 1 0 0 2]; bars are placed at the left bin edges
metWeights = [-1; 0; 0; 2];
rxnWeights = [-1; -1; 0; 3; 3];
expectedX = [-1.5, -0.5, 0.5, 1.5, 2.5];
expectedSubtitle = {'1 incentivised, 2 unweighted, 1 penalised metabolites'; ...
    '2 incentivised, 1 unweighted, 2 penalised reactions'};

% red, green, blue and cyan bars, found by colour (bar counts are integers: exact comparison)
findBar = @(fig, colour) findobj(fig, 'Type', 'bar', 'FaceColor', colour);

%% weights only: two series, metabolites (red) and reactions (blue)

plotThermoKernelWeights(metWeights, rxnWeights);
weightsFigure = gcf;
assert(numel(findobj(weightsFigure, 'Type', 'bar')) == 2);
metaboliteBar = findBar(weightsFigure, [1 0 0]);
reactionBar = findBar(weightsFigure, [0 0 1]);
assert(isequal(metaboliteBar.YData, [1 2 0 1 0]) && isequal(reactionBar.YData, [2 1 0 0 2]));
assert(isequal(metaboliteBar.XData, expectedX) && isequal(reactionBar.XData, expectedX));
weightsAxes = gca;
assert(strcmp(weightsAxes.YScale, 'log'));
assert(strcmp(weightsAxes.Title.String, 'Incentivised(-ve), ambivalent(0), and penalised(+ve)'));
assert(isequal(cellstr(weightsAxes.Subtitle.String), expectedSubtitle));
assert(strcmp(weightsAxes.XLabel.String, 'ThermoKernel Weights') && strcmp(weightsAxes.YLabel.String, 'Counts (log scale)'));
weightsLegend = findobj(weightsFigure, 'Type', 'legend');
assert(isequal(weightsLegend.String, {'metabolites', 'reactions'}));
close(weightsFigure);

%% weights and output-model booleans: omitted incentivised entries (green, cyan)

% metabolite 1 (weight -1) and reaction 2 (weight -1) are incentivised but absent from the
% output model, so each omitted series has one count in the bin of -1
plotThermoKernelWeights(metWeights, rxnWeights, logical([0; 1; 1; 0]), logical([1; 0; 1; 1; 1]));
weightsFigure = gcf;
assert(numel(findobj(weightsFigure, 'Type', 'bar')) == 4);
metaboliteBar = findBar(weightsFigure, [1 0 0]);
metaboliteOmittedBar = findBar(weightsFigure, [0 1 0]);
reactionBar = findBar(weightsFigure, [0 0 1]);
reactionOmittedBar = findBar(weightsFigure, [0 1 1]);
assert(isequal(metaboliteBar.YData, [1 2 0 1 0]) && isequal(reactionBar.YData, [2 1 0 0 2]));
assert(isequal(metaboliteOmittedBar.YData, [1 0 0 0 0]) && isequal(reactionOmittedBar.YData, [1 0 0 0 0]));
weightsAxes = gca;
assert(strcmp(weightsAxes.YScale, 'log'));
assert(strcmp(weightsAxes.Title.String, 'Incentivised(-ve), ambivalent(0), and penalised(+ve)'));
assert(isequal(cellstr(weightsAxes.Subtitle.String), expectedSubtitle));
weightsLegend = findobj(weightsFigure, 'Type', 'legend');
assert(isequal(weightsLegend.String, {'metabolites', 'metabolites omitted', 'reactions', 'reactions omitted'}));
close(weightsFigure);

% restore the default figure visibility
set(0, 'DefaultFigureVisible', defaultVisible);

% change the directory
cd(currentDir)
