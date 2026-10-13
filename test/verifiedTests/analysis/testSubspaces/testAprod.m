% The COBRAToolbox: testAprod.m
%
% Purpose:
%     - aprod is the example matrix-vector product used to test LSQR: it multiplies a vector by the
%     matrix stored in the real work array (mode 1) or by its transpose (mode 2).
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/analysis/subspaces/lsqr/aprod.m
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
fileDir = fileparts(which('testAprod'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

A = [1 2 3; 4 5 6];

%% mode 1: y = A x

assert(isequal(aprod(1, 2, 3, [1; 0; 1], [], A), [4; 10]));

%% mode 2: y = A' x

assert(isequal(aprod(2, 2, 3, [1; 1], [], A), [5; 7; 9]));

%% any other mode value is treated as mode 2

assert(isequal(aprod(3, 2, 3, [1; 1], [], A), [5; 7; 9]));

% change the directory
cd(currentDir)
