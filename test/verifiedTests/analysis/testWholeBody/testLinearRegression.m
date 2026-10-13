% The COBRAToolbox: testLinearRegression.m
%
% Purpose:
%     - linearRegression fits a straight line to data by least squares and returns the intercept,
%     the slope, the coefficient of determination and the residuals.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/analysis/wholeBody/PSCMToolbox/linearRegression.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature tier1-test-batch4, 2026-10-13.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testLinearRegression'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% tolerance for floating-point comparisons
tol = 1e-12;

x = [1; 2; 3; 4];

%% points on a line

[a0, a1, Rsqr, Residuals] = linearRegression(x, 2 * x + 1);
assert(abs(a0 - 1) < tol && abs(a1 - 2) < tol);
assert(abs(Rsqr - 1) < tol);
assert(norm(Residuals) < tol);

%% noisy data

y = [2.1; 3.9; 6.2; 7.8];
[a0, a1, Rsqr, Residuals] = linearRegression(x, y);
% least squares line from the normal equations: slope = Sxy / Sxx, intercept = mean(y) - slope mean(x)
slope = sum((x - mean(x)) .* (y - mean(y))) / sum((x - mean(x)).^2);
assert(abs(a1 - slope) < tol && abs(a0 - (mean(y) - slope * mean(x))) < tol);
assert(Rsqr > 0.99 && Rsqr < 1);
assert(abs(sum(Residuals)) < 1e-10);
assert(norm(Residuals - (y - (a0 + a1 * x))) < tol);

% change the directory
cd(currentDir)
