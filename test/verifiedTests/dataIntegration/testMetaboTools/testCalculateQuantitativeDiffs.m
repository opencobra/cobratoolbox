% The COBRAToolbox: testCalculateQuantitativeDiffs.m
%
% Purpose:
%     - calculateQuantitativeDiffs looks up the detection limit of every uptake and secretion
%       exchange of two conditions and splits the exchanges common to both conditions by their
%       slope ratio into higher uptake and higher secretion in condition 1 or condition 2. The
%       function is QUARANTINED (Constitution III-Defects, quarantine in back-fill campaigns):
%       it stops with an error when the two conditions share no uptake or no secretion
%       exchange, and when one of the four requested difference sets is empty, so no assertion
%       about the function is made.
%
% Function under test:
%     src/dataIntegration/metabotools/calculateQuantitativeDiffs.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; hand-built exchange lists would suffice.
%
% Coverage exemptions:
%     every line - calculateQuantitativeDiffs is quarantined for the defects below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: No uptake or no secretion exchange common to both conditions stops the call
%       SEVERITY: error
%       TRIGGER: r = {'EX_a'; 'EX_b'}; calculateQuantitativeDiffs(r, [0.5; 1.5], r, [1; 2],
%         {'EX_a'}, {'EX_b'}, {'EX_a'}, {'EX_a'}) (no common uptake), or the same call with
%         uptake {'EX_a'}, {'EX_a'} and secretion {'EX_a'}, {'EX_b'} (no common secretion)
%       OBSERVED: Unrecognized function or variable 'common_slope_upt'. (line 81), and
%         Unrecognized function or variable 'common_slope_secr'. (line 101)
%         (R2025a, 2026-11-15)
%       EXPECTED: empty difference sets for the side without common exchanges
%       LINES: 81, 101
%     - DEFECT: An empty difference set is not assigned, so a call requesting it stops
%       SEVERITY: error
%       TRIGGER: r = {'EX_a'; 'EX_b'}; [a, b] = calculateQuantitativeDiffs(r, [0.5; 1.5], r,
%         [1; 2], {'EX_a'}, {'EX_a'}, {'EX_a'}, {'EX_a'}) (the only common uptake has ratio
%         0.5, so no exchange has higher uptake in condition 2); the documented call with all
%         eight outputs fails whenever any of the four sets is empty
%       OBSERVED: Output argument "cond2_upt_higher" (and possibly others) not assigned a
%         value in the execution with "calculateQuantitativeDiffs" function.
%         (R2025a, 2026-11-15)
%       EXPECTED: an empty cell array for an empty difference set
%       LINES: 84, 90, 104, 110
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testCalculateQuantitativeDiffs'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
