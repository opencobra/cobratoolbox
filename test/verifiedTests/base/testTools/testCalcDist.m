% The COBRAToolbox: testCalcDist.m
%
% Purpose:
%     - calcDist computes a weighted edit distance between a search string and a database string (cheap gaps at the ends, case differences cost 0.05, other differences 1).
%       Characterization test that PINS the current behaviour (feature
%       026-tier1-test-batch2, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/base/utilities/calcDist.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     None. Every executable line (including the local functions insertDist and simDistance) is reached below.
%
% Known defects / quirks pinned (NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 026-tier1-test-batch2, 2026-10-11.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testCalcDist'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% tolerance for floating-point comparisons: the distances are sums of the constants 0.05,
% 0.1, 0.8 and 1, so rounding is far below 1e-12
tol = 1e-12;

%% identical strings and case-only differences

assert(abs(calcDist('abc', 'abc')) < tol);
% each letter that differs only by case costs 0.05
assert(abs(calcDist('abc', 'ABC') - 0.15) < tol);
% string input is converted to text
assert(abs(calcDist("abc", 'abc')) < tol);

%% substitutions

% one different letter costs 1
assert(abs(calcDist('abc', 'abd') - 1) < tol);
assert(abs(calcDist('glucose', 'glucosa') - 1) < tol);
assert(abs(calcDist('a', 'b') - 1) < tol);

%% a longer database string (extra characters at the ends cost 0.1 each)

assert(abs(calcDist('abc', 'abcde') - 0.2) < tol);

%% a longer search string (missing characters cost 0.8 each at the ends)

assert(abs(calcDist('abcde', 'abc') - 1.6) < tol);

%% empty strings

assert(abs(calcDist('', 'abc') - 0.3) < tol);
assert(abs(calcDist('abc', '') - 2.4) < tol);

%% both strings different and of different lengths

assert(abs(calcDist('ab', 'xyz') - 2) < tol);
assert(abs(calcDist('xyz', 'ab') - 2.7) < tol);

% change the directory
cd(currentDir)
