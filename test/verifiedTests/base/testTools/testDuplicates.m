% The COBRAToolbox: testDuplicates.m
%
% Purpose:
%     - duplicates(A) maps the first instance of each row of A to its later duplicates (M), flags
%       the rows that repeat an earlier row (duplicateBool) and returns unique(A, 'rows',
%       'stable') outputs C, IA, IC. This test checks the documented example (char column),
%       a numeric matrix compared row by row, a column cell array of text and an input without
%       duplicates. Expected values are the documented example and hand-listed duplicates.
%
% Function under test:
%     src/base/utilities/duplicates.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: A cell array with more than one column is compared element by element, so M is not m x m
%       SEVERITY: limitation
%       TRIGGER: [M, duplicateBool] = duplicates({'a', 'a', 'b'})
%       OBSERVED: M = [0 1] (1 x 2) and duplicateBool = [0; 1] (2 x 1) for an input with one row
%       EXPECTED: M of size m x m and duplicateBool of size m x 1 (m = 1 here), as documented
%       LINES: 50
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testDuplicates'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% all outputs are logical or integer-valued, so every comparison below is exact

%% documented example: a char column with repeated letters

A = ['a'; 'a'; 'b'; 'c'; 'd'; 'd'; 'b'; 'b'; 'e'];
[M, duplicateBool, C, IA, IC] = duplicates(A);
% M from the help text: row 1 -> 2, row 3 -> 7 and 8, row 5 -> 6
expectedM = zeros(9);
expectedM(1, 2) = 1;
expectedM(3, [7 8]) = 1;
expectedM(5, 6) = 1;
assert(isequal(size(M), [9 9]) && isequal(full(M), expectedM));
assert(islogical(duplicateBool));
assert(isequal(full(duplicateBool), logical([0; 1; 0; 0; 0; 1; 1; 1; 0])));
% unique first instances in order of appearance, and the maps between A and C
assert(isequal(C, ['a'; 'b'; 'c'; 'd'; 'e']));
assert(isequal(IA, [1; 3; 4; 5; 9]));
assert(isequal(IC, [1; 1; 2; 3; 4; 4; 2; 2; 5]));
assert(isequal(C(IC, :), A) && isequal(A(IA, :), C));

%% numeric matrix: rows are compared as wholes

A = [1 2; 3 4; 1 2; 1 3; 3 4; 1 2];
[M, duplicateBool, C, IA, IC] = duplicates(A);
% rows 3 and 6 repeat row 1, row 5 repeats row 2, row 4 ([1 3]) is unique
expectedM = zeros(6);
expectedM(1, [3 6]) = 1;
expectedM(2, 5) = 1;
assert(isequal(full(M), expectedM));
assert(isequal(full(duplicateBool), logical([0; 0; 1; 0; 1; 1])));
assert(isequal(C, [1 2; 3 4; 1 3]) && isequal(IA, [1; 2; 4]) && isequal(IC, [1; 2; 1; 3; 2; 1]));

%% column cell array of text (the form used by check4DuplicatesInList)

A = {'atp'; 'adp'; 'atp'; 'h2o'; 'adp'};
[M, duplicateBool, C, IA, IC] = duplicates(A);
expectedM = zeros(5);
expectedM(1, 3) = 1;
expectedM(2, 5) = 1;
assert(isequal(full(M), expectedM));
assert(isequal(full(duplicateBool), logical([0; 0; 1; 0; 1])));
assert(isequal(C, {'atp'; 'adp'; 'h2o'}) && isequal(IA, [1; 2; 4]) && isequal(IC, [1; 2; 1; 3; 2]));

%% no duplicates: M is all zero and no row is flagged

[M, duplicateBool] = duplicates([3; 1; 2]);
assert(isequal(size(M), [3 3]) && nnz(M) == 0);
assert(~any(duplicateBool) && isequal(size(duplicateBool), [3 1]));

% restore the directory
cd(currentDir)
