% The COBRAToolbox: testNullSpaceOperator.m
%
% Purpose:
%     - nullSpaceOperator(S, scale, printLevel) factorises S' with LUSOL (lusol_obj) and returns
%       a structure (Cinv, L, p, q, rank) from which nullSpaceOperatorApply builds W with
%       S*W = 0. The function is QUARANTINED (Constitution III-Defects, quarantine in back-fill
%       campaigns): the documented option scale = 0 always raises an error, because the scaled
%       matrix A and the column scaling Cinv are only defined inside the scaling branch; no
%       assertion about the function is made.
%
% Function under test:
%     src/analysis/subspaces/nullspace/nullSpaceOperator.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; a test would use a hand-built sparse matrix and the LUSOL
%     interface of external/base/solvers/lusol (present on the reference machine).
%
% Coverage exemptions:
%     every line - nullSpaceOperator is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The option scale = 0 always fails
%       SEVERITY: unusable-option
%       TRIGGER: nullSpaceOperator(sparse([1 -1 0 0; 0 1 -1 0]), 0, 0)
%       OBSERVED: "Unrecognized function or variable 'A'." at line 151 (R2025a, 2026-11-15); A
%         (and Cinv, used on line 227) are assigned only on lines 79-81 inside "if scale"
%       EXPECTED: the operator of the unscaled S (INPUTS: "scale: {(1), 0} geometric mean
%         scaling of S"), e.g. rank 2 for the matrix above, as with scale = 1
%       LINES: 72-90, 151, 227
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testNullSpaceOperator'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
