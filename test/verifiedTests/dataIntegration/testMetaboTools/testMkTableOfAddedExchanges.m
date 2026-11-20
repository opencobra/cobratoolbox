% The COBRAToolbox: testMkTableOfAddedExchanges.m
%
% Purpose:
%     - mkTableOfAddedExchanges builds a cell table with one row per exchange reaction of
%       Ex_added_all_unique (the output of statisticsAddedExchanges, column 1) and one column
%       per sample: the cell of a sample holds the exchange (as a 1x1 cell) when the sample's
%       ResultsAllCellLines.<sample>.Ex_RxnsAdded lists it, and stays empty otherwise.
%     - Once the defect below is fixed, the test should check hand-built ResultsAllCellLines
%       structures and exchange lists (two samples, exchanges shared and not shared), with the
%       table derived by hand, for lists shorter and longer than their number of columns.
%       Quarantined: no behaviour of mkTableOfAddedExchanges is asserted until the error
%       defect below is fixed; this file only opens the test.
%
% Function under test:
%     src/dataIntegration/metabotools/mkTableOfAddedExchanges.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver, hand-built result structures.
%
% Coverage exemptions:
%     every line - mkTableOfAddedExchanges is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: An exchange list with fewer rows than columns stops the function
%       SEVERITY: error
%       TRIGGER: R.s1.Ex_RxnsAdded = {'EX_a'; 'EX_b'}; R.s1.MinMaxAddedRxns = [0 1; -1 0];
%         R.s2.Ex_RxnsAdded = {'EX_b'}; R.s2.MinMaxAddedRxns = [-1 0];
%         mkTableOfAddedExchanges(R, {'s1', 's2'}, statisticsAddedExchanges(R, {'s1', 's2'}))
%         (a 2 x 4 list)
%       OBSERVED: (R2025a, 2026-11-15) "Unable to perform assignment because the size of the
%         left side is 4-by-1 and the size of the right side is 2-by-1." (line 20): line 19
%         sizes the table with length(Ex_added_all_unique), the larger of its rows and
%         columns (up to 6 columns from statisticsAddedExchanges)
%       EXPECTED: a 2 x 3 table, one row per exchange
%       LINES: 19-20
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testMkTableOfAddedExchanges'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
