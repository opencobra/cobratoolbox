% The COBRAToolbox: testLP10.m
%
% Purpose:
%     - LP10(K, P, v, LPproblem, epsilon, adaptiveScalingFlag, nonPen) solves LP-10 of FASTCORE:
%       minimise the L1 norm of the fluxes of the non-core reactions P (except those in nonPen)
%       while the core reactions K carry at least a threshold. With the fixed scaling (flag 0)
%       the problem is scaled by 1e4 (bounds, right hand side and threshold epsilon) and V is
%       the scaled solution; with the adaptive scaling (flag 1) the threshold is 10*min(v(K)),
%       the problem is not scaled, and an infeasible adaptive problem falls back to the fixed
%       scaling. The test checks the early return, the argument checks and, for every solver,
%       the optimum of hand-built LPs whose optimal objective is derived by hand: S*V = b
%       (scaled where the problem is scaled), the bounds, the core threshold and the objective.
%       Where the split of a flux among parallel reactions is not unique only their sum is
%       asserted.
%
% Function under test:
%     src/dataIntegration/transcriptomics/FASTCORE/LP10.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - solves LPs (hand-built LPproblem of 2 metabolites and 5 reactions), every
%     available LP solver among gurobi and glpk.
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
fileDir = fileparts(which('testLP10'));
cd(fileDir);

% require an LP solver; skip gracefully if none is available
solvers = prepareTest('needsLP', true, 'useSolversIfAvailable', {'gurobi', 'glpk'});
globalsBefore = who('global');
initialSolverState = CobraSolverState.get();

% Network: uptake 1 (-> A), core reaction 2 (A -> B), exports 3 and 4 (B ->) and
% 5 (A ->); all irreversible with upper bound 10
S = sparse([1 -1  0  0 -1; ...
            0  1 -1 -1  0]);
LPproblem.A = S;
LPproblem.b = zeros(2, 1);
LPproblem.csense = ['E'; 'E'];
LPproblem.lb = zeros(5, 1);
LPproblem.ub = 10 * ones(5, 1);
n = 5;
K = 2;
P = [1; 3; 4; 5];
epsilon = 1e-4;
scalingFactor = 1e4;

% tolerance: the optima below are vertices of LPs with entries of order 1 to 1e3; solver
% feasibility tolerances are about 1e-6 relative, so 1e-6 is used for scaled values of
% order 1 and a relative check is used where values are scaled
tol = 1e-6;

%% K or P empty: an empty vector is returned before any LP is built

V = LP10([], P, ones(n, 1), LPproblem, epsilon, 0, []);
assert(isempty(V) && isnumeric(V));
V = LP10(K, [], ones(n, 1), LPproblem, epsilon, 0, []);
assert(isempty(V) && isnumeric(V));

%% an adaptiveScalingFlag other than 0 or 1 is rejected

assert(verifyCobraFunctionError('LP10', 'inputs', {K, P, ones(n, 1), LPproblem, epsilon, 2, []}));

