% The COBRAToolbox: testReassignFwBwMatch.m
%
% Purpose:
%     - reassignFwBwMatch renumbers the forward/backward reaction match vector after a selection of reactions: partners that are no longer selected get 0.
%       Characterization test that PINS the current behaviour (feature
%       026-tier1-test-batch2, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/reconstruction/refinement/reassignFwBwMatch.m
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
%     - Generated for feature 026-tier1-test-batch2, 2026-10-11.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testReassignFwBwMatch'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

%% all partners selected

% reactions 1 and 2 are partners; reaction 3 has none; reaction 4 is selected, 3 is not
matchNew = reassignFwBwMatch([2 1 0 0], [1 1 0 1]);
% selected reactions 1, 2, 4 become 1, 2, 3
assert(isequal(matchNew, [2; 1; 0]));

%% a partner that is not selected becomes 0

matchNew = reassignFwBwMatch([2 1 3 0], [1 0 1 1]);
% reaction 1's partner (2) is not selected; reaction 3 matches itself
assert(isequal(matchNew, [0; 2; 0]));

%% everything selected: the vector is unchanged (as a column)

assert(isequal(reassignFwBwMatch([3 0 1], [1 1 1]), [3; 0; 1]));

% change the directory
cd(currentDir)
