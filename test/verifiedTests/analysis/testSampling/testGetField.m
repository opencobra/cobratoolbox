% The COBRAToolbox: testGetField.m
%
% Purpose:
%     - getField returns the value of a field of a structure, or a default value when the field is
%     absent.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/analysis/sampling/BarrierRound/utils/getField.m
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
fileDir = fileparts(which('testGetField'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

s = struct('a', 5, 'b', 'text');

%% existing field

assert(getField(s, 'a', 0) == 5);
assert(strcmp(getField(s, 'b', 'default'), 'text'));

%% missing field returns the default

assert(getField(s, 'c', 42) == 42);
assert(isempty(getField(struct(), 'a', [])));

% change the directory
cd(currentDir)
