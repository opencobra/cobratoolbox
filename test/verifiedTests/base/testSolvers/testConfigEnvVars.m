% The COBRAToolbox: testConfigEnvVars.m
%
% Purpose:
%     - configEnvVars sets the global solver paths GUROBI_PATH, ILOG_CPLEX_PATH, TOMLAB_PATH and
%       MOSEK_PATH when ENV_VARS.STATUS is 0, from (1) the solver folder at a standard location
%       when it is already on the MATLAB path ('*---'), (2) another MATLAB path entry naming
%       the solver ('-*--'), (3) the environment variable of the solver ('--*-'), or (4) the
%       solver folder at a standard location ('---*'), and then sets ENV_VARS.STATUS to 1.
%       The test makes the result independent of the solvers installed on the machine: HOME
%       points to a tempname folder whose Library folder holds fake solver folders (~/Library/
%       is the last standard location, so they are chosen over real installations), the MATLAB
%       path entries naming a solver are removed for the duration of the test, and the solver
%       environment variables are set by the test. Expected values follow from the help text
%       and the folder layout the code builds (gurobi: <root>/<os>64/matlab, CPLEX:
%       <root>/cplex/matlab/<arch>, TOMLAB and MOSEK: <root>/).
%     - The HOME and solver environment variables, the MATLAB path and the five globals are
%       saved and restored (also on failure, through onCleanup).
%
% Function under test:
%     src/base/solvers/init/configEnvVars.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; fake solver folders in a tempname folder. Declares
%     needsUnix: the default locations, the path separator and the regular expressions of the
%     function are those of Linux and macOS.
%
% Coverage exemptions:
%     Line 59: Windows only (ispc), the default locations C:\ etc.
%     Line 201: Windows only, path entries separated by ;.
%     Lines 290, 292: Windows and macOS only, the gurobi folder names win64 and mac64.
%     Lines 306, 308: Windows and macOS only, the CPLEX folder names x64_win64 and x86-64_osx.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The call stops with an error when ENV_VARS.STATUS is not set
%       SEVERITY: limitation
%       TRIGGER: global ENV_VARS; ENV_VARS = struct('printLevel', 0); configEnvVars(0) (also
%         with ENV_VARS = [])
%       OBSERVED: Unrecognized field name "STATUS". (MATLAB:nonExistentField), and Dot indexing
%         is not supported for variables of this type. (MATLAB:structRefFromNonStruct) for
%         ENV_VARS = [] (R2025a, 2026-11-15): exist('ENV_VARS.STATUS', 'var') is never 1 because
%         ENV_VARS.STATUS is not a variable name, so ENV_VARS.STATUS is always read.
%         initCobraToolbox sets ENV_VARS.STATUS = 0 before its call
%       EXPECTED: the paths configured when ENV_VARS.STATUS does not exist, as the test of
%         line 33 suggests, or this requirement documented
%       LINES: 33
%     - DEFECT: GUROBI_PATH from an environment variable ending in linux64 or mac64 gets a double separator
%       SEVERITY: cosmetic
%       TRIGGER: environment variable GUROBI_PATH = /x/gurobi1000/linux64 on Linux (no gurobi
%         folder at a standard location on the MATLAB path)
%       OBSERVED: GUROBI_PATH = /x/gurobi1000//linux64/matlab (R2025a, 2026-11-15): in the regular expression
%         \/(win64$)|(mac64$)|(linux64$) the separator belongs to the first alternative only,
%         so only linux64 (not /linux64) is removed before /linux64/matlab is appended
%       EXPECTED: /x/gurobi1000/linux64/matlab
%       LINES: 240-241
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testConfigEnvVars'));
cd(fileDir);

% the default locations, path separator and regular expressions of configEnvVars are those
% of Unix systems
prepareTest('needsUnix', true);

% save everything the test or the function changes; restoreConfigEnvVarsState (local
% function below) restores it when savedStateGuard is cleared or the test stops with an error
saved.globalsBefore = who('global');
global ENV_VARS GUROBI_PATH ILOG_CPLEX_PATH TOMLAB_PATH MOSEK_PATH
saved.ENV_VARS = ENV_VARS;
saved.GUROBI_PATH = GUROBI_PATH;
saved.ILOG_CPLEX_PATH = ILOG_CPLEX_PATH;
saved.TOMLAB_PATH = TOMLAB_PATH;
saved.MOSEK_PATH = MOSEK_PATH;
saved.envNames = {'HOME', 'GUROBI_PATH', 'GUROBI_HOME', 'ILOG_CPLEX_PATH', 'TOMLAB_PATH', 'MOSEK_PATH'};
saved.envValues = cellfun(@getenv, saved.envNames, 'UniformOutput', false);
saved.path = path;
fakeRoot = tempname;
saved.fakeRoot = fakeRoot;
savedStateGuard = onCleanup(@() restoreConfigEnvVarsState(saved));

% fake HOME with solver folders in ~/Library/ (the last standard location); MOSEK is looked up
% in ~/Library/Mosek/ (the last of its subfolders)
fakeHome = fullfile(fakeRoot, 'home');
mkdir(fullfile(fakeHome, 'Library', 'gurobi950'));
mkdir(fullfile(fakeHome, 'Library', 'CPLEX_Studio129'));
mkdir(fullfile(fakeHome, 'Library', 'tomlab'));
mkdir(fullfile(fakeHome, 'Library', 'Mosek', '10.0'));
setenv('HOME', fakeHome);
for iName = 2:numel(saved.envNames)
    setenv(saved.envNames{iName}, '');
