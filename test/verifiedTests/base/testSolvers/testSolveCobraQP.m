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

printLevel=0;
        
% set the tolerance
tol = 1e-4;

if 1
    % test solver packages
    useIfAvailable = {'tomlab_cplex','ibm_cplex','pdco','gurobi'};
    %useIfAvailable = {'pdco'};
    solverPkgs = prepareTest('needsQP',true,'useSolversIfAvailable', useIfAvailable,'excludeSolvers',{'qpng','dqqMinos','mosek'});
else
    % test solver packages
    %useIfAvailable = {'pdco'};
    useIfAvailable = {'tomlab_cplex','ibm_cplex', 'gurobi','qpng','ibm_cplex','mosek','pdco'};
    solverPkgs = prepareTest('needsQP',true,'useSolversIfAvailable', useIfAvailable); % 'excludeSolvers',{'gurobi'}); %not working 
end

if 0
    %when adding a new solver, it may not be working initially so it will
    %not appear in solverPkgs so bypass it temporarily to run the tests to
    %debug the interface to the solver
    %solverPkgs.QP{end}='gurobi';
    solverPkgs.QP={'gurobi'};
end

clear QPproblem QPproblem2 QPproblem3 QPproblem4 QPproblem5

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
QPproblem2.osense = 1;
QPproblem2.c = -1*[0, 0, 0]';  %Test solving maximisation of linear part
QPproblem2.A = [1, -1, -1 ; 0, 0, 1];  % Constraint matrix
QPproblem2.b = [0, 5]'; %Accumulate 5 B
QPproblem2.lb = [0, -inf, 0]';
QPproblem2.ub = [inf, inf, inf]';
QPproblem2.csense = ['E'; 'E'];


QPproblem3.F = [1, 0, 0; 0, 1, 0; 0, 0, 1];  % Matrix F in 1/2 * x' * F * x + c' * x
QPproblem3.osense = 1; 
QPproblem3.c = -1*[1, 1, 1]';  %Test solving maximisation of linear part
QPproblem3.A = [1, -1, 0 ; 0, 1, -1];  % Constraint matrix
QPproblem3.b = [0, 0]'; % Steady State
QPproblem3.lb = [0, 0, 0]';
QPproblem3.ub = [inf, inf, inf]';
QPproblem3.csense = ['E'; 'E'];

% http://www2.isye.gatech.edu/~spyros/LP/node2.html
QPproblem4.c = [200; 400];
QPproblem4.A = [1 / 40, 1 / 60; 1 / 50, 1 / 50];
QPproblem4.b = [1; 1];
QPproblem4.lb = [0; 0];
QPproblem4.ub = [1; 1];
QPproblem4.osense = -1;
QPproblem4.csense = ['L'; 'L'];
QPproblem4.F = zeros(size(QPproblem4.A,2));

% set up QP problem
QPproblem5.F = -1*[8, 1; 1, 8];  %Test solving maximisation
QPproblem5.c = [3, -4]';  % Vector c in 1/2 * x' * F * x + c' * x
QPproblem5.A = [1, 1; 1, -1];  % Constraint matrix
QPproblem5.b = [5, 0]';
QPproblem5.lb = [0, 0]';
QPproblem5.ub = [inf, inf]';
QPproblem5.x0 = [0, 1]';  % starting point
QPproblem5.osense = -1; %Maximise whole objective
QPproblem5.csense = ['L'; 'E'];


for k = 1:length(solverPkgs.QP)

    
    % change the COBRA solver (LP)
    solverOK = changeCobraSolver(solverPkgs.QP{k}, 'QP', 0);

    if solverOK

        fprintf('   Running testSolveCobraQP using %s ... ', solverPkgs.QP{k});
       fprintf('\n')
        QPsolution = solveCobraQP(QPproblem, 'printLevel', printLevel);

        if strcmp(solverPkgs.QP{k},'dqqMinos')
            pause(0.1)
        end
        % Check QP results with expected answer.
        assert(any(abs(QPsolution.obj + 0.0278)  < tol & abs(QPsolution.full - 0.0556) < [tol; tol]));
        
        if strcmp(solverPkgs.QP{k}, 'ibm_cplex') && isunix
            % Note: On windows, the timelimit parameter has no effect
            % test IBM-Cplex-specific parameters. No good example for testing this. Just test time limit
            QPsolution = solveCobraQP(QPproblem, struct('timelimit', 0.0), 'printLevel', printLevel);
            % no solution because zero time is given and cplex status = 11
            assert(isempty(QPsolution.full) & isnan(QPsolution.obj) & QPsolution.origStat == 11)
        end
        
        QPsolution2 = solveCobraQP(QPproblem2,'printLevel', printLevel);
        if ~strcmp(solverPkgs.QP{k},'gurobi')
            assert(abs(QPsolution2.obj - 37.5 / 2) < tol); %Objective value
            assert(all( abs(QPsolution2.full - [2.5;-2.5;5]) < tol)); % Flux distribution
        else
            assert(abs(QPsolution2.obj - 25) < tol); %Objective value
            assert(all( abs(QPsolution2.full - [5;0;5]) < tol)); % Flux distribution
        end
        
        %Test solving maximisation of linear part
        QPsolution3 = solveCobraQP(QPproblem3,'printLevel', printLevel);
        assert(all(abs(QPsolution3.full - 1)< tol)); %We optimize for 0.5x^2 not x^2
        
        
        QPsolution4 = solveCobraQP(QPproblem4,'printLevel', printLevel);
        if ~strcmp(solverPkgs.QP{k},'gurobi')
            %QPsolution4.obj
            %QPsolution4.full
            assert(abs(QPsolution4.obj - 600)< tol);
        else
            %QPsolution4.obj
            %QPsolution4.full
            assert(abs(QPsolution4.obj - 20000)< tol);
        end
        
        %Test solving maximisation of whole function
        QPsolution5 = solveCobraQP(QPproblem5,'printLevel', printLevel);
        %QPsolution5.obj
        %QPsolution5.full
        assert(abs(QPsolution5.obj - 2.3065e-09)< tol);
        
    end
end
fprintf('...Done.\n\n');
% change the directory
cd(currentDir)
