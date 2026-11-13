% The COBRAToolbox: testGetCobraSolverVersion.m
%
% Purpose:
%     - getCobraSolverVersion(solverName, printLevel, rootPathSolver) reads the version of a solver
%       from the installation path stored in the solver's global path variable (ILOG_CPLEX_PATH,
%       GUROBI_PATH, MOSEK_PATH) or, for TOMLAB, from `ver('tomlab')`, and returns it as text
%       ('' when it cannot tell, 'undetermined' when the path does not have the expected form).
%       This test sets the global path variables to hand-built paths whose version is known, so
%       every pattern and fallback is checked without the solvers being installed, then restores
%       the globals. The version text expected for each path follows from the path itself.
%     - When the toolbox is not initialised (global SOLVERS empty) the function first runs
%       initCobraToolbox; the last section triggers this and restores the solver state afterwards.
%
% Function under test:
%     src/base/solvers/getSetSolver/getCobraSolverVersion.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model and no solver (paths are hand-built; nothing is solved).
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
fileDir = fileparts(which('testGetCobraSolverVersion'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% save every global the function reads or changes, to restore them at the end
global ILOG_CPLEX_PATH GUROBI_PATH MOSEK_PATH TOMLAB_PATH ENV_VARS SOLVERS
saved = struct('cplex', ILOG_CPLEX_PATH, 'gurobi', GUROBI_PATH, 'mosek', MOSEK_PATH, ...
    'tomlab', TOMLAB_PATH, 'envVars', ENV_VARS, 'solvers', SOLVERS);
% (globals that exist now: anything new at the end was created by this test or by the functions
% it calls, including CobraSolverState and initCobraToolbox)
globalsBefore = who('global');
initialSolverState = CobraSolverState.get();
fs = filesep;

%% the version is the text that follows the solver's name pattern in the path

GUROBI_PATH = [fs 'opt' fs 'gurobi1103' fs 'linux64' fs 'matlab'];
assert(strcmp(getCobraSolverVersion('gurobi', 0), '1103'));
ILOG_CPLEX_PATH = [fs 'opt' fs 'ibm' fs 'CPLEX_Studio1271' fs 'cplex' fs 'matlab'];
assert(strcmp(getCobraSolverVersion('ibm_cplex', 0), '1271'));
MOSEK_PATH = [fs 'opt' fs 'Mosek9' fs 'toolbox' fs 'r2017a'];
assert(strcmp(getCobraSolverVersion('mosek', 0), '9'));
% MOSEK installed under mosektoolslinux64x86: the version is the folder after mosek/
MOSEK_PATH = [fs 'opt' fs 'mosektoolslinux64x86' fs 'mosek' fs '10.1' fs 'toolbox'];
assert(strcmp(getCobraSolverVersion('mosek', 0), '10.1'));

%% the version in a folder of its own (gurobi/951/...): the second folder is used

GUROBI_PATH = [fs 'opt' fs 'gurobi' fs '951' fs 'linux64'];
assert(strcmp(getCobraSolverVersion('gurobi', 0), '951'));

%% printLevel 1 (the default) prints the version; the result is the same

GUROBI_PATH = [fs 'opt' fs 'gurobi1103' fs 'linux64' fs 'matlab'];
assert(strcmp(getCobraSolverVersion('gurobi'), '1103'));
assert(strcmp(getCobraSolverVersion('gurobi', 1, 'ignored root path'), '1103'));

%% a path with no folder after the pattern: 'undetermined' (and a message at printLevel 1)

GUROBI_PATH = [fs 'opt' fs 'mygurobi1103'];
assert(strcmp(getCobraSolverVersion('gurobi', 0), 'undetermined'));
assert(strcmp(getCobraSolverVersion('gurobi', 1), 'undetermined'));

%% no installation path, or a solver without version detection: ''

GUROBI_PATH = '';
assert(isempty(getCobraSolverVersion('gurobi', 0)));
assert(isempty(getCobraSolverVersion('gurobi', 1)));
assert(isempty(getCobraSolverVersion('glpk', 0)));
assert(isempty(getCobraSolverVersion('glpk', 1)));

%% TOMLAB: the version comes from ver('tomlab'), with the dot removed

% a folder that MATLAB's ver recognises as a toolbox named tomlab, version 8.9
tomlabRoot = tempname;
mkdir(fullfile(tomlabRoot, 'tomlab'));
fid = fopen(fullfile(tomlabRoot, 'tomlab', 'Contents.m'), 'w');
fprintf(fid, '%% TOMLAB Optimization Environment\n%% Version 8.9 (R2025a) 01-Jan-2026\n');
fclose(fid);
TOMLAB_PATH = tomlabRoot;
pathBefore = path;
for name = {'tomlab_cplex', 'tomlab_snopt', 'cplex_direct'}
    assert(strcmp(getCobraSolverVersion(name{1}, 0), '89'), name{1});
end
% the path is the same afterwards (the TOMLAB folders are removed again)
assert(isempty(setxor(strsplit(path, pathsep), strsplit(pathBefore, pathsep))));
% a TOMLAB folder without the toolbox description: ''
delete(fullfile(tomlabRoot, 'tomlab', 'Contents.m'));
assert(isempty(getCobraSolverVersion('tomlab_cplex', 0)));
rmdir(tomlabRoot, 's');

%% toolbox not initialised (SOLVERS empty): initCobraToolbox runs first

SOLVERS = [];
GUROBI_PATH = [fs 'opt' fs 'gurobi1103' fs 'linux64' fs 'matlab'];
glpkVersion = getCobraSolverVersion('glpk', 0);
assert(isempty(glpkVersion) && ~isempty(SOLVERS));

% restore the globals and the solver state, and the directory
ILOG_CPLEX_PATH = saved.cplex;
GUROBI_PATH = saved.gurobi;
MOSEK_PATH = saved.mosek;
TOMLAB_PATH = saved.tomlab;
ENV_VARS = saved.envVars;
SOLVERS = saved.solvers;
CobraSolverState.restore(initialSolverState);
% remove the globals that did not exist before the test
newGlobals = setdiff(who('global'), globalsBefore);
if ~isempty(newGlobals)
    clearvars('-global', newGlobals{:});
end
cd(currentDir)
