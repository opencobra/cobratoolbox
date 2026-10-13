% The COBRAToolbox: testCreateDeltaMatchMatrix.m
%
% Purpose:
%     - createDeltaMatchMatrix builds the constraint matrix that measures the absolute difference of
%     the flux of reactions that two sets (models) have in common: two rows per common reaction.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch3, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/base/createDeltaMatchMatrix.m
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
%     - Generated for feature tier1-test-batch3, 2026-10-12.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testCreateDeltaMatchMatrix'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

%% two sets with two common reactions

% common: 'a' (position 1 in set 1, 2 in set 2) and 'c' (3 and 1). Columns are the reactions of
% set 1 (3), of set 2 (3) and the 2 * 2 difference variables
matrix = full(createDeltaMatchMatrix({'a', 'b', 'c'}, {'c', 'a', 'z'}));
expected = [-1 0 0   0 1 0   1 0 0 0;
             0 0 -1  1 0 0   0 1 0 0;
             1 0 0   0 -1 0  0 0 1 0;
             0 0 1  -1 0 0   0 0 0 1];
assert(isequal(matrix, expected));

%% no common reaction: an empty matrix with one column per reaction

emptyMatrix = createDeltaMatchMatrix({'a'}, {'b'});
assert(isequal(size(emptyMatrix), [0 2]));

% change the directory
cd(currentDir)
