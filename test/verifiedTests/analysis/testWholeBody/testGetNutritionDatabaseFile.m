% The COBRAToolbox: testGetNutritionDatabaseFile.m
%
% Purpose:
%     - getNutritionDatabaseFile(database, fileType, edition) returns the path of a USDA, Frida
%       or BLS nutrition database file (<prefix><edition>_<fileType>.mat): from
%       papers/2025_nutritionToolbox/<database>Database when it is there, otherwise from the
%       MATLAB path, and with the latest edition that has a flux table when no edition is given.
%     - Once the defect below is fixed, the test should check: the default edition against an
%       independent listing of the shipped database folders (the papers submodule), the path
%       of every documented file type of the shipped data including the USDA food items file,
%       the lookup on the MATLAB path with hand-made files of a fictitious edition 1999 in a
%       tempname folder (numeric, string and mixed-case inputs, the lowercase prefix of the
%       USDA info file), and every error message (edition not a four-digit year, unknown
%       database, no database folder, file not found).
%       Quarantined: no behaviour of getNutritionDatabaseFile is asserted until the error
%       defect below is fixed; this file only opens the test.
%
% Function under test:
%     src/analysis/wholeBody/Nutrition_Modelling_Toolbox/getNutritionDatabaseFile.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; reads only folder listings (no database is loaded).
%
% Coverage exemptions:
%     every line - getNutritionDatabaseFile is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The documented file type 'foodItems' of the USDA database is not found
%       SEVERITY: error
%       TRIGGER: getNutritionDatabaseFile('usda', 'foodItems') with the papers submodule checked
%         out ('foodItems' (usda) is a documented value of fileType, header lines 12-14)
%       OBSERVED: (R2025a, 2026-11-17) error "Could not find USDA2024_foodItems.mat in
%         <toolbox>/papers/2025_nutritionToolbox/usdaDatabase or on the MATLAB path." at line
%         90: line 85 builds USDA<edition>_foodItems.mat (the name createUSDAdatabase writes),
%         while the shipped folder holds USDA2024_100gFluxValue.mat, USDA2024_100gMacros.mat,
%         usda2024_infoFile.mat and USDAFoodItems.mat (the same at the submodule commit the
%         toolbox records and on the submodule's origin/master)
%       EXPECTED: the path of the shipped USDA food items file
%       LINES: 85-90
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.
%     - Quarantined after the independent review (T027/T028), 2026-11-17.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testGetNutritionDatabaseFile'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
