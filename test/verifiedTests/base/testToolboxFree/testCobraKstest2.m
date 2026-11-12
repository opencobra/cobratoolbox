% The COBRAToolbox: testCobraKstest2.m
%
% Purpose:
%     - cobraKstest2 is the plain-MATLAB replacement for kstest2 (Statistics and Machine
%       Learning Toolbox). This test checks the MathWorks documentation numbers (D = 0.28,
%       n1 = n2 = 50: p = 0.0158 one-sided, 0.0317 two-sided) on data with the same statistic,
%       the statistics of the three tails against SciPy, the p-values against the Stephens
%       formula, the positional form (alpha, tail) used by compareTwoSamplesStat, numeric tail
%       codes, NaN removal, the clip of the two-sided series, the errors for unsupported options
%       and empty samples, and (only where the toolbox is installed) parity with kstest2.
%
% Function under test:
%     src/base/utilities/toolboxFree/cobraKstest2.m
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
fileDir = fileparts(which('testCobraKstest2'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

relativeError = @(value, reference) abs(value - reference) ./ abs(reference);

%% documentation numbers: D = 0.28 with n1 = n2 = 50

% x = 0:49 and y = 14:63 give F1 - F2 = 0.28 at its maximum (the documentation example's D).
% references/g1_stats.py (section kstest2): one-sided p = 0.015830485828401256, two-sided
% p = 0.03166084605179076 (equal to SciPy kstwobign.sf of the same lambda); the documentation
% reports 0.0158 and 0.0317. Sums of exponentials: 1e-12 relative
[h, p, k] = cobraKstest2(0:49, 14:63, 'Tail', 'larger');
assert(abs(k - 0.28) < 1e-14 && relativeError(p, 0.015830485828401256) < 1e-12 && h == true);
[h, p, k] = cobraKstest2(0:49, 14:63, 'Alpha', 0.01);
assert(abs(k - 0.28) < 1e-14 && relativeError(p, 0.03166084605179076) < 1e-12 && h == false);
assert(round(p, 4) == 0.0317);
% the other one-sided statistic of these data is 0, so p = 1
[~, p, k] = cobraKstest2(0:49, 14:63, 'tail', 'smaller');
assert(k == 0 && p == 1);

%% statistics of the three tails against SciPy, positional form of compareTwoSamplesStat

% SciPy 1.16.3 ks_2samp statistics (two-sided, 'greater', 'less') with Stephens p-values
a = [0.0 0.3 -0.27 -0.89 -0.45 -0.99 0.06 1.34 -0.49 -0.62 0.49 0.36 0.11 -0.93 -0.03 0.7 -1.34 -0.46 -1.9 -1.29 -1.84 -0.24 -1.27];
b = [0.75 0.6 0.16 -2.87 -0.3 0.34 0.55 -1.59 -0.22 -0.87 -0.65 1.78 -0.65 0.36 1.55 -0.36 0.25 0.54 0.48 -1.19 0.5 2.17 -1.61 1.52 0.56 -0.43 3.0 1.39 -1.16 0.5 1.15];
[~, p, k] = cobraKstest2(a, b);
assert(relativeError(k, 0.3955119214586255) < 1e-14 && relativeError(p, 0.022675036148070222) < 1e-12);
[h, p, k] = cobraKstest2(a, b, 0.01, 'larger');
assert(relativeError(k, 0.3955119214586255) < 1e-14 && relativeError(p, 0.0113375345964872) < 1e-12 && h == false);
[~, p, k] = cobraKstest2(a, b, 0.01, 'smaller');
assert(relativeError(k, 0.03225806451612903) < 1e-14 && relativeError(p, 0.970640710521884) < 1e-12);
% numeric tail codes 1 and -1, empty alpha keeps the default, columns and NaN removal
[~, pCode] = cobraKstest2(a', [b NaN]', [], 1);
assert(relativeError(pCode, 0.0113375345964872) < 1e-12);
[~, pCode] = cobraKstest2(a, b, 0.05, -1);
assert(relativeError(pCode, 0.970640710521884) < 1e-12);
[~, pCode] = cobraKstest2(a, b, 0.05, 0);
assert(relativeError(pCode, 0.022675036148070222) < 1e-12);
% positional alpha only
[h, pAlphaOnly] = cobraKstest2(a, b, 0.03);
[~, pDefault] = cobraKstest2(a, b);
assert(h == true && pAlphaOnly == pDefault);

%% identical samples: D = 0, the two-sided series is clipped to 1

[h, p, k] = cobraKstest2([1 2 3], [3 2 1]);
assert(k == 0 && p == 1 && h == false);

%% errors: unknown option, odd name-value list, bad tail, too many positional arguments, empty sample

assert(verifyCobraFunctionError('cobraKstest2', 'inputs', {a, b, 'Method', 'exact'}, ...
    'testMessage', 'cobraKstest2: unsupported option ''Method'' (options are name-value pairs ''Alpha'' and ''Tail'').'));
assert(verifyCobraFunctionError('cobraKstest2', 'inputs', {a, b, 'Tail'}, ...
    'testMessage', 'cobraKstest2: unsupported option ''Tail'' (options are name-value pairs ''Alpha'' and ''Tail'').'));
assert(verifyCobraFunctionError('cobraKstest2', 'inputs', {a, b, 'Tail', 'both'}, ...
    'testMessage', 'cobraKstest2: unsupported option ''Tail'' value ''both'' (use ''unequal'', ''larger'' or ''smaller'').'));
assert(verifyCobraFunctionError('cobraKstest2', 'inputs', {a, b, 0.05, 2}, ...
    'testMessage', 'cobraKstest2: unsupported option ''Tail'' value ''2'' (use ''unequal'', ''larger'' or ''smaller'').'));
assert(verifyCobraFunctionError('cobraKstest2', 'inputs', {a, b, 0.05, 'larger', {1}}, ...
    'testMessage', 'cobraKstest2: unsupported option ''cell'' (positional form is cobraKstest2(x1, x2, alpha, tail)).'));
assert(verifyCobraFunctionError('cobraKstest2', 'inputs', {[NaN NaN], b}, ...
    'testMessage', 'cobraKstest2: each sample needs at least one value that is not NaN.'));

%% parity with kstest2 (only where the Statistics and Machine Learning Toolbox is installed)

if exist('kstest2', 'file') == 2 && license('test', 'Statistics_Toolbox')
    tails = {'unequal', 'larger', 'smaller'};
    for t = 1:3
        [h, p, k] = cobraKstest2(a, b, 'Tail', tails{t});
        [hToolbox, pToolbox, kToolbox] = kstest2(a, b, 'Tail', tails{t});
        assert(h == hToolbox && abs(p - pToolbox) <= 1e-12 * pToolbox && abs(k - kToolbox) <= 1e-14);
    end
    [~, p] = cobraKstest2(a, b, 0.01, 'larger');
    [~, pToolbox] = kstest2(a, b, 0.01, 'larger');
    assert(abs(p - pToolbox) <= 1e-12 * pToolbox);
    fprintf('parity with kstest2: passed\n');
else
    fprintf('skipped: Statistics and Machine Learning Toolbox not installed\n');
end

% change the directory
cd(currentDir)
