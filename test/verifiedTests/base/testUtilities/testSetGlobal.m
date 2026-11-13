% The COBRAToolbox: testSetGlobal.m
%
% Purpose:
%     - setGlobal(globalName, globalValue) sets the global variable named globalName to
%       globalValue (creating it if needed). This test sets globals of several types, overwrites
%       one, reads them back through a `global` declaration in the test (independent of the
%       COBRA getter), and removes every global it created.
%
% Function under test:
%     src/base/utilities/setGlobal.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: A global named globalName cannot be set
%       SEVERITY: limitation
%       TRIGGER: setGlobal('globalName', value)
%       OBSERVED: the function declares its own argument variable global, so the text it then
%         evaluates is no longer the name; MATLAB raises MATLAB:m_illegal_character
%       EXPECTED: the global variable globalName set to value, as for any other name
%       LINES: 13-14
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-13.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testSetGlobal'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% names that no other code uses, so that the test cannot clash with toolbox globals
numberName = 'TESTSETGLOBAL_NUMBER';
structName = 'TESTSETGLOBAL_STRUCT';

%% a new global variable is created with the given value

setGlobal(numberName, 42);
global TESTSETGLOBAL_NUMBER
assert(ismember(numberName, who('global')));
assert(isequal(TESTSETGLOBAL_NUMBER, 42));

%% an existing global is overwritten, and values of any type are kept unchanged

setGlobal(numberName, [1 2; 3 4]);
assert(isequal(TESTSETGLOBAL_NUMBER, [1 2; 3 4]));
structValue = struct('name', 'value', 'list', {{'a', 'b'}});
setGlobal(structName, structValue);
global TESTSETGLOBAL_STRUCT
assert(isequal(TESTSETGLOBAL_STRUCT, structValue));

%% the name globalValue (the function's own second argument) also works

setGlobal('globalValue', 7);
global globalValue
assert(isequal(globalValue, 7));

% remove every global this test created and restore the directory
clearvars -global TESTSETGLOBAL_NUMBER TESTSETGLOBAL_STRUCT globalValue
cd(currentDir)
