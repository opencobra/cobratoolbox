% The COBRAToolbox: testEchelonNullspace.m
%
% Purpose:
%     - echelonNullspace returns the echelon form of the left (default) or right null space of a
%     matrix S as [-L0 I] with a permutation P.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch3, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/analysis/subspaces/nullspace/echelonNullspace.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The returned null-space matrix L is built with P instead of its transpose
%       SEVERITY: wrong-result
%       TRIGGER: any matrix whose QR pivoting permutes the rows (left) or columns (right), e.g. [1 0
%         1 2; 0 1 1 3; 1 1 2 5]
%       OBSERVED: L = [-L0 I]*P does not satisfy L*S = 0 (left) or S*L = 0 (right); the documented
%         identity holds only with P ([-L0 I]*P*S = 0)
%       EXPECTED: L*S = 0 for the left and S*L = 0 for the right null space
%       LINES: 95, 145
%
% Authors:
%     - Generated for feature tier1-test-batch3, 2026-10-12.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testEchelonNullspace'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% tolerance for the null-space residuals: a QR factorisation and Gauss-Jordan elimination of a
% tiny matrix, so rounding is far below 1e-10
tol = 1e-10;

S = [1 0 1 2; 0 1 1 3; 1 1 2 5];          % 3 x 4, rank 2 (row 3 = row 1 + row 2)
rankS = 2;

% The returned L is not checked (see the header); the parts L0, I, P and p are, with the
% identity that holds for them: [-L0 I] * P' * S = 0 (left) and S * ([-L0 I] * P')' = 0 (right).

%% left null space (default)

[L0, I, P, ~, p] = echelonNullspace(S);
assert(isequal(size(L0), [3 - rankS, rankS]));
assert(isequal(full(I), eye(3 - rankS)));
assert(isequal(sort(sum(P, 1)), ones(1, 3)) && isequal(sort(sum(P, 2))', ones(1, 3)));   % a permutation matrix
assert(isequal(sort(p(:))', 1:3));
assert(norm(full([-L0 I] * P' * S), 'fro') < tol);

%% right null space

[L0, I, P, ~, p] = echelonNullspace(S, 'right');
assert(isequal(size(L0), [4 - rankS, rankS]));
assert(isequal(full(I), eye(4 - rankS)));
assert(isequal(size(P), [4 4]) && isequal(sort(p(:))', 1:4));
assert(norm(full(S * ([-L0 I] * P')'), 'fro') < tol);

%% a tolerance can be given

[L0, I, P] = echelonNullspace(S, 'left', 1e-10);
assert(norm(full([-L0 I] * P' * S), 'fro') < tol);
[L0, I, P] = echelonNullspace(S, 'right', 1e-10);
assert(norm(full(S * ([-L0 I] * P')'), 'fro') < tol);

%% a large matrix makes the default tolerance exceed 1e-12 and it is limited to 1e-12

[L0, I, P] = echelonNullspace(1e4 * S);
assert(norm(full([-L0 I] * P' * (1e4 * S)), 'fro') < 1e-6);
[L0, I, P] = echelonNullspace(1e4 * S, 'right');
assert(norm(full((1e4 * S) * ([-L0 I] * P')'), 'fro') < 1e-6);

%% full row rank: the left null space is empty

L0 = echelonNullspace([1 0 0; 0 1 0]);
assert(isequal(size(L0), [0 2]));

% change the directory
cd(currentDir)
