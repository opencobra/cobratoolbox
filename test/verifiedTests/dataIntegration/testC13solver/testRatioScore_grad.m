% The COBRAToolbox: testRatioScore_grad.m
%
% Purpose:
%     - ratioScore_grad returns the gradient of the ratio score of two linear combinations of the
%     variables.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/dataIntegration/fluxomics/c13solver/ratioScore_grad.m
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
fileDir = fileparts(which('testRatioScore_grad'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% tolerance for floating-point comparisons
tol = 1e-8;

Prob.user.ration = [1; 0; 1];
Prob.user.ratiod = [0; 1; 1];
x = [2; 4; 6];

%% explicit gradient

% (d' x) n - (n' x) d over (d' x)^2 with n'x = 8 and d'x = 10
expected = (10 * [1; 0; 1] - 8 * [0; 1; 1]) / 100;
assert(norm(ratioScore_grad(x, Prob) - expected) < 1e-12);

%% finite-difference check against ratioScore

step = 1e-6;
numeric = zeros(3, 1);
for i = 1:3
    e = zeros(3, 1);
    e(i) = step;
    numeric(i) = (ratioScore(x + e, Prob) - ratioScore(x - e, Prob)) / (2 * step);
end
assert(norm(ratioScore_grad(x, Prob) - numeric) < tol);

% change the directory
cd(currentDir)
