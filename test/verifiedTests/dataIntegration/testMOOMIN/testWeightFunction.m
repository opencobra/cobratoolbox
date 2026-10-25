% The COBRAToolbox: testWeightFunction.m
%
% Purpose:
%     - weightFunction converts the posterior probability of differential expression of a gene into
%     a reaction weight, capped at the weight of a certain difference.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/dataIntegration/transcriptomics/MOOMIN/weightFunction.m
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
fileDir = fileparts(which('testWeightFunction'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% tolerance for floating-point comparisons
tol = 1e-12;

alpha = 2; beta = 3; pThresh = 0.1;
cap = -alpha * beta * log(1 - pThresh);

%% certainty of a difference gives the cap

assert(abs(weightFunction(1, alpha, beta, pThresh) - cap) < tol);

%% weight below the cap

% PPDE = 0.2: beta (-log(0.8) + log(0.9)) = 3 (0.223144 - 0.105361) = 0.353 is below the cap 0.632
ppde = 0.2;
expected = beta * (-log(1 - ppde) + log(1 - pThresh));
assert(abs(weightFunction(ppde, alpha, beta, pThresh) - expected) < tol);
assert(expected < cap);

%% weight limited by the cap

assert(abs(weightFunction(0.999, alpha, beta, pThresh) - cap) < tol);

%% negative weight for low probability

assert(weightFunction(0.05, alpha, beta, pThresh) < 0);

% change the directory
cd(currentDir)
