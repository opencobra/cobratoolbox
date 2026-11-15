% The COBRAToolbox: testGetCorrespondingCols.m
%
% Purpose:
%     - getCorrespondingCols returns, among the columns selected by colBool, those that have a
%       nonzero in a row selected by rowBool ('inclusive'), those that in addition have no
%       nonzero outside these rows ('exclusive'), or the difference of the two ('partial').
%       This test uses the matrix of the documented example, a restricted column set, a
%       column with no nonzero, and checks the errors for invalid input. Expected vectors are
%       read off the documented example and the definition (hand derivation).
%
% Function under test:
%     src/analysis/topology/getCorrespondingCols.m
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
%       TRIGGER: getCorrespondingCols(eye(2), true(2, 1), true(3, 1), 'inclusive')
%       OBSERVED: the error message is 'length of rowBool must equal size(A,2)'
%       EXPECTED: a message naming colBool, 'length of colBool must equal size(A,2)'
%       LINES: 68
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-13.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testGetCorrespondingCols'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% the matrix of the documented example; rows 1 to 3 are selected
A = [-1  0  0  0  0;
      2 -3  0  0  0;
      0  4 -5  0  0;
      0  0  6 -7  0;
      0  0  0  0  0];
rowBool = logical([1; 1; 1; 0; 0]);
colBool = true(5, 1);

%% documented example: exclusive, inclusive and partial on all columns

% exclusive: columns 1 and 2 only touch rows 1 to 3; column 3 also touches row 4
exclusive = getCorrespondingCols(A, rowBool, colBool, 'exclusive');
assert(isequal(exclusive, logical([1; 1; 0; 0; 0])));
% inclusive: columns 1 to 3 touch at least one of rows 1 to 3; columns 4 and 5 do not
inclusive = getCorrespondingCols(A, rowBool, colBool, 'inclusive');
assert(isequal(inclusive, logical([1; 1; 1; 0; 0])));
% partial: inclusive but not exclusive
partial = getCorrespondingCols(A, rowBool, colBool, 'partial');
assert(isequal(partial, logical([0; 0; 1; 0; 0])));
assert(isequal(partial, inclusive & ~exclusive));
% the output is an n x 1 logical vector in every mode
assert(islogical(partial) && isequal(size(partial), [5, 1]));

%% columns outside colBool are never returned

colSubset = logical([0; 1; 1; 1; 0]);
assert(isequal(getCorrespondingCols(A, rowBool, colSubset, 'exclusive'), logical([0; 1; 0; 0; 0])));
assert(isequal(getCorrespondingCols(A, rowBool, colSubset, 'inclusive'), logical([0; 1; 1; 0; 0])));
assert(isequal(getCorrespondingCols(A, rowBool, colSubset, 'partial'), logical([0; 0; 1; 0; 0])));

% an empty column selection returns no column
assert(isequal(getCorrespondingCols(A, rowBool, false(5, 1), 'inclusive'), false(5, 1)));

%% sparse matrix and a row selection that covers every row

% with every row selected, exclusive and inclusive both return the nonzero columns
allRows = true(5, 1);
assert(isequal(getCorrespondingCols(sparse(A), allRows, colBool, 'exclusive'), logical([1; 1; 1; 1; 0])));
assert(isequal(getCorrespondingCols(sparse(A), allRows, colBool, 'partial'), false(5, 1)));

%% errors for invalid input

assert(verifyCobraFunctionError('getCorrespondingCols', 'inputs', {A, double(rowBool), colBool, 'inclusive'}, ...
    'testMessage', 'rowBool must be a logical vector'));
assert(verifyCobraFunctionError('getCorrespondingCols', 'inputs', {A, rowBool, double(colBool), 'inclusive'}, ...
    'testMessage', 'colBool must be a logical vector'));
assert(verifyCobraFunctionError('getCorrespondingCols', 'inputs', {A, true(4, 1), colBool, 'inclusive'}, ...
    'testMessage', 'length of rowBool must equal size(A,1)'));
% a colBool of the wrong length raises an error; its message names rowBool (cosmetic defect
% above), so only the error itself is checked
assert(verifyCobraFunctionError('getCorrespondingCols', 'inputs', {A, rowBool, true(4, 1), 'inclusive'}));
assert(verifyCobraFunctionError('getCorrespondingCols', 'inputs', {A, rowBool, colBool, 'other'}, ...
    'testMessage', 'Did not recognise mode: other'));

% change the directory
cd(currentDir)
