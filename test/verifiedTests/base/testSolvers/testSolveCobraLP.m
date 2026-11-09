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
%     - Solver names that the interface refuses or writes to a file (opti, lindo, mps, an unknown
%       name) are selected with validationLevel -1: no solver is imitated, the branch does not
%       call one. All other branches run with the real gurobi, glpk and pdco.
%
% Function under test:
%     src/base/solvers/solveCobraLP.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - toy LPs and ecoli_core_model, gurobi, glpk and pdco.
%
% Coverage exemptions:
%     Line 175: unreachable, ~find(regexp(...)) is empty or false, so the condition is never true.
%     Lines 183-184: defective input skipped, see the defect below.
%     Line 247: ibm_cplex branch, solver not available.
%     Line 273: unreachable, needs a MATLAB older than 8.4 and the baseline is R2024b.
%     Line 279: opti branch for Windows, OS-specific.
%     Lines 367-460: dqqMinos branch, solver not available (needs csh, not installed).
%     Lines 463-580: quadMinos branch, solver not available (needs csh, not installed).
%     Lines 650-664: lp_solve branch, solver not working on this machine.
%     Lines 667-770: mosek branch, solver not available.
%     Lines 779-820: mosek_linprog branch, solver not available.
%     Lines 847-849: unreachable, the branch of an if 1.
%     Lines 886-887: unreachable, gurobi always returns a point with the status OPTIMAL.
%     Lines 944-1025: matlab branch, linprog of the Optimization Toolbox not available.
%     Lines 1030-1039: optarrow branch, the OptArrow backend is not available.
%     Lines 1043-1106: tomlab_cplex branch, solver not available.
%     Lines 1115-1127: cplex_direct branch, solver not available.
%     Lines 1166-1244: cplexlp branch, solver not available.
%     Lines 1251-1374: ibm_cplex branch, solver not available.
%     Lines 1486-1487: unreachable, the branch of an if 0.
%     Lines 1512-1514: unreachable, the branch of an if 0.
%     Line 1532: unreachable, an empty solver name stops at line 267.
%     Lines 1550-1553: mosek_linprog and optarrow branch, only they leave the slacks unset, not available.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The option lifting stops on an undefined variable
%       SEVERITY: unusable-option
%       TRIGGER: solverParams.lifting = 1
%       OBSERVED: line 184 passes printLevel, which does not exist in this function, so the call
%         stops with Unrecognized function or variable printLevel
%       EXPECTED: the problem reformulated with problemTypeParams.printLevel
%       LINES: 183-184
%
% Author:
%     - CI integration: Laurent Heirendt, February 2017
%     - Status-matrix characterization: generated for feature
%       009-fba-characterization-statusmap, 2026-07-15; merged into this file by
%       feature 018-test-naming-convention, 2026-08-17.
%     - Coverage completed by feature 20261104-115314-test-coverage-100, 2026-11-04.
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
initialSolverState = CobraSolverState.get();

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
optimalityConditionSolvers = prepareTest('needsLP', true, 'useSolversIfAvailable', ...
    {'glpk', 'matlab', 'tomlab_cplex', 'gurobi', 'mosek', 'ibm_cplex', 'pdco'});
solverPkgs = optimalityConditionSolvers.LP;

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

