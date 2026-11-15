% The COBRAToolbox: testParseSolverParameters.m
%
% Purpose:
%     - parseSolverParameters(problemType, varargin) returns the COBRA parameters of a
%       problem type (param) and the remaining, solver-specific parameters
%       (solverOnlyParams). The defaults come from getCobraSolverParams with the structure
%       form struct('solver', <selected solver>), whose documented priority is
%       "paramStructure > solver type paramStructure (the global CBT_<type>_PARAMS) >
%       default values set within getCobraSolverParams". The optional inputs are
%       parameter/value pairs, optionally with one parameter structure first or last; a
%       field of that structure wins over a pair with the same name (comment of line 73).
%       The test sets the solver state by hand (CobraSolverState) to known values, derives
%       every expected value from that state, the documented defaults of
%       getCobraSolverParams (lines 90-116 there) and the parameter lists of
%       getCobraSolverParamsOptionsForType, and restores the state at the end.
%
% Function under test:
%     src/base/solvers/param/parseSolverParameters.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; the solver selection and parameter globals are set to
%     hand-built values through CobraSolverState and restored.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The invalid-parameters error message shows literal \n instead of line breaks
%       SEVERITY: cosmetic
%       TRIGGER: parseSolverParameters('LP', 'feasTol', 1e-3, 'x')
%       OBSERVED: the message reads "Invalid Parameters supplied.\nParameters have to be
%         supplied ..." with the two characters \n (MATLAB R2025a); error is called with
%         a single argument, so escape sequences are not converted
%       EXPECTED: three lines, as the '\n' in the message text intends
%       LINES: 54-56
%     - DEFECT: param does not hold the additional (solver-specific) parameters
%       SEVERITY: cosmetic
%       TRIGGER: [param, solverOnlyParams] = parseSolverParameters('LP', struct('Method', 2))
%       OBSERVED: param has only the COBRA fields of the LP type; Method is only in
%         solverOnlyParams
%       EXPECTED: per OUTPUTS, param is "The COBRA Toolbox specific parameters for this
%         problem type given the provided parameters, plus any additional parameters";
%         every caller in src/ (solveCobraLP, parseCobraVarargin, ...) takes the solver
%         parameters from solverOnlyParams, so the header is the likely error
%       LINES: 91-102
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testParseSolverParameters'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% save the solver state and the list of globals; CobraSolverState creates the 14 solver
% globals if they do not exist yet
globalsBefore = who('global');
savedSolverState = CobraSolverState.get();

% hand-built solver state: a selected LP solver name and one global LP parameter
% override; the MILP type has a selected solver and no global parameters
testState = savedSolverState;
testState.solver.LP = 'lpSolverOfTheTest';
testState.params.LP = struct('feasTol', 1e-9, 'printLevel', 2);
testState.solver.MILP = 'milpSolverOfTheTest';
testState.params.MILP = [];
CobraSolverState.restore(testState);

% expected LP parameters without optional inputs: the fields of
% getCobraSolverParamsOptionsForType('LP'), with the defaults of getCobraSolverParams,
% feasTol and printLevel from the global LP parameters and solver from the selected
% LP solver (struct('solver', defaultSolver) of line 39)
expectedLP = struct('multiscale', 0, 'problemType', 'LP', 'verify', 0, 'minNorm', [], ...
    'printLevel', 2, 'primalOnly', 0, 'saveInput', [], 'feasTol', 1e-9, 'optTol', 1e-6, ...
    'solver', 'lpSolverOfTheTest', 'debug', 0, 'logFile', []);

%% no optional input: defaults, global parameters and selected solver
% proves lines 30-40, 85-88 and the default branch of the loop (line 101); isequal
% compares the values exactly (they are copied, not computed) and ignores field order
[param, solverOnlyParams] = parseSolverParameters('LP');
assert(isequal(param, expectedLP));
assert(isequal(solverOnlyParams, struct()));

%% a problem type without global parameters uses the defaults of getCobraSolverParams
% MILP has no global parameters (CBT_MILP_PARAMS = []), so every value is the documented
% default except solver, which is the selected MILP solver
[param, solverOnlyParams] = parseSolverParameters('MILP');
expectedMILP = struct('problemType', 'MILP', 'intTol', 1e-12, 'relMipGapTol', 1e-12, ...
    'absMipGapTol', 1e-12, 'timeLimit', 1e36, 'logFile', [], 'printLevel', 0, ...
    'saveInput', [], 'feasTol', 1e-6, 'optTol', 1e-6, 'solver', 'milpSolverOfTheTest', ...
    'debug', 0);
