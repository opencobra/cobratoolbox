% The COBRAToolbox: testPlotThermoKernelExtractStats.m
%
% Purpose:
%     - plotThermoKernelExtractStats plots histograms of the reaction and metabolite weights
%       given to thermoKernel and confusion matrices that compare the sign of each nonzero
%       weight (negative = wanted active/present, positive = wanted inactive/absent) with
%       whether the reaction or metabolite was kept in the extracted model. The test checks
%       that nothing is plotted for all-zero weights, and for nonzero weights the figures,
%       titles, accuracies and the percentages shown, worked out by hand from the inputs.
%       The file defines the function plotThermoModelExtractStats; MATLAB runs it under the
%       file name, which is what the test calls.
%
% Function under test:
%     src/dataIntegration/XomicsToModel/thermoKernel/plotThermoKernelExtractStats.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - reporting on hand-built weight vectors, no model and no solver; figures are
%     invisible and closed.
%
% Coverage exemptions:
%     Lines 25-35, 39-46, 51-58, 65-66, 86-89, 104, 134-137, 150: dead code, unreachable by any
%     input - each lies in a branch selected by a constant (if 0, if 1, or "&& 0" at lines
%     24, 38, 50, 80, 103, 128 and 149).
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testPlotThermoKernelExtractStats'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

defaultVisible = get(0, 'DefaultFigureVisible');
set(0, 'DefaultFigureVisible', 'off');

% the model is not read by the function; only the weights and kept/removed flags are
model = struct('h0', zeros(3, 1));

% percentages and accuracies are ratios of small integers; 1e-12 only absorbs rounding
tol = 1e-12;

%% all-zero weights: nothing is plotted

figuresBefore = findall(0, 'Type', 'figure');
plotThermoKernelExtractStats(model, zeros(4, 1), zeros(4, 1), zeros(3, 1), zeros(3, 1), ...
    true(3, 1), true(4, 1));
assert(isempty(setdiff(findall(0, 'Type', 'figure'), figuresBefore)));

%% nonzero reaction and metabolite weights: histograms and confusion matrices

% reactions: weights [-1 2 0 -3], kept [1 0 1 0]. Nonzero weights: reactions 1, 2, 4 with
% kept/wanted pairs (Active, Active), (Inactive, Inactive), (Inactive, Active); with the
% kept state as rows and the wanted state as columns C = [1 0; 1 1], accuracy 2/3, column
% percentages [50 0; 50 100].
% metabolites: weights [-2 0 1], kept [1 1 0]. Nonzero weights: metabolites 1 and 3 with
% pairs (Active, Active), (Inactive, Inactive): C = eye(2), accuracy 1, percentages 100*eye(2).
rxnWeights = [-1; 2; 0; -3];
metWeights = [-2; 0; 1];
figuresBefore = findall(0, 'Type', 'figure');
plotThermoKernelExtractStats(model, [1; -1; 0; 1], rxnWeights, [1; 0; -1], metWeights, ...
    logical([1; 1; 0]), logical([1; 0; 1; 0]));
newFigures = setdiff(findall(0, 'Type', 'figure'), figuresBefore);
assert(numel(newFigures) == 4);

newAxes = findall(newFigures, 'Type', 'axes');
axesTitles = arrayfun(@(ax) ax.Title.String, newAxes, 'UniformOutput', false);
assert(isequal(sort(axesTitles), sort({'Reaction weights'; 'Metabolite weights'; ...
    'Reaction confusion matrix, accuracy = 0.66667'; 'Metabolite confusion matrix, accuracy = 1'})));

% the confusion matrices are drawn as images of the column percentages
rxnAxes = newAxes(strcmp(axesTitles, 'Reaction confusion matrix, accuracy = 0.66667'));
rxnImage = findobj(rxnAxes, 'Type', 'image');
assert(max(max(abs(rxnImage.CData - [50 0; 50 100]))) < tol);
assert(isequal(rxnAxes.XTickLabel, {'Active'; 'Inactive'}));
metAxes = newAxes(strcmp(axesTitles, 'Metabolite confusion matrix, accuracy = 1'));
metImage = findobj(metAxes, 'Type', 'image');
assert(max(max(abs(metImage.CData - [100 0; 0 100]))) < tol);

% each histogram axes holds the drawn bars
rxnHistAxes = newAxes(strcmp(axesTitles, 'Reaction weights'));
assert(~isempty(rxnHistAxes.Children));
metHistAxes = newAxes(strcmp(axesTitles, 'Metabolite weights'));
assert(~isempty(metHistAxes.Children));

close(newFigures);
set(0, 'DefaultFigureVisible', defaultVisible);

% change the directory
cd(currentDir)
