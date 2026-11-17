% The COBRAToolbox: testCompareSampleTraj.m
%
% Purpose:
%     - compareSampleTraj plots, for each reaction of a list, the sampled flux trajectories of
%       several samples (one line per sample) in a grid of subplots. A test would check the number
%       of subplots, the plotted trajectories and the axis limits against hand-built samples of a
%       createModel model.
%     - The function is QUARANTINED (Constitution III-Defects, quarantine in back-fill campaigns):
%       the documented call without the optional nBins stops with an error (first defect below), so
%       this file makes no assertion about the function.
%
% Function under test:
%     src/analysis/sampling/compareSampleTraj.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - a createModel model, hand-built sample matrices, a figure, no solver.
%
% Coverage exemptions:
%     every line - compareSampleTraj is quarantined for the defect below
%     (feature 20261113-142115-test-backfill-tiers).
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The documented default of nBins is never set, so a call without nBins fails
%       SEVERITY: error
%       TRIGGER: compareSampleTraj({'r1'}, {[1 2 3; 4 5 6]}, {model}) with model =
%       createModel({'r1','r2'}, {'r1','r2'}, {'A -> B','B ->'}) (nBins omitted, documented
%       default nSamples/25)
%       OBSERVED: 'Not enough input arguments.' at line 50 (MATLAB R2025a): lines 17-20 assign the
%       default to a variable named bins, and line 50 then reads the unset nBins
%       EXPECTED: nBins = round(nSamples/25) is used, as the header documents
%       LINES: 17-20, 50
%     - DEFECT: The fallback to the reversed reaction <name>_r never runs
%       SEVERITY: wrong-result
%       TRIGGER: a reaction name that is not in a model whose reversed half <name>_r is, e.g.
%       rxnNames {'r1_'} with model.rxns {'r1'; 'r2'}, nBins 5
%       OBSERVED: 'Index in position 1 is invalid. Array indices must be positive integers or
%       logical values.' at line 46 (MATLAB R2025a): findRxnIDs returns 0, not an empty array, for
%       an absent name, so the isempty tests of lines 40 and 55 are never true and 0 is used as an
%       index
%       EXPECTED: the reaction is looked up as <name>_r (lines 41 and 56) and, if absent, the
%       error 'Reaction does not exist' of line 43
%       LINES: 40-45, 55-58
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testCompareSampleTraj'));
cd(fileDir);

% declare the requirements of this test. The function is quarantined, so this file needs no
% solver, MATLAB toolbox or particular operating system; the call is the standard opening of
% a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
