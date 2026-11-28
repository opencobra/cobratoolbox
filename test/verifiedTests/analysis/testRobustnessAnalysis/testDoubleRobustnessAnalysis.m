% The COBRAToolbox: testDoubleRobustnessAnalysis.m
%
% Purpose:
%     - doubleRobustnessAnalysis finds the flux range of two control reactions, fixes both on
%       an nPoints x nPoints grid over these ranges and optimises the objective (the model's
%       or objRxn, maximised or minimised) at each point, and optionally plots the surface.
%     - Once the defect below is fixed, the test should use a createModel network with two
%       uptakes and two products of different capacities (objective values derived by hand),
%       and check the grid values for the model objective, for objRxn with and without
%       objType, for 'min', the default nPoints (20) and plotResFlag, the plot (figure closed)
%       and the errors for unknown control reactions (verifyCobraFunctionError).
%       testRobustnessAnalysis.m also calls the function with four arguments. Quarantined: no
%       behaviour of doubleRobustnessAnalysis is asserted until the defect below is fixed;
%       this file only opens the test.
%
% Function under test:
%     src/analysis/robustnessAnalysis/doubleRobustnessAnalysis.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - LPs on a hand-built createModel network, every available LP solver.
%
% Coverage exemptions:
%     every line - doubleRobustnessAnalysis is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: objRxn is ignored unless objType is also given
%       SEVERITY: wrong-result
%       TRIGGER: doubleRobustnessAnalysis(model, 'EX_A', 'EX_C', 2, false, 'S2') with model =
%         changeObjective(createModel({'EX_A', 'R1', 'R2', 'S1', 'S2', 'EX_C'}, {'EX_A', 'R1',
%         'R2', 'S1', 'S2', 'EX_C'}, {' -> A', 'A -> P', 'A -> Q', 'P -> ', 'Q -> ', ' -> C'},
%         'upperBoundList', [10 1000 3 1000 1000 10], 'printLevel', 0), 'S1')
%       OBSERVED: (R2025a, gurobi, 2026-11-25) objFlux = [0 0; 10 10], the maximum of the model
%         objective S1; with objType 'max' added the same call returns [0 0; 3 3], the maximum
%         of S2. Line 38 tests nargin > 6, so objRxn alone (six arguments) is dropped
%       EXPECTED: [0 0; 3 3] for six arguments: objRxn is documented as optional on its own and
%         objType defaults to 'max'
%       LINES: 38-42
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-25.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testDoubleRobustnessAnalysis'));
cd(fileDir);

% declare the requirements of this test. The function is quarantined and not called, so no
% solver is needed; the call is the standard opening of a COBRA test and the place where the
% requirement (an LP solver) is added when the defect is fixed
prepareTest();

% change the directory
cd(currentDir)
