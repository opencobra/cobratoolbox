% The COBRAToolbox: testFindUpDownRegulatedGenes.m
%
% Purpose:
%     - findUpDownRegulatedGenes compares two sheets (columns Geneid and Data) of a
%       transcriptomics workbook and returns, for every gene of the source sheet, the gene ID,
%       the source value, the target value and 'Up' (target larger), 'Down' (target smaller) or
%       'Equal'. Errors inside the function are caught and displayed, so a missing sheet leaves
%       the output unassigned and the call fails. This test writes a small workbook to a
%       temporary folder and checks every comparison outcome, the accepted forms of the sheet
%       names (1x1 cell, char, string) and the failure for a missing sheet. Expected values are
%       the hand-written sheet values.
%     - The function is QUARANTINED (Constitution III-Defects, quarantine in back-fill
%       campaigns): the severity audit T009a raised the first defect below (a documented input
%       that silently returns another gene's value), so this file makes no assertion about the
%       function. The checks described above are those of the wave 03 version of this test
%       (git history), to be restored once the defect is fixed.
%
% Function under test:
%     src/analysis/igemRNA/findUpDownRegulatedGenes/findUpDownRegulatedGenes.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; a hand-built workbook written to a temporary folder that is
%     removed at the end.
%
% Coverage exemptions:
%     every line - findUpDownRegulatedGenes is quarantined for the defects below (feature
%     20261113-142115-test-backfill-tiers, severity audit T009a). Before the quarantine the
%     test reached every executable line.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Genes are matched by row position, not by gene ID
%       SEVERITY: wrong-result
%       TRIGGER: source sheet A (g1 = 1, g2 = 5, g3 = 3) and target sheet with the same genes in
%         the order g3 = 3, g2 = 4, g1 = 2, or a target sheet with only g1 = 2
%       OBSERVED: reordered target: {'g1', 1, 3, 'Up'; 'g2', 5, 4, 'Down'; 'g3', 3, 2, 'Down'}
%         (the target values of g3 and g1 are swapped); shorter target: MATLAB:badsubscript is
%         caught and displayed and {'g1', 1, 2, 'Up'; 'g2', 5, [], []} is returned
%       EXPECTED: g1 compared with 2 and g3 with 3; a missing gene reported or rejected. The
%         function assumes both sheets list the same genes in the same order; OUTPUTS documents
%         each row as "geneId, source dataset expression value, target dataset expression
%         value" and the header puts no ordering requirement on the sheets, so a target sheet
%         in another order is a documented input that silently returns another gene's value
%         (severity audit T009a)
%       LINES: 30-32
%     - DEFECT: Errors when the source sheet holds no gene
%       SEVERITY: limitation
%       TRIGGER: findUpDownRegulatedGenes({'E'}, {'E'}, workbook) with a sheet E that has only
%         the header Geneid, Data
%       OBSERVED: MATLAB:unassignedOutputs, Output argument "result" (and possibly others) not
%         assigned a value in the execution with "findUpDownRegulatedGenes" function.
%       EXPECTED: an empty result
%       LINES: 1, 29
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.
%     - Converted to the quarantine layout after the severity audit 2026-11-15 (T009a).

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testFindUpDownRegulatedGenes'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
