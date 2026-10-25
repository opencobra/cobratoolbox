% The COBRAToolbox: testRatioScore.m
%
% Purpose:
%     - ratioScore evaluates the ratio of two linear combinations of the variables, used as a score
%     by the 13C flux solver.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/dataIntegration/fluxomics/c13solver/ratioScore.m
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
fileDir = fileparts(which('testRatioScore'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% tolerance for floating-point comparisons
tol = 1e-12;

Prob.user.ration = [1; 0; 1];
Prob.user.ratiod = [0; 1; 1];
x = [2; 4; 6];

%% ratio of the two combinations

% numerator 2 + 6 = 8, denominator 4 + 6 = 10
assert(abs(ratioScore(x, Prob) - 0.8) < tol);

%% the ratio does not change when x is scaled

assert(abs(ratioScore(3 * x, Prob) - 0.8) < tol);

%% a vanishing denominator gives infinity

assert(isinf(ratioScore([1; 0; 0], Prob)));

% change the directory
cd(currentDir)
