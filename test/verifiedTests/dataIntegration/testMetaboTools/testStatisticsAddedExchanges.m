% The COBRAToolbox: testStatisticsAddedExchanges.m
%
% Purpose:
%     - statisticsAddedExchanges collects the exchange reactions added to the models of all
%       samples (ResultsAllCellLines.<sample>.Ex_RxnsAdded) and returns a table of the distinct
%       exchanges with their number of occurrences (column 2) and, from the flux ranges
%       ResultsAllCellLines.<sample>.MinMaxAddedRxns, 'secretion' (column 3, min >= 0 and
%       max > 0), 'uptake' (column 4, min < 0 and max <= 0) and 'both1' (column 5, min < 0 <
%       max; column 6, min > 0 > max), ordered by the frequency of appearance (documented).
%     - Once the defect below is fixed, the test should check hand-built ResultsAllCellLines
%       structures (two samples, exchanges shared and not shared, each range pattern) with
%       the counts and labels derived by hand, including the order by decreasing frequency.
%       Quarantined: no behaviour of statisticsAddedExchanges is asserted until the
%       wrong-result defect below is fixed; this file only opens the test.
%
% Function under test:
%     src/dataIntegration/metabotools/statisticsAddedExchanges.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver, hand-built result structures.
%
% Coverage exemptions:
%     every line - statisticsAddedExchanges is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The table is not ordered by frequency as documented; the sorted copy goes to a
%         differently spelled variable
%       SEVERITY: wrong-result
%       TRIGGER: R.s1.Ex_RxnsAdded = {'EX_a'; 'EX_b'}; R.s1.MinMaxAddedRxns = [0 1; -1 0];
%         R.s2.Ex_RxnsAdded = {'EX_b'}; R.s2.MinMaxAddedRxns = [-1 0];
%         statisticsAddedExchanges(R, {'s1', 's2'})
%       OBSERVED: (R2025a, 2026-11-15) rows {'EX_a', 1, 'secretion', []} then {'EX_b', 2, [],
%         'uptake'} (alphabetical order of unique): lines 74 and 76 assign to
%         EX_added_all_unique, while the output is Ex_added_all_unique; sortrows(output, -2)
%         itself returns the rows in the documented order
%       EXPECTED: EX_b (2 occurrences) before EX_a (1 occurrence)
%       LINES: 74-76
%     - DEFECT: The sample counter is printed for every sample
%       SEVERITY: cosmetic
%       TRIGGER: any call with at least one sample
%       OBSERVED: (R2025a, 2026-11-15) "i =" and the index are printed once per sample (line
%         32 has no semicolon)
%       EXPECTED: no console output, or output gated behind a printLevel
%       LINES: 32
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testStatisticsAddedExchanges'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