for k = 1:length(solvers.LP)
    solverOK = changeCobraSolver(solvers.LP{k}, 'LP', 0);
    if ~solverOK
        continue
    end
    fprintf('   Testing LP10 using %s ... \n', solvers.LP{k});

    %% fixed scaling (flag 0): the optimum is the scaled threshold through the core reaction
    % Penalised: v1 + v3 + v4 + v5 = 2*v2 + 2*v5 (mass balance of A and B), so the minimum is
    % v2 = epsilon*1e4 = 1, v5 = 0, v1 = 1 and v3 + v4 = 1 (split not unique)
    V = LP10(K, P, ones(n, 1), LPproblem, epsilon, 0, []);
    assert(isequal(size(V), [n, 1]));
    assert(norm(S * V, inf) < tol);
    assert(all(V >= -tol) && all(V <= 10 * scalingFactor + tol));
    assert(abs(V(2) - epsilon * scalingFactor) < tol);
    assert(abs(V(1) - 1) < tol && abs(V(5)) < tol);
    assert(abs(V(3) + V(4) - 1) < tol);

    %% an empty flag means fixed scaling (a message is printed) and gives the same optimum
    V = LP10(K, P, ones(n, 1), LPproblem, epsilon, [], []);
    assert(abs(V(2) - 1) < tol && abs(V(3) + V(4) - 1) < tol && abs(V(5)) < tol);

    %% nonPen: reaction 4 is not penalised, so all of B leaves through it (unique optimum)
    % Objective v1 + v3 + v5 = v2 + v3 + 2*v5 (v1 = v2 + v5), minimised at v2 = 1 and
    % v3 = v5 = 0, so v4 = 1
    V = LP10(K, P, ones(n, 1), LPproblem, epsilon, 0, 4);
    assert(norm(S * V, inf) < tol);
    assert(abs(V(2) - 1) < tol && abs(V(4) - 1) < tol && abs(V(3)) < tol);

    %% fixed scaling with a nonzero right hand side: b is scaled by 1e4 like the bounds
    % An extra equality v5 = 3e-4 becomes V(5) = 3 in the scaled problem; the optimum keeps
    % V(2) = 1 and V(1) = V(2) + V(5) = 4
    LPb = LPproblem;
    LPb.A = [S; 0 0 0 0 1];
    LPb.b = [0; 0; 3e-4];
    LPb.csense = ['E'; 'E'; 'E'];
    V = LP10(K, P, ones(n, 1), LPb, epsilon, 0, []);
    assert(norm(LPb.A * V - scalingFactor * LPb.b, inf) < tol);
    assert(abs(V(5) - 3) < tol && abs(V(2) - 1) < tol && abs(V(1) - 4) < tol);

    %% adaptive scaling (flag 1): threshold 10*min(v(K)), no scaling of V
    % v(K) = 0.5 gives the threshold 5: v2 = 5, v1 = 5, v3 + v4 = 5; with nonPen = 4, v4 = 5
    vIn = 0.5 * ones(n, 1);
    V = LP10(K, P, vIn, LPproblem, epsilon, 1, []);
    assert(norm(S * V, inf) < tol);
    assert(all(V >= -tol) && all(V <= 10 + tol));
    assert(abs(V(2) - 5) < tol && abs(V(1) - 5) < tol && abs(V(3) + V(4) - 5) < tol);
    V = LP10(K, P, vIn, LPproblem, epsilon, 1, 4);
    assert(abs(V(4) - 5) < tol && abs(V(3)) < tol);

    %% adaptive scaling that is infeasible falls back to the fixed scaling
    % v(K) = 2 gives the threshold 20 > ub(2) = 10: the fixed-scaling optimum V(2) = 1 follows
    V = LP10(K, P, 2 * ones(n, 1), LPproblem, epsilon, 1, []);
    assert(norm(S * V, inf) < tol);
    assert(abs(V(2) - 1) < tol && abs(V(3) + V(4) - 1) < tol);

    %% an infeasible problem: warnings are printed and V still has one entry per reaction
    % ub(2) = 0 cannot carry the core threshold. V is NaN when the solver returns no solution
    % vector (gurobi); glpk returns its last iterate, which is not asserted
    LPinf = LPproblem;
    LPinf.ub(2) = 0;
    V = LP10(K, P, ones(n, 1), LPinf, epsilon, 0, []);
    assert(isequal(size(V), [n, 1]));
    if strcmp(solvers.LP{k}, 'gurobi')
        assert(all(isnan(V)));
    end
end

% restore the solver state and remove the globals created by this test
CobraSolverState.restore(initialSolverState);
newGlobals = setdiff(who('global'), globalsBefore);
for iGlobal = 1:numel(newGlobals)
    clear('global', newGlobals{iGlobal});
end

% change the directory
cd(currentDir)
