% The COBRAToolbox: testCheckPresentFields.m
%
% Purpose:
%     - checkPresentFields checks the fields of a model that are present against a table of field
%     properties (expected dimensions, linked fields and a validity expression) and records
%     inconsistencies in a results structure.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/reconstruction/modelGeneration/modelVerification/checkPresentFields.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     Line 33, the debugging display (if 0) that never runs. Lines 53-55, the numeric branch for the
%     first dimension, which always stops with an error (see the known defect).
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: A numeric size requirement stops the function with an error
%       SEVERITY: error
%       TRIGGER: a field property row whose second or third column is a number instead of a field
%         name
%       OBSERVED: the error message for the first dimension uses the variable x_pres before it is
%         assigned, so the call stops with "Unrecognized function or variable x_pres"
%       EXPECTED: the expected size compared with the actual size
%       LINES: 53-56
%
% Authors:
%     - Generated for feature tier1-test-batch4, 2026-10-13.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testCheckPresentFields'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

model.rxns = {'r1'; 'r2'};
model.lb = [0; 0];
model.c = [1; 2; 3];
% field properties: name, first dimension (a field name or NaN), second dimension, validity expression
properties = {'lb', 'rxns', NaN, 'isnumeric(x)'; ...
              'c', 'rxns', NaN, 'isnumeric(x)'; ...
              'rxns', 'rxns', NaN, 'iscell(x)'};

results.Errors = struct();

%% consistent fields give no errors

out = checkPresentFields(properties(1, :), model, results);
assert(isempty(fieldnames(out.Errors)));

%% a field whose size does not match the linked field

out = checkPresentFields(properties(2, :), model, results);
assert(isfield(out.Errors, 'inconsistentFields') && isfield(out.Errors.inconsistentFields, 'c'));
assert(contains(out.Errors.inconsistentFields.c, 'Size of c does not match elements in rxns'));

%% a missing linked field

missing = properties(1, :);
missing{2} = 'genes';
out = checkPresentFields(missing, model, results);
assert(isfield(out.Errors, 'missingFields') && isequal(out.Errors.missingFields, {'genes'}));
assert(isfield(out.Errors, 'inconsistentFields'));

%% a field that breaks its validity expression

invalid = properties(1, :);
invalid{4} = 'ischar(x)';
out = checkPresentFields(invalid, model, results);
assert(isfield(out.Errors, 'propertiesNotMatched') && isfield(out.Errors.propertiesNotMatched, 'lb'));

%% the second dimension can be linked to a field or given as a number

model.mets = {'a'; 'b'};
model.S = [1 0 0; 0 1 0];
matrixProperty = {'S', 'mets', 'rxns', 'isnumeric(x)'};
% S has 2 rows (matching mets) and 3 columns, but rxns has 2 entries
out = checkPresentFields(matrixProperty, model, results);
assert(isfield(out.Errors, 'inconsistentFields') && isfield(out.Errors.inconsistentFields, 'S'));
assert(contains(out.Errors.inconsistentFields.S, 'rxns: Size of S does not match elements in rxns'));
% a missing linked second field
matrixProperty{3} = 'reactions';
out = checkPresentFields(matrixProperty, model, results);
assert(isequal(out.Errors.missingFields, {'reactions'}));
% a number for the second dimension: lb has one column
out = checkPresentFields({'lb', NaN, 1, 'isnumeric(x)'}, model, results);
assert(isempty(fieldnames(out.Errors)));
out = checkPresentFields({'lb', NaN, 2, 'isnumeric(x)'}, model, results);
assert(contains(out.Errors.inconsistentFields.lb, 'Y Size of lb was 1. Expected 2'));

%% the positions that break a validity expression are listed

model.lb = [1; -1; 2; -3];
out = checkPresentFields({'lb', NaN, NaN, 'all(x > 0)'}, model, results);
assert(isfield(out.Errors, 'propertiesNotMatched'));
assert(contains(out.Errors.propertiesNotMatched.lb, '2') && contains(out.Errors.propertiesNotMatched.lb, '4'));

%% an expression that cannot be evaluated counts as not matched

out = checkPresentFields({'lb', NaN, NaN, 'thisFunctionDoesNotExist(x)'}, model, results);
assert(isfield(out.Errors, 'propertiesNotMatched') && isfield(out.Errors.propertiesNotMatched, 'lb'));

%% fields that are not in the model are skipped

absent = properties(1, :);
absent{1} = 'ub';
out = checkPresentFields(absent, model, results);
assert(isempty(fieldnames(out.Errors)));

% change the directory
cd(currentDir)
