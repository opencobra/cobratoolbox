% The COBRAToolbox: testPhysiologicalConstraintsHMDBbasedTEMP.m
%
% Purpose:
%     - physiologicalConstraintsHMDBbasedTEMP sets the bounds of the blood, cerebrospinal
%       fluid and urine exchange reactions of a whole-body model from metabolite
%       concentration ranges (HMDB tables shipped with the toolbox, or direct input) and the
%       physiological parameters of an individual, then applies fixed literature constraints.
%       The function is QUARANTINED (Constitution III-Defects, quarantine in back-fill
%       campaigns): the concentration ranges are never matched to the metabolites (defects
%       below), so no assertion about the function is made.
%
% Function under test:
%     src/analysis/persephone/additionalFunctions/physiologicalConstraintsHMDBbasedTEMP.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - a test would use a hand-built stand-in model (createModel) whose reaction
%     identifiers follow the whole-body naming (Organ_EX_met(e)_[bc], BBB_met[CSF]exp,
%     EX_met[u], ...) and hand-built IndividualParameters, no solver and no whole-body model.
%
% Coverage exemptions:
%     every line - physiologicalConstraintsHMDBbasedTEMP is quarantined for the defects below
%     (feature 20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Measured concentrations are never matched when the data has more than one row
%       SEVERITY: wrong-result
%       TRIGGER: physiologicalConstraintsHMDBbasedTEMP(model, IndividualParameters) (HMDB
%         tables) on a model with the reaction Kidney_EX_glc_D(e)_[bc] (Kidney_glc_D[e] <=>
%         glc_D[bc]); hand-built parameters: male, CardiacOutput 5360 ml/min, Hematocrit
%         0.4, kidney blood flow fraction 0.19 (glomerular filtration rate 122.2 ml/min)
%       OBSERVED: lb = -3.5196 and ub = 0 (MATLAB R2025a), the values of the default range
%         MConMin = 0, MConMax = MConDefaultBc = 20 uM (lines 376-378); every kidney,
%         cerebrospinal-fluid and urine exchange gets the default range; in 'direct' mode
%         with InputData {'glc_D', 4000, 6000; 'ala_L', 300, 500} and Biofluid 'bc' no bound
%         changes at all, while the single row {'glc_D', 4000, 6000} does set the kidney
%         bounds. Cause: strcat(metConcDataBc{:,VMHIDCol},'[bc]') (and the CSF, urine and
%         organ variants) expands the cell column into separate arguments, so strcat joins
%         all identifiers into one string ({'a';'b';'c'} gives 'abc[bc]') and ismember never
%         finds a metabolite; the original physiologicalConstraintsHMDBbased.m indexes with
%         parentheses, metConcDataBc(:,VMHIDCol)
%       EXPECTED: from the HMDB blood range of glc_D (1100-20880 uM): ub = -193.58 and
%         lb = -3674.5 mmol/day/person (the formulas of lines 408 and 433)
%       LINES: 374, 440, 513, 603
%     - DEFECT: Blood uptake constraints of organs other than the kidney are never applied
%       SEVERITY: wrong-result
%       TRIGGER: physiologicalConstraintsHMDBbasedTEMP(model, IndividualParameters, {},
%         'direct', {'glc_D', 4000, 6000}, 'bc') on a model with Liver_EX_glc_D(e)_[bc]
%         (Liver_glc_D[e] <=> glc_D[bc]), parameters as above with liver blood flow 0.27
%       OBSERVED: the bounds stay at -1000 and 1000 (MATLAB R2025a): line 440 compares the
%         identifier without the '[bc]' suffix with the metabolite 'glc_D[bc]', so X is
%         always empty and the uptake bound of lines 447-457 is never set (the second lookup
%         of line 442 is not used either)
%       EXPECTED: lb = -(5000/1000) * 868.3 * 60 * 24 / 1000 = -6251.8 mmol/day/person (line
%         449: the mean of the two concentrations and the liver plasma flow 0.27 * 5360 *
%         (1 - 0.4) ml/min)
%       LINES: 440-443
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testPhysiologicalConstraintsHMDBbasedTEMP'));
cd(fileDir);

% declare the requirements of this test: a Tier 2 test needs no solver, MATLAB toolbox or
% particular operating system; the function is quarantined, so nothing below calls it
prepareTest();

% change the directory
cd(currentDir)
