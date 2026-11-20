% The COBRAToolbox: testDuplicates.m
%
% Purpose:
%     - duplicates(A) maps the first instance of each row of A to its later duplicates (M), flags
%       the rows that repeat an earlier row (duplicateBool) and returns unique(A, 'rows',
%       'stable') outputs C, IA, IC. This test checks the documented example (char column),
%       a numeric matrix compared row by row, a column cell array of text and an input without
%       duplicates. Expected values are the documented example and hand-listed duplicates.
%     - The function is QUARANTINED (Constitution III-Defects, quarantine in back-fill
%       campaigns; severity audit T009a): a cell array with more than one column gives M and
%       duplicateBool of the wrong size (defect below), so no assertion about the function is
%       made; the checks described above are the plan for the test once the defect is
%       resolved.
%
% Function under test:
%     src/base/utilities/duplicates.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     every line - duplicates is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers, severity audit T009a)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: A cell array with more than one column is compared element by element, so M is not m x m
%       SEVERITY: wrong-result
%       TRIGGER: [M, duplicateBool] = duplicates({'a', 'a', 'b'})
%       OBSERVED: M = [0 1] (1 x 2) and duplicateBool = [0; 1] (2 x 1) for an input with one row
%       EXPECTED: M of size m x m and duplicateBool of size m x 1 (m = 1 here), as documented.
%         Severity audit 2026-11-15: INPUT documents "A: m x n array (compatible with
%         `unique`)" and OUTPUTS "M: m x m", "duplicateBool: m x 1"; for a 1 x 3 cell (a
%         documented m x n input) M is 1 x 2 and duplicateBool 2 x 1 because line 50 calls
%         unique element-wise
%       LINES: 50
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15; severity audit
%       2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testDuplicates'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
