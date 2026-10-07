% The COBRAToolbox: testExtendIndicesInDimenion.m
%
% Purpose:
%     - Characterization test that PINS the current behaviour of
%       extendIndicesInDimenion, which appends sizeIncrease new entries, all set
%       to a given value, to an array / cell array / table along one dimension.
%       The function previously had no test (feature 025-tier1-test-pilot). It
%       asserts EXISTING behaviour (Constitution Principle III, characterization
%       mode) and must not change extendIndicesInDimenion.
%
% Function under test:
%     src/base/utilities/extendIndicesInDimenion.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, small hand-built arrays. Never
%     skipped.
%
% Coverage exemptions:
%     None for line coverage: the catch block is reached by the class-mismatch
%     case below.
%     Console-noise exemption: when that catch block runs, the function itself
%     prints 'input class is:' / 'value class is:' and the two class names
%     (including MATLAB's 'ans = ...' echo) to the console. This output is
%     existing behaviour and is NOT suppressed here, because Constitution VII-A
%     forbids suppressing output with evalc. Expect those lines when this test
%     runs.
%
% Authors:
%     - Generated for feature 025-tier1-test-pilot, 2026-10-06.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testExtendIndicesInDimenion'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is still the standard
% opening of a COBRA test, and it is where a requirement would be added later (a
% test whose requirements are not met is skipped by the harness, not failed)
prepareTest();

% small numeric array shared by the numeric sections below (defined before the first
% %% section so that it is visible in every section when run with runtests)
original = [1 2; 3 4];

%% numeric array extended along dimension 1 (rows)

extended = extendIndicesInDimenion(original, 1, 0, 2);
% two new rows of the value 0 below the original rows; the original block is intact
assert(isequal(extended, [1 2; 3 4; 0 0; 0 0]));

%% numeric array extended along dimension 2 (columns)

extended = extendIndicesInDimenion(original, 2, 9, 1);
% one new column of the value 9 to the right of the original columns
assert(isequal(extended, [1 2 9; 3 4 9]));

%% sizeIncrease = 0 leaves the array unchanged

assert(isequal(extendIndicesInDimenion([1 2], 2, 0, 0), [1 2]));

%% cell array extended with a cell value

extendedCell = extendIndicesInDimenion({'a'; 'b'}, 1, {'z'}, 1);
assert(isequal(extendedCell, {'a'; 'b'; 'z'}));

%% table extended with rows built from a table value

% a table input is extended by vertical concatenation of repeated value rows
originalTable = table([1; 2]);
extendedTable = extendIndicesInDimenion(originalTable, 1, table(0), 2);
assert(height(extendedTable) == 4);
% original rows first, then two copies of the value row
assert(isequal(extendedTable.Var1, [1; 2; 0; 0]));

%% a value whose class cannot be assigned into the input raises an error

% assigning a cell into a numeric array fails inside the try block; the catch block
% prints the two classes (console noise, see the header) and raises this error
errorMessage = 'extendIndicesInDimenion: Input class must be the same as value class';
assert(verifyCobraFunctionError('extendIndicesInDimenion', 'inputs', {[1 2], 2, {1}, 1}, 'testMessage', errorMessage));

% change the directory
cd(currentDir)
