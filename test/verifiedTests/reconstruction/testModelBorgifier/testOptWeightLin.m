% The COBRAToolbox: testOptWeightLin.m
%
% Purpose:
%     - optWeightLin returns the objective used to fit linear weights of a score: one over one plus
%     the absolute difference of the mean weighted scores of the high-scoring and the low-scoring
%     vectors.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/reconstruction/comparison/modelBorgifier/optWeightLin.m
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
fileDir = fileparts(which('testOptWeightLin'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% tolerance for floating-point comparisons
tol = 1e-12;

weight = [1; 1];
high = [1 2; 3 4];
low = [0 0; 1 1];

%% objective value

% high scores [4; 6] with mean 5, low scores [1; 1] with mean 1: 1 / (|5 - 1| + 1)
assert(abs(optWeightLin(weight, high, low) - 0.2) < tol);

%% identical groups give the largest value one

assert(abs(optWeightLin(weight, high, high) - 1) < tol);

% change the directory
cd(currentDir)
