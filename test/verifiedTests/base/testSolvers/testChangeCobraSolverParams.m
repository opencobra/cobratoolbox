% The COBRAToolbox: testChangeCobraSolverParams.m
%
% Purpose:
%     - changeCobraSolverParams(solverType, paramName, paramValue) sets one field of the
%       global solver parameters of a problem type (CBT_<solverType>_PARAMS, through
%       CobraSolverState) when the name is one of the parameters that
%       getCobraSolverParamsOptionsForType lists for that type, and returns true; the
%       deprecated name objTol is set as optTol with a warning; any other name raises an
%       error. This test sets parameters of several types, checks that the other fields are
%       kept, the objTol alias and its warning, and the errors. Expected values are the
%       values set (exact) and the parameter lists of getCobraSolverParamsOptionsForType.
%       The solver state is saved with CobraSolverState.get and restored at the end; the
%       global variables that did not exist before the test are removed.
%
% Function under test:
%     src/base/solvers/param/changeCobraSolverParams.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; the global solver parameters are set and restored.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The error for a parameter that is not allowed always names LP solvers
%       SEVERITY: cosmetic
%       TRIGGER: changeCobraSolverParams('MILP', 'minNorm', 1)
%       OBSERVED: the error message is 'Parameter name minNorm not allowed for LP solvers'
%       EXPECTED: a message naming the solver type given, MILP
%       LINES: 85
%     - DEFECT: solverType is documented as optional with default 'LP' but cannot be omitted
%       SEVERITY: cosmetic
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

% save the global variables and the solver state; both are restored at the end
globalsBefore = who('global');
solverStateBefore = CobraSolverState.get();

%% an allowed LP parameter is set and the other LP parameters are kept

assert(changeCobraSolverParams('LP', 'feasTol', 1e-9) == true);
lpParams = CobraSolverState.getParams('LP');
% the value is stored as given (exact)
assert(lpParams.feasTol == 1e-9);
assert(changeCobraSolverParams('LP', 'printLevel', 3));
lpParams = CobraSolverState.getParams('LP');
assert(lpParams.printLevel == 3 && lpParams.feasTol == 1e-9);
% a char value (logFile) is stored as well
assert(changeCobraSolverParams('LP', 'logFile', 'lp.log'));
lpParams = CobraSolverState.getParams('LP');
assert(strcmp(lpParams.logFile, 'lp.log'));

%% parameters of other problem types change only the global of that type

lpParamsBefore = CobraSolverState.getParams('LP');
assert(changeCobraSolverParams('MILP', 'relMipGapTol', 1e-5));
assert(changeCobraSolverParams('NLP', 'iterationLimit', 50));
milpParams = CobraSolverState.getParams('MILP');
nlpParams = CobraSolverState.getParams('NLP');
assert(milpParams.relMipGapTol == 1e-5 && nlpParams.iterationLimit == 50);
assert(isequal(CobraSolverState.getParams('LP'), lpParamsBefore));
% every parameter listed by getCobraSolverParamsOptionsForType('QP') can be set
qpNames = getCobraSolverParamsOptionsForType('QP');
for i = 1:numel(qpNames)
    assert(changeCobraSolverParams('QP', qpNames{i}, i));
end
qpParams = CobraSolverState.getParams('QP');
assert(all(cellfun(@(name) isfield(qpParams, name), qpNames)));

%% the deprecated name objTol sets optTol and warns

lastwarn('');
assert(changeCobraSolverParams('LP', 'objTol', 1e-7));
lpParams = CobraSolverState.getParams('LP');
assert(lpParams.optTol == 1e-7 && ~isfield(lpParams, 'objTol'));
% the warning is shown (not suppressed) and recorded as the last warning
assert(strcmp(lastwarn, 'objTol being depreciated for the more standard optTol'));

%% a parameter that is not allowed for the type raises an error and changes nothing

stateBeforeError = CobraSolverState.get();
assert(verifyCobraFunctionError('changeCobraSolverParams', 'inputs', {'LP', 'intTol', 1e-6}, ...
    'testMessage', 'Parameter name intTol not allowed for LP solvers'));
% for another type, the message names LP solvers (cosmetic defect above): only the error
% itself is checked
assert(verifyCobraFunctionError('changeCobraSolverParams', 'inputs', {'MILP', 'minNorm', 1}));
% objTol for a type without optTol (NLP) is not allowed either
assert(verifyCobraFunctionError('changeCobraSolverParams', 'inputs', {'NLP', 'objTol', 1}));
assert(isequal(CobraSolverState.get(), stateBeforeError));

%% an unknown solver type raises the error of getCobraSolverParamsOptionsForType

assert(verifyCobraFunctionError('changeCobraSolverParams', 'inputs', {'XYZ', 'feasTol', 1}, ...
    'testMessage', 'Solver type XYZ is not supported by the COBRA Toolbox'));

% restore the solver state and remove the global variables created by the test
CobraSolverState.restore(solverStateBefore);
assert(isequal(CobraSolverState.get(), solverStateBefore));
newGlobals = setdiff(who('global'), globalsBefore);
for i = 1:numel(newGlobals)
    clearvars('-global', newGlobals{i});
end

% change the directory
cd(currentDir)
