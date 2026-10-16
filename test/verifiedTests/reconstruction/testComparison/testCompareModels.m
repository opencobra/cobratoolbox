% The COBRAToolbox: testCompareModels.m
%
% Purpose:
%     - compareModels compares two model structures field by field and returns whether they are the
%     same, a table listing the differences (field, values, sizes and reason) and the raw difference
%     structure.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/reconstruction/comparison/compareModels.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     Line 67, the removal of a leading parent name from dotted field paths: the comparison reports
%     differences in nested structures under the name of the top-level field, so no dotted path
%     occurred. Lines 89 and 95-101, the local functions valueSize2str and sizeVec2str: nothing in
%     the file calls them.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Two arguments with the same variable name make the function stop
%       SEVERITY: limitation
%       TRIGGER: compareModels called with arguments that have the same variable name, for example
%         compareModels(A, A)
%       OBSERVED: the names of the input variables are used as table column names and two columns
%         named alike make the table construction fail with "Duplicate table variable name"
%       EXPECTED: a table with distinct column names
%       LINES: 16-19
%
% Authors:
%     - Generated for feature tier1-test-batch4, 2026-10-13.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testCompareModels'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

modelA.a = 1;
modelA.b = [1 2 3];
modelA.c = 'x';

%% identical models

modelB = modelA;
[isSameModel, diffTable, why] = compareModels(modelA, modelB);
assert(isSameModel);
assert(height(diffTable) == 0);
assert(isequal(diffTable.Properties.VariableNames, {'field', 'modelA', 'modelB', 'modelA_size', 'modelB_size', 'reason'}));
assert(isempty(why));

%% a different value and an extra field

modelB.b = [1 2 4];
modelB.d = 5;
[isSameModel, diffTable, why] = compareModels(modelA, modelB);
assert(~isSameModel);
assert(height(diffTable) >= 2);
assert(isequal(diffTable.Properties.VariableNames, {'field', 'modelA', 'modelB', 'modelA_size', 'modelB_size', 'reason'}));
% the differing field and the extra field are listed
assert(any(strcmp(diffTable.field, 'b')) && any(strcmp(diffTable.field, 'd')));
assert(~isempty(why));

%% differences inside nested structures are listed with the nested field name

nestedA.s.t.x = 1;
nestedB.s.t.x = 2;
[~, diffTable, ~] = compareModels(nestedA, nestedB);
assert(height(diffTable) >= 1);
assert(~any(startsWith(diffTable.field, 's.')));

%% arguments that are not variables get default names

[~, diffTable, ~] = compareModels(struct('x', 1), struct('x', 2));
assert(isequal(diffTable.Properties.VariableNames, {'field', 'modelA', 'modelB', 'modelA_size', 'modelB_size', 'reason'}));

%% the column names follow the variable names of the call

first.x = 1;
second.x = 2;
[~, diffTable, ~] = compareModels(first, second);
assert(isequal(diffTable.Properties.VariableNames, {'field', 'first', 'second', 'first_size', 'second_size', 'reason'}));

% change the directory
cd(currentDir)
