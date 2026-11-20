% The COBRAToolbox: testPhysiologicalConstraintsHMDBbased.m
%
% Purpose:
%     - physiologicalConstraintsHMDBbased bounds the blood, cerebrospinal fluid and urine
%       exchanges of a whole-body model from metabolite concentration ranges (the bundled
%       HMDB tables or direct input), organ blood flows, the glomerular filtration rate and
%       the creatinine excretion, then applies a fixed set of literature constraints (air,
%       water, brain and heart ATP, glucose and alanine fluxes of muscle, liver, red blood
%       cells and brain, adipocyte glycerol). This test uses a hand-built 46-reaction model
%       with one reaction of every kind the function looks for and hand-built physiological
%       parameters, and checks the bounds against values worked out by hand from the formulas
%       of the function (uptake = concentration x plasma flow x 60 x 24 / 1e6 mmol/day,
%       kidney secretion with the filtration rate, CSF with the CSF blood flow, urine with the
%       creatinine excretion) and the HMDB table entries the fixture names (glc_D 1100-20880,
%       ala_L 143-629, urea 1766.2-10383, creat 5.5-130.4, tym 0-0.0137, no 0-2.4e-6,
%       co2 11100-28460, o2 2780-7780, glyc 2-632.4 uM in blood; glc_D 740-8690, urea 0-7640,
%       na1 89692-153000 uM in CSF; glc_D 0-942.7, urea 6.579-38812.4 umol/mmol creatinine in
%       urine), for a man and a woman, with the direct input in its three biofluids, the
%       default concentrations, the excluded metabolites and the reset of inverted bounds.
%     - Quarantined: the body asserts nothing about the function (the checks above describe
%       the test written before the quarantine, kept for the lead).
%
% Function under test:
%     src/analysis/wholeBody/PSCMToolbox/setConstraints/physiologicalConstraintsHMDBbased.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - model manipulation without a solver on a hand-built model with the fields the
%     function reads (rxns, mets, S, lb, ub); no whole-body model is loaded.
%
% Coverage exemptions:
%     every line - physiologicalConstraintsHMDBbased is quarantined for the wrong-result defect(s)
%     below (feature 20261113-142115-test-backfill-tiers).
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: ExclList is ignored for the blood exchanges of every organ but the kidney
%       SEVERITY: wrong-result
%       TRIGGER: a model with the reaction Liver_EX_xyz(e)_[bc] (Liver_xyz[e] <=> xyz[bc], bounds
%                -1000/1000, xyz not in the HMDB table); physiologicalConstraintsHMDBbased(model,
%                IndividualParameters, {'Liver_EX_xyz(e)_[bc]'})
%       OBSERVED: MATLAB R2025a: the lower bound becomes -21.6 (default concentration 20 uM x
%                 liver plasma flow), the same as without ExclList; the general blood branch
%                 (lines 447-525) never consults ExclList, which only the kidney (line 425),
%                 CSF (line 605, HMDB input only) and urine (line 749) branches merge into
%                 their exclusion lists
%       EXPECTED: the bounds of a reaction in ExclList unchanged (documented: "list of
%                 reaction identifiers that should not receive an updated bound")
%       LINES: 447-525, 602-603
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testPhysiologicalConstraintsHMDBbased'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
