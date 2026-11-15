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
%
% Function under test:
%     src/analysis/igemRNA/findUpDownRegulatedGenes/findUpDownRegulatedGenes.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; a hand-built workbook written to a temporary folder that is
%     removed at the end.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Genes are matched by row position, not by gene ID
%       SEVERITY: limitation
%       TRIGGER: source sheet A (g1 = 1, g2 = 5, g3 = 3) and target sheet with the same genes in
%         the order g3 = 3, g2 = 4, g1 = 2, or a target sheet with only g1 = 2
%       OBSERVED: reordered target: {'g1', 1, 3, 'Up'; 'g2', 5, 4, 'Down'; 'g3', 3, 2, 'Down'}
%         (the target values of g3 and g1 are swapped); shorter target: MATLAB:badsubscript is
%         caught and displayed and {'g1', 1, 2, 'Up'; 'g2', 5, [], []} is returned
%       EXPECTED: g1 compared with 2 and g3 with 3; a missing gene reported or rejected. The
%         function assumes both sheets list the same genes in the same order
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

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testFindUpDownRegulatedGenes'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% workbook with two datasets of the same three genes in the same order
tmpDir = tempname;
mkdir(tmpDir);
workbook = fullfile(tmpDir, 'transcriptomics.xlsx');
geneIds = {'g1'; 'g2'; 'g3'};
writetable(table(geneIds, [1.5; 5; 3], 'VariableNames', {'Geneid', 'Data'}), workbook, 'Sheet', 'Control');
writetable(table(geneIds, [2; 4.25; 3], 'VariableNames', {'Geneid', 'Data'}), workbook, 'Sheet', 'Treated');

%% source vs target: one 'Up', one 'Down' and one 'Equal'

result = findUpDownRegulatedGenes({'Control'}, {'Treated'}, workbook);
% the values are read back from the workbook unchanged (binary fractions), so equality is exact
assert(isequal(result, {'g1', 1.5, 2, 'Up'; 'g2', 5, 4.25, 'Down'; 'g3', 3, 3, 'Equal'}));

%% the reverse comparison swaps 'Up' and 'Down'; char and string sheet names are accepted

result = findUpDownRegulatedGenes('Treated', "Control", workbook);
assert(isequal(result, {'g1', 2, 1.5, 'Down'; 'g2', 4.25, 5, 'Up'; 'g3', 3, 3, 'Equal'}));

%% a missing sheet: the read error is caught and displayed, and the output stays unassigned

assert(verifyCobraFunctionError('findUpDownRegulatedGenes', 'inputs', {{'Missing'}, {'Treated'}, workbook}, ...
    'outputArgCount', 1));

% remove the workbook
rmdir(tmpDir, 's');

% change the directory
cd(currentDir)
