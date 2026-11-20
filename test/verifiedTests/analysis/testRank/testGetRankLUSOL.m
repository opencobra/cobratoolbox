% The COBRAToolbox: testGetRankLUSOL.m
%
% Purpose:
%     - getRankLUSOL(A, printLevel) returns the rank of A from a LUSOL factorisation
%       (lusol_obj, threshold partial pivoting) and the row and column pivot orders p and q,
%       with p(1:rankA) independent rows and q(1:rankA) independent columns; it drops zero
%       columns before the factorisation and appends their indices to q, and falls back to
%       MATLAB's lu and rank when LUSOL is missing or fails. The function is QUARANTINED
%       (Constitution III-Defects, quarantine in back-fill campaigns): when A has a zero
%       column, q holds positions in the reduced matrix instead of column indices of A, so
%       q(1:rankA) can name a zero column and q is not a permutation; no assertion about the
%       function is made. (testRank.m checks the rank of iAF1260.S with the old layout.)
%
% Function under test:
%     src/analysis/subspaces/rank/getRankLUSOL.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; a test would use hand-built matrices, the LUSOL interface of
%     external/base/solvers/lusol (present on the reference machine), and classdef stubs of
%     lusol_obj on a temporary path to reach the fallback and the LUSOL inform codes 3-9.
%
% Coverage exemptions:
%     every line - getRankLUSOL is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: q is wrong when A has a zero column
%       SEVERITY: wrong-result
%       TRIGGER: [rankA, p, q] = getRankLUSOL([0 1 2; 0 2 5])
%       OBSERVED: rankA = 2, q = [2; 1; 1] (R2025a, 2026-11-15, LUSOL); q(1:2) = [2 1]
%         includes the zero column 1 (rank(A(:, q(1:2))) = 1), column 3 is missing and 1 is
%         repeated. [1 0 2; 2 0 5; 1 0 1] gives q = [2; 1; 2]. The pivot order of the reduced
%         matrix A(:, ~bool) (line 65) is used as column indices of A, then ind(bool) is
%         appended (lines 199-201)
%       EXPECTED: q a permutation of 1:3 with q(1:2) = the independent columns 2 and 3 and
%         q(3) = 1 (OUTPUTS: "q(1:rankA) gives indices of independent columns"; comment of
%         line 198: "pad out q in case some columns are dropped")
%       LINES: 62-66, 199-201
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testGetRankLUSOL'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
