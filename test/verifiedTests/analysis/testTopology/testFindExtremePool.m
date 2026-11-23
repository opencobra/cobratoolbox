% The COBRAToolbox: testFindExtremePool.m
%
% Purpose:
%     - findExtremePool(model, obj, printLevel, positive, internal, solverSettings) maximises
%       obj'*x over the left null space of S (S'*x = 0, sum(x) = 1, -100 <= x <= 100, or
%       0 <= x <= 100 when positive), restricted to the stoichiometrically consistent reactions
%       when internal, and returns the solution with entries below 10*feasTol set to zero. The
%       network A + B -> AB (R1) with the exchange EX_A (A ->) has unique optima, derived by
%       hand in each section; the test checks them, S'*x = 0, sum(x) = 1, the bounds, and that
%       solver settings are passed on.
%
% Function under test:
%     src/analysis/topology/extremeRays/optimalRays/findExtremePool.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - a hand-built network of 3 metabolites and 2 reactions; an LP solver
%     (solveCobraLP), the solver that prepareTest returns.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-23.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testFindExtremePool'));
cd(fileDir);

% declare the requirements of this test: an LP solver
solvers = prepareTest('needsLP', true);

% the solver state is changed below; note the globals that exist now to remove new ones at the
% end, and save the state to restore it
globalsBefore = who('global');
initialSolverState = CobraSolverState.get();
changeCobraSolver(solvers.LP{1}, 'LP', 0);

% the default objective is random
rng(3);

% the optima are vertices with entries 0, 0.5, 100 and -99.5; an LP solver meets the
% constraints within its feasibility tolerance (1e-6 by default), so 1e-6 is used
tol = 1e-6;

% metabolites A, B, AB; reactions R1 (A + B -> AB) and EX_A (A ->)
model = struct();
model.S = sparse([-1 -1; -1 0; 1 0]);
model.SConsistentRxnBool = [true; false];

%% defaults: a random objective over the left null space of the whole S
% by hand: EX_A gives x_A = 0 and R1 gives x_AB = x_A + x_B, so sum(x) = 1 leaves the single
% point [0; 0.5; 0.5], whatever the objective
[x, sol] = findExtremePool(model);
assert(sol.stat == 1);
assert(max(abs(x - [0; 0.5; 0.5])) <= tol);
assert(max(abs(model.S' * x)) <= tol && abs(sum(x) - 1) <= tol);
% x is sol.full with entries below 10*feasTol set to zero: x_A is exactly 0
assert(x(1) == 0 && max(abs(x - sol.full)) <= 10 * getCobraSolverParams('LP', 'feasTol'));

%% internal reactions only, non-negative pools
% by hand: only R1 constrains x (x_AB = x_A + x_B); with x >= 0 and sum(x) = 1, maximising x_A
% gives x_A = 0.5, x_B = 0, x_AB = 0.5
obj = [1; 0; 0];
[x, sol] = findExtremePool(model, obj, 0, 1, 1);
assert(sol.stat == 1);
assert(max(abs(x - [0.5; 0; 0.5])) <= tol);
assert(all(x >= 0) && abs(sum(x) - 1) <= tol);
assert(abs(model.S(:, 1)' * x) <= tol);

%% internal reactions only, pools of any sign, with solver settings
% by hand: without x >= 0, x_A grows to its bound 100 and x_B = 0.5 - x_A = -99.5 (>= -100),
% x_AB = 0.5. The settings (a printLevel and a feasibility tolerance) are passed on to
% solveCobraLP as name-value pairs; an empty structure means no settings
[x, sol] = findExtremePool(model, obj, 0, 0, 1, struct('feasTol', 1e-8, 'optTol', 1e-8));
assert(sol.stat == 1);
assert(max(abs(x - [100; -99.5; 0.5])) <= tol);
assert(all(x >= -100 - tol & x <= 100 + tol));
[x, sol] = findExtremePool(model, obj, 0, 0, 1, []);
assert(sol.stat == 1 && max(abs(x - [100; -99.5; 0.5])) <= tol);

%% the whole S with pools of any sign: the same single point as with the defaults
[x, sol] = findExtremePool(model, obj, 0, 0, 0);
assert(sol.stat == 1 && max(abs(x - [0; 0.5; 0.5])) <= tol);

% restore the solver state and remove the globals created by the test
CobraSolverState.restore(initialSolverState);
newGlobals = setdiff(who('global'), globalsBefore);
for k = 1:numel(newGlobals)
    clearvars('-global', newGlobals{k});
end

% change the directory
cd(currentDir)
