% The COBRAToolbox: testSetDietConstraints.m
%
% Purpose:
%     - setDietConstraints closes every Diet_EX_ uptake of a whole-body model, opens the
%       metabolites essential to the AGORA microbes and a fixed list of compounds missing from
%       the diet database, then sets the lower and upper bounds of the diet exchanges from a
%       diet table (a predefined diet script or a user cell array of reaction identifiers and
%       flux values in mmol/day/person) with special rules for micronutrients, ions and
%       sulfate, scaled by a factor.
%     - Once the defect below is fixed, the test should check, on a hand-built model with one
%       diet exchange of every kind (plain nutrient, micronutrients <= 10 and > 10, ion,
%       sulfate, choline, a missing compound, AGORA essentials) and two reactions that are no
%       diet exchange: the bounds against values worked out by hand from the rules of the
%       function (lb = -1.2 x value x factor, ub = -0.8 x value x factor, micronutrient and ion
%       exceptions) for flux values given as numbers and as text, the default factor, the five
%       predefined diets (entry counts and the glucose and sodium values read from the diet
%       scripts) and the recorded SetupInfo.
%       Quarantined: no behaviour of setDietConstraints is asserted until the error defect
%       below is fixed; this file only opens the test.
%
% Function under test:
%     src/analysis/wholeBody/PSCMToolbox/setConstraints/setDietConstraints.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - model manipulation without a solver on a hand-built model with the fields the
%     function reads (rxns, lb, ub); no whole-body model is loaded.
%
% Coverage exemptions:
%     every line - setDietConstraints is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: A user diet with numeric flux values stops with an error
%       SEVERITY: error
%       TRIGGER: model = struct('rxns', {{'Diet_EX_glc_D[d]'; 'Diet_EX_na1[d]';
%         'Diet_EX_thm[d]'}}, 'lb', [-1; -1; -1], 'ub', [1; 1; 1]);
%         setDietConstraints(model, {'Diet_EX_glc_D[d]', 10}); also
%         setDietConstraints(model, {'Diet_EX_thm[d]', 1}) (a micronutrient)
%       OBSERVED: (R2025a, 2026-11-17) error "Input must be a character vector or string
%         scalar." from str2num, called at line 166 (glucose) and at line 156 (thiamin); the
%         header (lines 18-22) documents Diet as "a diet cell array whose first column holds
%         diet exchange reaction identifiers and whose second column holds the corresponding
%         flux values", without restricting the values to text; the same diet with the value
%         '10' (text) gives lb = -12, ub = -8 for glucose
%       EXPECTED: numeric flux values accepted as documented, giving the same bounds as the
%         same values written as text
%       LINES: 156-166, 174-178
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.
%     - Quarantined after the independent review (T027/T028), 2026-11-17.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testSetDietConstraints'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
