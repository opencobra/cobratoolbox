% The COBRAToolbox: testFindGenesBelowThresholdLocal1.m
%
% Purpose:
%     - findGenesBelowThresholdLocal1 reads the transcriptomics workbook trDataPath and returns
%       the genes of sheet sheetIndex whose expression is below the global threshold, as rows
%       {geneId, value, 'Low', 'Global'}, or, failing that, below the gene's local threshold
%       (the mean of the gene over all sheets of the same phenotype), as rows
%       {geneId, value, 'Low', 'Local'}. The function is QUARANTINED (Constitution
%       III-Defects, quarantine in back-fill campaigns): the local threshold is not the mean of
%       the gene (defect below), so no assertion about the function is made.
%
% Function under test:
%     src/analysis/igemRNA/LT1/findGenesBelowThresholdLocal1.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; a test would use a small hand-built workbook.
%
% Coverage exemptions:
%     every line - findGenesBelowThresholdLocal1 is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The local threshold is the sum divided by the row length minus one, not the mean
%       SEVERITY: wrong-result
%       TRIGGER: a workbook with sheets S1_P (g1 = 10, g2 = 2) and S2_P (g1 = 20, g2 = 2);
%         findGenesBelowThresholdLocal1(5, workbook, 1)
%       OBSERVED: {'g2', 2, 'Low', 'Global'} only: avg = expressionSum/length(row)-1 is
%         evaluated as (10 + 20) / 3 - 1 = 9 (the row also holds the gene ID), so g1 (10) is
%         not below its local threshold
%       EXPECTED: also {'g1', 10, 'Low', 'Local'}: the local threshold of g1 is its mean over
%         the two sheets, 15, and 10 < 15
%       LINES: 66-67
%     - DEFECT: Errors when no gene qualifies
%       SEVERITY: error
%       TRIGGER: findGenesBelowThresholdLocal1(-100, workbook, 1) with the workbook above
%       OBSERVED: MATLAB:unassignedOutputs, Output argument "genes" (and possibly others) not
%         assigned a value in the execution with "findGenesBelowThresholdLocal1" function.
%       EXPECTED: an empty list of genes
%       LINES: 1, 51-75
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-13.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testFindGenesBelowThresholdLocal1'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
