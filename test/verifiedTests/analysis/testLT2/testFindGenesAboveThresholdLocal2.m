% The COBRAToolbox: testFindGenesAboveThresholdLocal2.m
%
% Purpose:
%     - findGenesAboveThresholdLocal2 reads the transcriptomics workbook trDataPath and returns
%       the genes of sheet sheetIndex whose expression is at or above the upper global
%       threshold, or between the lower and upper thresholds and at or above the local threshold
%       of the gene, as rows {geneId, value, 'High', 'Global'/'Local'}. The local
%       threshold of a gene is meant to be its mean over all sheets of the same phenotype. The
%       function is QUARANTINED (Constitution III-Defects, quarantine in back-fill campaigns):
%       the local threshold is not the mean of the gene (defect below), so no assertion about
%       the function is made.
%
% Function under test:
%     src/analysis/igemRNA/LT2/findGenesAboveThresholdLocal2.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; a test would use a small hand-built workbook.
%
% Coverage exemptions:
%     every line - findGenesAboveThresholdLocal2 is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The local threshold is the sum divided by the row length minus one, not the mean
%       SEVERITY: wrong-result
%       TRIGGER: a workbook with sheets S1_P (g1 = 10, g2 = 2) and S2_P (g1 = 20, g2 = 2);
%         findGenesAboveThresholdLocal2(5, 100, workbook, 1)
%       OBSERVED: {"g1", 10, 'High', 'Local'}: avg = expressionSum/length(row)-1 is evaluated
%         as (10 + 20) / 3 - 1 = 9 (the row also holds the gene ID), so 10 passes the local test
%       EXPECTED: no gene: the local threshold of g1 is its mean over the two sheets, 15, and
%         10 < 15; g2 = 2 is below the lower threshold
%       LINES: 67-68
%     - DEFECT: Errors when no gene qualifies
%       SEVERITY: error
%       TRIGGER: findGenesAboveThresholdLocal2(100, 200, workbook, 1) with the workbook above
%       OBSERVED: MATLAB:unassignedOutputs, Output argument "genes" (and possibly others) not
%         assigned a value in the execution with "findGenesAboveThresholdLocal2" function.
%       EXPECTED: an empty list of genes
%       LINES: 1, 52-76
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testFindGenesAboveThresholdLocal2'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
