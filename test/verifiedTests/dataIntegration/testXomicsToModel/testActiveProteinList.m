% The COBRAToolbox: testActiveProteinList.m
%
% Purpose:
%     - activeProteinList splits a list of proteins into active (expression at or above a
%       threshold) and inactive sets. The function is QUARANTINED (Constitution III-Defects,
%       quarantine in back-fill campaigns): the inactive set holds the proteins above the
%       threshold instead of those below it, so no assertion about the function is made.
%
% Function under test:
%     src/dataIntegration/XomicsToModel/proteomics/activeProteinList.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; hand-built expression vectors would suffice.
%
% Coverage exemptions:
%     every line - activeProteinList is quarantined for the defects below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The inactive proteins are those above the threshold
%       SEVERITY: wrong-result
%       TRIGGER: [active, inactive] = activeProteinList([1; 2; 3], {'a'; 'b'; 'c'}, 2, 0)
%       OBSERVED: active = {'b'; 'c'}, inactive = {'c'} (R2025a, 2026-11-15); line 39 uses
%         proteomicsEx > treshold
%       EXPECTED: inactive = {'a'}, the proteins whose expression is below the threshold, the
%         complement of the active set
%       LINES: 39
%     - DEFECT: The histogram marks the threshold at 2 whatever threshold is given
%       SEVERITY: cosmetic
%       TRIGGER: activeProteinList(proteomicsEx, proteomicsGenes, 5, 3)
%       OBSERVED: the red line and the label Threshold are drawn at x = 2 (lines 29-30 use the
%         constant 2)
%       EXPECTED: the line at x = treshold
%       LINES: 29-30
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testActiveProteinList'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
