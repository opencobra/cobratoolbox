% The COBRAToolbox: testPlotThermoKernelStats.m
%
% Purpose:
%     - plotThermoKernelStats draws, in one figure with two tiles, the confusion matrices of the
%       reactions and metabolites that thermoKernel was asked to keep or drop (input
%       activeInactiveRxn/presentAbsentMet, overridden by the sign of rxnWeights/metWeights)
%       against those kept in the output model (thermoModelRxnBool/thermoModelMetBool), with the
%       accuracy as subtitle. The test checks, on hand-built vectors, the two tiles, their
%       titles and accuracy subtitles and the column percentages drawn by plotConfMat, for both
%       ways of giving the input (explicit {1, -1, 0} vectors and weights). Expected confusion
%       matrices and accuracies are counted by hand in the comments.
%
% Function under test:
%     src/dataIntegration/XomicsToModel/thermoKernel/plotThermoKernelStats.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; hand-built vectors. Figures are created invisible and
%     closed.
%
% Coverage exemptions:
%     Lines 88-130: unreachable - the alternative layout (one figure per confusion matrix) is
%     the else branch of "if 1" (line 36), dead code.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testPlotThermoKernelStats'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% draw figures invisibly; the default is restored at the end
defaultVisible = get(0, 'DefaultFigureVisible');
set(0, 'DefaultFigureVisible', 'off');

% the percentages are ratios of small integers times 100 and the accuracy is printed by
% num2str (5 significant digits), so the tolerance only absorbs rounding
tol = 1e-12;

%% explicit reaction labels and metabolite weights

% reactions: input (T) = [A I I 0 A], output model (P) = [A A I I A]; reaction 4 is unspecified
% and dropped. Pairs (P, T): (A,A) x2, (A,I) x1, (I,I) x1 -> C = [2 1; 0 1], accuracy 3/4.
% plotConfMat draws 100 * C ./ column sums = [100 50; 0 50].
% metabolites: no labels; weights [-1 0 2] give T = [A 0 I], P = [A I I]; metabolite 2 is
% dropped -> C = [1 0; 0 1], accuracy 1, percentages [100 0; 0 100].
plotThermoKernelStats([1; -1; -1; 0; 1], [], logical([1; 1; 0; 0; 1]), [], [-1; 0; 2], logical([1; 0; 0]));
statsFigure = gcf;
assert(numel(findobj(statsFigure, 'Type', 'tiledlayout')) == 1);
tileAxes = findobj(statsFigure, 'Type', 'axes');
assert(numel(tileAxes) == 2);
titles = arrayfun(@(ax) ax.Title.String, tileAxes, 'UniformOutput', false);
reactionAxes = tileAxes(strcmp(titles, 'Reactions'));
metaboliteAxes = tileAxes(strcmp(titles, 'Metabolites'));
assert(numel(reactionAxes) == 1 && numel(metaboliteAxes) == 1);
assert(strcmp(reactionAxes.Subtitle.String, 'Accuracy = 0.75'));
assert(strcmp(metaboliteAxes.Subtitle.String, 'Accuracy = 1'));
reactionImage = findobj(reactionAxes, 'Type', 'image');
metaboliteImage = findobj(metaboliteAxes, 'Type', 'image');
assert(max(max(abs(reactionImage.CData - [100 50; 0 50]))) < tol);
assert(max(max(abs(metaboliteImage.CData - [100 0; 0 100]))) < tol);
assert(isequal(reactionAxes.XTickLabel, {'Active'; 'Inactive'}));
assert(strcmp(reactionAxes.XLabel.String, 'Input weights') && strcmp(reactionAxes.YLabel.String, 'Output model'));
close(statsFigure);

%% reaction weights and explicit metabolite labels

% reactions: no labels; weights [-2 0 3 -1] give T = [A 0 I A], P = [I A A A]; reaction 2 is
% dropped. Pairs: (I,A), (A,I), (A,A) -> C = [1 1; 1 0], accuracy 1/3 (printed 0.33333),
% percentages 100 * C ./ [2 1] = [50 100; 50 0].
% metabolites: labels [1 -1 0 -1], no weights, P = [A A I I]; metabolite 3 is dropped.
% Pairs: (A,A), (A,I), (I,I) -> C = [1 1; 0 1], accuracy 2/3 (printed 0.66667),
% percentages 100 * C ./ [1 2] = [100 50; 0 50].
plotThermoKernelStats([], [-2; 0; 3; -1], logical([0; 1; 1; 1]), [1; -1; 0; -1], [], logical([1; 1; 0; 0]));
statsFigure = gcf;
tileAxes = findobj(statsFigure, 'Type', 'axes');
titles = arrayfun(@(ax) ax.Title.String, tileAxes, 'UniformOutput', false);
reactionAxes = tileAxes(strcmp(titles, 'Reactions'));
metaboliteAxes = tileAxes(strcmp(titles, 'Metabolites'));
assert(strcmp(reactionAxes.Subtitle.String, 'Accuracy = 0.33333'));
assert(strcmp(metaboliteAxes.Subtitle.String, 'Accuracy = 0.66667'));
reactionImage = findobj(reactionAxes, 'Type', 'image');
metaboliteImage = findobj(metaboliteAxes, 'Type', 'image');
assert(max(max(abs(reactionImage.CData - [50 100; 50 0]))) < tol);
assert(max(max(abs(metaboliteImage.CData - [100 50; 0 50]))) < tol);
close(statsFigure);

% restore the default figure visibility
set(0, 'DefaultFigureVisible', defaultVisible);

% change the directory
cd(currentDir)
