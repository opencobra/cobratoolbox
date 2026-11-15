% The COBRAToolbox: testRestoreEnvironment.m
%
% Purpose:
%     - restoreEnvironment(environment, restorePath, printLevel) sets every global variable
%       named in environment.globals to its stored value, deletes the globals that are not
%       named there and, unless restorePath is false, sets the MATLAB path to
%       environment.path; with printLevel 1 it prints each value and the path.
%     - The test builds the environment by hand from the current globals (read with
%       getGlobalValue) and the current path, so the environment it restores is the one the
%       test started with: every global and the path are back to their initial state after
%       each call, and the globals the test adds are removed. Expected values are those
%       stored values.
%
% Function under test:
%     src/base/utilities/restoreEnvironment.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; only global variables and the path are changed, and both
%     are restored.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The printed path is cut at a folder name with a % sign
%       SEVERITY: cosmetic
%       TRIGGER: a folder named '100%done' on environment.path, restoreEnvironment(environment, true, 1)
%       OBSERVED: "Path set to:" is followed by '<tempdir>/100' and nothing else: the path is
%         used as the format of sprintf, which stops at the conversion %d that has no data
%         (backslashes in folder names would likewise be read as escapes); the path itself is
%         restored correctly; the test uses no such folder name
%       EXPECTED: every folder of the path, one per line
%       LINES: 44
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-13.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testRestoreEnvironment'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% the environment to restore: every current global (plus one the test owns, value 1) and the
% current path. Global names no other code uses, so the test cannot clash with the toolbox
setGlobal('TESTRESTOREENVIRONMENT_KEPT', 1);
globalNames = who('global');
savedGlobals = struct();
for k = 1:numel(globalNames)
    savedGlobals.(globalNames{k}) = getGlobalValue(globalNames{k});
end
savedPath = path;
environment = struct('globals', savedGlobals, 'path', savedPath);
tmpDir = tempname;
mkdir(tmpDir);

%% defaults: globals reset to the stored values, other globals deleted, path restored

setGlobal('TESTRESTOREENVIRONMENT_KEPT', 2);
setGlobal('TESTRESTOREENVIRONMENT_NEW', 3);
addpath(tmpDir);
restoreEnvironment(environment);
% the stored value is back, exactly
assert(isequal(getGlobalValue('TESTRESTOREENVIRONMENT_KEPT'), 1));
% the global that was not in the environment is gone, and no other global was added or removed
assert(isequal(sort(who('global')), sort(globalNames)));
% every other global still holds its stored value
for k = 1:numel(globalNames)
    assert(isequal(getGlobalValue(globalNames{k}), savedGlobals.(globalNames{k})), globalNames{k});
end
assert(strcmp(path, savedPath));

%% restorePath false: the globals are restored, the path is left as it is

setGlobal('TESTRESTOREENVIRONMENT_KEPT', 5);
addpath(tmpDir);
restoreEnvironment(environment, false);
assert(isequal(getGlobalValue('TESTRESTOREENVIRONMENT_KEPT'), 1));
assert(ismember(tmpDir, strsplit(path, pathsep)));
rmpath(tmpDir);
assert(strcmp(path, savedPath));

%% printLevel 1: each global and the path are printed (the full path, one folder per line)

setGlobal('TESTRESTOREENVIRONMENT_KEPT', 6);
addpath(tmpDir);
restoreEnvironment(environment, true, 1);
assert(isequal(getGlobalValue('TESTRESTOREENVIRONMENT_KEPT'), 1));
assert(strcmp(path, savedPath));

% remove the global and the folder this test created and restore the directory
clearvars -global TESTRESTOREENVIRONMENT_KEPT
rmdir(tmpDir);
cd(currentDir)
