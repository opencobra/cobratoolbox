% The COBRAToolbox: testMergeCobraParams.m
%
% Purpose:
%     - mergeCobraParams merges two parameter structures; where both define a field the value of the
%     first structure is kept.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/base/solvers/param/mergeCobraParams.m
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
%     - Generated for feature tier1-test-batch4, 2026-10-13.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testMergeCobraParams'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

%% fields of both structures are kept

merged = mergeCobraParams(struct('a', 1), struct('b', 2));
assert(isequal(merged, struct('b', 2, 'a', 1)));

%% the first structure wins when a field is in both

merged = mergeCobraParams(struct('a', 1, 'c', 3), struct('a', 10, 'b', 2));
assert(merged.a == 1 && merged.b == 2 && merged.c == 3);

%% empty structures

assert(isequal(mergeCobraParams(struct(), struct('x', 1)), struct('x', 1)));
assert(isequal(mergeCobraParams(struct('x', 1), struct()), struct('x', 1)));

% change the directory
cd(currentDir)
