% The COBRAToolbox: testSolveCobraCPLEX.m
%
% Purpose:
%     - testSolveCobraCPLEX tests the solveCobraCPLEX function and its different methods
%
% Author:
%     - Laurent Heirendt, November 2017
%

prepareTest('requiredSolvers',{'ibm_cplex'}) %Could this also use tomlab cplex??

global CBTDIR

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testSolveCobraCPLEX'));
cd(fileDir);

% change the solver
% Note: test for tomlab_cplex needs to be implemented
solverOK = changeCobraSolver('ibm_cplex');

% define tolerance
tol = 1e-6;

if solverOK
    % read the model
    model = getDistributedModel('ecoli_core_model.mat');

    % obtain the solution with optimizeCbModel
    solOptCbModel = optimizeCbModel(model);

    fprintf(' > Testing solveCobraCPLEX with standard parameters ... ');

    % test with default parameters
    sol = solveCobraCPLEX(model);

    % assert the solution status
    assert(sol.origStat == 1 && solOptCbModel.origStat == 1)

    % assert the equivalency of the objective value
    assert(abs(sol.obj - solOptCbModel.obj) < tol)

    % assert the full solution
    assert(norm(sol.full - solOptCbModel.full) < tol)

    fprintf(' Done.\n');

    % printLevel test
    for printLevel = 0:3
        fprintf([' > Testing solveCobraCPLEX with printLevel = ' num2str(printLevel) ' ... ']);

        sol = solveCobraCPLEX(model, printLevel);

        % assert the solution status
        assert(sol.origStat == 1 && solOptCbModel.origStat == 1)

        % assert the equivalency of the objective value
        assert(abs(sol.obj - solOptCbModel.obj) < tol)

        % assert the full solution
        assert(norm(sol.full - solOptCbModel.full) < tol)
        fprintf(' Done.\n');
    end

    % test the conflictResolve
    for conflictResolve = 0:1
        fprintf([' > Testing solveCobraCPLEX with conflictResolve = ' num2str(conflictResolve) ' ... ']);

        sol = solveCobraCPLEX(model, printLevel, [], conflictResolve);

        % assert the solution status
        assert(sol.origStat == 1 && solOptCbModel.origStat == 1)

        % assert the equivalency of the objective value
        assert(abs(sol.obj - solOptCbModel.obj) < tol)

        % assert the full solution
        assert(norm(sol.full - solOptCbModel.full) < tol)
        fprintf(' Done.\n');
    end

    % test if the conflict resolution file is created
    model = createToyModelForAltOpts();

    % flip the lower bound to yield an infeasible problem
    model.lb = -model.lb;

    % solve the infeasible problem
    solution = solveCobraCPLEX(model);
    assert(solution.origStat == 3 && solution.stat == 0);

    % solve the infeasible problem and output a conflict resolution file
    sol = solveCobraCPLEX(model, 2, [], 1);

    % check for the existence of the conflict resolution file
    assert(exist('COBRA_CPLEX_conflict_file.txt', 'file') == 2)
    assert(exist('CPLEX_conflict_file.txt', 'file') == 2)

    % remove conflict files
    delete 'COBRA_CPLEX_conflict_file.txt'
    delete 'CPLEX_conflict_file.txt'
end

cd(currentDir);