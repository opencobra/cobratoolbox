% The COBRAToolbox: testSparseLP.m
%
% Purpose:
%     - tests the basic functionalit of sparseLP
%
% Authors:
%     - CI integration: Laurent Heirendt March 2017
%
% Note:
%     - The solver libraries must be included separately

% define global paths
global path_GUROBI

% define the path to The COBRAToolbox
pth = which('initCobraToolbox.m');
CBTDIR = pth(1:end - (length('initCobraToolbox.m') + 1));

initTest([CBTDIR, filesep, 'test', filesep, 'verifiedTests', filesep, 'testCardOpt']);

% set the tolerance
tol = 1e-8;

% define the solver packages to be used to run this test
solverPkgs = {'gurobi6'};

for k = 1:length(solverPkgs)

    % add the solver paths (temporary addition for CI)
    if strcmp(solverPkgs{k}, 'gurobi6')
        addpath(genpath(path_GUROBI));
    end

    % change the COBRA solver (LP)
    solverOK = changeCobraSolver(solverPkgs{k});

    if solverOK == 1
        fprintf('   Testing sparseLP using %s ... ', solverPkgs{k});

        %Load data
        % n = 5;
        % m = 5;
        % constraint.A = diag(ones(m,1));
        % constraint.b = ones(m,1);
        % constraint.lb = [-2 -1 -1 -2 1]';
        % constraint.ub = [-1 1 2 2 3]';
        % constraint.csense = repmat('<', 5, 1);

        n = 100;
        m = 50;
        constraint.A = rand(m,n);
        x0 = rand(n,1);
        constraint.b = constraint.A*x0;
        constraint.lb = -1000*ones(n,1);
        constraint.ub = 1000*ones(n,1);
        constraint.csense = repmat('E', m, 1);


        %Define the parameters
        params.nbMaxIteration = 1000;
        params.epsilon = 10e-6;
        params.theta   = 2;    %parameter of l0 approximation
        params.p = 0.5;


        % solution = sparseLP('exp',constraint,params);
        % solution = sparseLP('cappedL1',constraint,params);
        % solution = sparseLP('log',constraint,params);
        % solution = sparseLP('SCAD',constraint,params);
        % solution = sparseLP('lp-',constraint,params);
        solution = sparseLP('lp+',constraint,params);
        x_0 = length(find(abs(solution.x) > 10e-6));

        assert(norm(constraint.A * solution.x - constraint.b,2) < tol)
        assert(x_0 == 50);

        % output a success message
        fprintf('Done.\n');
    end

    % remove the solver paths (temporary addition for CI)
    if strcmp(solverPkgs{k}, 'gurobi6')
        rmpath(genpath(path_GUROBI));
    end
end

% change the directory
cd(CBTDIR)
