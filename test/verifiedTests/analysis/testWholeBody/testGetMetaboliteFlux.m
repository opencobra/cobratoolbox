% The COBRAToolbox: testGetMetaboliteFlux.m
%
% Purpose:
%     - getMetaboliteFlux(diet, ...) converts a diet of USDA, Frida or BLS food items (grams per
%       day) into Diet_EX_<met>[d] metabolite fluxes from the per-100 g flux tables, summing
%       duplicate items and the fluxes of several databases, and optionally adds the starch that
%       the USDA macros do not measure (addStarch). The function is QUARANTINED (Constitution
%       III-Defects, quarantine in back-fill campaigns): the addStarch option stops with an error
%       for every food of the shipped USDA database, and for a food whose macro values contain one
%       of the nutrient ids it looks up; no assertion about the function is made.
%
% Function under test:
%     src/analysis/wholeBody/Nutrition_Modelling_Toolbox/getMetaboliteFlux.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; a test would pass hand-built flux and macro tables and load
%     hand-made database files of a fictitious edition from a tempname folder.
%
% Coverage exemptions:
%     every line - getMetaboliteFlux is quarantined for the defects below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: addStarch fails for every food of the shipped USDA database
%       SEVERITY: unusable-option
%       TRIGGER: getMetaboliteFlux({'167512', 100}, 'addStarch', true) with the shipped
%         papers/2025_nutritionToolbox/usdaDatabase (edition 2024)
%       OBSERVED: (R2025a, 2026-11-15) error MATLAB:TooManyOutputsDueToMissingBraces "Unable to
%         perform assignment with 0 elements on the right-hand side." at line 222: the starch
%         flux is looked up as Diet_EX_strch1[d], but the shipped USDA2024_100gFluxValue table
%         names starch starch1200 (usda2024_infoFile: nutrient 1009 Starch, vmhID starch1200)
%         and has no strch1 row; the same error for food 169951
%       EXPECTED: the metabolite fluxes with the unmeasured starch added to the starch flux, as
%         the help text documents for addStarch
%       LINES: 222, 231
%     - DEFECT: addStarch fails when a macro value of the food equals a looked-up nutrient id
%       SEVERITY: error
%       TRIGGER: flux = table({'strch1'; 'glc_D'}, [10; 20], 'VariableNames', {'VMHID', '100001'});
%         macro = table([1009; 1005; 1063; 1079; 1104], [NaN; 50; 10; 5; 1009], 'VariableNames',
%         {'nutrient_id', '100001'}); getMetaboliteFlux({'100001', 100}, 'addStarch', true,
%         'fluxTableUsda', flux, 'foodMacroUsda', macro)
%       OBSERVED: (R2025a, 2026-11-15) error MATLAB:badsubscript "The logical indices in position 1
%         contain a true value outside of the array bounds." at line 272: macrosSpef == 1009 is
%         compared over both columns [nutrient_id, value], so a value of 1009 selects a row
%         beyond the table. With the value 7 instead of 1009 the call returns strch1 29.438
%         (10 + (50 - 10 - 5) / 1.8006). In the shipped USDA 2024 macros, food 169951 holds the
%         value 1009 and food 167780 the value 2000 (nutrient 1104)
%       EXPECTED: the comparison on the nutrient_id column only, and the starch flux computed
%       LINES: 272, 278, 285-287, 299-301
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testGetMetaboliteFlux'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
