% The COBRAToolbox: testConfigEnvVars.m
%
% Purpose:
%     - configEnvVars sets the global solver paths GUROBI_PATH, ILOG_CPLEX_PATH, TOMLAB_PATH and
%       MOSEK_PATH when ENV_VARS.STATUS is 0, from (1) the solver folder at a standard location
%       when it is already on the MATLAB path ('*---'), (2) another MATLAB path entry naming
%       the solver ('-*--'), (3) the environment variable of the solver ('--*-'), or (4) the
%       solver folder at a standard location ('---*'), and then sets ENV_VARS.STATUS to 1.
%     - The function is QUARANTINED (Constitution III-Defects, quarantine in back-fill
%       campaigns): the independent review (T027/T028) showed that the documented call
%       configEnvVars(printLevel) stops with an error when the global ENV_VARS has no STATUS
%       field, although line 33 evidently means to configure the paths in that case, so this
%       file makes no assertion about the function. The wave version of this test (git
%       history) made the result machine-independent (fake HOME with solver folders, solver
%       path entries removed, solver environment variables set by the test) and checked the
%       four methods and STATUS 1; it is the starting point once the defect is fixed.
%
% Function under test:
%     src/base/solvers/init/configEnvVars.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; fake solver folders in a tempname folder.
%
% Coverage exemptions:
%     every line - configEnvVars is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers, independent review T027/T028). Before the
%     quarantine the test exempted lines 59, 201 (Windows only), 290, 292, 306 and 308
%     (Windows and macOS folder names).
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The call stops with an error when ENV_VARS.STATUS is not set
%       SEVERITY: error
%       TRIGGER: configEnvVars(printLevel) when the global ENV_VARS has no field STATUS; for
%         example clear global ENV_VARS; configEnvVars(0) (ENV_VARS = []), or global ENV_VARS;
%         ENV_VARS = struct('printLevel', 0); configEnvVars(0)
%       OBSERVED: (R2025a, 2026-11-17) "Dot indexing is not supported for variables of this
%         type." (MATLAB:structRefFromNonStruct) for ENV_VARS = [], and "Unrecognized field
%         name "STATUS"." (MATLAB:nonExistentField) for the struct, both at line 33:
%         exist('ENV_VARS.STATUS', 'var') is always 0 (ENV_VARS.STATUS is not a variable
%         name), so the first test of line 33 never holds and ENV_VARS.STATUS is always read
%       EXPECTED: the solver paths configured, as the first test of line 33 (STATUS not yet
%         set) intends; the USAGE configEnvVars(printLevel) states no condition on ENV_VARS
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
%     - Converted to the quarantine layout after the independent review (T027/T028), 2026-11-17.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testConfigEnvVars'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
