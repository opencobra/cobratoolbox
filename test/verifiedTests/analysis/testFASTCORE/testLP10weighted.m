% The COBRAToolbox: testLP10weighted.m
%
% Purpose:
%     - LP10weighted (whose file defines the function LP9weighted) solves the weighted LP-9 of
%       FASTCORE: minimise sum(W(P) .* |v(P)|) while the core reactions K carry at least
%       epsilon, scaled by 1e5. The function is QUARANTINED (Constitution III-Defects,
%       quarantine in back-fill campaigns): the variable bounds and the core bound are scaled by
%       1e5 but the right hand side b is not, so a feasible problem with a nonzero b is reported
%       infeasible; no assertion about the function is made. No src/ function calls
%       LP10weighted (2026-11-23); src/reconstruction/fastGapFill/AuxillaryFiles/LP9weighted.m
%       has the same code.
%
% Function under test:
%     src/dataIntegration/transcriptomics/FASTCORE/LP10weighted.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - solves an LP (hand-built LPproblem).
%
% Coverage exemptions:
%     every line - LP10weighted is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: A nonzero right hand side b is not scaled with the bounds
%       SEVERITY: wrong-result
%       TRIGGER: LPp.A = sparse([1 -1; 1 0]); LPp.b = [0; 1]; LPp.csense = ['E'; 'E'];
%         LPp.lb = [0; 0]; LPp.ub = [10; 10]; model.S = LPp.A(1, :);
%         V = LP10weighted([1; 1], 2, 1, model, LPp, 1e-4) (gurobi)
%       OBSERVED: (R2025a, 2026-11-23) "0 = sol.stat", "INFEASIBLE = sol.origStat", the warning
%         "LP solution may not be optimal" and V = [NaN NaN]: line 58 scales the core bound
%         (v(2) >= 1e-4 * 1e5 = 10) and lines 61-62 the bounds, but line 50 keeps b unscaled,
%         so v(1) = 1 and v(2) >= 10 cannot both hold
%       EXPECTED: an optimal solution (v = [1; 1] is feasible for the unscaled problem: v(1) = 1,
%         v(2) = 1 >= 1e-4), as LP10 returns for the same problem because it scales b (line 145)
%       LINES: 50, 65
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-23.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testLP10weighted'));
cd(fileDir);

% declare the requirements of this test. The function is quarantined and is not called, so
% none is listed; the call is the standard opening of a COBRA test and the place where a
% requirement would be added once the defect is fixed
prepareTest();

% change the directory
cd(currentDir)
