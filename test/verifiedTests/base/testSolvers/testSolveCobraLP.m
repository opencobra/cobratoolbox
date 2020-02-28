% The COBRAToolbox: testSolveCobraLP.m
%
% Purpose:
%     - testSolveCobraLP tests the SolveCobraLP function and its different methods
%
% Author:
%     - CI integration: Laurent Heirendt, February 2017
%
% Note:
%       test is performed on objective as solution can vary between machines, solver version etc..

global CBTDIR

%Test the requirements
useSolversIfAvailable = {'cplex_direct', 'glpk', 'gurobi', 'ibm_cplex', 'matlab', 'mosek', ...
            'pdco', 'quadMinos', 'tomlab_cplex', 'mosek_linprog', 'dqqMinos'}; % 'lp_solve': legacy
solvers = prepareTest('needsLP',true,'useSolversIfAvailable',useSolversIfAvailable);

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testSolveCobraLP'));
cd(fileDir);

% define a dummy model: http://www2.isye.gatech.edu/~spyros/LP/node2.html
LPproblem.c = [200; 400];
LPproblem.A = [1 / 40, 1 / 60; 1 / 50, 1 / 50];
LPproblem.b = [1; 1];
LPproblem.lb = [0; 0];
LPproblem.ub = [1; 1];
LPproblem.osense = -1;
LPproblem.csense = ['L'; 'L'];

% set the tolerance
tol = 1e-4;

% test solver packages
solverPkgs = solvers.LP;

% list of tests
testSuite = {'dummyModel', 'ecoli'};

for k = 1:length(solverPkgs)

    % change the COBRA solver (LP)
    solverOK = changeCobraSolver(solverPkgs{k}, 'LP', 0);

    for p = 1:length(testSuite)
        fprintf('   Running %s with solveCobraLP using %s ... ', testSuite{p}, solverPkgs{k});

        if p == 1
            % solve LP problem printing summary information
            for printLevel = 0:3
                LPsolution = solveCobraLP(LPproblem, 'printLevel', printLevel);
            end

            for i = 1:length(LPsolution.full)
                assert((abs(LPsolution.full(i) - 1) < tol))
            end
            assert(abs(LPsolution.obj) - 600 < tol)

        elseif p == 2
            % solve th ecoli_core_model (csense vector is missing)
            % Note: this is explicitly a load, to test missing csense vector compensation
            load([getDistributedModelFolder('ecoli_core_model.mat') filesep 'ecoli_core_model.mat'], 'model');

            % solveCobraLP
            solution_solveCobraLP = solveCobraLP(model);

            % optimizeCbModel
            solution_optimizeCbModel = optimizeCbModel(model);

            % compare both solution objects
            assert(abs(solution_solveCobraLP.obj-solution_optimizeCbModel.f) < 1e-6);
            assert(isequal(solution_solveCobraLP.full, solution_optimizeCbModel.x))
            assert(isequal(solution_solveCobraLP.rcost, solution_optimizeCbModel.w))
            assert(isequal(solution_solveCobraLP.dual, solution_optimizeCbModel.y))
            assert(solution_solveCobraLP.stat == solution_optimizeCbModel.stat)
        end

        % output a success message
        fprintf('Done.\n');
    end
end


% define solver packages
solverPkgs={'cplex_direct', 'glpk', 'gurobi', 'ibm_cplex', 'matlab', 'mosek', ...
            'pdco', 'quadMinos', 'tomlab_cplex', 'mosek_linprog', 'dqqMinos'}; % 'lp_solve': legacy

% load the ecoli_core_model
model = getDistributedModel('ecoli_core_model.mat');

% set the tolerance
tol = 1e-6;

% set pdco relative parameters
params.feasTol = 1e-12;
params.pdco_method = 2;
params.pdco_maxiter = 400;
params.pdco_xsize = 1e-1;
params.pdco_zsize = 1e-1;

% run LP with various solvers
[~, all_obj] = runLPvariousSolvers(model, solverPkgs, params);

% test here the output
assert(abs(min(all_obj) - max(all_obj)) < tol)

clear model
model.c = [200; 400];
model.S = [1/40, 1/60; 1/50, 1/50];
model.b = [1; 1];
model.lb = [0; 0];
model.ub = [1; 1];
model.osense = -1;
model.csense = ['L'; 'L'];

% set pdco relative parameters
params.feasTol = 1e-12;
params.pdco_method = 1;
params.pdco_maxiter = 400;
params.pdco_xsize = 1e-12;
params.pdco_zsize = 1e-12;

[~, all_obj] = runLPvariousSolvers(model, solverPkgs, params);
assert(abs(min(all_obj) - max(all_obj)) < tol)

clear model
% test constraints with csense 'G'
% max x
% s.t. -x >= -1,
%      0 <= x <= 100
model.S = -1;
model.b = -1;
model.csense = 'G';
model.lb = 0;
model.ub = 100;
model.c = 1;
model.osense = -1;
[~, all_obj] = runLPvariousSolvers(model, solverPkgs, params);
assert(abs(min(all_obj)) < tol + 1.0 & abs(max(all_obj)) < tol + 1.0)

% only test the solvers for which the optimality conditions have been implemented
solverPkgs = {'pdco', 'glpk', 'matlab', 'tomlab_cplex', 'gurobi', 'mosek', 'ibm_cplex'};

% change the COBRA solver (LP)
for k = 1:length(solverPkgs)
    solverOK = changeCobraSolver(solverPkgs{k}, 'LP', 0);

    if solverOK
        fprintf('   Running optimalityConditions tests in solveCobraLP using %s ... ', solverPkgs{k});

        assert(~verifyCobraFunctionError('solveCobraLP', 'inputs', {LPproblem}));
        fprintf(' Done.\n');
    end
end

% change the directory
cd(currentDir)
