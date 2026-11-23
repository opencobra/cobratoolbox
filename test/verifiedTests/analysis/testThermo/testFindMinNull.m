% The COBRAToolbox: testFindMinNull.m
%
% Purpose:
%     - findMinNull(model, formulation, parameters) finds the reactions of internal cycles and
%       the directions in which they take part (rxnInLoops, reverse and forward columns), by
%       relaxed LPs and MILPs (formulation 1, default) or by one MILP followed by LPs
%       (formulation 2), and returns a null-space basis N of the stoichiometric matrix restricted
%       to these reactions. Reactions with a coefficient below 1e-3 that are found in no cycle
%       are listed in loopInfo.ignoreRxns. The expected cycles of the hand-built networks are
%       derived by hand (see the comments of each section). Three further networks, with entries
%       0, +-1 and +-1e-4, were found by a seeded random search (2026-11-23, gurobi) because
%       their LP solutions reach the rarer checks of formulation 1 (a small-coefficient reaction
%       found in a cycle only by its own LP, lines 143-144 and 154-155, and the checks of
%       steps 7 and 9, lines 195-201 and 241-247); for them the test asserts only invariants:
%       directions allowed by the bounds, S*N = 0, and N zero outside the reactions found.
%
% Function under test:
%     src/analysis/thermo/thermoFBA/findMinNull.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - hand-built networks of 2 to 9 reactions; an LP and a MILP solver (solveCobraLP,
%     solveCobraMILP), the solver that prepareTest returns for each.
%
% Coverage exemptions:
%     None. Every executable line is reached below (lines 143-144, 154-155, 195-201 and 241-247
%     depend on which of several optimal LP solutions the solver returns; they are reached with
%     gurobi on the reference machine).
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-23.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testFindMinNull'));
cd(fileDir);

% declare the requirements of this test: an LP and a MILP solver
solvers = prepareTest('needsLP', true, 'needsMILP', true);

% the solver state is changed below; note the globals that exist now to remove new ones at the
% end, and save the state to restore it
globalsBefore = who('global');
initialSolverState = CobraSolverState.get();
changeCobraSolver(solvers.LP{1}, 'LP', 0);
changeCobraSolver(solvers.MILP{1}, 'MILP', 0);

% N comes from sparseNull (LU factors) of matrices with entries 1 and 1e-4: S*N vanishes up to
% rounding, which 1e-9 relative to the largest entry of N covers
nullTol = @(N) 1e-9 * max([1; full(abs(N(:)))]);

