% The COBRAToolbox: testGetDefaultTableRow.m
%
% Purpose:
%     - getDefaultTableRow returns, for a table row held in a cell array, a row of the default
%     values of the class of each entry.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/base/utilities/getDefaultTableRow.m
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
fileDir = fileparts(which('testGetDefaultTableRow'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

%% default values of text, numeric and logical entries

row = {'name', 5, true};
defaultRow = getDefaultTableRow(row);
assert(isequal(size(defaultRow), [1 3]));
assert(isequaln(defaultRow{1, 1}, getDefaultValue('name')));
assert(isequaln(defaultRow{1, 2}, getDefaultValue(5)));
assert(isequaln(defaultRow{1, 3}, getDefaultValue(true)));

%% only the first row is used

rows = {'a', 1; 'b', 2};
defaultRow = getDefaultTableRow(rows);
assert(isequal(size(defaultRow), [1 2]));
assert(isequaln(defaultRow, getDefaultTableRow(rows(1, :))));

% change the directory
cd(currentDir)
