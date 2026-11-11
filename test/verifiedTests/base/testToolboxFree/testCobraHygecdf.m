% The COBRAToolbox: testCobraHygecdf.m
%
% Purpose:
%     - cobraHygecdf is the plain-MATLAB replacement for hygecdf (Statistics and Machine
%       Learning Toolbox). This test checks the MathWorks documentation values (lower tail
%       0:8 and upper tail [7 8] for M = 100, K = 20, N = 10) against SciPy, the column call of
%       FEA (x = counts - 1 with a per-subsystem K, 'upper'), a large population with a small
%       upper tail, non-integer x, values outside the support, invalid parameters, scalar
%       expansion, the errors for unsupported options and invalid input, and (only where the
%       toolbox is installed) parity with hygecdf.
%
% Function under test:
%     src/base/utilities/toolboxFree/cobraHygecdf.m
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
fileDir = fileparts(which('testCobraHygecdf'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

relativeError = @(value, reference) abs(value - reference) ./ abs(reference);

%% MathWorks documentation values (M = 100, K = 20, N = 10)

% references/g1_stats.py (section hygecdf), SciPy 1.16.3 hypergeom.cdf / hypergeom.sf; the
% documentation shows 0.0951 0.3630 0.6812 0.8904 0.9745 0.9961 0.9996 1.0000 1.0000 and
% 2.378e-05, 7.9e-07. Each term is exp of a sum of gammaln values (about 1e-14 relative error
% each), so 1e-11 relative
refLower = [0.09511627243078843 0.36304943420765723 0.6812200638176888 0.8904281490407234 0.9745354535729569 0.9960669235332087 0.9996082837240395 0.9999762172503596 0.9999992130957547];
assert(max(relativeError(cobraHygecdf(0:8, 100, 20, 10), refLower)) < 1e-11);
refUpper = [2.378274964037914e-05 7.869042453734031e-07];
assert(max(relativeError(cobraHygecdf([7 8], 100, 20, 10, 'upper'), refUpper)) < 1e-11);
% the option is case-insensitive and may be a string
assert(isequal(cobraHygecdf(7, 100, 20, 10, "UPPER"), cobraHygecdf(7, 100, 20, 10, 'upper')));

%% FEA call: column x = counts - 1 with a column K, scalar M and N, upper tail

% SciPy 1.16.3 hypergeom.sf(x - 1, 95, K, 12)
counts = [2; 0; 5; 1; 3];
subsystemSizes = [10; 3; 7; 40; 25];
refFea = [0.3689562987672936; 1.0; 0.0002509175338044773; 0.9991973257899806; 0.6638285017653349];
pFea = cobraHygecdf(counts - 1, 95, subsystemSizes, 12, 'upper');
assert(isequal(size(pFea), [5 1]) && max(relativeError(pFea, refFea)) < 1e-11);
% x = -1 lies below the support: the upper tail is 1 (R14 returned NaN; FEA discards it)
assert(pFea(2) == 1);

%% large population, small upper tail kept to relative accuracy

% SciPy 1.16.3: hypergeom.sf(30, 5000, 200, 300) = 6.604763785041544e-07, cdf = 0.9999993395236215.
% gammaln(5001) is about 3.8e4, so each log-term carries an absolute rounding error of about
% eps*3.8e4 = 1e-11, which is the relative error of each term: 1e-10 relative
assert(relativeError(cobraHygecdf(30, 5000, 200, 300, 'upper'), 6.604763785041544e-07) < 1e-10);
assert(relativeError(cobraHygecdf(30, 5000, 200, 300), 0.9999993395236215) < 1e-10);

%% non-integer x is rounded down; support limits and invalid parameters

assert(cobraHygecdf(2.7, 100, 20, 10) == cobraHygecdf(2, 100, 20, 10));
% support of X is 0..min(K, N); with N > M - K the lower limit is N - (M - K)
assert(cobraHygecdf(10, 100, 20, 10) == 1 && cobraHygecdf(10, 100, 20, 10, 'upper') == 0);
assert(cobraHygecdf(1, 10, 8, 5) == 0 && cobraHygecdf(1, 10, 8, 5, 'upper') == 1);
assert(cobraHygecdf(-1, 100, 20, 10) == 0);
% NaN, negative, non-integer parameters, K > M and N > M give NaN
pInvalid = cobraHygecdf([NaN 1 1 1 1 1], [100 -1 100.5 100 10 10], [20 0 20 20 20 5], [10 0 10 -2 5 20]);
assert(all(isnan(pInvalid)));
% scalar expansion over a row of x and output size
assert(isequal(size(cobraHygecdf([0 1 2], 50, 10, 5)), [1 3]));
assert(isequal(size(cobraHygecdf(zeros(0, 2), 50, 10, 5)), [0 2]));

%% errors: unsupported option, non-numeric input, size mismatch

assert(verifyCobraFunctionError('cobraHygecdf', 'inputs', {1, 100, 20, 10, 'lower'}, ...
    'testMessage', 'cobraHygecdf: unsupported option ''lower'' (only ''upper'' is supported).'));
assert(verifyCobraFunctionError('cobraHygecdf', 'inputs', {1, 100, 20, 10, true}, ...
    'testMessage', 'cobraHygecdf: unsupported option ''logical'' (only ''upper'' is supported).'));
assert(verifyCobraFunctionError('cobraHygecdf', 'inputs', {'1', 100, 20, 10}, ...
    'testMessage', 'cobraHygecdf: inputs must be real numeric arrays.'));
assert(verifyCobraFunctionError('cobraHygecdf', 'inputs', {[1 2], 100, [20 20 20], 10}, ...
    'testMessage', 'cobraHygecdf: non-scalar inputs must have the same size.'));

%% parity with hygecdf (only where the Statistics and Machine Learning Toolbox is installed)

if exist('hygecdf', 'file') == 2 && license('test', 'Statistics_Toolbox')
    xValues = (0:10)';
    assert(max(relativeError(cobraHygecdf(xValues, 100, 20, 10), hygecdf(xValues, 100, 20, 10))) < 1e-10);
    assert(max(relativeError(cobraHygecdf(xValues(1:end - 1), 100, 20, 10, 'upper'), hygecdf(xValues(1:end - 1), 100, 20, 10, 'upper'))) < 1e-10);
    assert(max(relativeError(pFea([1 3:5]), hygecdf(counts([1 3:5]) - 1, 95, subsystemSizes([1 3:5]), 12, 'upper'))) < 1e-10);
    fprintf('parity with hygecdf: passed\n');
else
    fprintf('skipped: Statistics and Machine Learning Toolbox not installed\n');
end

% change the directory
cd(currentDir)
