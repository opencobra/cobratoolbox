% The COBRAToolbox: testGetCorrespondingRows.m
%
% Purpose:
%     - getCorrespondingRows returns, among the rows selected by rowBool, those that have a
%       nonzero in a column selected by colBool ('inclusive'), those that in addition have no
%       nonzero outside these columns ('exclusive'), or the difference of the two
%       ('partial'). This test uses the matrix of the documented example, a restricted row
%       set, a sparse matrix and an empty column selection, and checks the errors for invalid
%       input. Expected vectors are read off the documented example and the definition (hand
%       derivation).
%
% Function under test:
%     src/analysis/topology/getCorrespondingRows.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver, hand-built matrices.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The error for a colBool of the wrong length names rowBool
%       SEVERITY: cosmetic
%       TRIGGER: getCorrespondingRows(eye(2), true(2, 1), true(3, 1), 'inclusive')
%       OBSERVED: the error message is 'length of rowBool must equal size(A,2)'
%       EXPECTED: a message naming colBool, 'length of colBool must equal size(A,2)'
%       LINES: 72
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testGetCorrespondingRows'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% the matrix of the documented example; columns 1 to 3 are selected
A = [-1  0  0  0  0;
      2 -3  0  0  0;
      0  4 -5  0  0;
      0  0  6 -7  0;
      0  0  0  0  0];
rowBool = true(5, 1);
colBool = logical([1; 1; 1; 0; 0]);

%% documented example: exclusive, inclusive and partial on all rows

% exclusive: rows 1 to 3 only have nonzeros in columns 1 to 3; row 4 also in column 4
exclusive = getCorrespondingRows(A, rowBool, colBool, 'exclusive');
assert(isequal(exclusive, logical([1; 1; 1; 0; 0])));
% inclusive: rows 1 to 4 have a nonzero in columns 1 to 3; row 5 is zero
inclusive = getCorrespondingRows(A, rowBool, colBool, 'inclusive');
assert(isequal(inclusive, logical([1; 1; 1; 1; 0])));
% partial: the extra rows of inclusive that are not in exclusive
partial = getCorrespondingRows(A, rowBool, colBool, 'partial');
assert(isequal(partial, logical([0; 0; 0; 1; 0])));
assert(isequal(partial, inclusive & ~exclusive));
% the output is an m x 1 logical vector in every mode
assert(islogical(partial) && isequal(size(partial), [5, 1]));

%% rows outside rowBool are never returned

rowSubset = logical([0; 1; 1; 1; 1]);
assert(isequal(getCorrespondingRows(A, rowSubset, colBool, 'exclusive'), logical([0; 1; 1; 0; 0])));
assert(isequal(getCorrespondingRows(A, rowSubset, colBool, 'inclusive'), logical([0; 1; 1; 1; 0])));
assert(isequal(getCorrespondingRows(A, rowSubset, colBool, 'partial'), logical([0; 0; 0; 1; 0])));

% an empty row selection returns no row
assert(isequal(getCorrespondingRows(A, false(5, 1), colBool, 'inclusive'), false(5, 1)));

%% sparse matrix, all columns and no column selected

% with every column selected, exclusive and inclusive both return the nonzero rows
allColumns = true(5, 1);
assert(isequal(getCorrespondingRows(sparse(A), rowBool, allColumns, 'exclusive'), logical([1; 1; 1; 1; 0])));
assert(isequal(getCorrespondingRows(sparse(A), rowBool, allColumns, 'partial'), false(5, 1)));
% with no column selected, no row corresponds in any mode
assert(isequal(getCorrespondingRows(A, rowBool, false(5, 1), 'inclusive'), false(5, 1)));
assert(isequal(getCorrespondingRows(A, rowBool, false(5, 1), 'exclusive'), false(5, 1)));

%% errors for invalid input

assert(verifyCobraFunctionError('getCorrespondingRows', 'inputs', {A, double(rowBool), colBool, 'inclusive'}, ...
    'testMessage', 'rowBool must be a logical vector'));
assert(verifyCobraFunctionError('getCorrespondingRows', 'inputs', {A, rowBool, double(colBool), 'inclusive'}, ...
    'testMessage', 'colBool must be a logical vector'));
assert(verifyCobraFunctionError('getCorrespondingRows', 'inputs', {A, true(4, 1), colBool, 'inclusive'}, ...
    'testMessage', 'length of rowBool must equal size(A,1)'));
% a colBool of the wrong length raises an error; its message names rowBool (cosmetic defect
% above), so only the error itself is checked
assert(verifyCobraFunctionError('getCorrespondingRows', 'inputs', {A, rowBool, true(4, 1), 'inclusive'}));
assert(verifyCobraFunctionError('getCorrespondingRows', 'inputs', {A, rowBool, colBool, 'other'}, ...
    'testMessage', 'Did not recognise mode: other'));

% change the directory
cd(currentDir)
