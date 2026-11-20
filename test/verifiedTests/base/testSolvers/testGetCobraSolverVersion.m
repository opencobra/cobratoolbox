% The COBRAToolbox: testGetCobraSolverVersion.m
%
% Purpose:
%     - getCobraSolverVersion(solverName, printLevel, rootPathSolver) reads the version of a solver
%       from the installation path stored in the solver's global path variable (ILOG_CPLEX_PATH,
%       GUROBI_PATH, MOSEK_PATH) or, for TOMLAB, from `ver('tomlab')`, and returns it as text
%       ('' when it cannot tell, 'undetermined' when the path does not have the expected form).
%     - The function is QUARANTINED (Constitution III-Defects, quarantine in back-fill
%       campaigns): the independent review (T027/T028) showed that the documented input
%       rootPathSolver has no effect, so this file makes no assertion about the function. The
%       pilot version of this test (git history) set the global path variables to hand-built
%       paths whose version is known and checked every pattern and fallback, the TOMLAB branch
%       and the initCobraToolbox branch; it is the starting point once the defect is fixed (its
%       call with a third argument and its "printLevel 1 (the default)" section followed the
%       code, see the two entries below).
%
% Function under test:
%     src/base/solvers/getSetSolver/getCobraSolverVersion.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model and no solver (paths are hand-built; nothing is solved).
%
% Coverage exemptions:
%     every line - getCobraSolverVersion is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers, independent review T027/T028). Before the
%     quarantine the test reached every executable line.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The documented input rootPathSolver has no effect
%       SEVERITY: unusable-option
%       TRIGGER: getCobraSolverVersion(solverName, printLevel, rootPathSolver) with a third
%         argument; for example global GUROBI_PATH; GUROBI_PATH = '';
%         getCobraSolverVersion('gurobi', 0, '/opt/gurobi1103/linux64/matlab')
%       OBSERVED: (R2025a, 2026-11-17) '' for GUROBI_PATH = '', and '950' for GUROBI_PATH =
%         '/opt/gurobi950/linux64/matlab' with the same third argument: rootPathSolver is only
%         defaulted (lines 38-40) and then overwritten (lines 88, 91, 94); the version always
%         comes from the global path variable
%       EXPECTED: the version detected from the given solver installation path (INPUT
%         rootPathSolver: "Path to the solver installation"), e.g. '1103'
%       LINES: 38-40, 88, 91, 94
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-13.
%     - Converted to the quarantine layout after the independent review (T027/T028), 2026-11-17.
%     - Help text of getCobraSolverVersion corrected to match the code (feature 20261120-151023-doc-matches-code), 2026-11-20.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testGetCobraSolverVersion'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
