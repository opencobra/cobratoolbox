% The COBRAToolbox: testGetEnvironment.m
%
% Purpose:
%     - getEnvironment() returns a structure with the fields globals (one field per global
%       variable, holding its value) and path (the current MATLAB path). This test creates
%       globals of known values (a structure and an empty global), checks that every global
%       and only the globals are captured with their values, and that the path is the current
%       path. The function changes nothing; the globals the test creates are removed.
%     - Expected values: the values the test assigns, the list of `who('global')`, the value of
%       CBTDIR read through a `global` declaration, and `path`.
%
% Function under test:
%     src/base/utilities/getEnvironment.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; only global variables and the path are read.
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
fileDir = fileparts(which('testGetEnvironment'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% globals with names no other code uses, so that the test cannot clash with toolbox globals
structValue = struct('name', 'value', 'list', {{1, 'x'}});
setGlobal('TESTGETENVIRONMENT_STRUCT', structValue);
global TESTGETENVIRONMENT_EMPTY

%% every global is captured with its value, and the path is the current path

environment = getEnvironment();
assert(isequal(sort(fieldnames(environment)), {'globals'; 'path'}));
% one field per global, no more
assert(isequal(sort(fieldnames(environment.globals)), sort(who('global'))));
% values are copies of the globals, so they compare exactly
assert(isequal(environment.globals.TESTGETENVIRONMENT_STRUCT, structValue));
assert(isempty(environment.globals.TESTGETENVIRONMENT_EMPTY));
global CBTDIR
assert(isequal(environment.globals.CBTDIR, CBTDIR));
assert(ischar(environment.path) && strcmp(environment.path, path));

%% the captured values do not follow later changes of the globals

setGlobal('TESTGETENVIRONMENT_STRUCT', 0);
assert(isequal(environment.globals.TESTGETENVIRONMENT_STRUCT, structValue));

% remove the globals this test created and restore the directory
clearvars -global TESTGETENVIRONMENT_STRUCT TESTGETENVIRONMENT_EMPTY
cd(currentDir)
