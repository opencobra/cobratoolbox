% The COBRAToolbox: testChangeCobraSolverParams.m
%
% Purpose:
%     - changeCobraSolverParams(solverType, paramName, paramValue) sets one field of the
%       global solver parameters of a problem type (CBT_<solverType>_PARAMS, through
%       CobraSolverState) when the name is one of the parameters that
%       getCobraSolverParamsOptionsForType lists for that type, and returns true; the
%       deprecated name objTol is set as optTol with a warning; any other name raises an
%       error. Once the defect is fixed, the test should set parameters of several types and
%       check that the other fields are kept, the objTol alias and its warning, and the
%       errors. Expected values are the values set (exact) and the parameter lists of
%       getCobraSolverParamsOptionsForType. The solver state is saved with
%       CobraSolverState.get and restored at the end; the global variables that did not exist
%       before the test are removed.
%       Quarantined: no behaviour of changeCobraSolverParams is asserted until the
%       unusable-option defect below is fixed; this file only opens the test.
%
% Function under test:
%     src/base/solvers/param/changeCobraSolverParams.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; the global solver parameters are set and restored.
%
% Coverage exemptions:
%     every line - changeCobraSolverParams is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The error for a parameter that is not allowed always names LP solvers
%       SEVERITY: cosmetic
%       TRIGGER: changeCobraSolverParams('MILP', 'minNorm', 1)
%       OBSERVED: the error message is 'Parameter name minNorm not allowed for LP solvers'
%       EXPECTED: a message naming the solver type given, MILP
%       LINES: 85
%     - DEFECT: solverType is documented as optional with default 'LP' but cannot be omitted
%       SEVERITY: unusable-option
%       TRIGGER: changeCobraSolverParams('feasTol', 1e-9)
%       OBSERVED: error 'Solver type feasTol is not supported by the COBRA Toolbox' (the first
%         input is always the solver type; USAGE lists three inputs)
%       EXPECTED: per INPUTS ("solverType: Solver type, 'LP' or 'MILP' (opt, default, 'LP')"),
%         the LP parameter feasTol set; the USAGE line and the code agree that the input is
%         required, so the INPUTS text is the likely error
%       LINES: 80
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testChangeCobraSolverParams'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
