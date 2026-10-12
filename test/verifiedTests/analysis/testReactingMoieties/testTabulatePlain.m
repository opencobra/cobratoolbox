% The COBRAToolbox: testTabulatePlain.m
%
% Purpose:
%     - tabulatePlain counts how often each distinct value occurs and returns a cell array with the
%     value, the count and the percentage, in order of first appearance.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch3, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/analysis/topology/reactingMoieties/tabulatePlain.m
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

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testTabulatePlain'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% tolerance for the percentages: a ratio of small integers times 100
tol = 1e-10;

%% numbers

result = tabulatePlain([3 1 3 2 3]);
assert(isequal(result(:, 1:2), {3, 3; 1, 1; 2, 1}));
assert(norm([result{:, 3}] - [60 20 20]) < tol);

%% text values

result = tabulatePlain({'b'; 'a'; 'b'});
assert(isequal(result(:, 1:2), {'b', 2; 'a', 1}));
assert(norm([result{:, 3}] - [200/3 100/3]) < tol);

%% no values: an empty table with three columns

result = tabulatePlain([]);
assert(isequal(size(result), [0 3]));

% change the directory
cd(currentDir)
