% The COBRAToolbox: testFastSNP.m
%
% Purpose:
%     - fastSNP(model, parameters) finds a sparse basis of the internal cycles (Fast-SNP, Saa
%       and Nielsen 2016): it repeatedly solves the LP min sum|v| s.t. S_int*v = 0, v within
%       the direction of the bounds (|v| <= 1000), w'(I - P)v >= 1e-3 (or <= -1e-3) for a random
%       weight w and the projection P on the vectors found, and adds the sparser feasible
%       solution, scaled to a smallest non-zero entry of magnitude 1, until both LPs are
%       infeasible. Exchange reactions (one non-zero coefficient) are left out. The cycles of the
%       hand-built networks are derived by hand: the test checks that N spans them (rank, S*N =
%       0, zero rows outside the cycles), that each column respects the reaction directions and
%       is scaled as documented, the branch that picks a column, and the reported parameters.
%       The weights are random (rng fixed), so the basis is checked by these invariants, not
%       entry by entry, except where the cycle space is one-dimensional.
%
% Function under test:
%     src/analysis/thermo/thermoFBA/fastSNP.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - hand-built networks of 3 to 9 reactions; an LP solver (solveCobraLP), the solver
%     that prepareTest returns.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The weight vector is returned in resInfo.weights, not in the documented resInfo.weight
%       SEVERITY: cosmetic
%       TRIGGER: [N, resInfo] = fastSNP(model) for any model
%       OBSERVED: (R2025a, gurobi, 2026-11-23) resInfo has the field weights and no field weight
%       EXPECTED: the help text (OUTPUT resInfo) documents the field .weight
%       LINES: 130
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-23.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testFastSNP'));
cd(fileDir);

% declare the requirements of this test: an LP solver
solvers = prepareTest('needsLP', true);

% the solver state is changed below; note the globals that exist now to remove new ones at the
% end, and save the state to restore it
globalsBefore = who('global');
initialSolverState = CobraSolverState.get();
changeCobraSolver(solvers.LP{1}, 'LP', 0);

% the weights are random
rng(42);

% the LP solutions are scaled by their smallest entry; entries equal up to the solver's
% rounding (feasTol 1e-6 relative to fluxes near 1e-3) differ by far less than 1e-6 after
% scaling, so 1e-6 is used for entries; S*N for integer S and such N vanishes to 1e-9
tol = 1e-6;
feasTol = getCobraSolverParams('LP', 'feasTol');

%% two forward cycles beside exchanges and dead ends
% metabolites A, B, C, D, E; reactions EX_A (A <=>), R1 (A -> B), R2 (B -> C), R3 (C <=> A),
% R4 (A -> C), R5 (B <=> D), EX_D (D <=>), R6 (B <=> 1e-4 E), EX_E (E <=>).
% By hand: the internal cycles are R1 + R2 + R3 and R4 + R3, both with R3 forward, so the cycle
% space has dimension 2 and every cycle is non-negative; R5 and R6 end in D and E and carry no
% cyclic flux. In the first iteration w > 0, so w'v <= -1e-3 is infeasible for non-negative v and
% the first solution is taken (line 111); the loop ends at the third iteration
model = struct();
model.S = sparse([-1 -1  0  1 -1  0  0  0     0;    % A
                   0  1 -1  0  0 -1  0 -1     0;    % B
                   0  0  1 -1  1  0  0  0     0;    % C
                   0  0  0  0  0  1 -1  0     0;    % D
                   0  0  0  0  0  0  0  1e-4 -1]);  % E
model.lb = [-1000; 0; 0; -1000; 0; -1000; -1000; -1000; -1000];
model.ub = 1000 * ones(9, 1);
[N, resInfo] = fastSNP(model);
assert(isequal(size(N), [9, 2]) && rank(N) == 2);
assert(max(max(abs(model.S * N))) <= 1e-9);
% only R1-R4 are in cycles; the columns are non-negative and scaled to a smallest entry of 1
assert(~any(any(N([1, 6:9], :))));
assert(all(N(:) >= 0));
for j = 1:size(N, 2)
    assert(abs(min(N(N(:, j) ~= 0, j)) - 1) <= tol);
end
% each column is one of the two elementary cycles (the sparsest feasible solutions)
cycles = [0 1 1 1 0 0 0 0 0; 0 0 0 1 1 0 0 0 0]';
for j = 1:size(N, 2)
    assert(min(max(abs(cycles - N(:, j)), [], 1)) <= tol);
end
% the reported parameters (the weights have one entry per internal reaction, R1-R6 here)
assert(resInfo.iter == 3 && numel(resInfo.iterTime) == 3 && all(resInfo.iterTime >= 0));
assert(isequal(size(resInfo.weights), [1, 6]) && all(resInfo.weights > 0 & resInfo.weights < 1));
assert(resInfo.M == 1e3 && resInfo.tol0 == 1e-9 && resInfo.epsilon == 1e-3);
assert(resInfo.feasTol == feasTol);

%% a cycle that can only run backwards: the second LP gives the column (line 109)
% A <=> B <=> C <=> A with bounds [-1000, 0]: the only cycle is -(R1 + R2 + R3), so w'v >= 1e-3
% is infeasible for w > 0 and the column is the solution of w'v <= -1e-3, scaled to -[1; 1; 1]
backwardModel = struct();
backwardModel.S = sparse([-1 0 1; 1 -1 0; 0 1 -1]);
backwardModel.lb = -1000 * ones(3, 1);
backwardModel.ub = zeros(3, 1);
[N, resInfo] = fastSNP(backwardModel);
assert(isequal(size(N), [3, 1]) && max(abs(N + 1)) <= tol);
assert(resInfo.iter == 2);

%% a reversible cycle: both LPs are feasible and the sparser solution is kept (line 114)
% both solutions are +-[1; 1; 1] (equally sparse), and the first, [1; 1; 1], is kept; solver
% parameters are passed on to solveCobraLP
reversibleModel = backwardModel;
reversibleModel.ub = 1000 * ones(3, 1);
[N, resInfo] = fastSNP(reversibleModel, 'printLevel', 0);
assert(isequal(size(N), [3, 1]) && max(abs(N - 1)) <= tol);
assert(resInfo.iter == 2);

%% a network without cycles gives an empty basis after one iteration
% EX_A (A <=>), R1 (A <=> B), EX_B (B <=>): R1 alone cannot form a cycle
acyclicModel = struct();
acyclicModel.S = sparse([-1 -1 0; 0 1 -1]);
acyclicModel.lb = -1000 * ones(3, 1);
acyclicModel.ub = 1000 * ones(3, 1);
[N, resInfo] = fastSNP(acyclicModel);
assert(isequal(size(N), [3, 0]));
assert(resInfo.iter == 1 && isequal(size(resInfo.weights), [1, 1]));

% restore the solver state and remove the globals created by the test
CobraSolverState.restore(initialSolverState);
newGlobals = setdiff(who('global'), globalsBefore);
for k = 1:numel(newGlobals)
    clearvars('-global', newGlobals{k});
end

% change the directory
cd(currentDir)
