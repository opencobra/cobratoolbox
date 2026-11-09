% The COBRAToolbox: testSolveCobraMIQP.m
%
% Purpose:
%     - testSolveCobraMIQP tests the SolveCobraMIQP function and its different methods
%     - Solver names that the interface refuses (an unknown name) are selected with
%       validationLevel -1: no solver is imitated, the branch does not call one. All other
%       branches run with the real gurobi.
%
% Function under test:
%     src/base/solvers/solveCobraMIQP.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - toy MIQP, gurobi.
%
% Coverage exemptions:
%     Lines 107-112: defective input skipped, see the defect below.
%     Lines 124-161: tomlab_cplex branch, solver not available.
%     Lines 170-225: gurobi_mex branch, solver not available.
%     Line 285: unreachable, exist('resultgurobi.pi') looks for a name that no variable can have.
%     Lines 294-319: ibm_cplex branch, solver not available.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The option saveInput stops the call
%       SEVERITY: unusable-option
%       TRIGGER: the parameter saveInput
%       OBSERVED: the function saves a variable MILPproblem, while its input is MIQPproblem, so
%         the call stops with Variable MILPproblem not found
%       EXPECTED: MIQPproblem saved to the file, and the solve going on
%       LINES: 107-112
%
% Author:
%     - CI integration: Laurent Heirendt, April 2017
%     - Coverage completed by feature 20261104-115314-test-coverage-100, 2026-11-04.
%
% Note:
%       test is performed on objective as solution can vary between machines, solver version etc..

global CBTDIR
global SOLVERS 

%Do this test for all available MIQP solvers
UseIfAvailable = fieldnames(SOLVERS); %We will simply use all available solvers that are MIQP solvers.
solvers = prepareTest('needsMIQP',true,'useSolversIfAvailable',UseIfAvailable);
initialSolverState = CobraSolverState.get();

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testSolveCobraMIQP'));
cd(fileDir);

% set the tolerance
tol = 1e-4;

% MIQP Solver test: http://tomopt.com/docs/quickguide/quickguide006.php

% set up MIQP problem.
MIQPproblem.c    = [-6 0]';
MIQPproblem.F    = [4 -2;-2 4];
MIQPproblem.A    = [1 1];
MIQPproblem.b  = 1.9;
MIQPproblem.lb  = [0 0]';
MIQPproblem.ub  = [Inf Inf]';
MIQPproblem.osense = 1;
MIQPproblem.csense = 'L';
MIQPproblem.vartype = ['I'; 'C'];

for k = 1:length(solvers.MIQP)

    % change the COBRA solver (LP)
    solverOK = changeCobraSolver(solvers.MIQP{k}, 'MIQP', 0);

    fprintf('   Running testSolveCobraQP using %s ... ', solvers.MIQP{k});
    
    MIQPsolution = solveCobraMIQP(MIQPproblem, 'printLevel', 0);
    
    % Check MIQP results with expected answer.
    assert(abs(MIQPsolution.obj + 4.5) < tol & all(abs(MIQPsolution.full - [1;0.5]) < tol));
    
    % output a success message
    fprintf('Done.\n');

end

%% Interface branches: solver state, inputs, the status of each available solver
coverageError = [];
try
    coverageSolvers = prepareTest('needsMIQP', true, 'useSolversIfAvailable', {'gurobi'});
    isAvailable = @(solverName) any(strcmp(coverageSolvers.MIQP, solverName));

    %% an explicit solver state selects the solver of one call only
    if isAvailable('gurobi')
        changeCobraSolver('nonsense', 'MIQP', 0, -1);
        explicitState = CobraSolverState.get();
        explicitState.solver.MIQP = 'gurobi';
        solution = solveCobraMIQP(MIQPproblem, 'cobraSolverState', explicitState);
        assert(strcmp(solution.solver, 'gurobi') && abs(solution.obj + 4.5) < tol);
        assert(strcmp(CobraSolverState.getSolver('MIQP'), 'nonsense'));
    end

    %% solver names that the interface refuses without calling a solver
    refusedSolvers = {'', 'There is no solver for MIQP problems available'; ...
                      'nonsense', 'Unknown solver: nonsense'};
    for i = 1:size(refusedSolvers, 1)
        changeCobraSolver(refusedSolvers{i, 1}, 'MIQP', 0, -1);
        assertErrorContains(@() solveCobraMIQP(MIQPproblem), refusedSolvers{i, 2});
    end

    %% gurobi
    if isAvailable('gurobi')
        changeCobraSolver('gurobi', 'MIQP', 0);

        % printing, and an integrality tolerance above the lower limit of gurobi
        solution = solveCobraMIQP(MIQPproblem, 'printLevel', 1, 'intTol', 1e-6);
        assert(solution.stat == 1 && abs(solution.obj + 4.5) < tol);

        % an empty csense means equalities: x1 + x2 = 1.9 with x1 integer and x2 continuous
        noSense = MIQPproblem;
        noSense.csense = '';
        solution = solveCobraMIQP(noSense);
        assert(solution.stat == 1 && abs(sum(solution.full) - 1.9) < tol);
        assert(abs(solution.full(1) - round(solution.full(1))) < tol);
    end
catch coverageError
end
CobraSolverState.restore(initialSolverState);
if ~isempty(coverageError)
    rethrow(coverageError);
end

% change the directory
cd(currentDir)

function assertErrorContains(functionHandle, expectedText)
    % The call has to stop with an error whose message contains expectedText.
    threw = false;
    try
        functionHandle();
    catch ME
        threw = true;
        assert(contains(ME.message, expectedText), 'unexpected error: %s', ME.message);
    end
    assert(threw, 'no error was thrown');
end