%% Interface branches: solver state, inputs, the status of each available solver
% The MATLAB path is not touched here. Names of solvers that are not installed are selected with
% validationLevel -1 only where the interface refuses them without calling any solver.
coverageTol = 1e-6;
coverageDir = tempname;
mkdir(coverageDir);
coverageError = [];
try
    coverageSolvers = prepareTest('needsLP', true, 'useSolversIfAvailable', {'gurobi', 'glpk', 'pdco'});
    isAvailable = @(solverName) any(strcmp(coverageSolvers.LP, solverName));

    %% an explicit solver state selects the solver of one call only
    if isAvailable('gurobi') && isAvailable('glpk')
        changeCobraSolver('gurobi', 'LP', 0);
        explicitState = CobraSolverState.get();
        explicitState.solver.LP = 'glpk';
        solution = solveCobraLP(LPproblem, 'cobraSolverState', explicitState);
        assert(strcmp(solution.solver, 'glpk') && abs(solution.obj - 600) < tol);
        assert(strcmp(CobraSolverState.getSolver('LP'), 'gurobi'));
    end

    changeCobraSolver(coverageSolvers.LP{1}, 'LP', 0);

    %% minNorm is refused by every solver except cplex_direct
    assertErrorContains(@() solveCobraLP(LPproblem, 'minNorm', 1), 'minNorm only works for LP solver');

    %% the input is saved on request
    savedFile = fullfile(coverageDir, 'savedLP.mat');
    solveCobraLP(LPproblem, 'saveInput', savedFile);
    savedInput = load(savedFile);
    assert(isequal(savedInput.LPproblem.A, LPproblem.A) && isequal(savedInput.LPproblem.c, LPproblem.c));

    %% a sense that is not E, L or G is refused
    wrongSense = LPproblem;
    wrongSense.csense = ['L'; 'X'];
    assertErrorContains(@() solveCobraLP(wrongSense), 'Incorrect formulation of LPproblem.csense');

    %% without b a zero right hand side is assumed: only x = 0 fits the rows A*x <= 0 with x >= 0
    solution = solveCobraLP(rmfield(LPproblem, 'b'));
    assert(contains(lastwarn, 'LP problem has no defined b'));
    assert(solution.stat == 1 && abs(solution.obj) < coverageTol);

    %% solver names that the interface refuses without calling a solver
    refusedSolvers = {'', 'Default LP solver not selected'; ...
                      'lindo_new', 'The lindo interfaces are legacy interfaces'; ...
                      'lindo_old', 'The lindo interfaces are legacy interfaces'; ...
                      'lindo', 'The lindo interface is obsolete'; ...
                      'nonsense', 'Unknown solver: nonsense'; ...
                      'opti', 'OPTI is not compatible with UNIX systems'};
    for i = 1:size(refusedSolvers, 1)
        if ~isunix && strcmp(refusedSolvers{i, 1}, 'opti')
            continue
        end
        changeCobraSolver(refusedSolvers{i, 1}, 'LP', 0, -1);
        assertErrorContains(@() solveCobraLP(LPproblem), refusedSolvers{i, 2});
    end

    %% the legacy mps interface writes the problem to a file and returns nothing
    changeCobraSolver('mps', 'LP', 0, -1);
    cd(coverageDir);
    solution = solveCobraLP(LPproblem);
    assert(isempty(solution) && exist(fullfile(coverageDir, 'LP.mps'), 'file') == 2);
    cd(fileDir);

    %% glpk: an empty csense means equalities, and tolbnd replaces the feasibility tolerance
    if isAvailable('glpk')
        changeCobraSolver('glpk', 'LP', 0);
        noSense = struct('c', [1; 2], 'A', [1, 1], 'b', 1, 'lb', [0; 0], 'ub', [1; 1], ...
            'osense', -1, 'csense', '');
        solution = solveCobraLP(noSense);
        assert(solution.stat == 1 && abs(solution.obj - 2) < coverageTol);
        assert(norm(solution.full - [0; 1], inf) < coverageTol);
        solution = solveCobraLP(LPproblem, struct('tolbnd', 1e-7));
        assert(solution.stat == 1 && abs(solution.obj - 600) < tol);
    end

    %% gurobi
    if isAvailable('gurobi')
        changeCobraSolver('gurobi', 'LP', 0);

        % minimisation: the costs are positive and x >= 0
        minimisation = LPproblem;
        minimisation.osense = 1;
        solution = solveCobraLP(minimisation);
        assert(solution.stat == 1 && abs(solution.obj) < coverageTol);

        % a basis of a previous solve is accepted as a start
        solution = solveCobraLP(LPproblem, struct('Method', 0));
        withBasis = LPproblem;
        withBasis.basis = solution.basis;
        solution = solveCobraLP(withBasis, struct('Method', 0));
        assert(solution.stat == 1 && abs(solution.obj - 600) < tol);

        % the other values of Method
        for gurobiMethod = [-1, 0]
            solution = solveCobraLP(LPproblem, struct('Method', gurobiMethod));
            assert(solution.stat == 1 && abs(solution.obj - 600) < tol);
        end

        % x1 + x2 = 1 and x1 + x2 = 2: gurobi 11 answers INF_OR_UNBD from presolve and the second
        % solve tells infeasible; the native status depends on the version, the canonical one not
        infeasible = struct('c', [1; 1], 'A', [1, 1; 1, 1], 'b', [1; 2], 'lb', [-inf; -inf], ...
            'ub', [inf; inf], 'osense', 1, 'csense', ['E'; 'E']);
        solution = solveCobraLP(infeasible);
        assert(solution.stat == 0 && isempty(solution.full));

        % costs near 1e10: the stationarity residual of the diagnostic output is a rounding
        % error of about 1e-6, above the 1e-8 at which the diagnostic pauses
        largeCosts = struct('c', 1e10 * [pi; exp(1); sqrt(2)], ...
            'A', [sqrt(3), 1 / 7, 2.3; 1 / 3, sqrt(5), 1.7], 'b', [1; 2], 'lb', [0; 0; 0], ...
            'ub', [inf; inf; inf], 'osense', -1, 'csense', ['L'; 'L']);
        solution = solveCobraLP(largeCosts, 'printLevel', 3);
        assert(solution.stat == 1 && norm(solution.full - max(solution.full, 0), inf) < coverageTol);
    end

    %% pdco
    if isAvailable('pdco')
        changeCobraSolver('pdco', 'LP', 0);

        % the solver parameters given explicitly, at their default values
        pdcoParams = struct('d1', 1e-4, 'd2', 5e-4, 'x0', ones(4, 1), 'y0', ones(2, 1), ...
            'z0', ones(4, 1), 'xsize', 1, 'zsize', 1);
        solution = solveCobraLP(LPproblem, pdcoParams);
        assert(solution.stat == 1 && abs(solution.obj - 600) < 1e-2);

        % large regularisation: pdco converges to a point of its regularised problem, which
        % fails the primal and the dual optimality check of solveCobraLP
        solution = solveCobraLP(LPproblem, struct('d1', 1, 'd2', 1));
        assert(solution.stat == 1);
        assert(contains(solution.origStat, 'WARNING Primal optimality condition'));
        assert(contains(solution.origStat, 'WARNING Dual optimality condition'));

        % one iteration is not enough
        solution = solveCobraLP(LPproblem, struct('MaxIter', 1));
        assert(solution.stat == 0 && solution.origStat == 1 && isnan(solution.obj));

        % a Cholesky factorisation fails on a non-finite matrix, which the interface reports
        nonFinite = LPproblem;
        nonFinite.A(1, 1) = Inf;
        assertErrorContains(@() solveCobraLP(nonFinite, struct('MaxIter', 3, 'Method', 1)), ...
            'Cannot perform LP on a stoichiometric matrix with NaN of Inf');
    end
catch coverageError
end
cd(fileDir);
CobraSolverState.restore(initialSolverState);
rmdir(coverageDir, 's');
if ~isempty(coverageError)
    rethrow(coverageError);
end

% change the directory
cd(currentDir)


function assertErrorContains(functionHandle, expectedText)
    % The call has to stop with an error whose message contains expectedText.
    threw = false;
    try
        functionHandle();
    catch ME
        threw = true;
        assert(contains(ME.message, expectedText), 'unexpected error: %s', ME.message);
    end
    assert(threw, 'no error was thrown');
end

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