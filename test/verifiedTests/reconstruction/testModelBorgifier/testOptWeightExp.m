% The COBRAToolbox: testOptWeightExp.m
%
% Purpose:
%     - optWeightExp returns the objective used to fit exponent weights of a score: one over one
%     plus the absolute difference of the mean weighted, exponentiated scores of the high-scoring
%     and the low-scoring vectors.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/reconstruction/comparison/modelBorgifier/optWeightExp.m
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
fileDir = fileparts(which('testOptWeightExp'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% tolerance for floating-point comparisons
tol = 1e-12;

% weights: coefficients in the first column and exponents in the second
weight = [1 1; 2 2];
high = [1 2; 3 4];
low = [0 1; 1 1];

%% objective value

% high scores: [1 9; 2 16] * [1; 2] = [19; 34] with mean 26.5; low scores: [0 1; 1 1] * [1; 2] = [2; 3] with mean 2.5
assert(abs(optWeightExp(weight, high, low, 2, 2) - 1 / (24 + 1)) < tol);

%% identical groups give the largest value one

assert(abs(optWeightExp(weight, high, high, 2, 2) - 1) < tol);

% change the directory
cd(currentDir)
