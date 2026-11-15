% The COBRAToolbox: testGenerateMexFastFVA.m
%
% Purpose:
%     - generateMexFastFVA(rootPathCPLEX, printLevel) compiles the C source of fastFVA
%       (cplexFVA.c) into a MEX file against an IBM CPLEX installation. It takes the CPLEX root
%       from the global ILOG_CPLEX_PATH when rootPathCPLEX is not given or empty, reads the CPLEX
%       version from that path (getCobraSolverVersion), and stops with an error when the CPLEX
%       include folder or library folder is missing. This test builds CPLEX installation
%       folders by hand in a temporary folder (CPLEX 12.10 and 12.8, the two sides of the
%       version switch of the function) and checks the two errors, whose expected text follows
%       from the folders themselves; the last section runs the function with the toolbox not
%       initialised (global SOLVERS empty), which makes it run initCobraToolbox first. Every
%       global, the solver state and the MATLAB path are restored at the end.
%
% Function under test:
%     src/analysis/FVA/fastFVA/mex/generateMexFastFVA.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver (CPLEX folders are hand-built; nothing is compiled or solved).
%
% Coverage exemptions:
%     Lines 94, 95: not Linux (test for macOS and CPLEX library folder of macOS).
%     Lines 97, 107, 135: Windows only (CPLEX library folder and file names, no dynamic linker).
%     Lines 104, 105, 111, 114, 119-170 (executable lines): reached only when the CPLEX include and
%     library folders exist, after which the function configures mex and compiles cplexFVA.c
%     against CPLEX: this needs an IBM CPLEX installation, which the reference machine does not
%     have (and a C compiler); with hand-built folders it would configure mex in prefdir and run
%     the compiler on a fake installation.
%     Line 112: unreachable by any input - its condition repeats the folder test of line 101,
%     which is false at that point (see the first defect below).
%     Lines 173, 174, 176: unreachable by any input - cplexInstalled is false only when the
%     CPLEX root folder is missing, and then the include folder is missing too and line 89 stops
%     the function first; libraryExists is false only after the errors of lines 89 and 102.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: the existence of the CPLEX library file is never checked
%       SEVERITY: cosmetic
%       TRIGGER: generateMexFastFVA(root, 0) with root/include/ilcplex and
%                root/lib/x86-64_linux/static_pic present but no libcplex.a in the latter
%       OBSERVED: MATLAB 2026-11-13 (with mex replaced by a recording stub in a scratch run):
%                 the function goes on to "mex -setup c" and to the compilation, passing the
%                 missing .../static_pic/libcplex.a to mex; line 111 tests exist(lib, 'dir')
%                 again instead of the library file, so the error of line 112 cannot occur
%       EXPECTED: the error "The required CPLEX library file ... does not exist." of line 112
%       LINES: 110-112
%     - DEFECT: printLevel 2 prints a truncated compilation command and a warning
%       SEVERITY: cosmetic
%       TRIGGER: generateMexFastFVA(root, 2) with a CPLEX installation (include and library
%                folders present)
%       OBSERVED: MATLAB 2026-11-13 (scratch run, mex stubbed): "Warning: Escaped character '\$'
%                 is not valid." and the printed command stops at CFLAGS=" because the command
%                 text is passed to fprintf as its format
%       EXPECTED: the whole compilation command printed, without a warning
%       LINES: 141-143
%     - DEFECT: the CPLEX root stays on the MATLAB path when the function stops with an error
%       SEVERITY: cosmetic
%       TRIGGER: any call that ends with the errors of lines 89 or 102 (as in this test)
%       OBSERVED: MATLAB 2026-11-13: rootPathCPLEX, added to the path at line 66, is still on
%                 the path after the error; the path saved at line 63 is restored only at
%                 lines 163 and 173 (this test restores the path itself)
%       EXPECTED: the MATLAB path unchanged after the error
%       LINES: 63-66, 89, 102
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-13.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testGenerateMexFastFVA'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% save every global the function reads or changes, the MATLAB path and the solver state,
% to restore them at the end (globals that exist now: anything new at the end was created
% by this test or by the functions it calls, including CobraSolverState and initCobraToolbox)
global ILOG_CPLEX_PATH ENV_VARS SOLVERS
savedCplexPath = ILOG_CPLEX_PATH;
savedEnvVars = ENV_VARS;
savedSolvers = SOLVERS;
globalsBefore = who('global');
initialSolverState = CobraSolverState.get();
pathBefore = path;

% hand-built CPLEX installations: <root>/CPLEX_Studio<version>/cplex with its matlab folder
fakeRoot = tempname;
cplexRoot1210 = fullfile(fakeRoot, 'CPLEX_Studio1210', 'cplex');
cplexRoot128 = fullfile(fakeRoot, 'CPLEX_Studio128', 'cplex');
mkdir(fullfile(cplexRoot1210, 'matlab', 'x86-64_linux'));
mkdir(fullfile(cplexRoot128, 'matlab', 'x86-64_linux'));

