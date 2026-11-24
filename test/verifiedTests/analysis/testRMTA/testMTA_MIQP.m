% The COBRAToolbox: testMTA_MIQP.m
%
% Purpose:
%     - MTA_MIQP knocks out the given reactions of an MTA optimisation problem (lb = ub = 0),
%       solves the MIQP with solveCobraMIQP and returns the flux variables v (indices
%       idx_variables.v) and the solver solution; when no solution is returned the fluxes are
%       zero. The test checks a hand-built 3-variable MIQP whose optimum is derived by hand,
%       the same problem with a knock-out (new optimum, also derived by hand), an infeasible
%       knock-out (zero fluxes), every optional parameter, and that the returned solution
%       satisfies the constraints, bounds and integrality.
%
% Function under test:
%     src/analysis/rMTA/MTA_MIQP.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - one small MIQP per call, every available MIQP solver (gurobi here; ibm_cplex is
%     not installed on the reference machine).
%
% Coverage exemptions:
%     Line 78: unreachable by any input. solveCobraMIQP always returns a numeric stat (the
%     canonical status from mapSolverStatus), so the character-status branch of line 77 is
%     never taken.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-23.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testMTA_MIQP'));
cd(fileDir);

% the function solves an MIQP: require an MIQP solver
globalsBefore = who('global');
solvers = prepareTest('needsMIQP', true);
initialSolverState = CobraSolverState.get();

% a hand-built MIQP with variables x = [v1; v2; y], y binary:
%   min 0.5 * (v1^2 + v2^2) - 3 v1 - 2 v2 + y
%   s.t. v1 - 10 y <= 0,   0 <= v1, v2 <= 10
% By hand: with y = 1 the unconstrained minimiser v = (3, 2) is feasible, objective
% 0.5 * 13 - 9 - 4 + 1 = -5.5; with y = 0, v1 = 0 and v2 = 2, objective -2. The optimum is
% v = (3, 2), y = 1, objective -5.5 (unique: the objective is strictly convex in v).
% Knocking out v1 (index 1) forces y = 0: v = (0, 2), objective -2.
% A third row v1 + v2 >= 1 makes the knock-out of both v1 and v2 infeasible.
problem = struct();
problem.A = sparse([1, 0, -10; 1, 1, 0]);
problem.b = [0; 1];
problem.csense = ['L'; 'G'];
problem.F = sparse(diag([1, 1, 0]));
problem.c = [-3; -2; 1];
problem.lb = [0; 0; 0];
problem.ub = [10; 10; 1];
problem.vartype = 'CCB';
problem.osense = 1;
problem.idx_variables = struct('v', [1, 2], 'y_plus_F', 3, 'y_minus_F', [], ...
    'y_plus_B', [], 'y_minus_B', []);

% the optimum is a vertex/stationary point computed to the solvers' default feasibility and
% optimality tolerances (1e-9 or so); 1e-6 is well above them
tol = 1e-6;

for k = 1:numel(solvers.MIQP)
    solverName = solvers.MIQP{k};
    solverOK = changeCobraSolver(solverName, 'MIQP', 0);
    assert(solverOK == 1);
    fprintf('   Testing MTA_MIQP using %s ... \n', solverName);

    %% default parameters, no knock-out: the infinite time limit is capped at 1e75 (line 66)
    [vRes, solution] = MTA_MIQP(problem, []);
    assert(solution.stat == 1);
    assert(all(abs(vRes - [3; 2]) < tol));
    assert(abs(solution.obj - (-5.5)) < tol);
    % the solution satisfies the constraints, bounds and integrality
    x = solution.full;
    assert(x(1) - 10 * x(3) <= tol && x(1) + x(2) >= 1 - tol);
    assert(all(x >= problem.lb - tol) && all(x <= problem.ub + tol));
    assert(abs(x(3) - round(x(3))) < tol);

    %% knock-out of v1 with every optional parameter (finite time limit: line 66 skipped)
    [vRes, solution] = MTA_MIQP(problem, 1, 'numWorkers', 1, 'timeLimit', 60, ...
        'printLevel', 0, 'FORCE_CPLEX', 0);
    assert(solution.stat == 1);
    assert(all(abs(vRes - [0; 2]) < tol));
    assert(abs(solution.obj - (-2)) < tol);
    assert(abs(solution.full(3)) < tol);

    %% knock-out of v1 and v2 makes v1 + v2 >= 1 infeasible: no solution, zero fluxes
    % (lines 81-84: solution.full is empty, so the fluxes default to zero)
    [vRes, solution] = MTA_MIQP(problem, [1, 2], 'printLevel', 2);
    assert(solution.stat ~= 1);
    assert(isequal(vRes, zeros(2, 1)));
end

% restore the solver state and remove the globals created by this test
CobraSolverState.restore(initialSolverState);
newGlobals = setdiff(who('global'), globalsBefore);
if ~isempty(newGlobals)
    clear('global', newGlobals{:});
end

% change the directory
cd(currentDir)
