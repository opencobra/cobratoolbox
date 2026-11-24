% The COBRAToolbox: testGetCobraSolver.m
%
% Purpose:
%     - getCobraSolver(solverType, validate) returns the solver selected for a problem type
%       (the global CBT_<type>_SOLVER) and, when validate is true, validates it with
%       changeCobraSolver. The function is QUARANTINED (Constitution III-Defects, quarantine in
%       back-fill campaigns): three documented call forms stop with an error (the documented
%       default solverType, the documented type 'all', and validate given as false with two
%       outputs); no assertion about the function is made. Every src/ call passes 'LP' or 'QP'
%       with validate omitted or 1 (SteadyCom, optimizeWBModel; 2026-11-23), so no caller
%       reaches the defects.
%
% Function under test:
%     src/base/solvers/getSetSolver/getCobraSolver.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - reads and validates the selected solver (validation solves a small LP).
%
% Coverage exemptions:
%     every line - getCobraSolver is quarantined for the defects below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The documented default solverType LP is not implemented
%       SEVERITY: error
%       TRIGGER: solverName = getCobraSolver()
%       OBSERVED: (R2025a, 2026-11-23) "Not enough input arguments." (MATLAB:minrhs) at line 31;
%         the help text says solverType is optional with default LP
%       EXPECTED: the LP solver name, as getCobraSolver('LP') returns ('gurobi' in the same session)
%       LINES: 31
%     - DEFECT: The documented solverType all returns no solver name
%       SEVERITY: error
%       TRIGGER: solverName = getCobraSolver('all')
%       OBSERVED: (R2025a, 2026-11-23) "Output argument "solverName" (and possibly others) not
%         assigned a value in the execution with "getCobraSolver" function."
%         (MATLAB:unassignedOutputs); the switch has no case for 'all'
%       EXPECTED: the solver names for all problem types, as the help text documents 'all'
%       LINES: 31-47
%     - DEFECT: validate given as false leaves solverOK unassigned
%       SEVERITY: error
%       TRIGGER: [solverName, solverOK] = getCobraSolver('LP', false)
%       OBSERVED: (R2025a, 2026-11-23) "Output argument "solverOK" (and possibly others) not
%         assigned a value in the execution with "getCobraSolver" function."
%         (MATLAB:unassignedOutputs); solverOK = NaN is set only when validate is omitted
%       EXPECTED: solverName 'gurobi' and solverOK NaN, as the help text documents for false
%       LINES: 26-29
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-23.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testGetCobraSolver'));
cd(fileDir);

% declare the requirements of this test. The function is quarantined and is not called, so
% none is listed; the call is the standard opening of a COBRA test and the place where a
% requirement would be added once the defects are fixed
prepareTest();

% change the directory
cd(currentDir)
