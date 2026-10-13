% The COBRAToolbox: testNLPobjPerFlux.m
%
% Purpose:
%     - NLPobjPerFlux evaluates the objective per unit flux: the linear objective of a model divided
%     by the sum of squares of the flux vector.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/base/solvers/NLP/NLPobjPerFlux.m
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
fileDir = fileparts(which('testNLPobjPerFlux'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% tolerance for floating-point comparisons
tol = 1e-12;

Prob.user.model.c = [1; 0; 2];

%% ratio of the linear objective to the squared norm of the flux

value = NLPobjPerFlux([1; 2; 3], Prob);
% c'v = 1 + 6 = 7 and v'v = 14
assert(abs(value - 7 / 14) < tol);

%% scaling the flux scales the value inversely

assert(abs(NLPobjPerFlux([2; 4; 6], Prob) - 14 / 56) < tol);

%% a zero flux gives not a number

assert(isnan(NLPobjPerFlux([0; 0; 0], Prob)));

% change the directory
cd(currentDir)
