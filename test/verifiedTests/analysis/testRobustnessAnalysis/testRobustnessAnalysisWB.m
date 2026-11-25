% The COBRAToolbox: testRobustnessAnalysisWB.m
%
% Purpose:
%     - robustnessAnalysisWB is the whole-body version of robustnessAnalysis: it finds the
%       range of a control reaction with optimizeWBModel, fixes the control reaction at
%       nPoints values of that range and optimises the objective (objRxn, objType) at each,
%       optionally plotting the result. Quarantined: no behaviour of robustnessAnalysisWB is
%       asserted until the defect below is fixed.
%
% Function under test:
%     src/analysis/robustnessAnalysis/robustnessAnalysisWB.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - LP through optimizeWBModel (solver validated for the PSCM toolbox) on a toy
%     model.
%
% Coverage exemptions:
%     every line - robustnessAnalysisWB is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The documented objType input is ignored
%       SEVERITY: unusable-option
%       TRIGGER: robustnessAnalysisWB(model, 'EX_A', 3, false, 'EX_B', 'min') on the toy model
%         EX_A ( -> A, ub 10), R1 (A -> B), R2 (A -> C), EX_B (B -> ), EX_C (C -> ) with
%         model.osenseStr = 'max'
%       OBSERVED: (R2025a, gurobi, 2026-11-25) controlFlux = [0; 5; 10], objFlux = [0; 5; 10]
%         (EX_B maximised); robustnessAnalysis with the same inputs returns objFlux =
%         [0; 0; 0]. Line 61 sets objType on tmpModel, but the model optimised at line 62 is
%         modelControlled, which keeps the sense of the input model
%       EXPECTED: objFlux = [0; 0; 0]: EX_B minimised at each EX_A value (all flux through
%         R2), as the help documents for objType
%       LINES: 61
%     - DEFECT: The function inside the file is named robustnessAnalysis
%       SEVERITY: cosmetic
%       TRIGGER: reading the file or its help text
%       OBSERVED: line 1 declares robustnessAnalysis and the USAGE line names
%         robustnessAnalysis; MATLAB calls the function by its file name robustnessAnalysisWB,
%         and the help does not say that the optimisations use optimizeWBModel
%       EXPECTED: the function and USAGE named robustnessAnalysisWB
%       LINES: 1
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-25.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testRobustnessAnalysisWB'));
cd(fileDir);

% declare the requirements of this test; nothing that calls robustnessAnalysisWB runs while
% it is quarantined, so no solver is required yet
prepareTest();

% change the directory
cd(currentDir)
