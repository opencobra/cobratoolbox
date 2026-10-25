% The COBRAToolbox: testSubspaceSVD.m
%
% Purpose:
%     - subspaceSVD returns the economy singular value decomposition of a matrix restricted to its
%     numerical rank.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/analysis/subspaces/subspaceProjection/subspaceSVD.m
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
fileDir = fileparts(which('testSubspaceSVD'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% tolerance for floating-point comparisons
tol = 1e-12;

%% a rank-deficient matrix gives rank 1 and reproduces the matrix

S = [1 2; 2 4; 3 6];
[U1, D1, V1, r] = subspaceSVD(S);
assert(r == 1);
assert(isequal(size(U1), [3 1]) && isequal(size(D1), [1 1]) && isequal(size(V1), [2 1]));
assert(abs(D1 - sqrt(70)) < 1e-10);
assert(norm(U1 * D1 * V1' - S, 'fro') < 1e-10);
% orthonormal columns
assert(abs(norm(U1) - 1) < tol && abs(norm(V1) - 1) < tol);

%% a full-rank matrix keeps all singular values

[U1, D1, V1, r] = subspaceSVD([2 0; 0 3]);
assert(r == 2);
assert(norm(diag(D1) - [3; 2]) < tol);
assert(norm(U1' * U1 - eye(2)) < tol && norm(V1' * V1 - eye(2)) < tol);

%% a sparse matrix is accepted

[~, ~, ~, r] = subspaceSVD(sparse([1 0; 0 1]));
assert(r == 2);

%% the zero matrix has rank 0

[U1, D1, V1, r] = subspaceSVD(sparse(2, 3));
assert(r == 0 && isempty(U1) && isempty(D1) && isempty(V1));

% change the directory
cd(currentDir)
