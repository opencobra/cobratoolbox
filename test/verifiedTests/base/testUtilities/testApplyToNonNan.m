% The COBRAToolbox: testApplyToNonNan.m
%
% Purpose:
%     - applyToNonNan applies a function to the non-NaN entries of each column of a matrix and
%     returns one value per column.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/base/utilities/applyToNonNan.m
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
fileDir = fileparts(which('testApplyToNonNan'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

data = [1 NaN 3; 3 4 NaN; NaN 6 9];

%% mean of the valid entries of each column

result = applyToNonNan(data, @mean);
assert(isequal(result, [2 5 6]));

%% other functions

assert(isequal(applyToNonNan(data, @max), [3 6 9]));
assert(isequal(applyToNonNan(data, @numel), [2 2 2]));

%% a column without NaN

assert(isequal(applyToNonNan([1 2; 3 4], @sum), [4 6]));

% change the directory
cd(currentDir)
