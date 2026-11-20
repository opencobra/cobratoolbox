% The COBRAToolbox: testMakeDietFormatConsistant.m
%
% Purpose:
%     - makeDietFormatConsistant renames the components of a diet (an n x 2 cell array) to the
%       reaction identifiers setFoodConstraints expects: food items and food categories become
%       Food_EX_<name>[d], metabolites with a Diet_EX_<name>[d] reaction in the model become
%       Diet_EX_<name>[d]. A test would check both renamings and an unknown name left as it is.
%     - The function is QUARANTINED (Constitution III-Defects, quarantine in back-fill campaigns):
%       every call stops at its first line because the data file it loads is not in the
%       repository (defect below), so this file makes no assertion about the function.
%
% Function under test:
%     src/analysis/wholeBody/Nutrition_Modelling_Toolbox/makeDietFormatConsistant.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - renaming on a small hand-built model, no solver.
%
% Coverage exemptions:
%     every line - makeDietFormatConsistant is quarantined for the defect below
%     (feature 20261113-142115-test-backfill-tiers).
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: the food tables fdTable.mat and fdCategoriesTable.mat are not in the repository
%       SEVERITY: error
%       TRIGGER: any call, e.g. makeDietFormatConsistant(createModel({'Diet_EX_glc[d]'}, {'x'},
%       {'glc[d] <=> '}), {'glc', 1})
%       OBSERVED: MATLAB R2025a: "Unable to find file or directory 'fdTable.mat'." at line 21;
%       neither file is tracked by git or present anywhere in the working tree
%       EXPECTED: the diet {'Diet_EX_glc[d]', 1} (documented renaming for a metabolite with a
%       Diet_EX_ reaction in the model)
%       LINES: 21-29
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testMakeDietFormatConsistant'));
cd(fileDir);

% declare the requirements of this test. The function is quarantined, so this file needs no
% solver, MATLAB toolbox or particular operating system; the call is the standard opening of
% a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