end

% remove the MATLAB path entries the function would recognise as solver folders (real solver
% installations and the toolbox folder src/base/solvers/mosek)
pathEntries = strsplit(path, pathsep);
isSolverEntry = ~cellfun(@isempty, regexp(pathEntries, '/(CPLEX_Studio|gurobi\w|tomlab|mosek)'));
if any(isSolverEntry)
    rmpath(strjoin(pathEntries(isSolverEntry), pathsep));
end

% folder names the function appends for this operating system
if ismac
    gurobiSubDir = [filesep 'mac64' filesep 'matlab'];
    cplexSubDir = [filesep 'cplex' filesep 'matlab' filesep 'x86-64_osx'];
else
    gurobiSubDir = [filesep 'linux64' filesep 'matlab'];
    cplexSubDir = [filesep 'cplex' filesep 'matlab' filesep 'x86-64_linux'];
end

%% STATUS 1: nothing is changed

ENV_VARS.STATUS = 1;
GUROBI_PATH = 'unchanged1'; ILOG_CPLEX_PATH = 'unchanged2';
TOMLAB_PATH = 'unchanged3'; MOSEK_PATH = 'unchanged4';
configEnvVars(1);
assert(ENV_VARS.STATUS == 1);
assert(strcmp(GUROBI_PATH, 'unchanged1') && strcmp(ILOG_CPLEX_PATH, 'unchanged2'));
assert(strcmp(TOMLAB_PATH, 'unchanged3') && strcmp(MOSEK_PATH, 'unchanged4'));

%% STATUS 0, default printLevel: the four methods, one per solver

% gurobi: the standard folder ~/Library/gurobi950/<os>64/matlab is on the MATLAB path (the
% function compares the unexpanded ~/ form with the path, so the entry is built from a
% folder named ~ inside the tempname folder) -> method *---
gurobiOnPath = fullfile(fakeRoot, '~', 'Library', 'gurobi950', gurobiSubDir);
mkdir(gurobiOnPath);
addpath(gurobiOnPath);
% TOMLAB: another path entry names tomlab -> method -*--, the entry itself is used
tomlabEntry = fullfile(fakeRoot, 'site', 'tomlab', 'base');
mkdir(tomlabEntry);
addpath(tomlabEntry);
% CPLEX: the environment variable is set -> method --*-, with the CPLEX subfolders appended
setenv('ILOG_CPLEX_PATH', '/fake/cplexroot');
% MOSEK: neither on the path nor in the environment -> method ---*, the standard folder

ENV_VARS.STATUS = 0;
configEnvVars();
% the paths are strings built by concatenation, compared exactly
assert(strcmp(GUROBI_PATH, ['~/Library/gurobi950' gurobiSubDir]));
assert(strcmp(TOMLAB_PATH, tomlabEntry));
assert(strcmp(ILOG_CPLEX_PATH, ['/fake/cplexroot' cplexSubDir]));
assert(strcmp(MOSEK_PATH, ['~/Library/Mosek/10.0' filesep]));
assert(ENV_VARS.STATUS == 1);

%% STATUS 0, printLevel 1: environment variables, and a solver that may not be found

rmpath(gurobiOnPath);
rmpath(tomlabEntry);
setenv('ILOG_CPLEX_PATH', '');
rmdir(fullfile(fakeHome, 'Library', 'CPLEX_Studio129'));
% the gurobi variable is given without the trailing <os>64 folder (the defect above concerns
% a variable ending in linux64 or mac64); the regular expression leaves it unchanged
setenv('GUROBI_PATH', '/fake/gurobi1000');
setenv('TOMLAB_PATH', '/fake/tomlab');

ENV_VARS.STATUS = 0;
configEnvVars(1);
assert(strcmp(GUROBI_PATH, ['/fake/gurobi1000' gurobiSubDir]));
assert(strcmp(TOMLAB_PATH, ['/fake/tomlab' filesep]));
assert(strcmp(MOSEK_PATH, ['~/Library/Mosek/10.0' filesep]));
% CPLEX is now only found if the machine has a CPLEX_Studio<version> folder at a standard
% location (the reference machine has none, so the instructions are printed and the path
% stays empty); either way the result is empty or such a folder
assert(isempty(ILOG_CPLEX_PATH) || contains(ILOG_CPLEX_PATH, 'CPLEX_Studio'));
assert(ENV_VARS.STATUS == 1);

% restore the environment, the path and the globals, and remove the temporary folder
clear savedStateGuard

% change the directory
cd(currentDir)

function restoreConfigEnvVarsState(saved)
% Restores the environment variables, the MATLAB path and the globals saved by this test and
% removes its temporary folder.
    global ENV_VARS GUROBI_PATH ILOG_CPLEX_PATH TOMLAB_PATH MOSEK_PATH
    for iName = 1:numel(saved.envNames)
        setenv(saved.envNames{iName}, saved.envValues{iName});
    end
    path(saved.path);
    ENV_VARS = saved.ENV_VARS;
    GUROBI_PATH = saved.GUROBI_PATH;
    ILOG_CPLEX_PATH = saved.ILOG_CPLEX_PATH;
    TOMLAB_PATH = saved.TOMLAB_PATH;
    MOSEK_PATH = saved.MOSEK_PATH;
    newGlobals = setdiff(who('global'), saved.globalsBefore);
    if ~isempty(newGlobals)
        clear('global', newGlobals{:});
    end
    if exist(saved.fakeRoot, 'dir')
        rmdir(saved.fakeRoot, 's');
    end
end
