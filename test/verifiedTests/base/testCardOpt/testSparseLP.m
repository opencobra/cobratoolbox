% The COBRAToolbox: testSparseLP.m
%
% Purpose:
%     - tests the basic functionalit of sparseLP
%
% Function under test:
%     src/base/solvers/cardOpt/sparseLP/sparseLP.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - hand-built LPs, every available LP solver among gurobi and glpk.
%
% Coverage exemptions:
%     Lines 98-99: unreachable, statements after the error call of line 97.
%     Lines 103-104: unreachable, statements after the error call of line 102.
%     Lines 108-109: unreachable, statements after the error call of line 107.
%     Lines 113-114: unreachable, statements after the error call of line 112.
%     Lines 118-119: unreachable, statements after the error call of line 117.
%     Lines 124-125: unreachable, statements after the error call of line 123.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - CI integration: Laurent Heirendt March 2017
%     - Coverage completed by feature 20261104-115314-test-coverage-100, 2026-11-04.
%

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testSparseLP'));
cd(fileDir);

% require an LP solver; skip gracefully if none is available
solvers = prepareTest('needsLP', true, 'useSolversIfAvailable', {'gurobi', 'glpk'});
initialSolverState = CobraSolverState.get();

% the random problems must be reproducible
rng(0);

% set the tolerance
tol = 1e-8;

% define the solver packages to be used to run this test
solverPkgs = solvers.LP;

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
                    solution = sparseLP(constraint, approxVect{i}, params);
                    x_0 = length(find(abs(solution.x) > 1e-6));

                    assert(norm(constraint.A * solution.x - constraint.b, 2) < tol);
                    assert(x_0 == 50);
                elseif testCase == 2
                    try
                        solution = sparseLP(constraint, approxVect{i}, params);
                    catch ME
                        assert(length(ME.message) > 0)
                    end
                end

                % output a success message
                fprintf('Done.\n');
            end
        end

        % a small feasible problem with a sparse solution: 3 rows and 6 columns
        small = struct('A', sparse([1, 0, 0, 1, 1, 0; 0, 1, 0, 1, 0, 1; 0, 0, 1, 0, 1, 1]), ...
            'b', [1; 2; 3], 'lb', -10 * ones(6, 1), 'ub', 10 * ones(6, 1), 'csense', repmat('E', 3, 1));

        % default approximation and default parameters
        solution = sparseLP(small);
        assert(solution.stat == 1);
        assert(norm(small.A * solution.x - small.b, inf) < tol);
        assert(nnz(abs(solution.x) > 1e-6) <= 3);

        % an empty parameter structure gets the same defaults
        [solution, nIterations] = sparseLP(small, 'cappedL1', struct());
        assert(solution.stat == 1 && nIterations >= 0);
        assert(norm(small.A * solution.x - small.b, inf) < tol);

        % all the approximations: the best one is returned, with at most as many nonzeros as
        % the same call with each approximation alone
        [solution, nIterations, bestApprox] = sparseLP(small, 'all');
        assert(solution.stat == 1 && nIterations >= 0);
        assert(any(strcmp(bestApprox, {'exp', 'log', 'SCAD', 'lp-', 'lp+', 'l1', 'cappedL1'})));
        assert(norm(small.A * solution.x - small.b, inf) < tol);
        feasTol = getCobraSolverParams('LP', 'feasTol');
        bestAlone = sparseLP(small, bestApprox);
        assert(nnz(abs(solution.x) > feasTol) == nnz(abs(bestAlone.x) > feasTol));

        % an infeasible problem: x(1) = 1 outside the bounds. The sub-problem fails, the point
        % is empty and, with all the approximations, nothing is selected
        infeasible = struct('A', sparse(1, 1, 1), 'b', 1, 'lb', -0.5, 'ub', 0.5, 'csense', 'E');
        solution = sparseLP(infeasible, 'cappedL1');
        assert(isempty(solution.x) && solution.stat ~= 1);
        [solution, nIterations, bestApprox] = sparseLP(infeasible, 'all');
        assert(isempty(solution.x) && solution.stat == 0 && nIterations == 0 && isempty(bestApprox));

        % output a success message
        fprintf('Done.\n');
    end
end

%% missing inputs and an unknown approximation are refused
required = struct('A', 1, 'b', 1, 'lb', 0, 'ub', 1, 'csense', 'E');
requiredFields = {'A', 'b', 'lb', 'ub', 'csense'};
messages = {'Error:LHS matrix is not defined', 'RHS vector is not defined', ...
    'Lower bound vector is not defined', 'Upper bound vector is not defined', ...
    'Constraint sense vector is not defined'};
for i = 1:numel(requiredFields)
    assert(verifyCobraFunctionError('sparseLP', 'inputs', {rmfield(required, requiredFields{i})}, ...
        'testMessage', messages{i}));
end
assert(verifyCobraFunctionError('sparseLP', 'inputs', {required, 'nonsense'}, ...
    'testMessage', 'Approximation is not valid'));

% leave the solver selection as it was found
CobraSolverState.restore(initialSolverState);

% change the directory
cd(currentDir)
