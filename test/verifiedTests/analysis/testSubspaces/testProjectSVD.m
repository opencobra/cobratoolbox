% The COBRAToolbox: testProjectSVD.m
%
% Purpose:
%     - projectSVD splits a vector into its projection onto the range of a matrix with orthonormal
%     columns and the remainder in the orthogonal complement.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/analysis/subspaces/subspaceProjection/projectSVD.m
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
fileDir = fileparts(which('testProjectSVD'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% tolerance for floating-point comparisons
tol = 1e-12;

%% projection onto a coordinate axis

[u1, u2] = projectSVD([1; 0; 0], [1; 2; 3]);
assert(isequal(u1, [1; 0; 0]) && isequal(u2, [0; 2; 3]));

%% projection onto a plane and orthogonality of the parts

U1 = [1 0; 0 1; 0 0];
u = [3; -2; 5];
[u1, u2] = projectSVD(U1, u);
assert(norm(u1 - [3; -2; 0]) < tol && norm(u2 - [0; 0; 5]) < tol);
assert(abs(u1' * u2) < tol && norm(u1 + u2 - u) < tol);

%% projection onto an oblique direction

d = [1; 1] / sqrt(2);
[u1, u2] = projectSVD(d, [2; 0]);
assert(norm(u1 - [1; 1]) < tol && norm(u2 - [1; -1]) < tol);

% change the directory
cd(currentDir)
