% The COBRAToolbox: testLeakTest.m
%
% Purpose:
%     - leakTest(model, params, printLevel) solves min ||v||_0 - ||s||_0 subject to
%       S*v + s = 0 and lb <= v <= ub with optimizeCardinality and returns v, s and the status.
%       The test checks, for every available LP solver, that the returned pair satisfies the
%       constraints and reaches the cardinality optimum derived by hand for a 3 x 4 network,
%       and that an invalid problem (lb > ub) returns the status of optimizeCardinality with
%       empty v and s.
%
% Function under test:
%     src/reconstruction/modelGeneration/stoichConsistency/leakTest.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - cardinality optimisation (LP sub-problems) on a hand-built 3 x 4 network.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The zero norms of v and s are printed whatever printLevel
%       SEVERITY: cosmetic
%       TRIGGER: leakTest(model, struct('epsilon', 1e-4), 0)
%       OBSERVED: (R2025a, gurobi, 2026-11-25) '||v||_0 =1' and '||s||_0 =2' are printed
%         although printLevel = 0
%       EXPECTED: no output for printLevel = 0
%       LINES: 63-64
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-25.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testLeakTest'));
cd(fileDir);

% declare the requirements: an LP solver for the sub-problems of optimizeCardinality
solvers = prepareTest('needsLP', true, 'useSolversIfAvailable', {'gurobi', 'glpk'});

% the solver is changed below: save the solver state and the global variables that exist now
globalsBefore = who('global');
initialSolverState = CobraSolverState.get();

% hand-built network: metabolites A, B, C; R1: A -> B, R2: B -> C, R3: C -> A, R4: A -> 2 C,
% all reversible within [-10, 10]
model.S = sparse([-1 0 1 -1; 1 -1 0 0; 0 1 -1 2]);
model.lb = -10 * ones(4, 1);
model.ub = 10 * ones(4, 1);
model.mets = {'A'; 'B'; 'C'};
model.rxns = {'R1'; 'R2'; 'R3'; 'R4'};
params.epsilon = 1e-4;

% the cardinality loop is a local method and its sub-problems are LPs: residuals and bounds to
% 1e-6 (100 times the default feasibility tolerance), and entries below 1e-6 count as zero
tol = 1e-6;

for k = 1:length(solvers.LP)
    changeCobraSolver(solvers.LP{k}, 'LP', 0);
    fprintf('   Testing leakTest using %s ... \n', solvers.LP{k});

    %% a solution is found (printLevel 1 prints the counts): constraints and optimum
    % S*v + s = 0 and the bounds hold. The optimum of nnz(v) - nnz(s) is -1: v = 0 gives 0;
    % every column of S has two non-zeros, so one reaction gives s with two non-zeros (-1),
    % and -2 would need s with three non-zeros from a single column, which none has
    rng(0);
    solution = leakTest(model, params, 1);
    assert(solution.stat == 1);
    assert(isequal(size(solution.v), [4, 1]) && isequal(size(solution.s), [3, 1]));
    assert(norm(model.S * solution.v + solution.s, inf) < tol);
    assert(all(solution.v >= model.lb - tol) && all(solution.v <= model.ub + tol));
    assert(nnz(abs(solution.v) > tol) - nnz(abs(solution.s) > tol) == -1);

    %% the same problem with printLevel 0: same invariants
    rng(0);
    solution = leakTest(model, params, 0);
    assert(solution.stat == 1);
    assert(norm(model.S * solution.v + solution.s, inf) < tol);
    assert(nnz(abs(solution.v) > tol) - nnz(abs(solution.s) > tol) == -1);

    %% an invalid problem (lb > ub for R1): optimizeCardinality's status -1, v and s empty
    invalidModel = model;
    invalidModel.lb(1) = 5;
    invalidModel.ub(1) = 1;
    rng(0);
    solution = leakTest(invalidModel, params, 0);
    assert(solution.stat == -1);
    assert(isempty(solution.v) && isempty(solution.s));
end

% restore the solver state, remove the global variables created here and change the directory
CobraSolverState.restore(initialSolverState);
newGlobals = setdiff(who('global'), globalsBefore);
for i = 1:numel(newGlobals)
    clearvars('-global', newGlobals{i});
end
cd(currentDir)
