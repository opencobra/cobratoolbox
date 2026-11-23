% The COBRAToolbox: testBlockedReac.m
%
% Purpose:
%     - blockedReac(S, rev, rxns, solver) finds the blocked reactions of a network and removes
%       them: the blocked irreversible reactions come from one LP (directionallyCoupled with
%       i = 0, entries -1), the blocked reversible reactions from a QR factorisation of the
%       remaining columns (a reversible reaction is blocked when its row of the null space
%       basis of S is zero). The test checks, for every solver, the blocked vector and the
%       reduced S, rev and rxns on hand-built networks whose blocked reactions are derived by
%       hand below (a dead end, a metabolite never produced, irreversible reactions blocked
%       only by their direction, a network without blocked reaction), with a legacy solver
%       name and with an explicit COBRA solver name.
%
% Function under test:
%     src/analysis/QFCA/blockedReac.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - one LP per call on hand-built networks of up to 5 metabolites and 8 reactions,
%     every available LP solver among gurobi and glpk.
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
fileDir = fileparts(which('testBlockedReac'));
cd(fileDir);

% the function solves an LP: require an LP solver and use gurobi and glpk where available
globalsBefore = who('global');
solvers = prepareTest('needsLP', true, 'useSolversIfAvailable', {'gurobi', 'glpk'});
initialSolverState = CobraSolverState.get();

% Network 1, metabolites A, B, C, D, X:
%   R1 (-> A), R2 (A -> B), R3 (B ->), R5 (D -> B), R7 (X -> A), R8 (X -> B) irreversible;
%   R4 (A <=> C) and R6 (A <=> B) reversible.
% By hand: R1, R2, R3 form the path -> A -> B ->, and R6 can carry A -> B in parallel to R2,
% so R1, R2, R3, R6 are unblocked. C occurs only in R4, so v4 = 0 (blocked reversible). D
% occurs only in R5, so v5 = 0 (blocked irreversible). X is consumed by R7 and R8 and
% produced by none: -v7 - v8 = 0 with v7, v8 >= 0 forces v7 = v8 = 0 (blocked irreversible,
% only by their direction: without it B -> X -> A would be a steady state).
S1 = sparse([1, -1,  0, -1,  0, -1,  1,  0; ...   % A
             0,  1, -1,  0,  1,  1,  0,  1; ...   % B
             0,  0,  0,  1,  0,  0,  0,  0; ...   % C
             0,  0,  0,  0, -1,  0,  0,  0; ...   % D
             0,  0,  0,  0,  0,  0, -1, -1]);     % X
rev1 = [0; 0; 0; 1; 0; 1; 0; 0];
rxns1 = {'R1'; 'R2'; 'R3'; 'R4'; 'R5'; 'R6'; 'R7'; 'R8'};
expectedBlocked1 = [0; 0; 0; 1; 1; 0; 1; 1];

% Network 2, metabolites A, B: R1 (-> A), R2 (A -> B) irreversible, R3 (B <=>) reversible;
% the path -> A -> B <=> carries flux through every reaction, so none is blocked
S2 = sparse([1, -1,  0; ...
             0,  1, -1]);
rev2 = [0; 0; 1];
rxns2 = {'R1'; 'R2'; 'R3'};

for k = 1:numel(solvers.LP)
    solverName = solvers.LP{k};
    solverOK = changeCobraSolver(solverName, 'LP', 0);
    assert(solverOK == 1);
    fprintf('   Testing blockedReac using %s ... \n', solverName);

    %% blocked irreversible and reversible reactions, legacy solver name
    % the blocked vector is the hand-derived one (integer values: exact comparison), and the
    % reduced S, rev and rxns are the columns and entries of the unblocked reactions
    [S, rev, rxns, blocked] = blockedReac(S1, rev1, rxns1, 'gurobi');
    assert(isequal(blocked, expectedBlocked1));
    assert(isequal(S, S1(:, expectedBlocked1 == 0)));
    assert(isequal(rev, rev1(expectedBlocked1 == 0)));
    assert(isequal(rxns, {'R1'; 'R2'; 'R3'; 'R6'}));

    %% the same network with the current COBRA solver named explicitly
    % 'gurobi' is a legacy name, 'glpk' an explicit COBRA solver name in directionallyCoupled;
    % the blocked reactions are a property of the network, so the result is the same
    [S, rev, rxns, blocked] = blockedReac(S1, rev1, rxns1, solverName);
    assert(isequal(blocked, expectedBlocked1));
    assert(isequal(S, S1(:, [1, 2, 3, 6])));
    assert(isequal(rev, [0; 0; 0; 1]));
    assert(isequal(rxns, {'R1'; 'R2'; 'R3'; 'R6'}));

    %% a network without blocked reaction is returned unchanged
    [S, rev, rxns, blocked] = blockedReac(S2, rev2, rxns2, solverName);
    assert(isequal(blocked, [0; 0; 0]));
    assert(isequal(S, S2));
    assert(isequal(rev, rev2));
    assert(isequal(rxns, rxns2));
end

% restore the solver state and remove the globals created by this test
CobraSolverState.restore(initialSolverState);
newGlobals = setdiff(who('global'), globalsBefore);
for iGlobal = 1:numel(newGlobals)
    clear('global', newGlobals{iGlobal});
end

% change the directory
cd(currentDir)
