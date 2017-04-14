% The COBRAToolbox: testSparseLP.m
%
% Purpose:
%     - tests the basic functionalit of sparseLP
%
% Authors:
%     - CI integration: Laurent Heirendt March 2017
%

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testSparseLP'));
cd(fileDir);

% set the tolerance
tol = 1e-8;

% define the solver packages to be used to run this test
solverPkgs = {'tomlab_cplex', 'gurobi6', 'glpk'};

% vector of approximations for sparseLP
approxVect = {'exp', 'cappedL1', 'log', 'SCAD', 'lp-', 'lp+'};

for k = 1:length(solverPkgs)

    % change the COBRA solver (LP)
    solverOK = changeCobraSolver(solverPkgs{k}, 'LP', 0);

    if solverOK == 1
        fprintf('   Testing sparseLP using %s ... \n', solverPkgs{k});

        % define the parameters
        params.nbMaxIteration = 1000;
        params.epsilon = 1e-6;
        params.theta = 2; %parameter of l0 approximation
        params.p = 0.5;

        for testCase = 1:2

            % define the model for the various test cases
            if testCase == 1  % feasible problem
                n = 100;
                m = 50;
                constraint.A = rand(m,n);
                x0 = rand(n,1);
                constraint.b = constraint.A*x0;
                constraint.lb = -1000*ones(n,1);
                constraint.ub = 1000*ones(n,1);
                constraint.csense = repmat('E', m, 1);
            elseif testCase == 2  % infeasible problem
                n = 5;
                m = 5;
                constraint.A = diag(ones(m,1));
                constraint.b = ones(m,1);
                constraint.lb = [-2 -1 -1 -2 1]';
                constraint.ub = [-1 1 2 2 3]';
                constraint.csense = repmat('<', 5, 1);
            end

            % loop through the various approxiations
            for i = 1:length(approxVect)
                fprintf('   -- testCase %i with approximation: %s ... ', testCase, approxVect{i});

                if testCase == 1
                    solution = sparseLP(approxVect{i}, constraint, params);
                    x_0 = length(find(abs(solution.x) > 1e-6));

                    assert(norm(constraint.A * solution.x - constraint.b, 2) < tol);
                    assert(x_0 == 50);
                elseif testCase == 2
                    try
                        solution = sparseLP(approxVect{i}, constraint, params);
                    catch ME
                        assert(length(ME.message) > 0)
                    end
                end

                % output a success message
                fprintf('Done.\n');
            end
        end

        % output a success message
        fprintf('Done.\n');
    end
end

% change the directory
cd(currentDir)
