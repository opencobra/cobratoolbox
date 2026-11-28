% The COBRAToolbox: testOptimizeWBModel.m
%
% Purpose:
%     - optimizeWBModel solves the LP (or the quadratically regularised problem) of a
%       whole-body model with optimizeCbModel after fixing the objective sense (osenseStr,
%       legacy osense, or assumed from the objective and minNorm), the solve method ('LP',
%       'QP' for minNorm ~= 0, 'QRLP', 'QRQP', or 'QPold', which rescales the bounds by 1/1000
%       and the solution back by 1000) and solver-specific scaling parameters, and refuses
%       solvers that are not validated for the PSCM toolbox. The function is quarantined for
%       the first defect below ('QPold' returns a flux vector that violates the coupling
%       constraints). This file only opens the test; it asserts nothing about the function.
%
% Function under test:
%     src/analysis/wholeBody/PSCMToolbox/optimizeWBModel.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - LP and QP on hand-built models (createModel); the PSCM-validated solvers
%     gurobi, ibm_cplex and mosek, whichever are available.
%
% Coverage exemptions:
%     every line - optimizeWBModel is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: QPold rescales the bounds but not the coupling constraints
%       SEVERITY: wrong-result
%       TRIGGER: m = createModel({'EX_a','R1','EX_b'}, {'','',''}, {' -> a[c]','a[c] -> b[c]',
%         'b[c] -> '}, 'printLevel', 0); m = changeObjective(m, 'EX_b'); m.ub(:) = 1e6;
%         m.ub(1) = 20000; m.lb(1) = 0; m.osenseStr = 'max';
%         mC = addCOBRAConstraints(m, {'R1'}, 5000, 'dsense', 'L');
%         s = optimizeWBModel(mC, struct('solveWBMmethod', 'QPold'))
%       OBSERVED: (R2025a, gurobi, 2026-11-25) s.stat = 1, s.f = 10000, s.v = [10000 10000
%         10000], so mC.C*s.v = 10000 > mC.d = 5000; the default method gives f = 5000. Lines
%         311-320 divide lb and ub by 1000 but leave d (and b) unscaled, so the second problem
%         is C*v <= 1000*d; lines 335-345 then multiply the solution by 1000. In the same call
%         s.ctrs_s = 4990 is the slack of the scaled problem: optimizeCbModel returns ctrs_s,
%         while lines 343-344 rescale a field ctrs_slack
%       EXPECTED: the rescaled solution solves the original problem (C*v <= d, f = 5000), as
%         the comments of lines 316-317 and 325 state, with all fields scaled back
%       LINES: 311-320, 343-344
%     - DEFECT: The CPLEX status text is never printed
%       SEVERITY: cosmetic
%       TRIGGER: param.solveWBMmethod = 'QPold', param.printLevel = 2 with ibm_cplex as LP
%         solver
%       OBSERVED: (R2025a, 2026-11-25) solverName = 'ibm_cplex'; solverName(:,1) is 'i' and
%         any(contains(solverName(:,1), 'cplex')) is 0: solverName is a character row, so
%         solverName(:,1) is its first character and the condition is false for every solver
%       EXPECTED: the CPLEX status text is printed for CPLEX solvers
%       LINES: 276-278, 350-352, 388-391
%     - DEFECT: The original status of gurobi is printed as a number
%       SEVERITY: cosmetic
%       TRIGGER: param.solveWBMmethod = 'QPold', param.printLevel = 1 with gurobi
%       OBSERVED: (R2025a, gurobi, 2026-11-25) "First solution.origStat = 79" followed by
%         "PTIMAL": origStat is the text 'OPTIMAL' and is printed with %i
%       EXPECTED: "First solution.origStat = OPTIMAL"
%       LINES: 275, 349
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-25.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testOptimizeWBModel'));
cd(fileDir);

% declare the requirements of this test. The function is quarantined, so this file runs no
% solver; the call is the standard opening of a COBRA test and the place where the
% requirements (LP and QP solvers validated for the PSCM toolbox) are added when the test
% is written
prepareTest();

% change the directory
cd(currentDir)
