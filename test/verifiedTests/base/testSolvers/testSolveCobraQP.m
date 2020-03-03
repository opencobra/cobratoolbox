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
useIfAvailable = {'tomlab_cplex','ibm_cplex', 'gurobi','qpng','ibm_cplex','mosek'};
% pdco is a normalizing solver not a general purpose QP solver, so it will
% fail the test
solverPkgs = prepareTest('needsQP',true,'useSolversIfAvailable', useIfAvailable,'excludeSolvers',{'pdco'});

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

QPproblem2.F = [1, 0, 0; 0, 1, 0; 0, 0, 1];  % Matrix F in 1/2 * x' * F * x + c' * x
QPproblem2.osense = -1; % Maximize the linear part of the objective
QPproblem2.c = [0, 0, 0]';  % Vector c in 1/2 * x' * F * x + c' * x
QPproblem2.A = [1, -1, -1 ; 0, 0, 1];  % Constraint matrix
QPproblem2.b = [0, 5]'; %Accumulate 5 B
QPproblem2.lb = [0, -inf, 0]';
QPproblem2.ub = [inf, inf, inf]';
QPproblem2.csense = ['E'; 'E'];


QPproblem3.F = [1, 0, 0; 0, 1, 0; 0, 0, 1];  % Matrix F in 1/2 * x' * F * x + c' * x
QPproblem3.osense = -1; % Maximize the linear part of the objective
QPproblem3.c = [1, 1, 1]';  % Vector c in 1/2 * x' * F * x + c' * x
QPproblem3.A = [1, -1, 0 ; 0, 1, -1];  % Constraint matrix
QPproblem3.b = [0, 0]'; % Steady State
QPproblem3.lb = [0, 0, 0]';
QPproblem3.ub = [inf, inf, inf]';
QPproblem3.csense = ['E'; 'E'];

for k = 1:length(solverPkgs.QP)

    % change the COBRA solver (LP)
    solverOK = changeCobraSolver(solverPkgs.QP{k}, 'QP', 0);

    if solverOK

        fprintf('   Running testSolveCobraQP using %s ... ', solverPkgs.QP{k});

        QPsolution = solveCobraQP(QPproblem, 'printLevel', 0);

        % Check QP results with expected answer.
        assert(any(abs(QPsolution.obj + 0.0278)  < tol & abs(QPsolution.full - 0.0556) < [tol; tol]));

        if strcmp(solverPkgs.QP{k}, 'ibm_cplex') && isunix
            % Note: On windows, the timelimit parameter has no effect
            % test IBM-Cplex-specific parameters. No good example for testing this. Just test time limit
            QPsolution = solveCobraQP(QPproblem, struct('timelimit', 0.0), 'printLevel', 0);
            % no solution because zero time is given and cplex status = 11
            assert(isempty(QPsolution.full) & isempty(QPsolution.obj) & QPsolution.origStat == 11)
        end
        QPsolution2 = solveCobraQP(QPproblem2);
        assert(abs(QPsolution2.obj - 37.5 / 2) < tol); %Objective value
        assert(all( abs(QPsolution2.full - [2.5;-2.5;5]) < tol)); % Flux distribution
        % output a success message
        
        %Test solving maximisation of linear part
        QPsolution3 = solveCobraQP(QPproblem3);
        assert(all(abs(QPsolution3.full - 1)< tol)); %We optimize for 0.5x^2 not x^2
        fprintf('Done.\n');
    end
end

% change the directory
cd(currentDir)
