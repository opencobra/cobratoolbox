% The COBRAToolbox: testSolveCobraLP.m
%
% Purpose:
%     - testSolveCobraLP tests the SolveCobraLP function and its different methods
%     - Also characterizes the dispatcher-level status matrix (optimal /
%       infeasible / unbounded, including gurobi barrier-without-crossover),
%       merged in from testCharacterizeSolveCobraLP.m per Constitution Principle
%       III-Naming (feature 018-test-naming-convention): one test file per
%       source function.
%
% Author:
%     - CI integration: Laurent Heirendt, February 2017
%     - Status-matrix characterization: generated for feature
%       009-fba-characterization-statusmap, 2026-07-15; merged into this file by
%       feature 018-test-naming-convention, 2026-08-17.
%
% Note:
%       test is performed on objective as solution can vary between machines, solver version etc..

global CBTDIR

%Test the requirements
if 1
    useSolversIfAvailable = {'cplex_direct', 'glpk', 'gurobi', 'ibm_cplex', 'matlab', 'mosek', ...
                             'quadMinos', 'tomlab_cplex', 'mosek_linprog', 'dqqMinos','cplexlp'}; % 'lp_solve': legacy
    excludeSolvers={'pdco'};
else
    useSolversIfAvailable = {'pdco'};
    excludeSolvers={'gurobi'};
end
       
solvers = prepareTest('needsLP',true,'useSolversIfAvailable',useSolversIfAvailable,'excludeSolvers',excludeSolvers);

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

for p = 1:length(testSuite)
    for k = 1:length(solverPkgs)

    if strcmp(solverPkgs{k},'gurobi')
        pause(0.01)
    end
    % change the COBRA solver (LP)
    solverOK = changeCobraSolver(solverPkgs{k}, 'LP', 0);

        fprintf('   Running %s with solveCobraLP using %s ... ', testSuite{p}, solverPkgs{k});

        if p == 1
            % solve LP problem printing summary information
            for printLevel = 0:3
                LPsolution = solveCobraLP(LPproblem, 'printLevel', printLevel);
            end

            assert(abs(LPsolution.obj) - 600 < tol)
            
            for i = 1:length(LPsolution.full)
                assert((abs(LPsolution.full(i) - 1) < tol))
            end
            

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


% load the ecoli_core_model
model = getDistributedModel('ecoli_core_model.mat');

% set the tolerance
params.feasTol = getCobraSolverParams('LP','feasTol');

% set pdco relative parameters
params.pdco_method = 21;
params.pdco_maxiter = 400;
params.pdco_xsize = 1;
params.pdco_zsize = 1;

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
params.feasTol = 1e-8;
params.pdco_method = 1;
params.pdco_maxiter = 400;
params.pdco_xsize = 1;
params.pdco_zsize = 1;

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
solverPkgs = {'glpk', 'matlab', 'tomlab_cplex', 'gurobi', 'mosek', 'ibm_cplex','pdco'};

%% change the COBRA solver (LP)
for k = 1:length(solverPkgs)
    solverOK = changeCobraSolver(solverPkgs{k}, 'LP', 0);

    if solverOK
        fprintf('   Running optimalityConditions tests in solveCobraLP using %s ... ', solverPkgs{k});

        assert(~verifyCobraFunctionError('solveCobraLP', 'inputs', {LPproblem}));
        fprintf(' Done.\n');
    end
end

%%
osenseStr = 'max';
minNorm = 'zero';
allowLoops = 1;
optimizeCbModel_param.zeroNormApprox = 'all';
solution = optimizeCbModel(model, osenseStr,minNorm, allowLoops, optimizeCbModel_param);
assert(solution.f0==1)
%%

%% Characterization: solveCobraLP status matrix (merged from testCharacterizeSolveCobraLP.m)
% PINS the dispatcher-level status outcomes of solveCobraLP (optimal / infeasible
% / unbounded) on a built LP problem, the status matrix the tests above do not
% assert (feature 009-fba-characterization-statusmap, W7-core / W2). Asserts
% EXISTING behaviour (Constitution Principle III characterization mode);
% canonical .stat is pinned exactly, objective within tolerance.

charTol = 1e-6;

% require an LP solver; skip cleanly otherwise
charSolverPkgs = prepareTest('needsLP', true);

charModel = buildCharToyModel();
charOptProblem = buildOptProblemFromModel(charModel);

for charK = 1:length(charSolverPkgs.LP)

    charSolverLP = charSolverPkgs.LP{charK};
    fprintf('   Characterizing solveCobraLP status matrix with %s ... ', charSolverLP);
    charSolverLPOK = changeCobraSolver(charSolverLP, 'LP', 0);

    if charSolverLPOK
        % --- OPTIMAL ---
        charSol = solveCobraLP(charOptProblem);
        assert(charSol.stat == 1);                       % canonical: optimal
        assert(abs(charSol.obj - 10) < charTol);         % objective pinned
        assert(norm(charSol.full - [10; 10; 10]) < charTol); % unique optimum

        % --- INFEASIBLE ---
        charInfProblem = charOptProblem;
        charInfProblem.lb(3) = 50;                       % demand 50 out, input capped at 10
        charSol = solveCobraLP(charInfProblem);
        assert(charSol.stat == 0);                       % canonical: infeasible

        % --- UNBOUNDED ---
        charUnbProblem = charOptProblem;
        charUnbProblem.ub = [inf; inf; inf];             % uncap the pathway
        charSol = solveCobraLP(charUnbProblem);
        assert(charSol.stat == 2);                       % canonical: unbounded

        % --- Barrier without crossover (Gurobi only) ---
        % Verify status outcomes work correctly with barrier + no crossover
        if strcmp(charSolverLP, 'gurobi')
            charBarrierParams.Method = 2;        % barrier
            charBarrierParams.Crossover = 0;     % no crossover

            % Test OPTIMAL with barrier/no-crossover
            charSolBarrier = solveCobraLP(charOptProblem, charBarrierParams);
            assert(charSolBarrier.stat == 1, 'Barrier/no-crossover should find optimal');
            assert(abs(charSolBarrier.obj - 10) < charTol, 'Barrier objective should match');

            % Test INFEASIBLE with barrier/no-crossover
            charSolBarrierInf = solveCobraLP(charInfProblem, charBarrierParams);
            assert(charSolBarrierInf.stat == 0, 'Barrier should detect infeasible correctly');

            % Test UNBOUNDED with barrier/no-crossover
            charSolBarrierUnb = solveCobraLP(charUnbProblem, charBarrierParams);
            assert(charSolBarrierUnb.stat == 2, 'Barrier should detect unbounded correctly');
        end

        fprintf('Done.\n');
    end
end

% change the directory
cd(currentDir)


function model = buildCharToyModel()
    % Tiny linear pathway A ->(R1, ub 10) -> B (R2) -> out (R3, objective).
    model = struct();
    model.rxns = {'R1'; 'R2'; 'R3'};
    model.mets = {'A'; 'B'};
    model.S = [1, -1, 0; 0, 1, -1];
    model.lb = [0; 0; 0];
    model.ub = [10; 1000; 1000];
    model.c = [0; 0; 1];
    model.b = [0; 0];
    model.csense = ['E'; 'E'];
    model.osenseStr = 'max';
end