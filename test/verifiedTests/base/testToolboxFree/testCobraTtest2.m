% The COBRAToolbox: testCobraTtest2.m
%
% Purpose:
%     - cobraTtest2 is the plain-MATLAB replacement for ttest2 (Statistics and Machine Learning
%       Toolbox, defaults: equal variances, two-sided, alpha 0.05). This test checks the
%       statistic, p-value, confidence interval and stats fields against SciPy, NaN removal,
%       row and column orientation of ci, the zero-variance cases, the errors for unsupported
%       options, and (only where the toolbox is installed) parity with ttest2.
%
% Function under test:
%     src/base/utilities/toolboxFree/cobraTtest2.m
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
fileDir = fileparts(which('testCobraTtest2'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

relativeError = @(value, reference) abs(value - reference) ./ abs(reference);

%% values against SciPy (row vectors, as in compareTwoSamplesStat; NaN removed)

% references/g1_stats.py (section ttest2), SciPy 1.16.3 ttest_ind(equal_var=True,
% nan_policy='omit'): t = -4.240212003036458, p = 0.0013883787299132134, df = 11,
% sd = 0.46225496609517736, ci = [-1.6565143769968491, -0.524438003955533]. p and ci go through
% the incomplete beta function and its inverse, so 1e-10 relative
x = [5.1 4.9 6.2 5.8 6.0 5.5 5.3 NaN];
y = [6.4 6.8 5.9 7.1 6.6 7.0];
[h, p, ci, stats] = cobraTtest2(x, y);
assert(h == 1 && isa(h, 'double'));
assert(relativeError(p, 0.0013883787299132134) < 1e-10);
assert(isequal(size(ci), [1 2]) && max(relativeError(ci, [-1.6565143769968491 -0.524438003955533])) < 1e-10);
assert(relativeError(stats.tstat, -4.240212003036458) < 1e-12 && stats.df == 11);
assert(relativeError(stats.sd, 0.46225496609517736) < 1e-12);

%% column vectors (optimalScores) give a column ci and the same p

[h, pColumn, ciColumn] = cobraTtest2(x', y');
assert(pColumn == p && isequal(size(ciColumn), [2 1]) && isequal(ciColumn', ci) && h == 1);

%% zero pooled standard deviation: t = Inf gives p = 0; equal means give NaN and h = NaN

[h, p, ~, stats] = cobraTtest2([2 2 2], [1 1]);
assert(stats.tstat == Inf && p == 0 && h == 1);
[h, p] = cobraTtest2([3 3], [3 3 3]);
assert(isnan(p) && isnan(h));

%% errors: any further argument, non-vector input

assert(verifyCobraFunctionError('cobraTtest2', 'inputs', {x, y, 'Vartype', 'unequal'}, ...
    'testMessage', 'cobraTtest2: unsupported option ''Vartype'' (only the syntax cobraTtest2(x, y) is supported).'));
assert(verifyCobraFunctionError('cobraTtest2', 'inputs', {x, y, 0.01}, ...
    'testMessage', 'cobraTtest2: unsupported option ''double'' (only the syntax cobraTtest2(x, y) is supported).'));
assert(verifyCobraFunctionError('cobraTtest2', 'inputs', {magic(3), y}, ...
    'testMessage', 'cobraTtest2: x and y must be numeric vectors.'));

%% parity with ttest2 (only where the Statistics and Machine Learning Toolbox is installed)

if exist('ttest2', 'file') == 2 && license('test', 'Statistics_Toolbox')
    rng(20261111);
    xRandom = randn(1, 20);
    yRandom = randn(1, 13) + 0.4;
    [h, p, ci, stats] = cobraTtest2(xRandom, yRandom);
    [hToolbox, pToolbox, ciToolbox, statsToolbox] = ttest2(xRandom, yRandom);
    assert(h == hToolbox && abs(p - pToolbox) <= 1e-12 * pToolbox && max(abs(ci - ciToolbox)) <= 1e-12);
    assert(abs(stats.tstat - statsToolbox.tstat) <= 1e-12 * abs(statsToolbox.tstat) && stats.df == statsToolbox.df);
    fprintf('parity with ttest2: passed\n');
else
    fprintf('skipped: Statistics and Machine Learning Toolbox not installed\n');
end

% change the directory
cd(currentDir)
