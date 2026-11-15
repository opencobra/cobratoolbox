% The COBRAToolbox: testSubspaceProjector.m
%
% Purpose:
%     - subspaceProjector(A, printLevel, sub_space) returns the orthogonal projection matrices
%       PR onto the row space range(A'), PN onto the null space null(A), PC onto the column
%       space range(A) and PL onto the left null space null(A') of an m x n matrix A, all four
%       ('all', the default) or only the one selected ('R', 'N', 'C', 'L'). This test checks
%       each selection, the defaults, an unknown selection (all outputs empty) and the
%       projector properties, on a full-row-rank and a rank-deficient matrix whose four
%       projectors are derived by hand (expected values below).
%
% Function under test:
%     src/analysis/subspaces/subspaceProjection/subspaceProjector.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver, hand-built matrices.
%
% Coverage exemptions:
%     Lines 105-128: the "otherwise" branch (Moore-Penrose pseudoinverse) runs only on an
%     architecture other than glnx86/glnxa64 (macOS, Windows); the reference machine is
%     glnxa64. The assertions below hold on either branch (same projectors).
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testSubspaceProjector'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% the projectors come from an SVD of a small, well-conditioned matrix, so they agree with
% the exact values to a few units of machine precision; 1e-12 leaves a wide margin
tol = 1e-12;

%% full row rank: A = [1 -1 0; 0 1 -1], null(A) = span([1; 1; 1]), range(A) = R^2

A = [1 -1 0; 0 1 -1];
% by hand: PN = u*u'/(u'*u) with u = [1; 1; 1], PR = I - PN, PC = I (range(A) = R^2), PL = 0
expectedPN = ones(3) / 3;
expectedPR = eye(3) - expectedPN;
expectedPC = eye(2);
expectedPL = zeros(2);

% default arguments (printLevel 1 prints the SVD timing, sub_space 'all')
[PR, PN, PC, PL] = subspaceProjector(A);
assert(max(max(abs(PR - expectedPR))) < tol);
assert(max(max(abs(PN - expectedPN))) < tol);
assert(max(max(abs(PC - expectedPC))) < tol);
assert(max(max(abs(PL - expectedPL))) < tol);

%% rank deficient: A = [1 1; 1 1; 0 0] (rank 1), every subspace is non-trivial

A = [1 1; 1 1; 0 0];
% by hand: range(A') = span([1; 1]), range(A) = span([1; 1; 0])
expectedPR = [0.5 0.5; 0.5 0.5];
expectedPN = [0.5 -0.5; -0.5 0.5];
expectedPC = [0.5 0.5 0; 0.5 0.5 0; 0 0 0];
expectedPL = eye(3) - expectedPC;

[PR, PN, PC, PL] = subspaceProjector(A, 0, 'all');
assert(max(max(abs(PR - expectedPR))) < tol);
assert(max(max(abs(PN - expectedPN))) < tol);
assert(max(max(abs(PC - expectedPC))) < tol);
assert(max(max(abs(PL - expectedPL))) < tol);

% projector properties: symmetric, idempotent, complementary, and A*PN = 0, PL'*A = 0
assert(max(max(abs(PR - PR'))) < tol && max(max(abs(PR * PR - PR))) < tol);
assert(max(max(abs(PC * PC - PC))) < tol);
assert(max(max(abs(PR + PN - eye(2)))) < tol && max(max(abs(PC + PL - eye(3)))) < tol);
assert(max(max(abs(A * PN))) < tol && max(max(abs(PL' * A))) < tol);

%% one subspace at a time: only the selected output is filled, the others are empty

[PR, PN, PC, PL] = subspaceProjector(A, 0, 'R');
assert(max(max(abs(PR - expectedPR))) < tol && isempty(PN) && isempty(PC) && isempty(PL));

[PR, PN, PC, PL] = subspaceProjector(A, 0, 'N');
assert(max(max(abs(PN - expectedPN))) < tol && isempty(PR) && isempty(PC) && isempty(PL));

[PR, PN, PC, PL] = subspaceProjector(A, 0, 'C');
assert(max(max(abs(PC - expectedPC))) < tol && isempty(PR) && isempty(PN) && isempty(PL));

[PR, PN, PC, PL] = subspaceProjector(A, 0, 'L');
assert(max(max(abs(PL - expectedPL))) < tol && isempty(PR) && isempty(PN) && isempty(PC));

%% an unknown selection returns four empty outputs (no branch matches)

[PR, PN, PC, PL] = subspaceProjector(A, 0, 'X');
assert(isempty(PR) && isempty(PN) && isempty(PC) && isempty(PL));

%% sparse input gives the same projectors (subspaceSVD works on full(A))

[PR, PN, PC, PL] = subspaceProjector(sparse(A), 1);
assert(max(max(abs(PR - expectedPR))) < tol && max(max(abs(PL - expectedPL))) < tol);
assert(max(max(abs(PN - expectedPN))) < tol && max(max(abs(PC - expectedPC))) < tol);

% change the directory
cd(currentDir)
