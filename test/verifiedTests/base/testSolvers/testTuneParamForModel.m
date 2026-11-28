% The COBRAToolbox: testTuneParamForModel.m
%
% Purpose:
%     - tuneParamForModel converts a COBRA model to an LP problem (buildOptProblemFromModel)
%       and forwards it, with its optional inputs in order, to tuneParam, which tunes the IBM
%       ILOG CPLEX parameters. The test checks the documented requirement: without IBM CPLEX
%       the call ends with the tuneParam error "This function requires IBM ILOG CPLEX" (so the
%       model was converted and handed over), and the LP solver selection is unchanged. Where
%       IBM CPLEX works, a short tuning run must return a parameter structure.
%
% Function under test:
%     src/base/solvers/cplex/tuneParamForModel.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - solver-dependent: the real tuning needs IBM ILOG CPLEX (ibm_cplex); on a
%     machine without it the call raises tuneParam's documented error. Hand-built model.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-25.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testTuneParamForModel'));
cd(fileDir);

% declare the requirements of this test. No requirement is listed: without IBM CPLEX the
% documented error is checked, with it a short tuning run is made
prepareTest();

% the solver selection is saved and restored; the global SOLVERS (read below) is created
% by initCobraToolbox, and any global this test creates is removed at the end
globalsBefore = who('global');
initialSolverState = CobraSolverState.get();
global SOLVERS

% a small model: a -> b -> exported b, uptake of a limited to 10
model = createModel({'EX_a', 'R1', 'EX_b'}, {'', '', ''}, ...
    {' -> a[c]', 'a[c] -> b[c]', 'b[c] -> '}, 'printLevel', 0);
model.lb(1) = 0;
model.ub(1) = 10;
model = changeObjective(model, 'EX_b');

lpSolverBefore = CobraSolverState.getSolver('LP');
cplexWorks = isstruct(SOLVERS) && isfield(SOLVERS, 'ibm_cplex') && SOLVERS.ibm_cplex.working;

if ~cplexWorks
    %% without IBM CPLEX: the model reaches tuneParam, which raises its documented error
    % the exact message of tuneParam proves that the converted problem was forwarded and
    % that the CPLEX requirement stated in the help text is enforced
    assert(verifyCobraFunctionError('tuneParamForModel', 'inputs', {model}, ...
        'testMessage', 'This function requires IBM ILOG CPLEX'));
    % the optional inputs are forwarded too, with the same outcome
    assert(verifyCobraFunctionError('tuneParamForModel', 'inputs', {model, struct(), 5, 1, 0}, ...
        'testMessage', 'This function requires IBM ILOG CPLEX'));
    % tuneParam put the previous LP solver back after trying ibm_cplex
    assert(strcmp(CobraSolverState.getSolver('LP'), lpSolverBefore));
else
    %% with IBM CPLEX: a short tuning run (5 s, one repeat, silent) returns a structure
    % usable as the contFunctName argument of solveCobraLP
    optimParam = tuneParamForModel(model, struct(), 5, 1, 0);
    assert(isstruct(optimParam));
end

% leave the solver selection and the globals as they were found
CobraSolverState.restore(initialSolverState);
clear SOLVERS
globalsAfter = who('global');
newGlobals = setdiff(globalsAfter, globalsBefore);
if ~isempty(newGlobals)
    clear('global', newGlobals{:});
end

% change the directory
cd(currentDir)
