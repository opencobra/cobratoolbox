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
solverPkgs = {'mosek', 'gurobi', 'ibm_cplex', 'tomlab_cplex', 'glpk'};

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
% logical conditions
for k = 1:length(solverPkgs)

    solverLP = changeCobraSolver(solverPkgs{k}, 'LP', 0);
    solverQP = changeCobraSolver(solverPkgs{k}, 'QP', 0);

    if solverLP && solverQP
        fprintf(' Testing testDuals with %s ... ', solverPkgs{k});

        % obtain the solution
        solQP = solveCobraQP(QPproblem);
        solLP = solveCobraLP(LPproblem);

        % test the sign of the ojective value
        assert(norm(solQP.obj - solLP.obj) < tol)

        % test the sign of the duals
        assert(norm(solQP.dual - solLP.dual) < tol)

        % test the sign of reduced costs
        assert(norm(solQP.rcost - solLP.rcost) < tol)

        % print an exit message
        fprintf(' Done.\n');
    end
end
% change the directory
cd(currentDir)