% checks shared by every network: sizes, directions allowed by the bounds, no exchange reaction
% (one non-zero coefficient) in a cycle, N a null-space basis supported on the reactions found
checkInvariants = @(model, rxnInLoops, N) ...
    isequal(size(rxnInLoops), [numel(model.rxns), 2]) && islogical(rxnInLoops) ...
    && ~any(rxnInLoops(:, 1) & model.lb >= 0) && ~any(rxnInLoops(:, 2) & model.ub <= 0) ...
    && ~any(any(rxnInLoops(sum(model.S ~= 0, 1)' <= 1, :))) ...
    && size(N, 1) == numel(model.rxns) ...
    && full(max([0; abs(reshape(model.S * N, [], 1))])) <= nullTol(N) ...
    && ~any(any(N(~any(rxnInLoops, 2), :)));

%% a network with two forward cycles, a dead end and an ignored small-coefficient reaction
% metabolites A, B, C, D, E; reactions EX_A (A <=>), R1 (A -> B), R2 (B -> C), R3 (C <=> A),
% R4 (A -> C), R5 (B <=> D), EX_D (D <=>), R6 (B <=> 1e-4 E), EX_E (E <=>).
% By hand: the cycles are R1 + R2 + R3 (A -> B -> C -> A) and R4 + R3 (A -> C -> A), both with
% R3 forward (its reverse, A -> C, cannot return to A: R1, R2 and R4 are irreversible); R5 and R6
% end in D and E, which no other internal reaction uses, so they carry no cyclic flux. R6 has a
% coefficient below 1e-3 and is in no cycle, so it is ignored (loopInfo.ignoreRxns). The null
% space of S restricted to R1-R4 has dimension 4 - rank 2 = 2.
model = struct();
model.rxns = {'EX_A'; 'R1'; 'R2'; 'R3'; 'R4'; 'R5'; 'EX_D'; 'R6'; 'EX_E'};
model.S = sparse([-1 -1  0  1 -1  0  0  0     0;    % A
                   0  1 -1  0  0 -1  0 -1     0;    % B
                   0  0  1 -1  1  0  0  0     0;    % C
                   0  0  0  0  0  1 -1  0     0;    % D
                   0  0  0  0  0  0  0  1e-4 -1]);  % E
model.lb = [-1000; 0; 0; -1000; 0; -1000; -1000; -1000; -1000];
model.ub = 1000 * ones(9, 1);
expectedLoops = false(9, 2);
expectedLoops(2:5, 2) = true;

for formulation = 1:2
    [rxnInLoops, N, loopInfo] = findMinNull(model, formulation);
    assert(isequal(rxnInLoops, expectedLoops));
    assert(checkInvariants(model, rxnInLoops, N));
    assert(size(N, 2) == 2 && rank(full(N)) == 2);
    assert(isequal(loopInfo.ignoreRxns(:), {'R6'}));
    % the documented constants and the timings
    assert(loopInfo.M == 100 && loopInfo.minFlux == 0.1);
    assert(all([loopInfo.nsCPU, loopInfo.nsTime, loopInfo.loopPreprocessCPU, ...
        loopInfo.loopPreprocessTime] >= 0));
end

%% the default formulation, and solver parameters as the second input
% formulation omitted or empty is formulation 1; a non-scalar second input (here the name of a
% name-value pair) is taken as the first solver parameter
[rxnInLoops, N] = findMinNull(model);
assert(isequal(rxnInLoops, expectedLoops) && checkInvariants(model, rxnInLoops, N));
[rxnInLoops, N] = findMinNull(model, []);
assert(isequal(rxnInLoops, expectedLoops) && checkInvariants(model, rxnInLoops, N));
[rxnInLoops, N] = findMinNull(model, 'printLevel', 0);
assert(isequal(rxnInLoops, expectedLoops) && checkInvariants(model, rxnInLoops, N));
[rxnInLoops, N] = findMinNull(model, 2, 'printLevel', 0);
assert(isequal(rxnInLoops, expectedLoops) && checkInvariants(model, rxnInLoops, N));

%% a reversible cycle takes part in both directions
% A <=> B <=> C <=> A: the cycle runs either way, so every reaction is in loops both ways; the
% null space is the cycle itself
reversibleModel = struct();
reversibleModel.rxns = {'R1'; 'R2'; 'R3'};
reversibleModel.S = sparse([-1 0 1; 1 -1 0; 0 1 -1]);
reversibleModel.lb = -1000 * ones(3, 1);
reversibleModel.ub = 1000 * ones(3, 1);
for formulation = 1:2
    [rxnInLoops, N, loopInfo] = findMinNull(reversibleModel, formulation);
    assert(isequal(rxnInLoops, true(3, 2)));
    assert(checkInvariants(reversibleModel, rxnInLoops, N));
    % the null vector is a multiple of [1; 1; 1]
    assert(size(N, 2) == 1 && norm(N / N(1) - 1, inf) <= 1e-12);
    assert(isempty(loopInfo.ignoreRxns));
end

%% a network whose only internal reaction is ignored: no cycle, no MILP variable
% R1 (A <=> 1e-4 B) between two exchanges carries no cyclic flux and has a small coefficient, so
% it is ignored; in formulation 2 the MILP is then built for no reaction, the solver returns no
% solution and the MILP is solved again with feasTol 1e-7 (lines 320-323), again without
% variables. No reaction is in a cycle and N has no column
ignoredModel = struct();
ignoredModel.rxns = {'EX_A'; 'R1'; 'EX_B'};
ignoredModel.S = sparse([-1 -1 0; 0 1e-4 -1]);
ignoredModel.lb = -1000 * ones(3, 1);
ignoredModel.ub = 1000 * ones(3, 1);
for formulation = 1:2
    [rxnInLoops, N, loopInfo] = findMinNull(ignoredModel, formulation);
    assert(isequal(rxnInLoops, false(3, 2)));
    assert(size(N, 1) == 3 && size(N, 2) == 0);
    assert(isequal(loopInfo.ignoreRxns(:), {'R1'}));
end

%% networks from a seeded random search that reach the rarer checks of formulation 1
% entries 0, +-1 and +-1e-4 (reactions with an entry 1e-4 have a "small" coefficient); bounds
% are +-1000 or 0. With gurobi the first network reaches lines 143-144, 154-155 and 195-199,
% the second lines 199-201 and the third lines 241-247; the results depend on which optimal LP
% solution the solver returns, so only invariants are asserted, for both formulations
randomNetworks = { ...
    {[-0.0001 -1 -1 0 1 1 0; 0 1 -1 -1 -0.0001 1 1; 1 -1 0 0 0 0 1; -1 -1 -1 0 -1 -1 0], ...
     [-1000 -1000 -1000 0 -1000 -1000 0], [1000 1000 0 1000 1000 1000 1000]}, ...
    {[0 1 1 -1 0 0 0; 0 0 -1 1 0.0001 1 -1; -1 1 -1 1 -1 0 -1; -1 1 0 1 -0.0001 -1 -0.0001], ...
     [-1000 -1000 0 -1000 -1000 -1000 -1000], [0 0 1000 0 0 1000 1000]}, ...
    {[0 0 0.0001 1 0 0.0001 0 0.0001; 0 1 -1 -1 1 -1 -1 1; -1 1 0 0.0001 -1 0 1 0; ...
      1 0 1 1 1 0 1 0; 1 -1 1 -1 -0.0001 1 1 -1], ...
     [-1000 -1000 -1000 -1000 0 -1000 -1000 -1000], [1000 1000 0 1000 1000 1000 1000 1000]}};
for iNetwork = 1:numel(randomNetworks)
    network = randomNetworks{iNetwork};
    randomModel = struct();
    randomModel.S = sparse(network{1});
    randomModel.lb = network{2}';
    randomModel.ub = network{3}';
    randomModel.rxns = strcat('R', arrayfun(@num2str, (1:size(randomModel.S, 2))', 'UniformOutput', false));
    for formulation = 1:2
        [rxnInLoops, N, loopInfo] = findMinNull(randomModel, formulation);
        assert(checkInvariants(randomModel, rxnInLoops, N));
        % every reaction found in a cycle is in N (the basis spans the cycles of these reactions)
        assert(all(any(N(any(rxnInLoops, 2), :), 2)));
        % ignored reactions have a small coefficient and are in no cycle
        ignored = ismember(randomModel.rxns, loopInfo.ignoreRxns);
        assert(all(any(abs(randomModel.S(:, ignored)) > 0 & abs(randomModel.S(:, ignored)) < 1e-3, 1)));
        assert(~any(any(rxnInLoops(ignored, :))));
    end
end

% restore the solver state and remove the globals created by the test
CobraSolverState.restore(initialSolverState);
newGlobals = setdiff(who('global'), globalsBefore);
for k = 1:numel(newGlobals)
    clearvars('-global', newGlobals{k});
end

% change the directory
cd(currentDir)
