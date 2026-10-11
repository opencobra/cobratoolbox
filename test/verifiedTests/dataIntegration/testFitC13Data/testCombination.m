% The COBRAToolbox: testCombination.m
%
% Purpose:
%     - Combination enumerates all k-element combinations of the numbers 1..n and returns their number and the combinations as columns.
%       Characterization test that PINS the current behaviour (feature
%       026-tier1-test-batch2, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/dataIntegration/fluxomics/c13solver/Combination.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     None for the tested inputs. The local function getNumberCombinations is covered through the n == k, n > k and n < k cases.
%
% Known defects documented (NOT tested, NOT fixed here):
%     k = 0 errors (MATLAB:badsubscript) because the combination vector cannot be indexed; that input is documented and NOT tested. For negative n or k the function prints "Negative parameter in constructor" to the console (console noise, not suppressed) and returns an empty value.
%
% Authors:
%     - Generated for feature 026-tier1-test-batch2, 2026-10-11.

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

%% negative parameters: a message is printed and an empty result is returned

assert(isempty(Combination(-1, 2)));
assert(isempty(Combination(3, -1)));

% change the directory
cd(currentDir)
