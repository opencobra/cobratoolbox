% The COBRAToolbox: testIsvar.m
%
% Purpose:
%     - isvar checks whether a name is a field of a structure or a variable of a table.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch3, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/base/utilities/isvar.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Index is 1 for a structure even when the field is missing
%       SEVERITY: limitation
%       TRIGGER: a structure and a name that is not one of its fields
%       OBSERVED: the third output (ind) is always 1 for structures
%       EXPECTED: an empty index when the field does not exist
%       LINES: 24-27
%
% Authors:
%     - Generated for feature tier1-test-batch3, 2026-10-12.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testIsvar'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

exampleStruct = struct('a', 1);
exampleTable = table([1; 2], [3; 4], 'VariableNames', {'x', 'y'});

%% structures: the field is present or not (the index output is not checked, see the header)

[tf, bool] = isvar(exampleStruct, 'a');
assert(tf == true && bool == true);
[tf, bool] = isvar(exampleStruct, 'z');
assert(tf == false && bool == false);

%% tables: logical position vector and index of the variable

[tf, bool, ind] = isvar(exampleTable, 'y');
assert(tf == true);
assert(isequal(bool, [false true]));
assert(ind == 2);

% a variable that is not in the table
[tf, bool, ind] = isvar(exampleTable, 'q');
assert(tf == false);
assert(isequal(bool, [false false]));
assert(isempty(ind));

% several names: true if any is present
[tf, bool, ind] = isvar(exampleTable, {'x', 'q'});
assert(tf == true);
assert(isequal(bool, [true false]));
assert(ind == 1);

% change the directory
cd(currentDir)
