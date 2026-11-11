% The COBRAToolbox: testCobraKsdensity.m
%
% Purpose:
%     - cobraKsdensity is the plain-MATLAB replacement for ksdensity (Statistics and Machine
%       Learning Toolbox) with its default settings. This test checks the bandwidth of the
%       MathWorks documentation example (bw = 1.5141), the grid, density values and bandwidth
%       against a SciPy normal-kernel estimate with the same bandwidth, the output sizes and
%       orientation required by discretizeFPKM (1 x 100 rows), NaN removal, the zero-MAD and
%       single-value fallbacks, long vectors (blocked evaluation), the errors for unsupported
%       options and invalid input, and (only where the toolbox is installed) parity with
%       ksdensity, which also settles the grid rule (UNCONFIRMED in the semantics note).
%
% Function under test:
%     src/base/utilities/toolboxFree/cobraKsdensity.m
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
fileDir = fileparts(which('testCobraKsdensity'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

relativeError = @(value, reference) abs(value - reference) ./ abs(reference);

%% MathWorks documentation example: bw = 1.5141

rng('default');
xDoc = [randn(30, 1); 5 + randn(30, 1)];
[f, xi, bw] = cobraKsdensity(xDoc);
assert(round(bw, 4) == 1.5141);
assert(isequal(size(f), [1 100]) && isequal(size(xi), [1 100]));

%% grid, bandwidth and density values against SciPy

% references/g1_stats.py (section ksdensity), SciPy 1.16.3 gaussian_kde with the kernel standard
% deviation set to bw: bw = 0.764292382478582, xi(1) = -1.0928771474357462,
% xi(100) = 9.992877147435745; f at points 1, 25, 50, 75, 100. Sums of exponentials: 1e-12
x = [2.1 3.4 3.4 5.0 1.2 7.7 4.4 3.9 2.8 6.1 NaN 4.0 3.3];
[f, xi, bw] = cobraKsdensity(x);
assert(relativeError(bw, 0.764292382478582) < 1e-13);
assert(relativeError(xi(1), -1.0928771474357462) < 1e-13 && relativeError(xi(100), 9.992877147435745) < 1e-13);
refF = [0.0004903861208216331 0.09533893637976115 0.21063986526574233 0.051326732569410206 0.0004833203105377438];
assert(max(relativeError(f([1 25 50 75 100]), refF)) < 1e-12);
% a column input gives the same row outputs
[fColumn, xiColumn] = cobraKsdensity(x');
assert(isequal(fColumn, f) && isequal(xiColumn, xi));

%% fallbacks: zero median absolute deviation, a single value

% more than half the values equal: MAD = 0, so sigma = max - min = 2, bw = 2*(4/(3*5))^(1/5)
[~, ~, bw] = cobraKsdensity([1 1 1 1 3]);
assert(relativeError(bw, 2 * (4 / 15) ^ (1 / 5)) < 1e-14);
% a single value: sigma = 0 and range 0, so bw = 1; the density integrates to about 1
[f, xi, bw] = cobraKsdensity(5);
assert(bw == 1 && abs(trapz(xi, f) - 1) < 0.01);

%% long vectors: blocks, and the kernel cut-off at 4 bandwidths when n*100 > 3e4

rng(20261111);
xLong = randn(25000, 1);
[fLong, xiLong, bwLong] = cobraKsdensity(xLong);
% direct evaluation at three points as an independent check (no blocks; only observations
% within 4 bandwidths contribute)
for k = [1 50 100]
    z = (xiLong(k) - xLong) / bwLong;
    direct = sum(exp(-0.5 * z(abs(z) <= 4) .^ 2)) / (numel(xLong) * bwLong * sqrt(2 * pi));
    assert(relativeError(fLong(k), direct) < 1e-12);
end
% 300 observations (n*100 = 3e4): the full sum; 301 observations: the windowed sum
xShort = randn(300, 1);
[fShort, xiShort, bwShort] = cobraKsdensity(xShort);
fullSum = mean(exp(-0.5 * ((xiShort(1) - xShort) / bwShort) .^ 2)) / (bwShort * sqrt(2 * pi));
assert(relativeError(fShort(1), fullSum) < 1e-12);

%% errors: unsupported options and invalid input

assert(verifyCobraFunctionError('cobraKsdensity', 'inputs', {x, 'Bandwidth', 0.5}, ...
    'testMessage', 'cobraKsdensity: unsupported option ''Bandwidth'' (only the default call cobraKsdensity(x) is supported).'));
assert(verifyCobraFunctionError('cobraKsdensity', 'inputs', {x, 0:10}, ...
    'testMessage', 'cobraKsdensity: unsupported option ''pts'' (only the default call cobraKsdensity(x) is supported).'));
assert(verifyCobraFunctionError('cobraKsdensity', 'inputs', {magic(3)}, ...
    'testMessage', 'cobraKsdensity: x must be a real numeric vector.'));
assert(verifyCobraFunctionError('cobraKsdensity', 'inputs', {[NaN NaN]}, ...
    'testMessage', 'cobraKsdensity: x must contain at least one value that is not NaN.'));

%% parity with ksdensity (only where the Statistics and Machine Learning Toolbox is installed)

if exist('ksdensity', 'file') == 2 && license('test', 'Statistics_Toolbox')
    [f, xi, bw] = cobraKsdensity(xDoc);
    [fToolbox, xiToolbox, bwToolbox] = ksdensity(xDoc);
    assert(abs(bw - bwToolbox) <= 1e-12 * bwToolbox);
    assert(max(abs(xi - xiToolbox)) <= 1e-12 * max(abs(xiToolbox)));
    assert(max(abs(f - fToolbox)) <= 1e-12 * max(fToolbox));
    fprintf('parity with ksdensity: passed\n');
else
    fprintf('skipped: Statistics and Machine Learning Toolbox not installed\n');
end

% change the directory
cd(currentDir)
