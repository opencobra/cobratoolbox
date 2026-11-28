% The COBRAToolbox: testFindMinimalLeakageMode.m
%
% Purpose:
%     - [Vp, Yp, statp, Vn, Yn, statn] = findMinimalLeakageMode(model, metBool,
%       modelBoundsFlag, epsilon, printLevel) is meant to find, for each metabolite of metBool,
%       a minimal leakage mode min ||v||_0 + ||y||_0 subject to S*v - y = 0 (or S*v + y = 0),
%       y >= 0, y(met) >= 1 and the flux bounds, by cardinality optimisation. The function is
%       QUARANTINED (Constitution III-Defects, quarantine in back-fill campaigns): with the
%       documented inputs it blocks every reaction and so never finds a leakage mode; no
%       assertion about the function is made.
%
% Function under test:
%     src/reconstruction/modelGeneration/stoichConsistency/findMinimalLeakageMode.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - cardinality optimisation (LP sub-problems); a test would declare
%     prepareTest('needsLP', true) and use a hand-built 3 x 4 network.
%
% Coverage exemptions:
%     every line - findMinimalLeakageMode is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Every reaction is blocked when model.SConsistentRxnBool is absent, so no leakage mode is found
%       SEVERITY: wrong-result
%       TRIGGER: model.S = sparse([-1 0 1 -1; 1 -1 0 0; 0 1 -1 2]) (A, B, C; R1: A -> B,
%         R2: B -> C, R3: C -> A, R4: A -> 2 C), model.lb = -10*ones(4, 1),
%         model.ub = 10*ones(4, 1), model.mets, model.rxns, no SConsistentRxnBool;
%         [Vp, Yp, statp, Vn, Yn, statn] = findMinimalLeakageMode(model, true(3, 1), 0, 1e-6, 3)
%         or findMinimalLeakageMode(model)
%       OBSERVED: (R2025a, gurobi, 2026-11-25) statp = statn = [0 0 0] ("A has no
%         semipositive leakage mode." for every metabolite): line 70 defaults
%         SConsistentRxnBool to false(n, 1) and lines 108-109 fix every reaction with a false
%         entry at zero, overriding modelBoundsFlag = 0 ("set all reaction bounds to -inf,
%         inf"). With model.SConsistentRxnBool = true(4, 1) the same call returns
%         statp = [1 1 1], e.g. C with v = [0 0 1 1] and y = [0 0 1]. With a truthful
%         SConsistentRxnBool (consistent reactions true) only consistent reactions stay
%         free, and they cannot form a leakage mode at all
%       EXPECTED: only S, lb and ub are required (help text); without SConsistentRxnBool no
%         reaction is known to be inconsistent and A, B and C each have a semipositive
%         leakage mode (statp = [1 1 1])
%       LINES: 69-70, 108-109
%     - DEFECT: The function switches every warning on when it returns
%       SEVERITY: cosmetic
%       TRIGGER: any call, e.g. the call above
%       OBSERVED: (R2025a, gurobi, 2026-11-25) line 132 runs "warning off" and line 218
%         "warning on", so warnings that were off before the call (MATLAB's defaults
%         included) are on after it, and warnings raised inside the loop are hidden
%       EXPECTED: the caller's warning state restored and the solver's warnings visible
%       LINES: 132, 218
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-25.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testFindMinimalLeakageMode'));
cd(fileDir);

% the function is quarantined: no requirement is declared and nothing calls it. When the
% defect is fixed, the test declares prepareTest('needsLP', true)
prepareTest();

% change the directory
cd(currentDir)
