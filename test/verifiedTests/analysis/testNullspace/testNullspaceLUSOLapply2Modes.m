% The COBRAToolbox: testNullspaceLUSOLapply2Modes.m
%
% Purpose:
%     - nullspaceLUSOLapply2Modes applies a null-space operator Z (mode 1) or its transpose (mode 2)
%     to a matrix without forming Z, using the factors stored in a null-space structure.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/analysis/subspaces/nullspace/nullspaceLUSOLapply2Modes.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Mode 2 is not the transpose of mode 1 for a general column permutation
%       SEVERITY: wrong-result
%       TRIGGER: a null-space structure whose column permutation p is not its own inverse (for
%         example p = [2; 3; 1])
%       OBSERVED: mode 1 places the rows with W(p,:) = Z while mode 2 applies the same assignment to
%         the input instead of its inverse, so the inner products <Z V1, V2> and <V1, Z V2> differ
%         (-159 against 255 for the example factors); the author notes that the permutation handling
%         in mode 2 is uncertain
%       EXPECTED: mode 2 returns Z V, so both inner products are equal
%       LINES: 71-73
%
% Authors:
%     - Generated for feature tier1-test-batch4, 2026-10-13.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testNullspaceLUSOLapply2Modes'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% tolerance for floating-point comparisons
tol = 1e-10;

% a hand-built null-space structure for a matrix with n = 3 columns and rank 1:
% unit lower triangular factor, column scales and a column permutation that swaps the first two
nullS.L = sparse([1 0 0; 2 1 0; 3 4 1]);
nullS.Cinv = sparse(diag([1 2 3]));
nullS.p = [2; 1; 3];
nullS.rank = 1;

%% mode 1: W = Z V

V = [1 2; 3 4];
W = nullspaceLUSOLapply2Modes(1, 3, 2, V, nullS);
% explicit evaluation of the same formula: Z = inv(L') [0; V], rows permuted by p, then scaled
Z = full(nullS.L') \ [zeros(1, 2); V];
expected = zeros(3, 2);
expected(nullS.p, :) = Z;
expected = full(nullS.Cinv) * expected;
assert(norm(full(W) - expected, 'fro') < tol);

%% mode 2: W = Z' V

V2 = [1 2; 3 4; 5 6];
W = nullspaceLUSOLapply2Modes(2, 3, 2, V2, nullS);
% explicit evaluation: scale, permute, solve with L and keep the rows after the rank
U = full(nullS.Cinv)' * V2;
U(nullS.p, :) = U;
Y = full(nullS.L) \ U;
expected = Y(nullS.rank + 1:3, :);
assert(norm(full(W) - expected, 'fro') < tol);

%% the two modes are transposes of each other for this (self-inverse) permutation

X = [1 2; 3 4];
Y = [1 -1; 2 0; 0 5];
Z1 = nullspaceLUSOLapply2Modes(1, 3, 2, X, nullS);
Z2 = nullspaceLUSOLapply2Modes(2, 3, 2, Y, nullS);
assert(abs(trace(Y' * full(Z1)) - trace(X' * full(Z2))) < tol);

% change the directory
cd(currentDir)
