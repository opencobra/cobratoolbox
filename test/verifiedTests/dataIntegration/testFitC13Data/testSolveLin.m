% The COBRAToolbox: testSolveLin.m
%
% Purpose:
%     - solveLin solves the linear system A*x = B only for the unknowns that are connected to a non-zero right-hand side; for several right-hand-side columns the first column is the complement 1 - sum of the others.
%       Characterization test that PINS the current behaviour (feature
%       026-tier1-test-batch2, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/dataIntegration/fluxomics/c13solver/solveLin.m
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
%     - Generated for feature 026-tier1-test-batch2, 2026-10-11.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testSolveLin'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% tolerance for floating-point comparisons: small linear solves, rounding only
tol = 1e-12;

%% single right-hand side

% independent unknowns: x = A\B
assert(norm(solveLin([2 0; 0 4], [2; 4]) - [1; 1]) < tol);
% an unknown that is not connected to any non-zero right-hand side stays 0
assert(norm(solveLin([2 0; 0 4], [2; 0]) - [1; 0]) < tol);
% connected unknowns are solved together: 2x + y = 0 and 4y = 4 give x = -1/2, y = 1
assert(norm(solveLin([2 1; 0 4], [0; 4]) - [-0.5; 1]) < tol);
% a third unknown that is disconnected from the others stays 0
assert(norm(solveLin([2 1 0; 0 4 0; 0 0 5], [0; 4; 0]) - [-0.5; 1; 0]) < tol);

%% several right-hand sides: columns 2.. are solved, column 1 is 1 - sum(other columns)

% identity-like case: lower-triangular A
A = [2 0 0; 1 4 0; 0 0 5];
B = [1 0 0; 0 4 0; 1 0 5];
assert(norm(solveLin(A, B) - eye(3), 'fro') < tol);

% a 2 x 2 system with right-hand sides [2; 4] and [3; 8]: x = A\B(:,2:3) = [4/7 4/7; 6/7 13/7]
solution = solveLin([2 1; 1 4], [1 2 3; 0 4 8]);
assert(norm(solution(:, 2:3) - [4/7 4/7; 6/7 13/7], 'fro') < tol);
assert(norm(solution(:, 1) - (1 - sum(solution(:, 2:3), 2))) < tol);

% change the directory
cd(currentDir)
