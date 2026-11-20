% The COBRAToolbox: testDirectionalityChangeReport.m
%
% Purpose:
%     - directionalityChangeReport writes, for each of 17 classes of change between the
%       qualitative (reconstruction) and quantitative (thermodynamic) reaction directions,
%       a structured report (metabolites ranked by the number of changed reactions they
%       take part in, then each reaction with its substrates and products) and a table
%       (reactions with formula and Gibbs energy ranges, cytoplasmic metabolites), one file
%       each, named <resultsBaseFileName><class>_StructuredView.txt and
%       <resultsBaseFileName><class>.txt. The function is QUARANTINED (Constitution
%       III-Defects, quarantine in back-fill campaigns): two pairs of classes share a file
%       name, so one class of each pair is lost, and two class descriptions state the wrong
%       probability bound (defects below), so no assertion about the function is made.
%
% Function under test:
%     src/analysis/thermo/directionalityReport/directionalityChangeReport.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - a test would use a hand-built three-reaction model with the thermodynamic
%     fields, a hand-built directions structure and a temporary folder; no solver.
%
% Coverage exemptions:
%     every line - directionalityChangeReport is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Two pairs of classes are written to the same file, so one class of each pair is lost
%       SEVERITY: wrong-result
%       TRIGGER: model = createModel({'R1'; 'R2'; 'R3'}, {'one'; 'two'; 'three'}, {'A[c] ->
%         B[c]'; 'B[c] -> C[c]'; 'C[c] -> A[c]'}, [], zeros(3, 1), 10 * ones(3, 1)) with
%         gasConstant = 8.3144621e-3, T = 298.15, DrGt0Min = [0; -4; -6], DrGt0Max = [0;
%         -4; 2], DrGtMin = [-3; -9; -10], DrGtMax = [3; 1; 5], DfGt0 = [-10; -20; -30],
%         DfG0_Uncertainty = [1; 2; 3], concMin = 1e-5 * ones(3, 1), concMax = 1e-2 *
%         ones(3, 1); directions with every documented field false(3, 1) except
%         forward2Reversible = true(3, 1), forward2Reversible_byConc_zero_fixed_DrG0 = [1; 0;
%         0], forward2Reversible_byConc_negative_fixed_DrG0 = [0; 1; 0],
%         forward2Reversible_bydGt0 = forward2Reversible_bydGt0LHS = [0; 0; 1]; in an empty
%         folder: directionalityChangeReport(model, directions, 0.2, 0, 'r_')
%       OBSERVED: MATLAB R2025a: 30 files for the 17 classes (34 expected);
%         r_forward_to_reversible_negative_exact_DrG0t.txt lists only R2, R1 (the zero
%         fixed DrGt0 class) is lost, and
%         r_forward_to_reversible_DrG0t_spans_zero_possibly_reversible.txt lists no reaction
%         although R3 is in forward2Reversible_bydGt0 (it is overwritten by the empty
%         bydGt0Mid class): lines 138 and 142, and lines 121 and 129, give the same file
%         name
%       EXPECTED: one pair of files per class: R1 in the zero fixed DrGt0 files and R3 in the
%         files of forward2Reversible_bydGt0
%       LINES: 121, 129, 138, 142
%     - DEFECT: The descriptions of the bydGt0LHS and bydGt0RHS classes state the wrong probability bound
%       SEVERITY: wrong-result
%       TRIGGER: the call above
%       OBSERVED: MATLAB R2025a:
%         r_forward_to_reversible_DrG0t_spans_zero_probably_forward_StructuredView.txt
%         (class forward2Reversible_bydGt0LHS, reaction R3) begins 'Metabolites which force
%         1 qualitatively  forward -> quantiatively reversible (DrG0t span the zero line).
%         Forward with probability less than 0.3.'; directionalityStats defines bydGt0LHS as
%         forwardProbability > 0.5 + cumNormProbCutoff and bydGt0RHS as < 0.5 -
%         cumNormProbCutoff, so lines 124 and 132 swap the two bounds
%       EXPECTED: bydGt0LHS: forward with probability greater than 0.7; bydGt0RHS: less than
%         0.3
%       LINES: 124, 132
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testDirectionalityChangeReport'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
