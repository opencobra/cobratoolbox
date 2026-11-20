% The COBRAToolbox: testPhysiologicalConstraintsHMDBbased_old.m
%
% Purpose:
%     - physiologicalConstraintsHMDBbased_old is the legacy version of
%       physiologicalConstraintsHMDBbased: it bounds the blood, cerebrospinal fluid and urine
%       exchanges of a whole-body model from metabolite concentrations (bundled HMDB tables or
%       direct input), organ blood flows, a filtration rate derived from the kidney blood flow
%       and the creatinine excretion, then applies fixed literature constraints. A test would
%       check the bounds against hand-worked values on a small hand-built model.
%     - The function is QUARANTINED (Constitution III-Defects, quarantine in back-fill campaigns):
%       ExclList is ignored for the blood exchanges of every organ but the kidney (defect
%       below, the same defect as in physiologicalConstraintsHMDBbased), so this file makes no
%       assertion about the function.
%
% Function under test:
%     src/analysis/wholeBody/PSCMToolbox/setConstraints/physiologicalConstraintsHMDBbased_old.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - model manipulation without a solver on a hand-built model with the fields the
%     function reads (rxns, mets, S, lb, ub); no whole-body model is loaded.
%
% Coverage exemptions:
%     every line - physiologicalConstraintsHMDBbased_old is quarantined for the defect below
%     (feature 20261113-142115-test-backfill-tiers).
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: ExclList is ignored for the blood exchanges of every organ but the kidney
%       SEVERITY: wrong-result
%       TRIGGER: a model with Liver_EX_xyz(e)_[bc] (Liver_xyz[e] <=> xyz[bc], bounds -1000/1000,
%       xyz not in the HMDB table) and the eight reactions of the literature constraints
%       (Muscle_EX_glc_D(e)_[bc], Muscle_EX_ala_L(e)_[bc], RBC_EX_glc_D(e)_[bc],
%       Brain_EX_glc_D(e)_[csf], Brain_EX_o2(e)_[csf], Liver_EX_ala_L(e)_[bc],
%       Liver_EX_glc_D(e)_[bc], Adipocytes_EX_glyc(e)_[bc]); IndividualParameters with gender
%       'male', CardiacOutput 5000, Hematocrit 0.4, MConDefaultBc 20, liver blood flow '"0.25"';
%       physiologicalConstraintsHMDBbased_old(model, IndividualParameters,
%       {'Liver_EX_xyz(e)_[bc]'})
%       OBSERVED: MATLAB R2025a: the lower bound of Liver_EX_xyz(e)_[bc] becomes -21.6 (20 uM x
%       liver plasma flow 750 ml/min x 1440 / 1e6), the same as without ExclList; the general
%       blood branch (lines 398-472) never reads ExclList, which only the kidney (line 376),
%       CSF (line 551, HMDB input only) and urine (line 695) branches use
%       EXPECTED: the bounds of a reaction in ExclList unchanged (documented: reactions to be
%       excluded from receiving updated bounds)
%       LINES: 398-472, 548-549
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testPhysiologicalConstraintsHMDBbased_old'));
cd(fileDir);

% declare the requirements of this test. The function is quarantined, so this file needs no
% solver, MATLAB toolbox or particular operating system; the call is the standard opening of
% a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
