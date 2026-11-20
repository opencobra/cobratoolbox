% The COBRAToolbox: testClearGlobal.m
%
% Purpose:
%     - clearGlobal(globalName) removes the global variable named globalName. This test creates
%       globals with a `global` declaration, clears one and checks that it is gone from the global
%       workspace while another one keeps its value, and that clearing a name that is not global
%       raises no error.
%
% Function under test:
%     src/base/utilities/clearGlobal.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-13.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testClearGlobal'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

%% only the named global is removed

global TESTCLEARGLOBAL_REMOVED TESTCLEARGLOBAL_KEPT
TESTCLEARGLOBAL_REMOVED = 1;
TESTCLEARGLOBAL_KEPT = 2;
clearGlobal('TESTCLEARGLOBAL_REMOVED');
assert(~ismember('TESTCLEARGLOBAL_REMOVED', who('global')));
assert(ismember('TESTCLEARGLOBAL_KEPT', who('global')));
% a new declaration of the removed name gives an empty variable: the old value is gone
clear TESTCLEARGLOBAL_REMOVED
global TESTCLEARGLOBAL_REMOVED
assert(isempty(TESTCLEARGLOBAL_REMOVED));
assert(isequal(TESTCLEARGLOBAL_KEPT, 2));

%% clearing a name that is not global does nothing and raises no error

clearGlobal('TESTCLEARGLOBAL_NEVER_DEFINED');
assert(~ismember('TESTCLEARGLOBAL_NEVER_DEFINED', who('global')));

% remove every global this test created and restore the directory
clearvars -global TESTCLEARGLOBAL_REMOVED TESTCLEARGLOBAL_KEPT
cd(currentDir)
