% The COBRAToolbox: testCompareModels.m
%
% Purpose:
%     - compareModels compares two model structures field by field and returns whether they are the
%     same, a table listing the differences (field, values, sizes and reason) and the raw difference
%     structure.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
%       Defect(s) fixed by feature 20261102-140321-tier1-safe-defect-fixes: Two arguments with the
%       same variable name make the function stop.
%
% Function under test:
%     src/reconstruction/comparison/compareModels.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     Line 71, the removal of a leading parent name from dotted field paths: the comparison reports
%     differences in nested structures under the name of the top-level field, so no dotted path
%     occurred. Line 93, the local function valueSize2str: nothing in the file calls it. Lines
%     100-101, the empty-size branch of the local function sizeVec2str: it is called only with the
%     result of size, which is never empty.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature tier1-test-batch4, 2026-10-13.
%     - Updated for feature 20261102-140321-tier1-safe-defect-fixes, 2026-11-02.

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

%% the same variable passed twice gives distinct column names

% (formerly a known defect: the coinciding variable names stopped the table construction)
same.x = 1;
[isSameModel, diffTable, why] = compareModels(same, same);
assert(isSameModel && height(diffTable) == 0 && isempty(why));
assert(isequal(diffTable.Properties.VariableNames, {'field', 'same_A', 'same_B', 'same_A_size', 'same_B_size', 'reason'}));

%% values of other types are summarised as text

typedA = struct('s', "one", 'f', @sin, 'cs', {{'p', 'q'}}, 'sp', sparse(eye(4)));
typedB = struct('s', "two", 'f', @cos, 'cs', {{'p', 'r'}}, 'sp', sparse(2 * eye(4)));
[~, diffTable, ~] = compareModels(typedA, typedB);
% a string scalar, a function handle, a short list of names, and a large sparse matrix by size and class
assert(isequal(diffTable.typedA(strcmp(diffTable.field, 's')), {'one'}));
assert(isequal(diffTable.typedA(strcmp(diffTable.field, 'f')), {'sin'}));
assert(isequal(diffTable.typedA(strcmp(diffTable.field, 'cs')), {'{p, q}'}));
assert(isequal(diffTable.typedA(strcmp(diffTable.field, 'sp')), {'[4x4 sparse double]'}));

% change the directory
cd(currentDir)
