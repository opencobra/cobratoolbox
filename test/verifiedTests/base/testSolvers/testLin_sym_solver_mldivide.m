% The COBRAToolbox: testLin_sym_solver_mldivide.m
%
% Purpose:
%     - lin_sym_solver_mldivide solves the symmetric linear system of a Newton-type step with the
%     backslash operator and returns minus the solution as the search direction.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/base/solvers/varKin/levMarMethods/lin_sym_solver_mldivide.m
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
fileDir = fileparts(which('testLin_sym_solver_mldivide'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% tolerance for floating-point comparisons
tol = 1e-12;

%% search direction of a diagonal system

dk = lin_sym_solver_mldivide([2 0; 0 4], [2; 8]);
assert(norm(dk - [-1; -2]) < tol);

%% general symmetric system

H = [4 1; 1 3];
g = [1; 2];
dk = lin_sym_solver_mldivide(H, g);
assert(norm(H * dk + g) < tol);

% change the directory
cd(currentDir)
