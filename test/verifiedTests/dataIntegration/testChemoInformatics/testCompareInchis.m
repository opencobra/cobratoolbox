% The COBRAToolbox: testCompareInchis.m
%
% Purpose:
%     - compareInchis scores a list of InChIs for one metabolite of a model: agreement of the
%       InChI net charge and formula (hydrogen ignored) with the model, number of
%       stereochemical sub-layers, standard InChI, how often the same InChI and the same main
%       layer occur in the list, and whether the InChI has the most layers.
%     - The function is QUARANTINED (Constitution III-Defects, quarantine in back-fill
%       campaigns): the independent review (T027/T028) showed that the R groups of a model
%       formula are not removed before the formula comparison, as the code and the help text
%       intend, so no InChI formula can match a metabolite with an R group; this file makes no
%       assertion about the function. The wave version of this test (git history) worked out
%       every column and the total scores by hand for short hand-written InChIs (row input,
%       empty entry, metCharges, metCharge, no charge field); it is the starting point once
%       the defect is fixed (its last section asserted the defective R-group result).
%
% Function under test:
%     src/dataIntegration/chemoInformatics/inchi/compareInchis.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - look-up on a createModel toy model with formulas and charges; no solver.
%
% Coverage exemptions:
%     every line - compareInchis is quarantined for the defects below (feature
%     20261113-142115-test-backfill-tiers, independent review T027/T028). Before the
%     quarantine the test exempted line 76 (unreachable, second entry below).
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The R groups of the model formula are replaced by R instead of removed, so the formula never matches
%       SEVERITY: wrong-result
%       TRIGGER: compareInchis(model, inchis, met) when the model formula of met contains X, Y,
%         * or FULLR together with other atoms; for example model.metFormulas = 'C6H12O6X' for
%         met 'glcr' and inchis = {'InChI=1S/C6H12O6/c7-1-2/h2H/t2-/m1/s1'}
%       OBSERVED: (R2025a, 2026-11-17) formulaOkBool false and score 6 (the same InChI scores
%         16 with formulaOkBool true for a metabolite with formula C6H12O6): line 78 calls
%         editChemicalFormula, which replaces X, Y, * and FULLR by R ('C6H12O6R'), so after
%         the hydrogen is removed 'C6O6R' is compared with 'C6O6' and the 10 formula points
%         are lost for every InChI
%       EXPECTED: the R groups removed before the comparison ("Remove the R groups from the
%         formula", line 72; formulas compared "excluding hydrogen and non-chemical atoms",
%         lines 109-111), so 'C6O6' matches and formulaOkBool is true
%       LINES: 72-83
%     - DEFECT: A model formula made only of R groups is not treated as H
%       SEVERITY: wrong-result
%       TRIGGER: compareInchis(model, inchis, met) with model.metFormulas = 'X' for met; for
%         example inchis = {'InChI=1S/p+1'}
%       OBSERVED: (R2025a, 2026-11-17) formulaOkBool false: regexprep({'X'}, ["X", "Y", "*",
%         "FULLR"], '') returns a 1-by-1 cell holding '', so isempty at line 75 is false, line
%         76 is never reached and the formula becomes editChemicalFormula({'X'}) = 'R'
%       EXPECTED: the formula set to 'H' (line 76), so that it matches an InChI whose formula
%         is hydrogen only
%       LINES: 75-76
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.
%     - Converted to the quarantine layout after the independent review (T027/T028), 2026-11-17.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testCompareInchis'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
