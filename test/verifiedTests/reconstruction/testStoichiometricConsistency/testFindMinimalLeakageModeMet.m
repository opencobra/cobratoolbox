% The COBRAToolbox: testFindMinimalLeakageModeMet.m
%
% Purpose:
%     - findMinimalLeakageModeMet(model, metBool, rxnBool, modelBoundsFlag, params,
%       printLevel) finds, for each metabolite of metBool, a minimal semipositive (leak) and
%       seminegative (siphon) mode min ||v||_0 + ||y||_0 subject to S*v -/+ y = 0, y >= 0,
%       y(met) >= 1 by cardinality optimisation, and returns the metabolites and reactions of
%       each mode with the net stoichiometries leakY and siphonY. The function is QUARANTINED
%       (Constitution III-Defects, quarantine in back-fill campaigns): leakY and siphonY are
%       returned swapped; no assertion about the function is made.
%
% Function under test:
%     src/reconstruction/modelGeneration/stoichConsistency/findMinimalLeakageModeMet.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - cardinality optimisation (LP sub-problems); a test would declare
%     prepareTest('needsLP', true) and use a hand-built 3 x 4 network.
%
% Coverage exemptions:
%     every line - findMinimalLeakageModeMet is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: leakY holds the siphon modes and siphonY the leak modes
%       SEVERITY: wrong-result
%       TRIGGER: model.S = sparse([-1 0 1 -1; 1 -1 0 0; 0 1 -1 2]) (A, B, C; R1: A -> B,
%         R2: B -> C, R3: C -> A, R4: A -> 2 C), model.lb = zeros(4, 1),
%         model.ub = 10*ones(4, 1), model.mets, model.rxns; [mLM, mLR, mSM, mSR, leakY,
%         siphonY, statp, statn] = findMinimalLeakageModeMet(model, true(3, 1), true(4, 1), 1, [], 0)
%       OBSERVED: (R2025a, gurobi, 2026-11-25) statp = [1 1 1], statn = [0 0 0],
%         minLeakMetBool = eye(3), minSiphonMetBool = zeros(3), but leakY = zeros(3) and
%         siphonY = eye(3): the y of the semipositive (leak) problem is stored in siphonY
%         (lines 162, 224) and the y of the seminegative (siphon) problem in leakY (lines 172,
%         309)
%       EXPECTED: leakY "metabolites in a positive leakage mode" = eye(3) and siphonY
%         "metabolites in a negative siphon mode" = zeros(3) (help text, lines 50-51); with
%         every reaction forward only no metabolite can be consumed without a producer
%       LINES: 162, 172, 222-224, 307-309
%     - DEFECT: The function switches every warning off and leaves them off
%       SEVERITY: cosmetic
%       TRIGGER: any call, e.g. the call above
%       OBSERVED: (R2025a, gurobi, 2026-11-25) warning('query', 'all').state is 'off' after
%         the call: line 191 runs "warning off" and nothing restores the state
%       EXPECTED: the caller's warning state restored
%       LINES: 191
%     - DEFECT: Output is printed whatever printLevel
%       SEVERITY: cosmetic
%       TRIGGER: the call above, printLevel = 0
%       OBSERVED: (R2025a, gurobi, 2026-11-25) the table header "#mets #rxns result metAbbr"
%         and one empty line per leaking metabolite are printed although printLevel = 0
%       EXPECTED: no output for printLevel = 0
%       LINES: 192, 239-241
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-25.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testFindMinimalLeakageModeMet'));
cd(fileDir);

% the function is quarantined: no requirement is declared and nothing calls it. When the
% defect is fixed, the test declares prepareTest('needsLP', true)
prepareTest();

% change the directory
cd(currentDir)
