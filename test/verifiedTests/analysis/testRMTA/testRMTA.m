% The COBRAToolbox: testRMTA.m
%
% Purpose:
%     - rMTA computes, for each gene (or reaction) knock-out, the best-case MTA score (MIQP),
%       the MOMA score (QP) and the worst-case MTA score (MIQP with the opposite changes) for
%       each alpha, combines them into the robust TS score rTS (and the deprecated one), and
%       can resume an interrupted run from the file temp_rMTA.mat in the current folder.
%     - Once the defect below is fixed, the test should run in a tempname folder on the
%       seven-reaction toy model of testMTA.m and check: S * v = 0, the bounds and the
%       knocked-out fluxes of every returned flux vector (Vres.bMTA, mMTA, wMTA), rTS and
%       old_rTS recomputed from bTS, mTS and wTS, mTS recomputed with MTA_TS, -Inf for
%       knock-outs with no effect and for an infeasible MOMA knock-out, reaction and gene
%       knock-outs, listKO with and without separator and its errors, two alphas, printLevel 0
%       and 1, and resuming from a temporary file saved in each of the three steps; the
%       stray output of the cosmetic defect is not asserted. Quarantined: no behaviour of rMTA
%       is asserted until the error defect below is fixed; this file only opens the test.
%
% Function under test:
%     src/analysis/rMTA/rMTA.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - MIQP and QP on the seven-reaction toy model of testMTA.m (gurobi on the
%     reference machine).
%
% Coverage exemptions:
%     every line - rMTA is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: A run interrupted after the MOMA step cannot be resumed, because the temporary
%         file saved there lacks i_alpha and k_alpha
%       SEVERITY: error
%       TRIGGER: an interruption between the save of line 324 and the first save of step 3
%         (line 382), reproduced by saving temp_rMTA.mat with the variables of line 324 (i, j,
%         k, best, moma, worst, score_best, score_moma, score_worst, Vres; best = moma = true,
%         worst = false) and calling rMTA(model, rxnFBS, Vref, 0.4, 0.01, 'rxnKO', 1,
%         'printLevel', 0) in that folder, with the toy model, Vref and rxnFBS of testMTA.m
%       OBSERVED: (R2025a, gurobi, 2026-11-25) MATLAB:UndefinedFunction "Unrecognized function
%         or variable 'i_alpha'." at line 170; k_alpha (line 172) is missing as well
%       EXPECTED: the run resumed at step 3, as the help promises ("prepared to be able to be
%         stopped and be launched again")
%       LINES: 170, 172, 324
%     - DEFECT: printLevel 0 does not silence the step messages
%       SEVERITY: cosmetic
%       TRIGGER: rMTA(model, rxnFBS, Vref, 0.4, 0.01, 'rxnKO', 1, 'printLevel', 0)
%       OBSERVED: (R2025a, gurobi, 2026-11-25) prints "-------------------", "Step 2 in
%         progress: MOMA", "QPproblem model for MOMA built" and "All MIQP problems performed";
%         the fprintf calls of lines 250, 256, 266, 325, 385 and 396 are not gated by printLevel
%       EXPECTED: no output with printLevel 0 (help: "1 if the process is wanted to be shown
%         on the screen, 0 otherwise")
%       LINES: 250, 256, 266, 325, 385, 396
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-25.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testRMTA'));
cd(fileDir);

% declare the requirements of this test. The function is quarantined and not called, so no
% solver is needed; the call is the standard opening of a COBRA test and the place where the
% requirement (MIQP and QP solvers) is added when the defect is fixed
prepareTest();

% change the directory
cd(currentDir)
