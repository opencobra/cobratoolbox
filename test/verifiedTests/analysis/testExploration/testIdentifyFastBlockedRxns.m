% The COBRAToolbox: testIdentifyFastBlockedRxns.m
%
% Purpose:
%     - identifyFastBlockedRxns finds the reactions of rxnList that cannot carry flux: it
%       maximises random positive weights of the unchecked reactions until no further reaction
%       carries flux above sTol, then minimises them in the same way, and returns the
%       reactions that never carried flux.
%     - Once the defect below is fixed, the test should use a createModel network with a
%       reaction that has no substrate (blocked), forward-only reactions, a reverse-only
%       reaction (found only by the minimisation) and parallel routes (several maximisation
%       rounds), with the blocked set derived by hand, and check: the default rxnList,
%       printLevel and sTol, a subset rxnList, printLevel 0 and 1, a network with no blocked
%       reaction (the minimisation is skipped), and sTol applied in both steps; seeds fixed
%       with rng because the weights are random. Quarantined: no behaviour of
%       identifyFastBlockedRxns is asserted until the defect below is fixed; this file only
%       opens the test.
%
% Function under test:
%     src/analysis/exploration/identifyFastBlockedRxns.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - LPs on a hand-built createModel network, every available LP solver.
%
% Coverage exemptions:
%     every line - identifyFastBlockedRxns is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The documented flux tolerance sTol is ignored in the minimisation step, which
%         always uses 1e-6
%       SEVERITY: unusable-option
%       TRIGGER: rng(1); identifyFastBlockedRxns(model, model.rxns, 0, 1e-2) with model =
%         createModel({'EX_B', 'R_fwd', 'R_tiny', 'R_rev', 'EX_A', 'R_blk'}, {'EX_B', 'R_fwd',
%         'R_tiny', 'R_rev', 'EX_A', 'R_blk'}, {' -> B', 'B -> A', 'B -> A', 'A <=> B',
%         'A -> ', 'C -> D'}, 'lowerBoundList', [0 0 0 -1e-3 0 0], 'upperBoundList', [10 10
%         1e-3 0 10 10], 'printLevel', 0)
%       OBSERVED: (R2025a, gurobi, 2026-11-25) returns {'R_blk', 'R_tiny'}: the forward-only
%         R_tiny (at most 1e-3) is reported blocked because 1e-3 < sTol, but the reverse-only
%         R_rev (at most -1e-3) is reported unblocked because line 79 compares with 1e-6. With
%         the default sTol the call returns {'R_blk'}
%       EXPECTED: sTol applied in both steps: {'R_blk', 'R_rev', 'R_tiny'} for sTol = 1e-2
%       LINES: 79
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-25.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testIdentifyFastBlockedRxns'));
cd(fileDir);

% declare the requirements of this test. The function is quarantined and not called, so no
% solver is needed; the call is the standard opening of a COBRA test and the place where the
% requirement (an LP solver) is added when the defect is fixed
prepareTest();

% change the directory
cd(currentDir)
