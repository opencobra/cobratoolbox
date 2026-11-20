% The COBRAToolbox: testGetCobraSolverParamsOptionsForType.m
%
% Purpose:
%     - getCobraSolverParamsOptionsForType(problemType) returns the names of the solver-independent
%       parameters supported for a problem type ('LP', 'QP', 'EP', 'CLP', 'MILP', 'MIQP', 'NLP'), or,
%       for a cell array of types, the sorted union of their lists. This test pins the list of every
%       type (the lists documented in the function), the union for a cell array, and the error for
%       an unknown type.
%
% Function under test:
%     src/base/solvers/param/getCobraSolverParamsOptionsForType.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver (it only lists parameter names), hand-built inputs.
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
fileDir = fileparts(which('testGetCobraSolverParamsOptionsForType'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% the parameter names of each problem type, in the order the function documents them
expected.LP = {'multiscale', 'problemType', 'verify', 'minNorm', 'printLevel', 'primalOnly', ...
    'saveInput', 'feasTol', 'optTol', 'solver', 'debug', 'logFile'};
expected.QP = {'multiscale', 'problemType', 'verify', 'printLevel', 'saveInput', 'debug', ...
    'feasTol', 'optTol', 'logFile', 'solver'};
expected.EP = {'multiscale', 'problemType', 'verify', 'printLevel', 'debug', 'feasTol', 'optTol', ...
    'solver'};
expected.CLP = expected.EP;
expected.MILP = {'problemType', 'intTol', 'relMipGapTol', 'absMipGapTol', 'timeLimit', 'logFile', ...
    'printLevel', 'saveInput', 'feasTol', 'optTol', 'solver', 'debug'};
expected.MIQP = {'problemType', 'timeLimit', 'method', 'feasTol', 'optTol', 'intTol', ...
    'relMipGapTol', 'absMipGapTol', 'printLevel', 'saveInput', 'logFile', 'solver'};
expected.NLP = {'problemType', 'warning', 'checkNaN', 'PbName', 'iterationLimit', 'timeLimit', ...
    'logFile', 'printLevel', 'saveInput', 'solver'};
problemTypes = fieldnames(expected);

%% one problem type: its list, in the documented order (a 1 x n cell of names)

for k = 1:numel(problemTypes)
    paramNames = getCobraSolverParamsOptionsForType(problemTypes{k});
    assert(isequal(paramNames, expected.(problemTypes{k})), problemTypes{k});
end

%% a cell array of types: the sorted union of their lists, without repetitions

paramNames = getCobraSolverParamsOptionsForType({'LP', 'MILP'});
assert(isequal(paramNames, unique([expected.LP, expected.MILP])));
assert(issorted(paramNames) && numel(paramNames) == numel(unique(paramNames)));
% a cell with one type gives that type's names, sorted
assert(isequal(getCobraSolverParamsOptionsForType({'NLP'}), sort(expected.NLP)));
% all types together
assert(isequal(getCobraSolverParamsOptionsForType(problemTypes'), ...
    unique([expected.LP, expected.QP, expected.EP, expected.MILP, expected.MIQP, expected.NLP])));

%% an unknown problem type raises an error naming it

assert(verifyCobraFunctionError('getCobraSolverParamsOptionsForType', 'inputs', {'XYZ'}, ...
    'testMessage', 'Solver type XYZ is not supported by the COBRA Toolbox'));

% change the directory
cd(currentDir)
