% The COBRAToolbox: testCreateUSDAdatabase.m
%
% Purpose:
%     - createUSDAdatabase(path2Files, varargin) reads the USDA FoodData Central files
%       (food.csv, food_nutrient.csv) and an info file linking USDA nutrients to VMH
%       metabolites, writes one food-nutrient table per food source, and saves the flux table
%       (mmol/100 g), the macro table, the info file and the food items as .csv/.mat files.
%       Quarantined: no behaviour of createUSDAdatabase is asserted until the unusable-option
%       defect below is fixed.
%
% Function under test:
%     src/analysis/wholeBody/Nutrition_Modelling_Toolbox/createUSDAdatabase.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; a test would write small hand-built USDA files into a
%     tempname folder.
%
% Coverage exemptions:
%     every line - createUSDAdatabase is quarantined for the defects below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: brandedFoods = true always raises an error
%       SEVERITY: unusable-option
%       TRIGGER: createUSDAdatabase(d, 'brandedFoods', true, 'foodSource2Use',
%         {'sr_legacy_food'; 'foundation_food'}) with a folder d holding food.csv,
%         food_nutrient.csv and usda2vmhInfoFile.xlsx (one branded_food item)
%       OBSERVED: error "Colon operands must be real scalars." on line 127 (the loop bound
%         size(brandedNames.fdc_id) is a 1x2 vector); past it, line 133 uses the undefined name
%         foodsnutrients (the table is foodNutrients) and lines 145 and 151 save into the
%         current folder instead of outputDir
%       EXPECTED: the branded-food tables are created, as the help text says ("brandedFoods -
%         boolean; if true the branded-foods source table is also created")
%       LINES: 127, 133
%     - DEFECT: The progress message has no space before the food source name
%       SEVERITY: cosmetic
%       TRIGGER: any call, e.g. the default foodSource2Use
%       OBSERVED: "Currently creating the individual database forsr_legacy_food" (strcat drops
%         the trailing blank of its first argument)
%       EXPECTED: "Currently creating the individual database for sr_legacy_food"
%       LINES: 94
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testCreateUSDAdatabase'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
