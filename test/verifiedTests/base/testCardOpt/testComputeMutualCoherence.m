% The COBRAToolbox: testComputeMutualCoherence.m
%
% Purpose:
%     - computeMutualCoherence returns the largest absolute inner product between different
%     normalised columns of a matrix.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/base/solvers/cardOpt/sparseLP/computeMutualCoherence.m
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
fileDir = fileparts(which('testComputeMutualCoherence'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% tolerance for floating-point comparisons
tol = 1e-12;

%% orthogonal columns have zero coherence

assert(computeMutualCoherence(eye(3)) < tol);

%% two parallel columns have coherence one

assert(abs(computeMutualCoherence([1 2; 1 2]) - 1) < tol);

%% a known angle

% the columns (1, 0) and (1, 1) have cosine 1/sqrt(2); scaling the columns does not matter
assert(abs(computeMutualCoherence([1 3; 0 3]) - 1 / sqrt(2)) < tol);

%% the largest of several angles

A = [1 0 1; 0 1 1];
% column 3 has cosine 1/sqrt(2) with columns 1 and 2
assert(abs(computeMutualCoherence(A) - 1 / sqrt(2)) < tol);

% change the directory
cd(currentDir)
