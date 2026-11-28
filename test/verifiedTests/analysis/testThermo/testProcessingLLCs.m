% The COBRAToolbox: testProcessingLLCs.m
%
% Purpose:
%     - processingLLCs prepares the localized loopless constraints (LLCs, Chan et al., 2017) of
%       the MILP built by addLoopLawConstraints: 'preprocess' finds the reactions whose loop
%       constraints are always needed (conditions I-III of Prop. 2) and relaxes the others,
%       'update' restores or relaxes the constraints for a given objective vector and says
%       whether an LP is enough. The function is quarantined for the defect below (the
%       preprocessing stops with an error when the problem has a '>=' or '=' constraint beyond
%       the mass balances). This file only opens the test; it asserts nothing about the
%       function.
%
% Function under test:
%     src/analysis/thermo/thermoFBA/processingLLCs.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - addLoopLawConstraints (MILP solver) and optimizeCbModel on a hand-built model.
%
% Coverage exemptions:
%     every line - processingLLCs is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Preprocessing stops with an error for a coupling constraint of sense G or E
%       SEVERITY: error
%       TRIGGER: m = createModel({'EX_a','R1','R2','R3','R4','EX_b'}, {'','','','','',''},
%         {' -> a[c]','a[c] -> b[c]','b[c] <=> c[c]','c[c] <=> d[c]','d[c] <=> b[c]','b[c] -> '},
%         'printLevel', 0); m.lb(1) = 0; m.ub(1) = 10; m = changeObjective(m, 'EX_b');
%         mC = addCOBRAConstraints(m, {'R2'}, 1, 'dsense', 'G');
%         LPproblem = buildOptProblemFromModel(mC);
%         [MILP, loopInfo] = addLoopLawConstraints(LPproblem, mC, 1:6, [], [],
%         struct('method', 'LLC-NS', 'printLevel', 0));
%         processingLLCs('preprocess', loopInfo, LPproblem, mC, 6, 'max', MILP)
%       OBSERVED: (R2025a, gurobi, 2026-11-25) error "Unrecognized function or variable
%         'con3A2'." in preprocessLLCs at line 129 (typo for cond3A2). The same model with
%         'dsense', 'L' is preprocessed (solveLP = 1). fluxVariability(mC, 100, 'max', [], 0, 0,
%         'LLC-NS') stops with the same error
%       EXPECTED: condition III of Prop. 2 is evaluated for '>=' and '=' rows as it is for '<='
%         rows (lines 119-126)
%       LINES: 129
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-25.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testProcessingLLCs'));
cd(fileDir);

% declare the requirements of this test. The function is quarantined, so this file runs no
% solver; the call is the standard opening of a COBRA test and the place where a requirement
% (an LP and a MILP solver) is added when the test is written
prepareTest();

% change the directory
cd(currentDir)
