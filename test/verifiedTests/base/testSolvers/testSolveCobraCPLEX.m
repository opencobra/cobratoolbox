% The COBRAToolbox: testSolveCobraCPLEX.m
%
% Purpose:
%     - testSolveCobraCPLEX tests the solveCobraCPLEX function and its different methods
%
% Author:
%     - Laurent Heirendt, November 2017
%

global CBTDIR

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testSolveCobraCPLEX'));
cd(fileDir);

% change the solver
solverOK = changeCobraSolver('ibm_cplex');

% define tolerance
tol = 1e-6;

if solverOK
    % read the model
    model = readCbModel([CBTDIR filesep 'test' filesep 'models' filesep 'mat' filesep 'ecoli_core_model.mat']);

    % obtain the solution with optimizeCbModel
    solOptCbModel = optimizeCbModel(model);

    fprintf(' > Testing solveCobraCPLEX with standard parameters ... ');

    % test with default parameters
    sol = solveCobraCPLEX(model);

    % assert the solution status
    assert(sol.origStat == 1 && solOptCbModel.origStat == 1)

    % assert the equivalency of the objective value
    assert(abs(sol.obj - sol.obj) < tol)

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
        assert(abs(sol.obj - sol.obj) < tol)

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
        assert(abs(sol.obj - sol.obj) < tol)

        % assert the full solution
        assert(norm(sol.full - solOptCbModel.full) < tol)
        fprintf(' Done.\n');
    end
end
