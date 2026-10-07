% The COBRAToolbox: testGetDefaultValue.m
%
% Purpose:
%     - Characterization test that PINS the current behaviour of getDefaultValue,
%       which returns a "default / empty" value of the same type (and, where it
%       applies, the same size) as its input. The function previously had no
%       test (feature 025-tier1-test-pilot). It asserts EXISTING behaviour
%       (Constitution Principle III, characterization mode) and must not change
%       getDefaultValue.
%
% Function under test:
%     src/base/utilities/getDefaultValue.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs, never skipped.
%
% Coverage exemptions:
%     None. Every executable line of getDefaultValue is reached below.
%
% Known defect pinned (NOT fixed here):
%     getDefaultValue has no final 'else' branch, so for an input that is none of
%     numeric / string / char / logical / cell (for example a struct or a function
%     handle) the output "defValue" is never assigned and MATLAB raises an
%     "unassigned output" error. The test asserts that this error still occurs so
%     that any future fix is a conscious, spec-driven change.
%
% Authors:
%     - Generated for feature 025-tier1-test-pilot, 2026-10-06.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testGetDefaultValue'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is still the standard
% opening of a COBRA test, and it is where a requirement would be added later (a
% test whose requirements are not met is skipped by the harness, not failed)
prepareTest();

%% Numeric inputs: NaN cast to the input class, same size as the input

% double matrix -> matrix of NaN with the same size (NaN is not equal to itself,
% hence isequaln)
defaultDouble = getDefaultValue([1 2; 3 4]);
assert(isequaln(defaultDouble, NaN(2, 2)));
assert(strcmp(class(defaultDouble), 'double'));

% single keeps its class
defaultSingle = getDefaultValue(single([1 2 3]));
assert(strcmp(class(defaultSingle), 'single'));
assert(isequaln(defaultSingle, single(NaN(1, 3))));

% integer classes cannot hold NaN: cast(NaN, 'int8') is 0, so the "default" of an
% integer array is zeros of that class. The class and the size are preserved.
defaultInteger = getDefaultValue(int8([1 2; 3 4]));
assert(strcmp(class(defaultInteger), 'int8'));
assert(isequal(defaultInteger, zeros(2, 2, 'int8')));

% an empty numeric array keeps its (empty) size
defaultEmptyNumeric = getDefaultValue(zeros(0, 3));
assert(isequal(size(defaultEmptyNumeric), [0 3]));

%% String and char inputs: empty string / empty char

% a string scalar gives the empty string
assert(isequal(getDefaultValue("abc"), ""));

% a string ARRAY collapses to a single empty string (the size is not preserved)
defaultStringArray = getDefaultValue(["a", "b"]);
assert(isequal(defaultStringArray, ""));
assert(isequal(size(defaultStringArray), [1 1]));

% a char vector gives the 0x0 empty char (also not size preserving)
defaultChar = getDefaultValue('abc');
assert(ischar(defaultChar) && isequal(size(defaultChar), [0 0]));

%% Logical inputs: false with the same size

assert(isequal(getDefaultValue([true false; true true]), false(2, 2)));

%% Cell inputs: the default of every element, recursively, keeping the shape

% mixed nested cell: numeric -> NaN, char -> '', logical -> false, cell -> recursion
defaultCell = getDefaultValue({1, 'a'; true, {2}});
assert(iscell(defaultCell) && isequal(size(defaultCell), [2 2]));
assert(isequaln(defaultCell, {NaN, ''; false, {NaN}}));

% an empty cell has no elements, so the result is an empty cell of the same size
assert(isequal(getDefaultValue({}), {}));

%% Unsupported types: the output is never assigned, MATLAB raises an error

% outputArgCount = 1 is required: MATLAB only raises the unassigned-output error
% when the caller actually requests an output
assert(verifyCobraFunctionError('getDefaultValue', 'inputs', {struct('a', 1)}, 'outputArgCount', 1));
assert(verifyCobraFunctionError('getDefaultValue', 'inputs', {@sin}, 'outputArgCount', 1));

% change the directory
cd(currentDir)
