% The COBRAToolbox: testCobraKruskalwallis.m
%
% Purpose:
%     - cobraKruskalwallis is the plain-MATLAB replacement for kruskalwallis (Statistics and
%       Machine Learning Toolbox). This test checks the MathWorks documentation example (beam
%       strength, p = 0.0018, with ties) against SciPy, the table layout read by the call sites
%       (performStatisticalAnalysis, retrieveModelStats, runNonparametricTests,
%       dimensionalityReductionAndMultivariateAnalysis), NaN removal with numeric groups,
%       categorical groups, the all-tied case (NaN), the default display option, the errors for
%       unsupported input, and (only where the toolbox is installed) parity with kruskalwallis.
%
% Function under test:
%     src/base/utilities/toolboxFree/cobraKruskalwallis.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261111-152503-toolbox-free-remaining, 2026-11-11.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testCobraKruskalwallis'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

relativeError = @(value, reference) abs(value - reference) ./ abs(reference);

%% MathWorks documentation example: beam strength, p = 0.0018 (with ties)

strength = [82 86 79 83 84 85 86 87 74 82 78 75 76 77 79 79 77 78 82 79];
alloy = [repmat({'st'}, 1, 8), repmat({'al1'}, 1, 6), repmat({'al2'}, 1, 6)];
[p, tbl, stats] = cobraKruskalwallis(strength, alloy, 'off');
% SciPy 1.16.3 kruskal (references/g1_stats.py, section kruskalwallis): H = 12.630188499619193,
% p = 0.0018087952739571063 (tie-corrected); ANOVA of the ranks SSg, SSe, SSt = 436.40625,
% 220.09375, 656.5 (exact in binary), sumt = 102, mean ranks 15.9375, 5, 8.75. The sums of
% squares are exact sums of quarter-integers, so they are compared to 1e-12 relative; p uses
% the incomplete gamma function, so 1e-10 relative
assert(round(p, 4) == 0.0018);
assert(relativeError(tbl{2, 5}, 12.630188499619193) < 1e-12 && relativeError(p, 0.0018087952739571063) < 1e-10);
assert(isequal(tbl(1, :), {'Source', 'SS', 'df', 'MS', 'Chi-sq', 'Prob>Chi-sq'}));
assert(isequal(tbl(:, 1)', {'Source', 'Groups', 'Error', 'Total'}));
assert(relativeError(tbl{2, 2}, 436.40625) < 1e-12 && tbl{2, 3} == 2 && relativeError(tbl{2, 4}, 218.203125) < 1e-12);
assert(relativeError(tbl{3, 2}, 220.09375) < 1e-12 && tbl{3, 3} == 17 && relativeError(tbl{3, 4}, 220.09375 / 17) < 1e-12);
assert(relativeError(tbl{4, 2}, 656.5) < 1e-12 && tbl{4, 3} == 19);
assert(isempty(tbl{3, 5}) && isempty(tbl{3, 6}) && isempty(tbl{4, 4}) && isempty(tbl{4, 5}) && isempty(tbl{4, 6}));
assert(tbl{2, 6} == p);
assert(isequal(stats.gnames, {'st'; 'al1'; 'al2'}) && isequal(stats.n, [8 6 6]));
assert(strcmp(stats.source, 'kruskalwallis') && stats.sumt == 102);
assert(max(relativeError(stats.meanranks, [15.9375 5 8.75])) < 1e-14);

%% numeric groups 0..k-1 with NaN in x (runNonparametricTests)

% SciPy 1.16.3 kruskal after removing NaN: H = 1.16015625, p = 0.5598546262141438
y = [0.3; NaN; 1.2; 0.3; 2.2; 5.0; 0.3; 4.1; 3.3; 2.2; 1.0];
groupCode = [0; 1; 1; 2; 0; 2; 1; 2; 0; 1; 0];
[p, tbl, stats] = cobraKruskalwallis(y, groupCode, 'off');
assert(relativeError(tbl{2, 5}, 1.16015625) < 1e-12 && relativeError(p, 0.5598546262141438) < 1e-10);
assert(sum(stats.n) == 10 && isequal(stats.gnames, {'0'; '1'; '2'}));

%% categorical groups and the default display option (no figure is drawn)

figuresBefore = numel(findall(groot, 'Type', 'figure'));
[pCategorical, tblCategorical] = cobraKruskalwallis(strength', categorical(alloy'));
assert(numel(findall(groot, 'Type', 'figure')) == figuresBefore);
% categorical order is alphabetical (al1, al2, st), which does not change H
assert(relativeError(tblCategorical{2, 5}, 12.630188499619193) < 1e-12 && abs(pCategorical - 0.0018087952739571063) < 1e-12);

%% all values tied: the total sum of squares of the ranks is 0, so H and p are NaN

[p, tbl] = cobraKruskalwallis([0 0 0 0], {'a', 'a', 'b', 'b'}, 'off');
assert(isnan(p) && isnan(tbl{2, 5}) && isnan(tbl{2, 6}));
% a single group (no degrees of freedom between groups): no test, p is NaN
assert(isnan(cobraKruskalwallis([1 2 3 4], {'a', 'a', 'a', 'a'}, 'off')));

%% errors: missing group, matrix x, unsupported display option, size mismatch

assert(verifyCobraFunctionError('cobraKruskalwallis', 'inputs', {magic(3)}, ...
    'testMessage', 'cobraKruskalwallis: a grouping variable is required (matrix input without group is not supported).'));
assert(verifyCobraFunctionError('cobraKruskalwallis', 'inputs', {magic(3), {'a', 'b', 'c'}}, ...
    'testMessage', 'cobraKruskalwallis: unsupported option ''matrix x'' (x must be a real numeric vector).'));
assert(verifyCobraFunctionError('cobraKruskalwallis', 'inputs', {[1 2], {'a', 'b'}, 'nodisplay'}, ...
    'testMessage', 'cobraKruskalwallis: unsupported option ''nodisplay'' (displayopt must be ''on'' or ''off'').'));
assert(verifyCobraFunctionError('cobraKruskalwallis', 'inputs', {[1 2], {'a', 'b'}, true}, ...
    'testMessage', 'cobraKruskalwallis: unsupported option ''logical'' (displayopt must be ''on'' or ''off'').'));
assert(verifyCobraFunctionError('cobraKruskalwallis', 'inputs', {[1 2 3], {'a', 'b'}, 'off'}, ...
    'testMessage', 'cobraKruskalwallis: group must have one entry per observation of x.'));

%% parity with kruskalwallis (only where the Statistics and Machine Learning Toolbox is installed)

if exist('kruskalwallis', 'file') == 2 && license('test', 'Statistics_Toolbox')
    rng(20261111);
    yRandom = round(4 * randn(36, 1)) + repelem([0; 1; 2], 12);
    yRandom([3 17]) = NaN;
    groupRandom = repelem({'g1'; 'g2'; 'g3'}, 12);
    [p, tbl, stats] = cobraKruskalwallis(yRandom, groupRandom, 'off');
    [pToolbox, tblToolbox, statsToolbox] = kruskalwallis(yRandom, groupRandom, 'off');
    assert(abs(p - pToolbox) <= 1e-12 * pToolbox && abs(tbl{2, 5} - tblToolbox{2, 5}) <= 1e-12 * tblToolbox{2, 5});
    assert(isequal(tbl(1, :), tblToolbox(1, :)) && isequal(tbl(:, 1), tblToolbox(:, 1)));
    assert(isequal(stats.n, statsToolbox.n) && stats.sumt == statsToolbox.sumt);
    fprintf('parity with kruskalwallis: passed\n');
else
    fprintf('skipped: Statistics and Machine Learning Toolbox not installed\n');
end

% change the directory
cd(currentDir)
