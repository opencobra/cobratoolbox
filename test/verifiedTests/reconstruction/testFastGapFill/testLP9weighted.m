% The COBRAToolbox: testLP9weighted.m
%
% Purpose:
%     - LP9weighted solves the weighted LP-9 of FASTCORE on a given LP problem: minimise
%       sum(W(P) .* |v(P)|) while the core reactions K carry at least epsilon, with the
%       variables scaled by 1e5. The function is QUARANTINED (Constitution III-Defects,
%       quarantine in back-fill campaigns): the variable bounds and the core bound are scaled
%       by 1e5 but the right hand side b is not, and the upper bound of the auxiliary variables
%       ignores the weights, so feasible problems are reported infeasible; no assertion about
%       the function is made. src/dataIntegration/transcriptomics/FASTCORE/LP10weighted.m has
%       the same code (quarantined for the first defect).
%
% Function under test:
%     src/reconstruction/fastGapFill/AuxillaryFiles/LP9weighted.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - solves an LP (hand-built LPproblem).
%
% Coverage exemptions:
%     every line - LP9weighted is quarantined for the defects below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: A nonzero right hand side b is not scaled with the bounds
%       SEVERITY: wrong-result
%       TRIGGER: LPp.A = sparse([1 -1; 1 0]); LPp.b = [0; 1]; LPp.csense = ['E'; 'E'];
%         LPp.lb = [0; 0]; LPp.ub = [10; 10]; model.S = LPp.A(1, :);
%         V = LP9weighted([1; 1], 2, 1, model, LPp, 1e-4) (gurobi)
%       OBSERVED: (R2025a, 2026-11-23) "0 = sol.stat", "INFEASIBLE = sol.origStat", the warning
%         "LP solution may not be optimal" (line 83) and V = [NaN NaN]: line 64 scales the core
%         bound (v(2) >= 1e-4 * 1e5 = 10) and lines 67-68 the bounds, but line 56 keeps b
%         unscaled, so v(1) = 1 and v(2) = v(1) >= 10 cannot both hold
%       EXPECTED: an optimal solution (v = [1; 1] is feasible for the unscaled problem:
%         v(1) = 1, v(2) = 1 >= 1e-4), as LP10 returns for the same problem because it
%         scales b (LP10.m line 145)
%       LINES: 56, 71
%     - DEFECT: The bound of the auxiliary variables ignores the weights
%       SEVERITY: wrong-result
%       TRIGGER: LPz.A = sparse([1 -1]); LPz.b = 0; LPz.csense = 'E'; LPz.lb = [0; 0];
%         LPz.ub = [10; 10]; mz.S = LPz.A; V = LP9weighted([2; 1], 2, 1, mz, LPz, 6) (gurobi)
%       OBSERVED: (R2025a, 2026-11-23) "0 = sol.stat", "INFEASIBLE = sol.origStat" and
%         V = [NaN NaN]: line 68 bounds z(P) by max(|ub(P)|, |lb(P)|) * 1e5 = 1e6 while lines
%         59-63 require z(P) >= W(P) * |v(P)| = 2 * 6e5; the same call with W = [1; 1]
%         returns V = [600000 600000]
%       EXPECTED: an optimal solution (v = [6; 6] is within the bounds and v(2) >= 6; the help
%         text allows any nonnegative W), with z(P) bounded by W(P) times the flux bound
%       LINES: 68
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-23.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testLP9weighted'));
cd(fileDir);

% declare the requirements of this test. The function is quarantined and is not called, so
% none is listed; the call is the standard opening of a COBRA test and the place where a
% requirement would be added once the defects are fixed
prepareTest();

% change the directory
cd(currentDir)
