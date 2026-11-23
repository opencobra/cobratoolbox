% The COBRAToolbox: testDecomposeMoietyVectors.m
%
% Purpose:
%     - decomposeMoietyVectors(L, N) splits each moiety vector (column of L, N'*L = 0) into
%       moiety vectors that cannot be decomposed further, by one MILP per vector (the smallest
%       non-zero integer vector a <= l with N'*a = 0), repeated on the remainder l - a, and
%       returns the distinct non-decomposable vectors. The expected decompositions are derived by
%       hand for small networks: in A + B -> AB the vector [1; 1; 2] (A, B, AB) is the sum of the
%       A moiety [1; 0; 1] and the B moiety [0; 1; 1]; in 2 A -> A2 the vector [1; 2] counts one
%       A moiety and cannot be split. The order of the columns depends on which minimal vector
%       the solver returns first, so columns are compared as sets.
%
% Function under test:
%     src/analysis/topology/conservedMoieties/decomposeMoietyVectors.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - hand-built stoichiometric matrices; a MILP solver (solveCobraMILP), every MILP
%     solver that prepareTest returns.
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
fileDir = fileparts(which('testDecomposeMoietyVectors'));
cd(fileDir);

% declare the requirements of this test: a MILP solver
solvers = prepareTest('needsMILP', true);

% the solver state is changed below; note the globals that exist now to remove new ones at the
% end, and save the state to restore it
globalsBefore = who('global');
initialSolverState = CobraSolverState.get();

% A + B -> AB (metabolites A, B, AB) and its two non-decomposable moieties
N = [-1; -1; 1];
moietyA = [1; 0; 1];
moietyB = [0; 1; 1];
% 2 A -> A2 (metabolites A, A2) and its single moiety
Ndimer = [-2; 1];
moietyDimer = [1; 2];

% the sets of columns of two matrices are equal (all entries are integers, so == is exact)
sameColumns = @(X, Y) size(X, 2) == size(Y, 2) && isequal(sortrows(X')', sortrows(Y')');

for iSolver = 1:numel(solvers.MILP)
    solverOK = changeCobraSolver(solvers.MILP{iSolver}, 'MILP', 0);
    assert(solverOK == 1);

    %% a sum of two moieties is split into them (two rounds of the outer loop)
    % round 1 finds one of the two moieties and keeps the other as remainder; round 2 finds the
    % remainder non-decomposable (its remainder is zero)
    D = decomposeMoietyVectors(moietyA + moietyB, N);
    assert(sameColumns(D, [moietyA, moietyB]));
    % every column is a moiety vector: N'*D = 0 exactly for integer data
    assert(~any(N' * D, 'all'));

    %% a non-decomposable moiety is returned unchanged
    D = decomposeMoietyVectors(moietyA, N);
    assert(isequal(D, moietyA));
    D = decomposeMoietyVectors(moietyDimer, Ndimer);
    assert(isequal(D, moietyDimer));

    %% repeated moieties are returned once
    % 2*[1; 0; 1] is split into two copies of moietyA; the sum and a copy of moietyA given
    % together give each of the two moieties once (the duplicates are removed at the end)
    D = decomposeMoietyVectors(2 * moietyA, N);
    assert(isequal(D, moietyA));
    D = decomposeMoietyVectors([moietyA + moietyB, moietyA, sparse(moietyB)], N);
    assert(sameColumns(D, [moietyA, moietyB]));

    %% a metabolite outside the moiety is left out of the MILP
    % A + B -> AB with a metabolite C that only takes part in C -> C2 (C, C2 appended); the A and
    % B moieties have zero entries for C and C2, which the MILP leaves out, and the C moiety
    % [0; 0; 0; 1; 2] is found alone
    Nlarge = [N, zeros(3, 1); zeros(2, 1), [-2; 1]];
    D = decomposeMoietyVectors([moietyA + moietyB; 0; 0], Nlarge);
    assert(sameColumns(D, [[moietyA; 0; 0], [moietyB; 0; 0]]));
    D = decomposeMoietyVectors([[moietyA; 1; 2], [0; 0; 0; 1; 2]], Nlarge);
    assert(sameColumns(D, [[moietyA; 0; 0], [0; 0; 0; 1; 2]]));
    assert(~any(Nlarge' * D, 'all'));
end

% restore the solver state and remove the globals created by the test
CobraSolverState.restore(initialSolverState);
newGlobals = setdiff(who('global'), globalsBefore);
for k = 1:numel(newGlobals)
    clearvars('-global', newGlobals{k});
end

% change the directory
cd(currentDir)
