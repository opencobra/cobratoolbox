% The COBRAToolbox: testSetSemiQuantConstraints.m
%
% Purpose:
%     - setSemiQuantConstraints rescales the lower bounds of exchange reactions of two models
%       (condition 1: modelA, condition 2: modelB) by the relative differences of signal
%       intensities given in four lists (higher uptake in condition 1 or 2, higher secretion
%       in condition 1 or 2), in the formats produced by calculateQuantitativeDiffs.
%     - The function is QUARANTINED (Constitution III-Defects, quarantine in back-fill
%       campaigns): the independent review (T027/T028) showed that an empty list of
%       exchanges with higher uptake in condition 1 stops the call, so this file makes no
%       assertion about the function. The wave version of this test (git history) built two
%       createModel models with different bounds and checked the bounds of every list
%       (including the d > 1 and p/100 > 1 cases and an empty cond2_upt_higher list) against
%       values worked out by hand; it is the starting point once the defect is fixed.
%
% Function under test:
%     src/dataIntegration/metabotools/setSemiQuantConstraints.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - bound manipulation on small createModel models; no solver.
%
% Coverage exemptions:
%     every line - setSemiQuantConstraints is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers, independent review T027/T028). Before the
%     quarantine the test reached every executable line.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: An empty cond1_upt_higher list stops with an error
%       SEVERITY: error
%       TRIGGER: setSemiQuantConstraints(m, m, cell(0, 2), {'EX_a', 0.5}, {'EX_b', 10},
%         {'EX_b', 10}) with m = createModel({'EX_a', 'EX_b'}, {'EX_a', 'EX_b'}, {'a <=> ',
%         'b <=> '}); any call with an empty cond1_upt_higher and a non-empty
%         cond2_secr_higher or cond1_secr_higher
%       OBSERVED: (R2025a, 2026-11-17) "Unrecognized function or variable 'c'." at line 76:
%         the row counter c is first set inside the loop over cond1_upt_higher (line 62), so
%         with zero rows the secretion loops (lines 76 and 91) read an undefined variable.
%         With both secretion lists empty as well, the call succeeds
%       EXPECTED: no bound changed for the empty list and the other lists applied. The header
%         (line 23) documents cond1_upt_higher as the "Exchange reactions and relative
%         differences with higher uptake in condition 1 compared to condition 2", a set that
%         can be empty, and the sibling list cond2_upt_higher works when empty
%       LINES: 62, 76, 91
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.
%     - Converted to the quarantine layout after the independent review (T027/T028), 2026-11-17.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testSetSemiQuantConstraints'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
