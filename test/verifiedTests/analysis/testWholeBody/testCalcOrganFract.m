% The COBRAToolbox: testCalcOrganFract.m
%
% Purpose:
%     - calcOrganFract computes the organ weights and weight fractions of an individual from
%       body-weight polynomials (Table 3 of PMID 19267313: 14 organs for a man, 15 for a
%       woman), derives six blood cell populations from the blood weight, takes the organs of
%       the model that have no polynomial from the reference man/woman table of
%       getOrganWeightFraction and rewrites IndividualParameters.OrgansWeights.
%     - Once the defect below is fixed, the test should check a 70 kg man, a 100 kg man and a
%       60 kg woman on a hand-built model whose reaction identifiers follow the whole-body
%       models (<Organ>_biomass_maintenance, including Lung_biomass_maintenance), with expected
%       weights evaluated independently from the polynomial coefficients and the blood cell
%       proportions listed in the function, reference weights for the organs without a
%       polynomial (Colon 300/290 g, sIEC 640/600 g) read from the reference table, the
%       model's lung weighted by the lung polynomial, the blood volume, and the rewritten
%       OrgansWeights table.
%       Quarantined: no behaviour of calcOrganFract is asserted until the wrong-result defect
%       below is fixed; this file only opens the test.
%
% Function under test:
%     src/analysis/wholeBody/PSCMToolbox/calcOrganFract.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - model look-ups without a solver on a hand-built model with the reaction
%     identifiers the function reads (no whole-body model is loaded).
%
% Coverage exemptions:
%     every line - calcOrganFract is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The lung of a whole-body model keeps the reference weight instead of the lung
%         polynomial
%       SEVERITY: wrong-result
%       TRIGGER: calcOrganFract(model, struct('sex', 'male', 'bodyWeight', 100,
%         'CardiacOutput', 5360, 'OrgansWeights', {{}})) for a model with the reaction
%         Lung_biomass_maintenance, e.g. struct('rxns', {{'Lung_biomass_maintenance'}}) or the
%         rxns of the shipped Harvey_1_03d (test/models/mat), whose only lung reaction is
%         Lung_biomass_maintenance (no reaction starts with Lungs_)
%       OBSERVED: (R2025a, 2026-11-17) the polynomials name the lung 'Lungs' (lines 70 and 88)
%         while the whole-body models and the reference table name it 'Lung' (OrganLists.m,
%         getOrganWeightFraction), so lines 174-188 treat the model's Lung as an organ without
%         polynomial: the output lists both 'Lungs' (1079.05 g at 70 kg, 1405.00 g at 100 kg)
%         and 'Lung' (536 g at every body weight, the reference man's value); the same with
%         the Harvey reactions at 100 kg
%       EXPECTED: the model's lung weighted by the lung polynomial of Table 3 (the header,
%         lines 4-8, and the comment of lines 167-171 keep only organs not given there
%         constant), listed once
%       LINES: 70, 88, 174-188
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.
%     - Quarantined after the independent review (T027/T028), 2026-11-17.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testCalcOrganFract'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
