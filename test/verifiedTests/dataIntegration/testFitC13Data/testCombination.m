% The COBRAToolbox: testCombination.m
%
% Purpose:
%     - Combination enumerates all k-element combinations of the numbers 1..n and returns their number and the combinations as columns.
%       Characterization test that PINS the current behaviour (feature
%       026-tier1-test-batch2, Constitution Principle III characterization mode);
%       it must not change the function under test.
%     - Defect(s) fixed by feature 20261102-140321-tier1-safe-defect-fixes: k = 0 errors; Negative
%       parameters print a message and return empty.
%
% Function under test:
%     src/dataIntegration/fluxomics/c13solver/Combination.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     None. The local function getNumberCombinations is covered through the n == k, n > k and n < k cases.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 026-tier1-test-batch2, 2026-10-11.
%     - Updated for feature 20261102-140321-tier1-safe-defect-fixes, 2026-11-02.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testCombination'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

%% 2 out of 4

combinations = Combination(4, 2);
assert(combinations.choose == 6);
% each column is one combination, in lexicographic order
assert(isequal(combinations.all, [1 1 1 2 2 3; 2 3 4 3 4 4]));

%% n equal to k: a single combination

combinations = Combination(3, 3);
assert(combinations.choose == 1);
assert(isequal(combinations.all, [1; 2; 3]));

%% k larger than n: no combination (and no list of combinations)

combinations = Combination(2, 3);
assert(combinations.choose == 0);
assert(~isfield(combinations, 'all'));

%% k = 0: one empty combination

% there is exactly one way to pick nothing: one combination with no element (a 0 x 1 column)
combinations = Combination(4, 0);
assert(combinations.choose == 1);
assert(isequal(size(combinations.all), [0 1]));
combinations = Combination(0, 0);
assert(combinations.choose == 1);
assert(isequal(size(combinations.all), [0 1]));

%% negative parameters raise an error

assert(verifyCobraFunctionError('Combination', 'inputs', {-1, 2}, 'outputArgCount', 1, ...
    'testMessage', 'Negative parameter in constructor'));
assert(verifyCobraFunctionError('Combination', 'inputs', {3, -1}, 'outputArgCount', 1, ...
    'testMessage', 'Negative parameter in constructor'));

% change the directory
cd(currentDir)