% the messages expected for a CPLEX root: missing include folder and missing library folder
% (the library folder depends on the operating system and, on Windows, on the CPLEX version)
missingIncludeMessage = @(root) ['The directory ' root filesep 'include' filesep 'ilcplex' ...
    ' does not exist. Please install the CPLEX solver as explained here.'];
if isunix && ~ismac
    libFolder = @(root, vs) [root filesep 'lib/x86-64_linux/static_pic'];
elseif ismac
    libFolder = @(root, vs) [root filesep 'lib/x86-64_osx/static_pic'];
else
    libFolder = @(root, vs) [root filesep 'lib\x64_windows_' vs '\stat_mda'];
end
missingLibraryMessage = @(root, vs) ['The CPLEX library ' libFolder(root, vs) ...
    ' does not exist. Please install the CPLEX solver as explained here.'];

%% CPLEX root taken from ILOG_CPLEX_PATH (no argument, or an empty rootPathCPLEX)

% ILOG_CPLEX_PATH = <root>/CPLEX_Studio1210/cplex/matlab/x86-64_linux: the root is the path up
% to 'cplex' (<root>/CPLEX_Studio1210/cplex) and the version 1210 (12.10, below 12.8.0 in the
% numbering of the function: 1210 / 10 = 121 < 128). The include folder is missing, so the
% function stops with the error naming <root>/include/ilcplex. Called with no argument
% (printLevel 1, the version is printed) and with an empty root at printLevel 0.
ILOG_CPLEX_PATH = fullfile(cplexRoot1210, 'matlab', 'x86-64_linux');
assert(verifyCobraFunctionError('generateMexFastFVA', ...
    'testMessage', missingIncludeMessage(cplexRoot1210)));
assert(verifyCobraFunctionError('generateMexFastFVA', 'inputs', {[], 0}, ...
    'testMessage', missingIncludeMessage(cplexRoot1210)));
path(pathBefore);

%% CPLEX root given but missing

% a root folder that does not exist (MATLAB warns when the function adds it to the path):
% the CPLEX installation is not found and the include folder is missing as well
missingRoot = fullfile(fakeRoot, 'missing', 'cplex');
assert(verifyCobraFunctionError('generateMexFastFVA', 'inputs', {missingRoot, 0}, ...
    'testMessage', missingIncludeMessage(missingRoot)));
path(pathBefore);

%% CPLEX root given: include folder present, library folder missing

% CPLEX 12.8 (version 128, from ILOG_CPLEX_PATH): the include folder exists, so the function
% looks for the library folder of the operating system and stops with the error naming it
mkdir(fullfile(cplexRoot128, 'include', 'ilcplex'));
ILOG_CPLEX_PATH = fullfile(cplexRoot128, 'matlab', 'x86-64_linux');
assert(verifyCobraFunctionError('generateMexFastFVA', 'inputs', {cplexRoot128, 0}, ...
    'testMessage', missingLibraryMessage(cplexRoot128, 'vs2015')));
% the same with the root of the 12.10 installation once its include folder exists
mkdir(fullfile(cplexRoot1210, 'include', 'ilcplex'));
ILOG_CPLEX_PATH = fullfile(cplexRoot1210, 'matlab', 'x86-64_linux');
assert(verifyCobraFunctionError('generateMexFastFVA', 'inputs', {cplexRoot1210, 0}, ...
    'testMessage', missingLibraryMessage(cplexRoot1210, 'vs2013')));
path(pathBefore);

%% toolbox not initialised (SOLVERS empty): initCobraToolbox runs first

% the root of the 12.8 installation is given explicitly, so the error does not depend on the
% ILOG_CPLEX_PATH that initCobraToolbox may set
SOLVERS = [];
assert(verifyCobraFunctionError('generateMexFastFVA', 'inputs', {cplexRoot128, 0}, ...
    'testMessage', missingLibraryMessage(cplexRoot128, 'vs2015')));
assert(~isempty(SOLVERS));

% remove the hand-built installations; restore the globals, the solver state, the path and
% the directory
rmdir(fakeRoot, 's');
ILOG_CPLEX_PATH = savedCplexPath;
ENV_VARS = savedEnvVars;
SOLVERS = savedSolvers;
CobraSolverState.restore(initialSolverState);
path(pathBefore);
% remove the globals that did not exist before the test
newGlobals = setdiff(who('global'), globalsBefore);
if ~isempty(newGlobals)
    clearvars('-global', newGlobals{:});
end
cd(currentDir)