assert(isequal(param, expectedMILP));
assert(isequal(solverOnlyParams, struct()));

%% parameter structure only: COBRA fields go to param, other fields to solverOnlyParams
% one input is odd, so the structure is taken from the end (lines 46-47, 59); feasTol
% overrides the global value (lines 95-98); Method stays a solver-only field. Whether
% param also holds Method is not asserted (cosmetic defect in the header)
[param, solverOnlyParams] = parseSolverParameters('LP', struct('feasTol', 1e-4, 'Method', 2));
assert(param.feasTol == 1e-4);
assert(isequal(solverOnlyParams, struct('Method', 2)));
assert(param.optTol == expectedLP.optTol && param.printLevel == 2);

%% parameter/value pairs only: an empty structure collects them (lines 63-64, 68-77)
% the COBRA parameters optTol and solver override the defaults; Presolve is solver-only
[param, solverOnlyParams] = parseSolverParameters('LP', 'optTol', 1e-8, 'solver', 'otherSolver', 'Presolve', 0);
expectedPairs = expectedLP;
expectedPairs.optTol = 1e-8;
expectedPairs.solver = 'otherSolver';
assert(isequal(param, expectedPairs));
assert(isequal(solverOnlyParams, struct('Presolve', 0)));

%% pairs followed by a parameter structure
% the last input is a structure, so it is removed from the pairs (line 59) and the pair
% feasTol is added to it
[param, solverOnlyParams] = parseSolverParameters('LP', 'feasTol', 1e-5, struct('Method', 1));
assert(param.feasTol == 1e-5);
assert(isequal(solverOnlyParams, struct('Method', 1)));

%% a parameter structure followed by pairs
% the last input is not a structure, so the first one is taken (lines 50-52)
[param, solverOnlyParams] = parseSolverParameters('LP', struct('Method', 1), 'feasTol', 1e-5);
assert(param.feasTol == 1e-5);
assert(isequal(solverOnlyParams, struct('Method', 1)));
expectedBoth = expectedLP;
expectedBoth.feasTol = 1e-5;
assert(isequal(param, expectedBoth));

%% a pair that duplicates a field of the structure: the structure wins, with a warning
% line 82; the documented rule (comment of line 73) is that the struct overrides the pair.
% The warning is not suppressed; lastwarn reads its text
lastwarn('');
[param, solverOnlyParams] = parseSolverParameters('LP', 'feasTol', 1e-5, struct('feasTol', 1e-7));
warningText = lastwarn();
assert(param.feasTol == 1e-7);
assert(isequal(solverOnlyParams, struct()));
assert(contains(warningText, 'Duplicate parameter feasTol'));

%% invalid inputs raise errors
% an odd number of inputs with no structure first or last (line 54; only the error is
% asserted, not its message: see the cosmetic defect in the header)
assert(verifyCobraFunctionError('parseSolverParameters', 'inputs', {'LP', 'feasTol', 1e-3, 'x'}));
% a parameter name that is not text (line 71)
assert(verifyCobraFunctionError('parseSolverParameters', 'inputs', {'LP', {1}, 2}, ...
    'testMessage', 'Parameters have to be supplied as ''parameterName''/Value pairs'));
% a parameter name that is not a valid field name (line 79)
assert(verifyCobraFunctionError('parseSolverParameters', 'inputs', {'LP', 'not valid', 2}, ...
    'testMessage', 'All parameters have to be valid matlab field names. not valid is not a valid field name'));
% an unknown problem type is rejected by getCobraSolverParamsOptionsForType (line 30)
assert(verifyCobraFunctionError('parseSolverParameters', 'inputs', {'XYZ'}, ...
    'testMessage', 'Solver type XYZ is not supported by the COBRA Toolbox'));

% restore the solver state and remove the globals this test created
CobraSolverState.restore(savedSolverState);
newGlobals = setdiff(who('global'), globalsBefore);
for iGlobal = 1:numel(newGlobals)
    clear('global', newGlobals{iGlobal});
end

% change the directory
cd(currentDir)
