% The COBRAToolbox: testDuals.m
%
% Purpose:
%     - make sure that the duals returned from solveCobraLP and
%       solveCobraQP have the same sign
%
% Authors:
%     - original version: Laurent Heirendt, March 2018
%

global CBTDIR

% save the current path
currentDir = pwd;

% define the solver packages to be used to run this test
solverPkgs = {'gurobi', 'mosek', 'ibm_cplex', 'tomlab_cplex', 'glpk'};

% define a tolerance
tol = 1e-4;

% define an LP problem
% Dummy Model
% http://www2.isye.gatech.edu/~spyros/LP/node2.html
LPproblem.c = [200; 400];
LPproblem.A = [1 / 40, 1 / 60; 1 / 50, 1 / 50];
LPproblem.b = [1; 1];
LPproblem.lb = [0; 0];
LPproblem.ub = [1; 1];
LPproblem.osense = -1;
LPproblem.csense = ['L'; 'L'];

QPproblem = LPproblem;
QPproblem.F = zeros(size(LPproblem.A,2));

% test if the signs returned from solveCobraLP and solverCobraQP are the same
% for a dummy problem
for k = 1:length(solverPkgs)

    % change the solver
    solverLP = changeCobraSolver(solverPkgs{k}, 'LP', 0);
    solverQP = changeCobraSolver(solverPkgs{k}, 'QP', 0);

    if solverLP && solverQP
        fprintf(' Testing testDuals with %s ... ', solverPkgs{k});

        % obtain the solution
        solQP = solveCobraQP(QPproblem);
        solLP = solveCobraLP(LPproblem);

        % test the sign of the ojective value
        assert(norm(solQP.obj + solLP.obj) < tol) %QP is always a minimisation, and thus will return the minimal value

        % test the sign of the duals
        assert(norm(solQP.dual - solLP.dual) < tol)

        % test the sign of reduced costs
        assert(norm(solQP.rcost - solLP.rcost) < tol)

        % print an exit message
        fprintf(' Done.\n');
    end
end

% test if the dual signs are the same for all the supported solvers
% supported solvers: ibm_cplex, tomlab_cplex, gurobi, mosek
% Note: for this part of the test, at least 2 of the supported
% solvers must be supported

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

solverCounter = 0;

for k = 1:length(solverPkgs)

    % change the solver
    solverQP = changeCobraSolver(solverPkgs{k}, 'QP', 0);

    if solverQP

        fprintf([' Testing the signs for ' solverPkgs{k} ' ...\n']);

        % increase the solverCounter
        solverCounter = solverCounter + 1;

        % obtain a new solution with the next solver
        solQP = solveCobraQP(QPproblem);

        % store a reference solution fromt the previous solver
        if solverCounter == 1
            refSolQP = solQP;
            refSolverName = solverPkgs{k};
            fprintf([' > The reference solver is ' refSolverName '.\n']);
        end

        % only solve a problem if there is already at least 1 solver
        if solverCounter > 1

            % check the sign of the duals
            assert(norm(solQP.dual - refSolQP.dual) < tol)

            % check the sign of the reduced costs
            assert(norm(solQP.rcost - refSolQP.rcost) < tol)

            % print out a success message
            fprintf([' > ' solverPkgs{k} ' has been tested against ' refSolverName '. Done.\n']);
        end
    end

end

% change the directory
cd(currentDir)
