% The COBRAToolbox: testCompareDietPerformance.m
%
% Purpose:
%     - compareDietPerformance constrains a model to each of several diets, fixes the
%       microbiota excretion reaction and runs flux variability analysis on a list of
%       reactions of interest, returning a table of the minimum and maximum flux of each
%       reaction under each diet. Quarantined: no behaviour of compareDietPerformance is
%       asserted until the defect below is fixed.
%
% Function under test:
%     src/analysis/wholeBody/Nutrition_Modelling_Toolbox/compareDietPerformance.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - LP (flux variability analysis) on a toy model.
%
% Coverage exemptions:
%     every line - compareDietPerformance is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Every call fails because the diet function setFoodConstraints no longer exists
%       SEVERITY: error
%       TRIGGER: any call with at least one diet, e.g. compareDietPerformance(model, {{'A', 1}},
%         {'R1'}) on a three-reaction toy model
%       OBSERVED: (R2025a, gurobi, 2026-11-25) error MATLAB:UndefinedFunction "Undefined function
%         'setFoodConstraints' for input arguments of type 'struct'." at line 69; no file
%         setFoodConstraints.m exists in the repository (removed by the commit "Overhaul of
%         nutrition toolbox")
%       EXPECTED: a table with the minimum and maximum flux of each reaction of interest under
%         each diet, as the help text describes
%       LINES: 69
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-25.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testCompareDietPerformance'));
cd(fileDir);

% declare the requirements of this test; nothing that calls compareDietPerformance runs while
% it is quarantined, so no solver is required yet
prepareTest();

% change the directory
cd(currentDir)
