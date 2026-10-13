% The COBRAToolbox: testNullSpaceOperatorApply.m
%
% Purpose:
%     - nullSpaceOperatorApply applies the null-space operator of a matrix S (built by
%     nullSpaceOperator) to a matrix V, giving columns that span the null space of S.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch3, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/analysis/subspaces/nullspace/nullSpaceOperatorApply.m
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
%     - Generated for feature tier1-test-batch3, 2026-10-12.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testNullSpaceOperatorApply'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% tolerance for the residual of S*W: LU factorisation and scaling of a tiny matrix, so
% rounding is far below 1e-10
tol = 1e-10;

S = sparse([1 2 0 1; 0 1 1 1; 1 3 1 2]);        % 3 x 4 with rank 2 (row 3 = row 1 + row 2)
nullS = nullSpaceOperator(S, 1, 0);              % scaling on, no printing
assert(nullS.rank == 2);

%% the identity gives a basis of the null space

basis = nullSpaceOperatorApply(nullS, speye(4 - nullS.rank));
assert(isequal(size(basis), [4 2]));
assert(norm(S * basis, 'fro') < tol);
% the two columns are independent
assert(rank(full(basis)) == 2);

%% any combination of the columns is in the null space

combination = nullSpaceOperatorApply(nullS, sparse([1; -3]));
assert(isequal(size(combination), [4 1]));
assert(norm(S * combination) < tol);

% change the directory
cd(currentDir)
