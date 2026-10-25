% The COBRAToolbox: testRemoveZeroRowsCols.m
%
% Purpose:
%     - removeZeroRowsCols removes the rows that are all zero and then the columns that are all zero
%     from a matrix.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/base/utilities/removeZeroRowsCols.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature tier1-test-batch4, 2026-10-13.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testRemoveZeroRowsCols'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

%% zero rows and columns are removed

A = [1 0 2; 0 0 0; 3 0 4];
assert(isequal(removeZeroRowsCols(A), [1 2; 3 4]));

%% a matrix without zero rows or columns is unchanged

B = [1 2; 3 4];
assert(isequal(removeZeroRowsCols(B), B));

%% columns that become zero only after removing rows are also removed

C = [0 0 5; 7 0 0];
% the zero column 2 is removed
assert(isequal(removeZeroRowsCols(C), [0 5; 7 0]));

%% a sparse matrix

S = sparse([1 0; 0 0]);
result = removeZeroRowsCols(S);
assert(issparse(result) && isequal(full(result), 1));

%% a zero matrix becomes empty

assert(isempty(removeZeroRowsCols(zeros(2, 2))));

% change the directory
cd(currentDir)
