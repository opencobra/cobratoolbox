% The COBRAToolbox: testCheckFluxConsistency.m
%
% Purpose:
%     - checkFluxConsistency builds one LP meant to test the flux consistency of all reactions
%       of a model (forward and reverse fluxes, dual variables and slacks capped by epsilon) and
%       returns the solveCobraLP result; fluxConsistent is always empty (help text). The
%       function is QUARANTINED (Constitution III-Defects, quarantine in back-fill campaigns):
%       line 21 computes model.S - model.S, a zero matrix, so the LP never contains the
%       stoichiometry and its solution does not depend on the model; no assertion about the
%       function is made.
%
% Function under test:
%     src/reconstruction/modelGeneration/fluxConsistency/GREEDY/checkFluxConsistency.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - solves an LP (hand-built model).
%
% Coverage exemptions:
%     every line - checkFluxConsistency is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The stoichiometric matrix of the LP is zero
%       SEVERITY: wrong-result
%       TRIGGER: S = zeros(4, 6); S(1, 1) = -1; S(2, 1) = 1; S(2, 2) = -1; S(3, 2) = 1;
%         S(3, 3) = 1; S(1, 3) = -1; S(2, 4) = -1; S(4, 4) = 1; S(1, 5) = 1; S(3, 6) = -1;
%         m1.S = S; m1.b = zeros(4, 1); [fc, sol1] = checkFluxConsistency(m1, 1e-8);
%         m2 = m1; m2.S = zeros(4, 6); [fc, sol2] = checkFluxConsistency(m2, 1e-8) (gurobi)
%       OBSERVED: (R2025a, 2026-11-23) sol1.stat = sol2.stat = 1, sol1.obj = sol2.obj = 1.2e-07
%         (= 2 * 6 * epsilon) and max(abs(sol1.full - sol2.full)) = 0: line 21 evaluates
%         [model.S - model.S] as a subtraction (zero matrix), so the constraints of lines 31-33
%         never see the model; with m1.b = [1; 0; 0; 0] the LP is infeasible (0 = S * v = b)
%         and for m3.S = sparse([1 0; 0 0]) (both reactions blocked) the objective is again
%         2 * n * epsilon
%       EXPECTED: an LP built from model.S (the comment of line 21, "assumes all reactions are
%         reversible", and the blocks [S -S] of line 31 split each reaction into forward and
%         reverse fluxes of the model), whose solution depends on the stoichiometry
%       LINES: 21
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-23.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testCheckFluxConsistency'));
cd(fileDir);

% declare the requirements of this test. The function is quarantined and is not called, so
% none is listed; the call is the standard opening of a COBRA test and the place where a
% requirement would be added once the defect is fixed
prepareTest();

% change the directory
cd(currentDir)
