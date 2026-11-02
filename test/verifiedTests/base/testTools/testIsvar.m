% The COBRAToolbox: testIsvar.m
%
% Purpose:
%     - isvar checks whether a name is a field of a structure or a variable of a table.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch3, Constitution Principle III characterization mode);
%       it must not change the function under test.
%       Defect(s) fixed by feature 20261102-140321-tier1-safe-defect-fixes: Index is 1 for a
%       structure even when the field is missing.
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
%     None found.
%
% Authors:
%     - Generated for feature tier1-test-batch3, 2026-10-12.
%     - Updated for feature 20261102-140321-tier1-safe-defect-fixes, 2026-11-02.

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

%% structures: the field is present or not (the index output is checked in the next section)

[tf, bool] = isvar(exampleStruct, 'a');
assert(tf == true && bool == true);
[tf, bool] = isvar(exampleStruct, 'z');
assert(tf == false && bool == false);

%% structures: the index is 1 for a present field and empty for a missing one

[tf, ~, ind] = isvar(exampleStruct, 'a');
assert(tf == true && isequal(ind, 1));
[tf, ~, ind] = isvar(exampleStruct, 'z');
assert(tf == false && isempty(ind));

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
