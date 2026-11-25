% The COBRAToolbox: testCheckIEM_WBM.m
%
% Purpose:
%     - checkIEM_WBM simulates an inborn error of metabolism on a whole-body model: it adds a
%       dummy reaction that sums the fluxes of the IEM reactions, maximises it in the healthy
%       model, requires minRxnsFluxHealthy of that maximum, knocks the IEM reactions out in the
%       disease model, checks the whole-body objective, and maximises (and optionally
%       minimises) each biomarker reaction in the healthy and the disease model. The function
%       is quarantined for the defects below. This file only opens the test; it asserts
%       nothing about the function.
%     - The model m of the reproductions below: m = createModel({'EX_a';'IEM1';
%       'Whole_body_objective_rxn';'DM_a'}, {'';'';'';''}, {' -> a[c]';'a[c] -> b[c]';
%       'b[c] -> ';'a[c] -> '}, 'lowerBoundList', [0 0 0 0], 'upperBoundList', [10 1000 1000 0],
%       'printLevel', 0). With gurobi and the documented defaults it gives the IEM maximum 10
%       (healthy) and 0 (disease), 'Healthy:DM_a' 2.5 and 'Disease:DM_a' 10, which the
%       construction predicts.
%
% Function under test:
%     src/analysis/wholeBody/PSCMToolbox/checkIEM_WBM.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - LPs through optimizeWBModel on a hand-built whole-body stand-in (createModel);
%     the PSCM-validated LP solvers gurobi and ibm_cplex, whichever are available.
%
% Coverage exemptions:
%     every line - checkIEM_WBM is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The minimisation of a biomarker in the disease model maximises it
%       SEVERITY: wrong-result
%       TRIGGER: m of the Purpose: S = checkIEM_WBM(m, {'IEM1'}, {'DM_a','Increased
%         (blood)'}, 0.75, 0, 1, 1)
%       OBSERVED: (R2025a, gurobi, 2026-11-25) S{6,4} ('Disease:DM_a', minimum) = '10', the
%         same as the maximum S{6,2} = '10'; the healthy minimum S{5,4} is '0'. Line 316 sets
%         modelIEM.osense = 1 but leaves modelIEM.osenseStr = 'max' (copied at line 209 from
%         line 143), and optimizeWBModel uses osenseStr when it is present
%       EXPECTED: S{6,4} = '0': with IEM1 knocked out, DM_a equals the uptake EX_a, whose lower
%         bound is 0 (lines 270-271 set both fields for the healthy model)
%       LINES: 316-318
%     - DEFECT: Biomarker upper bounds are set by prefix match
%       SEVERITY: wrong-result
%       TRIGGER: m of the Purpose with a fifth, closed reaction DM_ab ( -> a[c], bounds 0 0):
%         S = checkIEM_WBM(m, {'IEM1'}, {'DM_a','Increased (blood)'}, 0.75)
%       OBSERVED: (R2025a, gurobi, 2026-11-25) 'Healthy:DM_a' = '100000' and 'Disease:DM_a' =
%         '100000'; without DM_ab they are '2.5' and '10'. strmatch without 'exact' (lines 238
%         and 288) also sets the upper bound of DM_ab, a reaction whose identifier starts with
%         the biomarker's, to 100000 and opens an unlimited source of a
%       EXPECTED: only the biomarker reaction's bound changed ('2.5' and '10'), as line 122
%         ('exact') and line 240 (strcmp) select it
%       LINES: 238, 288
%     - DEFECT: fractionKO is ignored, and with fixIEMlb = 1 it makes the disease model
%       infeasible
%       SEVERITY: unusable-option
%       TRIGGER: m of the Purpose: checkIEM_WBM(m, {'IEM1'}, {'DM_a','Increased
%         (blood)'}, 0.75, 0, 0.5, 0, 0) and checkIEM_WBM(m, {'IEM1'}, ..., 0.75, 0, 0.5, 1, 1)
%       OBSERVED: (R2025a, gurobi, 2026-11-25) with fixIEMlb = 0 the output is identical to
%         fractionKO = 1 ('IEM Rxns All obj - Disease' = '0', 'Disease:DM_a' = '10'): lines
%         178-179 always set both bounds of the IEM reactions to 0 (the partial knock-out of
%         lines 175-176 is behind 'if 0'); with fixIEMlb = 1, line 168 requires the dummy
%         reaction (the sum of the IEM fluxes) to carry 5 while lines 178-179 fix them to 0,
%         so the disease LP is infeasible and the output stops after 3 rows ('NaN')
%       EXPECTED: a knock-out of the documented fraction (default 1 for 100% knockout): the
%         IEM flux limited to (1 - fractionKO) of its healthy maximum
%       LINES: 167-180
%     - DEFECT: reverseDirObj is ignored
%       SEVERITY: unusable-option
%       TRIGGER: m of the Purpose: checkIEM_WBM(m, {'IEM1'}, {'DM_a','Increased
%         (blood)'}, 0.75, 1)
%       OBSERVED: (R2025a, gurobi, 2026-11-25) the output is identical to reverseDirObj = 0
%         ('IEM Rxns All obj - Healthy' = '10', the maximum): line 136 sets model.osense = 1,
%         but line 143 sets model.osenseStr = 'max', which optimizeWBModel uses
%       EXPECTED: the minimisation problem is also checked, as the help of reverseDirObj says
%       LINES: 135-139, 143
%     - DEFECT: The LPSolver input is ignored
%       SEVERITY: unusable-option
%       TRIGGER: m of the Purpose: checkIEM_WBM(m, {'IEM1'}, {'DM_a','Increased
%         (blood)'}, 0.75, 0, 1, 0, 0, 'noSuchSolver')
%       OBSERVED: (R2025a, gurobi, 2026-11-25) the output is identical to the call without
%         LPSolver: lines 106-109 only set a default that nothing reads (the changeCobraSolver
%         call of line 110 is commented out), so the global LP solver is always used
%       EXPECTED: the documented LP solver ('ILOGcomplex' default, 'tomlab_cplex') is used
%       LINES: 106-109
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-25.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testCheckIEM_WBM'));
cd(fileDir);

% declare the requirements of this test. The function is quarantined, so this file runs no
% solver; the call is the standard opening of a COBRA test and the place where the
% requirements (an LP solver validated for the PSCM toolbox) are added when the test is
% written
prepareTest();

% change the directory
cd(currentDir)
