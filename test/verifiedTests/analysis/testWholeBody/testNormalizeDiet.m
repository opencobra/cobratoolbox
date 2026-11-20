% The COBRAToolbox: testNormalizeDiet.m
%
% Purpose:
%     - normalizeDiet scales the amounts of the food items of a diet (an n x 2 cell array) so
%       that the diet energy given by getDietEnergy equals a caloric target, keeping the
%       amounts of the listed exceptions. The function is QUARANTINED (Constitution
%       III-Defects, quarantine in back-fill campaigns): every call stops at its first line
%       because the food table it loads is not shipped, so no assertion about the function is
%       made.
%
% Function under test:
%     src/analysis/wholeBody/Nutrition_Modelling_Toolbox/normalizeDiet.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model and no solver; a test would use a hand-built diet.
%
% Coverage exemptions:
%     every line - normalizeDiet is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Every call fails because fdTable.mat is not shipped
%       SEVERITY: error
%       TRIGGER: any call, for example normalizeDiet({'167512', 100}, 2000, {})
%       OBSERVED: (R2025a, 2026-11-15) error MATLAB:load:couldNotReadFile "Unable to find file
%         or directory 'fdTable.mat'." at line 20; no fdTable.mat exists in the repository
%         (getDietEnergy, which normalizeDiet calls, dropped the fdTable food names in 2024 and
%         now reads USDA, Frida or BLS food IDs)
%       EXPECTED: the diet with the amounts of its food items scaled so that its energy equals
%         the calories argument
%       LINES: 20-54
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testNormalizeDiet'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
