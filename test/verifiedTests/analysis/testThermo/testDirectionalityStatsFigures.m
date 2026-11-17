% The COBRAToolbox: testDirectionalityStatsFigures.m
%
% Purpose:
%     - directionalityStatsFigures(directions, resultsBaseFileName, saveFigures) draws pie
%       charts of the counts (nnz) of the boolean vectors of a directions structure (as built
%       by directionalityStats): qualitative directions, quantitative directions, changed
%       directions, all qualitative -> quantitative transitions, forward -> reversible by
%       standard Gibbs energy (only when one of those four vectors is non-empty) and
%       forward -> reversible by concentration; the last two are saved as .fig files when
%       saveFigures is true.
%     - Once the defect below is fixed, the test should build a directions structure by hand
%       for 10 reactions that respects the subset relations of directionalityStats (the LHS,
%       Mid and RHS vectors partition forward2Reversible_bydGt0) and check the number of
%       figures, their titles with percentages computed by hand from the number of distinct
%       reactions, the pie labels and font size, and which .fig files are written (none by
%       default); figures invisible and closed, files in a tempname folder that is removed.
%       Quarantined: no behaviour of directionalityStatsFigures is asserted until the
%       wrong-result defect below is fixed; this file only opens the test.
%
% Function under test:
%     src/analysis/thermo/directionalityReport/directionalityStatsFigures.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver, hand-built boolean vectors; figures are invisible and
%     closed, the .fig files are written in a tempname folder that is removed.
%
% Coverage exemptions:
%     every line - directionalityStatsFigures is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The forward -> reversible by standard Gibbs energy chart counts every reaction
%         twice and doubles the percentage of its title
%       SEVERITY: wrong-result
%       TRIGGER: directions from directionalityStats for a 2-reaction model (S = [-1 0; 1 -1],
%         DrGtMin = [-5; -5], DrGtMax = [5; 5], DrGt0Min = [-1; -1], DrGt0Max = [1; 1],
%         forwardProbability = [0.5; 0.5], reaction 1 forwardRecon, both reversibleThermo,
%         cumNormProbCutoff 0.2), then directionalityStatsFigures(directions, name, 0)
%       OBSERVED: (R2025a, 2026-11-17) directionalityStats gives forward2Reversible_bydGt0 =
%         [true; false] and forward2Reversible_bydGt0Mid = [true; false]; the chart title
%         reads "(100 % of all reactions)" for one forward -> reversible reaction of two, and
%         the pie shows that reaction in two slices: the bydGt0 vector is drawn beside its
%         own subsets LHS, Mid and RHS (lines 126-129), which partition it, and the sum of the
%         four counts is divided by the number of reactions (line 141)
%       EXPECTED: "(50 % of all reactions)" and each reaction in one slice: the share of
%         distinct reactions, with bydGt0 not added to its subsets
%       LINES: 126-141
%     - DEFECT: The title of the standard Gibbs energy chart names the formation energy
%       SEVERITY: cosmetic
%       TRIGGER: any call with a non-empty forward2Reversible_bydGt0 (the trigger above)
%       OBSERVED: (R2025a, 2026-11-17) title "Forward -> Reversible (by
%         \Delta_{f}G^{\primem}_0)" while the slices are labelled with the reaction energy
%         \Delta_{r}G^{\primem}_0 and the vectors are built from DrGtMin and DrGtMax
%       EXPECTED: the reaction Gibbs energy \Delta_{r} in the title
%       LINES: 140
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.
%     - Quarantined after the independent review (T021), 2026-11-17.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testDirectionalityStatsFigures'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
