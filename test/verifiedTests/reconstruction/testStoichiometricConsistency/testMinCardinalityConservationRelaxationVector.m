% The COBRAToolbox: testMinCardinalityConservationRelaxationVector.m
%
% Purpose:
%     - [relaxRxnBool, solutionRelax] = minCardinalityConservationRelaxationVector(S, param,
%       printLevel) finds the fewest reactions whose relaxation x makes x + S'*z = 0 hold with
%       1 <= z <= 1/epsilon, by cardinality optimisation (optimizeCardinality), or, with
%       param.checkConsistency, first checks the stoichiometric consistency of S with an LP.
%       The function is QUARANTINED (Constitution III-Defects, quarantine in back-fill
%       campaigns): the consistency check stops with an error on every inconsistent network,
%       and the bounds of the relaxation problem are built with swapped lengths; no assertion
%       about the function is made.
%
% Function under test:
%     src/reconstruction/modelGeneration/stoichConsistency/minCardinalityConservationRelaxationVector.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - LP and cardinality optimisation; a test would declare prepareTest('needsLP',
%     true) and use hand-built stoichiometric matrices (3 x 4, 1 x 2).
%
% Coverage exemptions:
%     every line - minCardinalityConservationRelaxationVector is quarantined for the defects
%     below (feature 20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The consistency check stops with an error instead of relaxing an inconsistent network
%       SEVERITY: error
%       TRIGGER: S = sparse([-1 0 1 -1; 1 -1 0 0; 0 1 -1 2]) (R4: A -> 2 C makes it
%         inconsistent); minCardinalityConservationRelaxationVector(S, struct('epsilon', 1e-4), 0)
%         (param given without checkConsistency, whose default is then 1, line 55) or with
%         checkConsistency = 1
%       OBSERVED: (R2025a, gurobi, 2026-11-25) the consistency LP is infeasible (stat 0) and
%         the function stops with "solve for minimum cardinality of conservation relaxation
%         vector failed" (line 166); with printLevel 3 it stops earlier with
%         'Unrecognized field name "x".' at line 148. Line 83 sets done = 1 whatever the LP
%         status, so the relaxation never runs after the check. The same S with param omitted
%         (checkConsistency = 0) returns relaxRxnBool = [0 0 0 1]
%       EXPECTED: the check "prior to relaxation" (help text) followed by the relaxation when
%         S is inconsistent: relaxRxnBool = [0 0 0 1]
%       LINES: 54-56, 63-86, 148, 165-166
%     - DEFECT: The upper bounds of the relaxation problem are built with swapped lengths
%       SEVERITY: error
%       TRIGGER: minCardinalityConservationRelaxationVector(sparse([1 -3]),
%         struct('epsilon', 0.5, 'checkConsistency', 0), 0)
%       OBSERVED: (R2025a, gurobi, 2026-11-25) optimizeCardinality returns stat 0
%         (INF_OR_UNBD) and the function stops with "solve for minimum cardinality of
%         conservation relaxation vector failed": with [mlt, nlt] = size(S') (mlt reactions,
%         nlt metabolites) line 102 builds ub = [inf(nlt, 1); (1/epsilon)*ones(mlt, 1)], so the
%         second relaxation x(2) = 3*z >= 3 is capped at 1/epsilon = 2. The documented
%         problem is feasible: solveCobraLP of x + S'*z = 0, x free, 1 <= z <= 2 returns
%         stat 1 with x = [-1; 3], z = 1. The mirrored S = sparse([-3 1]) returns
%         relaxRxnBool = [1 1]
%       EXPECTED: ub = [inf(mlt, 1); (1/epsilon)*ones(nlt, 1)] (line 100 builds lb in that
%         order) and relaxRxnBool = [1 1] for S = [1 -3]
%       LINES: 102
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-25.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testMinCardinalityConservationRelaxationVector'));
cd(fileDir);

% the function is quarantined: no requirement is declared and nothing calls it. When the
% defects are fixed, the test declares prepareTest('needsLP', true)
prepareTest();

% change the directory
cd(currentDir)
