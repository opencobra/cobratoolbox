% The COBRAToolbox: testScore_ridge.m
%
% Purpose:
%     - score_ridge fits a ridge regression of a binary label (high/low) on the columns of a data matrix and returns the fraction of points classified correctly, with or without leave-one-out cross-validation.
%       Characterization test that PINS the current behaviour (feature
%       026-tier1-test-batch2, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/dataIntegration/fluxomics/score_ridge.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found. The accuracies below (other than the perfectly separable cases) are first-run references: no independent derivation exists, so they were recorded from the first run of the current implementation (2026-10-11, base MATLAB R2025a) and guard against unintended change.
%
% Authors:
%     - Generated for feature 026-tier1-test-batch2, 2026-10-11.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testScore_ridge'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% tolerance for floating-point comparisons: accuracies are fractions of a few points
% (multiples of 1/n), so rounding is far below 1e-12
tol = 1e-12;

%% perfectly separable data: every point is classified correctly

dataMatrix = [1 2 3 4; 4 3 2 1];     % 2 variables, 4 points
labels = [1 1 0 0]';                  % zeros are treated as -1
assert(abs(score_ridge(dataMatrix, labels) - 1) < tol);
% a different regularisation weight still separates these points
assert(abs(score_ridge(dataMatrix, labels, 0.5) - 1) < tol);
% strong regularisation, still separable
separableLarger = [1 2 3 4 5 6; 6 5 4 3 2 1];
separableLabels = [1 1 1 0 0 0]';
assert(abs(score_ridge(separableLarger, separableLabels, 100, 0) - 1) < tol);

%% leave-one-out cross-validation (fourth input different from 0)

% first-run references (see header)
assert(abs(score_ridge(dataMatrix, labels, 0.01, 1) - 0.5) < tol);
assert(abs(score_ridge(separableLarger, separableLabels, 0.01, 1) - 2/3) < tol);

%% data that does not separate the labels

uninformative = [1 2 3 4 5 6; 1 1 1 1 1 1];
alternatingLabels = [1 0 1 0 1 0]';
% first-run references (see header)
assert(abs(score_ridge(uninformative, alternatingLabels) - 2/3) < tol);
assert(abs(score_ridge(uninformative, alternatingLabels, 0.01, 1) - 0) < tol);

% change the directory
cd(currentDir)
