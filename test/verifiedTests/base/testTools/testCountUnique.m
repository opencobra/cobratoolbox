% The COBRAToolbox: testCountUnique.m
%
% Purpose:
%     - countUnique lists the distinct values of a list and how often each occurs, most frequent
%     first.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch3, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/base/utilities/countUnique.m
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
fileDir = fileparts(which('testCountUnique'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

%% text values: most frequent first

[sortedList, sortedCount] = countUnique({'b'; 'a'; 'b'; 'c'; 'b'; 'a'});
assert(isequal(sortedList, {'b'; 'a'; 'c'}));
assert(isequal(sortedCount, [3; 2; 1]));       % counts are always a column

%% numbers

[sortedList, sortedCount] = countUnique([3 1 3 2 3 1]);
assert(isequal(sortedList, [3 1 2]));
assert(isequal(sortedCount, [3; 2; 1]));

%% equal counts keep the sorted order of the values

[sortedList, sortedCount] = countUnique({'y'; 'x'});
assert(isequal(sortedList, {'x'; 'y'}));
assert(isequal(sortedCount, [1; 1]));

% change the directory
cd(currentDir)
