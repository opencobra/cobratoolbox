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

% % define the solver packages to be used to run this test
% if 0
%     solverPkgs = {'cplexlp', 'ibm_cplex', 'mosek',  'tomlab_cplex', 'glpk'};
% else
%     solverPkgs = {'cplexlp', 'ibm_cplex', 'mosek',  'tomlab_cplex', 'glpk', 'gurobi'};
%     %TODO something is wrong with the way gurobi's QP solver returns the optimal
%     %objective for a QP with either a missing linear or missing quadratic
%     %objective
%     %https://support.gurobi.com/hc/en-us/community/posts/360057936252-Optimal-objective-from-a-simple-QP-problem-
% end

if 1
    useSolversIfAvailable = {'ibm_cplex', 'tomlab_cplex'};
    excludeSolvers={'pdco','gurobi'};
else
   useSolversIfAvailable = {'ibm_cplex', 'tomlab_cplex','pdco'};
    excludeSolvers={'gurobi'};
end
       
solverPkgs = prepareTest('needsLP',true,'useSolversIfAvailable',useSolversIfAvailable,'excludeSolvers',excludeSolvers);

solverPkgs.LP
solverPkgs.QP

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
if 0
    QPproblem.F = zeros(2,2);
else
    QPproblem.F = sparse(2,2);
end

% test if the signs returned from solveCobraLP and solverCobraQP are the same
% for a dummy problem
for k = 1:length(solverPkgs.QP)

    % change the solver
    solverLP = changeCobraSolver(solverPkgs.LP{k}, 'LP', 0);
    solverQP = changeCobraSolver(solverPkgs.QP{k}, 'QP', 0);

    if solverLP && solverQP
        fprintf(' Testing testDuals with %s ... ', solverPkgs.LP{k});

        % obtain the solution
        solQP = solveCobraQP(QPproblem);
        solLP = solveCobraLP(LPproblem);

        % test the value of the ojective value
        assert(norm(solQP.obj - solLP.obj,inf) < tol)

        % test the sign of the duals
        assert(norm(solQP.dual - solLP.dual,inf) < tol)

        % test the sign of reduced costs
        assert(norm(solQP.rcost - solLP.rcost,inf) < tol)

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
    solverQP = changeCobraSolver(solverPkgs.QP{k}, 'QP', 0);

    if solverQP

        % increase the solverCounter
        solverCounter = solverCounter + 1;

        % obtain a new solution with the next solver
        solQP = solveCobraQP(QPproblem);

        % store a reference solution from the previous solver
        if solverCounter == 1

            refSolverName = solverPkgs.QP{k};
            fprintf([' > The reference solver is ' refSolverName '.\n']);
            refSolQP = solQP;
        end

        % only solve a problem if there is already at least 1 solver
        if solverCounter > 1

            fprintf([' Testing the solutions for ' solverPkgs.QP{k} ' ...\n']);
            
            % test the value of the objective
            assert(norm(solQP.obj - refSolQP.obj,inf) < tol)
        
            % check the sign of the duals
            assert(norm(solQP.dual - refSolQP.dual) < tol)

            % check the sign of the reduced costs
            assert(norm(solQP.rcost - refSolQP.rcost) < tol)

            % print out a success message
            fprintf([' > ' solverPkgs.QP{k} ' has been tested against ' refSolverName '. Done.\n']);
        end
    end

end

% change the directory
cd(currentDir)
