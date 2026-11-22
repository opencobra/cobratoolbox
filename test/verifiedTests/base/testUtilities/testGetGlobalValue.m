% The COBRAToolbox: testGetGlobalValue.m
%
% Purpose:
%     - getGlobalValue(globalName) returns the value of the global variable named globalName.
%       This test sets globals directly with a `global` declaration (independent of the COBRA
%       setter), reads them back, and pins what happens for a name that is not yet global: the
%       result is [] and, because the function declares the name global, an empty global of that
%       name exists afterwards. Every global the test creates is removed.
%
% Function under test:
%     src/base/utilities/getGlobalValue.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The value of a global named globalName cannot be read
%       SEVERITY: limitation
%       TRIGGER: getGlobalValue('globalName')
%       OBSERVED: the function declares its own argument variable global, so the text it then
%         evaluates is no longer the name; MATLAB raises MATLAB:m_illegal_character
%       EXPECTED: the value of the global variable globalName, as for any other name
%       LINES: 13-14
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-13.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testGetGlobalValue'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

%% the value of an existing global is returned unchanged, whatever its type

global TESTGETGLOBALVALUE_NUMBER TESTGETGLOBALVALUE_CELL
TESTGETGLOBALVALUE_NUMBER = pi;
TESTGETGLOBALVALUE_CELL = {'a', 1, struct('b', 2)};
assert(isequal(getGlobalValue('TESTGETGLOBALVALUE_NUMBER'), pi));
assert(isequal(getGlobalValue('TESTGETGLOBALVALUE_CELL'), {'a', 1, struct('b', 2)}));

%% the global named value (the function's own output) is read correctly

global value
value = 'the global named value';
assert(strcmp(getGlobalValue('value'), 'the global named value'));
clear value

%% a name that is not global: [] is returned and an empty global of that name now exists

assert(~ismember('TESTGETGLOBALVALUE_UNSET', who('global')));
assert(isequal(getGlobalValue('TESTGETGLOBALVALUE_UNSET'), []));
assert(ismember('TESTGETGLOBALVALUE_UNSET', who('global')));

% remove every global this test created and restore the directory
clearvars -global TESTGETGLOBALVALUE_NUMBER TESTGETGLOBALVALUE_CELL TESTGETGLOBALVALUE_UNSET value
cd(currentDir)
