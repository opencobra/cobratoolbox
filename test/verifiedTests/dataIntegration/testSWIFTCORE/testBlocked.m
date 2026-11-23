% The COBRAToolbox: testBlocked.m
%
% Purpose:
%     - blocked(S, rev, solver) solves the LP of swiftcc that finds the blocked irreversible
%       reactions: variables u (one per metabolite, free) and x (one per reaction, x = 0 for
%       reversible reactions, -1 <= x <= 0 for irreversible ones), constraints S'*u = x for
%       reversible and S'*u <= x for irreversible reactions, minimise the sum of x over the
%       irreversible reactions. The last n entries of result.x are -1 for the blocked
%       irreversible reactions and 0 otherwise; the first m entries are the certificate u.
%       The test checks, for every solver, the blocked reactions derived by hand on small
%       networks (a dead end, a network without blocked reaction, a mixed one), the
%       constraints of the LP on the returned point, the objective and the status, and the
%       three ways of naming the solver (empty, a legacy name, an explicit COBRA solver).
%
% Function under test:
%     src/dataIntegration/transcriptomics/SWIFTCORE/blocked.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - solves LPs (hand-built networks of up to 3 metabolites and 4 reactions), every
%     available LP solver among gurobi and glpk.
%
% Coverage exemptions:
%     Lines 56-57: unreachable, the LP always has the feasible point u = 0, x = 0 and is
%     bounded (the objective involves only x, with -1 <= x <= 0), so a working solver always
%     returns status 1.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-23.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testBlocked'));
cd(fileDir);

% require an LP solver; skip gracefully if none is available
solvers = prepareTest('needsLP', true, 'useSolversIfAvailable', {'gurobi', 'glpk'});
globalsBefore = who('global');
initialSolverState = CobraSolverState.get();

% tolerance: the optimal x are -1 or 0 and the certificates are of order 1; 1e-6 covers the
% solvers' feasibility tolerances
tol = 1e-6;

% Network 1: R1 (-> A) and R2 (A -> B), both irreversible; B has no outlet, so both are blocked
S1 = sparse([1 -1; ...
             0  1]);
rev1 = [0; 0];

% Network 2: R1 (-> A), R2 (A -> B), R3 (B <=>, reversible); no reaction is blocked
S2 = sparse([1 -1  0; ...
             0  1 -1]);
rev2 = [0; 0; 1];

% Network 3: R1 (-> A), R2 (A -> B), R3 (B ->), R4 (A -> C, C is a dead end), all irreversible;
% only R4 is blocked
S3 = sparse([1 -1  0 -1; ...
             0  1 -1  0; ...
             0  0  0  1]);
rev3 = [0; 0; 0; 0];

for k = 1:length(solvers.LP)
    solverOK = changeCobraSolver(solvers.LP{k}, 'LP', 0);
    if ~solverOK
        continue
    end
    fprintf('   Testing blocked using %s ... \n', solvers.LP{k});

    %% a dead end: both irreversible reactions are blocked (legacy solver name)
    % u_A <= x1 and u_B - u_A <= x2 allow x1 = x2 = -1 (u_A = -1, u_B = -2), objective -2
    result = blocked(S1, rev1, 'gurobi');
    assert(result.status == 1);
    assert(isequal(size(result.x), [2 + 2, 1]));
    assert(all(abs(result.x(3:4) + 1) < tol));
    assert(abs(result.objval + 2) < tol);
    % the certificate satisfies the constraints of the LP: S'*u <= x for irreversible reactions
    u = result.x(1:2);
    assert(all(S1' * u - result.x(3:4) <= tol));

    %% no blocked reaction: every x is 0 (no solver named)
    % summing u_A <= x1, u_B - u_A <= x2 and -u_B = x3 = 0 gives 0 <= x1 + x2, so x1 = x2 = 0
    result = blocked(S2, rev2, []);
    assert(result.status == 1);
    assert(all(abs(result.x(3:5)) < tol));
    assert(abs(result.objval) < tol);
    % the reversible reaction is an equality: (S'*u)(3) = x3 = 0
    u = result.x(1:2);
    assert(abs(S2(:, 3)' * u - result.x(5)) < tol);
    assert(all(S2(:, 1:2)' * u - result.x(3:4) <= tol));

    %% one blocked reaction among unblocked ones, other legacy names
    % u_A <= x1, u_B - u_A <= x2, -u_B <= x3 force x1 = x2 = x3 = 0; u_C - u_A <= x4 allows
    % x4 = -1, so the objective is -1
    for legacyName = {'linprog', 'cplex'}
        result = blocked(S3, rev3, legacyName{1});
        assert(result.status == 1);
        assert(all(abs(result.x(4:6)) < tol));
        assert(abs(result.x(7) + 1) < tol);
        assert(abs(result.objval + 1) < tol);
        assert(all(S3' * result.x(1:3) - result.x(4:7) <= tol));
    end

    %% the current COBRA solver named explicitly
    % 'gurobi' is a legacy name (line 47), 'glpk' an explicit COBRA solver name (line 50);
    % the result is the same
    result = blocked(S3, rev3, solvers.LP{k});
    assert(result.status == 1);
    assert(all(abs(result.x(4:6)) < tol));
    assert(abs(result.x(7) + 1) < tol);
end

% restore the solver state and remove the globals created by this test
CobraSolverState.restore(initialSolverState);
newGlobals = setdiff(who('global'), globalsBefore);
for iGlobal = 1:numel(newGlobals)
    clear('global', newGlobals{iGlobal});
end

% change the directory
cd(currentDir)
