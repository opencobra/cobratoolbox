% The COBRAToolbox: testDirectionallyCoupled.m
%
% Purpose:
%     - directionallyCoupled solves one LP that finds every reaction j directionally coupled to
%       a reaction i (a flux through j forces a flux through i) and returns a certificate (a
%       fictitious metabolite y with S(:, j)' * y <= result(j) for irreversible j and
%       S(:, j)' * y = 0 for reversible j). The test checks the coupling vector on three
%       hand-built networks whose couplings are derived by hand below, the certificate
%       inequalities, and the three ways of choosing the solver (none, a legacy name, an
%       explicit COBRA solver name).
%
% Function under test:
%     src/analysis/QFCA/directionallyCoupled.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - one LP per call on hand-built 2-metabolite networks, every available LP solver
%     among gurobi and glpk.
%
% Coverage exemptions:
%     Lines 61-62: unreachable by any input. The LP is always feasible (certificate 0, result 0)
%     and bounded (the objective is a sum of variables bounded in [-1, 0]), so a status other
%     than 1 needs a solver failure.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-23.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testDirectionallyCoupled'));
cd(fileDir);

% the function solves an LP: require an LP solver and use gurobi and glpk where available
globalsBefore = who('global');
solvers = prepareTest('needsLP', true, 'useSolversIfAvailable', {'gurobi', 'glpk'});
initialSolverState = CobraSolverState.get();

% the coupling entries are vertex values (-1 or 0) of an LP solved to the solvers' default
% feasibility tolerance (1e-9 or looser); 1e-6 separates them safely
tol = 1e-6;

% Network 1, metabolites A and B: R1 (-> A), R2 (A -> B), R3 (B ->), all irreversible.
% By hand: a flux through R1 or R2 can leave only through R3, so both are coupled to R3; and
% R2, R3 need A, which only R1 supplies, so both are coupled to R1.
S1 = sparse([1, -1, 0; 0, 1, -1]);
rev1 = [0; 0; 0];

% Network 2 adds R4 (A ->, irreversible): A can now leave through R4, so R1 is no longer
% coupled to R3, R2 still is, and R4 is not (it does not pass through B).
S2 = sparse([1, -1, 0, -1; 0, 1, -1, 0]);
rev2 = [0; 0; 0; 0];

% Network 3 makes R4 reversible: reversible reactions are never reported (entry 0), and the
% certificate must be orthogonal to their columns.
rev3 = [0; 0; 0; 1];

for k = 1:numel(solvers.LP)
    solverName = solvers.LP{k};
    solverOK = changeCobraSolver(solverName, 'LP', 0);
    assert(solverOK == 1);
    fprintf('   Testing directionallyCoupled using %s ... \n', solverName);

    %% no solver name: the configured COBRA LP solver is used (line 52)
    [certificate, result] = directionallyCoupled(S1, rev1, 3, '');
    % R1 and R2 are coupled to R3 (entries -1); the entry of i itself is free and not asserted
    assert(all(abs(result(1:2) - [-1; -1]) < tol));
    % the certificate proves it: S(:, j)' * y <= result(j) for the irreversible j ~= i
    assert(all(S1(:, 1:2)' * certificate <= result(1:2) + tol));
    assert(numel(certificate) == 2 && numel(result) == 3);

    %% a legacy solver name also uses the configured COBRA LP solver (line 52)
    [certificate, result] = directionallyCoupled(S1, rev1, 1, 'linprog');
    % R2 and R3 are coupled to R1
    assert(all(abs(result(2:3) - [-1; -1]) < tol));
    assert(all(S1(:, 2:3)' * certificate <= result(2:3) + tol));

    %% an explicit COBRA solver name goes to solveCobraLP's solver option (line 55 for any
    % name other than gurobi, linprog and cplex)
    [certificate, result] = directionallyCoupled(S2, rev2, 3, solverName);
    % only R2 is coupled to R3; R1 and R4 are not
    assert(all(abs(result([1, 2, 4]) - [0; -1; 0]) < tol));
    assert(all(S2(:, [1, 2, 4])' * certificate <= result([1, 2, 4]) + tol));

    %% a reversible reaction gets entry 0 and an equality row S(:, j)' * y = 0
    [certificate, result] = directionallyCoupled(S2, rev3, 3, 'gurobi');
    assert(all(abs(result([1, 2, 4]) - [0; -1; 0]) < tol));
    assert(abs(S2(:, 4)' * certificate) < tol);
    assert(all(S2(:, [1, 2])' * certificate <= result([1, 2]) + tol));
end

% restore the solver state and remove the globals created by this test
CobraSolverState.restore(initialSolverState);
newGlobals = setdiff(who('global'), globalsBefore);
if ~isempty(newGlobals)
    clear('global', newGlobals{:});
end

% change the directory
cd(currentDir)
