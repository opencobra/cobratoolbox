% The COBRAToolbox: testSolveCobraQP.m
%
% Purpose:
%     - testSolveCobraQP tests the SolveCobraQP function and its different methods
%
% Author:
%     - CI integration: Laurent Heirendt, April 2017
%
% Note:
%       test is performed on objective as solution can vary between machines, solver version etc..

global CBTDIR

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testSolveCobraQP'));
cd(fileDir);

% set the tolerance
tol = 1e-4;

% test solver packages
requireOneSolverOf = {'tomlab_cplex','ibm_cplex', 'gurobi'};
solverPkgs = prepareTest('needsQP',true,'requireOneSolverOf', requireOneSolverOf); 

%QP Solver test: http://tomopt.com/docs/quickguide/quickguide005.php

% set up QP problem
QPproblem.F = [8, 1; 1, 8];  % Matrix F in 1/2 * x' * F * x + c' * x
QPproblem.c = [3, -4]';  % Vector c in 1/2 * x' * F * x + c' * x
QPproblem.A = [1, 1; 1, -1];  % Constraint matrix
QPproblem.b = [5, 0]';
QPproblem.lb = [0, 0]';
QPproblem.ub = [inf, inf]';
QPproblem.x0 = [0, 1]';  % starting point
QPproblem.osense = 1;
QPproblem.csense = ['L'; 'E'];

for k = 1:length(solverPkgs.QP)

    % change the COBRA solver (LP)
    solverOK = changeCobraSolver(solverPkgs.QP{k}, 'QP', 0);

    if solverOK

        fprintf('   Running testSolveCobraQP using %s ... ', solverPkgs.QP{k});

        QPsolution = solveCobraQP(QPproblem, 'printLevel', 0);

        % Check QP results with expected answer.
        assert(any(abs(QPsolution.obj + 0.0278)  < tol & abs(QPsolution.full - 0.0556) < [tol; tol]));

        if strcmp(solverPkgs{k}, 'ibm_cplex') && isunix
            % Note: On windows, the timelimit parameter has no effect
            % test IBM-Cplex-specific parameters. No good example for testing this. Just test time limit
            QPsolution = solveCobraQP(QPproblem, struct('timelimit', 0.0), 'printLevel', 0);
            % no solution because zero time is given and cplex status = 11
            assert(isempty(QPsolution.full) & isempty(QPsolution.obj) & QPsolution.origStat == 11)
        end

        % output a success message
        fprintf('Done.\n');
    end
end

% change the directory
cd(currentDir)
