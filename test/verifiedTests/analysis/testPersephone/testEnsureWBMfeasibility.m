% The COBRAToolbox: testEnsureWBMfeasibility.m
%
% Purpose:
%     - ensureWBMfeasibility loads the whole-body models of a folder, tests which grow on a
%       diet, opens the diet to find models that cannot grow on any diet, searches the diet
%       components missing for the others (existing diet reactions with a larger uptake,
%       getMissingDietPersephone), propagates an updated diet to every model and writes
%       feasibility tables to dietGrowthStats.xlsx in the folder. Quarantined: no behaviour of
%       ensureWBMfeasibility is asserted until the defect below is fixed.
%
% Function under test:
%     src/analysis/persephone/ensureWBMfeasibility.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - LP (optimizeWBModel) on whole-body models.
%
% Coverage exemptions:
%     every line - ensureWBMfeasibility is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The solver option is ignored; the current LP solver is always used
%       SEVERITY: unusable-option
%       TRIGGER: ensureWBMfeasibility(folder, 'solver', 'glpk') while the current LP solver
%         (global CBT_LP_SOLVER) is gurobi; folder is an empty temporary folder
%       OBSERVED: (R2025a, 2026-11-25) CBT_LP_SOLVER is still 'gurobi' after the call: when
%         CBT_LP_SOLVER is not empty the else branch sets solver = CBT_LP_SOLVER whatever the
%         option says, and changeCobraSolver(solver, 'LP') then selects gurobi; the elseif
%         branch is unreachable (same empty test as the if branch)
%       EXPECTED: the models are solved with the solver given by the option (help text:
%         "solver: LP solver to use (default '', i.e. the current solver)"), i.e. glpk
%       LINES: 55-58, 62
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-25.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testEnsureWBMfeasibility'));
cd(fileDir);

% declare the requirements of this test; nothing that calls ensureWBMfeasibility runs while
% it is quarantined, so no solver is required yet
prepareTest();

% change the directory
cd(currentDir)
