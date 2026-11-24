% The COBRAToolbox: testFindBlockedIrrRxns.m
%
% Purpose:
%     - findBlockedIrrRxns finds the blocked irreversible reactions of a model with one LP that
%       minimises the number of irreversible reactions unable to carry a flux of at least tol
%       in their direction. The test checks, on a hand-built 5-metabolite model, the list of
%       blocked irreversible reactions (derived by hand: a reaction fed by a metabolite without
%       source, a reverse-only reaction into a dead end and a reaction fixed at zero; blocked
%       reversible reactions are not reported), the LP solution (S*v = b, bounds), the
%       tolerance returned for the default, a large and a small input tol and for a solver
%       parameter, and the infeasible-model branch.
%
% Function under test:
%     src/analysis/exploration/findBlockedIrrRxns.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - one LP per call on a hand-built model, every available LP solver among gurobi
%     and glpk.
%
% Coverage exemptions:
%     Lines 39-40: unreachable by any input, inside the "if 0" branch of line 38.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-23.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testFindBlockedIrrRxns'));
cd(fileDir);

% the function solves an LP: require an LP solver and use gurobi and glpk where available
globalsBefore = who('global');
solvers = prepareTest('needsLP', true, 'useSolversIfAvailable', {'gurobi', 'glpk'});
initialSolverState = CobraSolverState.get();

% a hand-built model:
%   EX_A  A <=>        reversible uptake/secretion of A
%   R1    A -> B       forward only, carries flux to EX_B
%   EX_B  B ->         forward only
%   R2    C -> B       forward only, but C has no source: blocked
%   R3    A -> D       reverse only (lb < 0, ub = 0), D is a dead end: blocked
%   R4    B -> A       reverse only, its reverse direction (A -> B) carries flux: not blocked
%   R5    A -> E       fixed at zero (lb = ub = 0): blocked and reported (lb >= 0)
%   R6    A <=> F      reversible, F is a dead end: blocked but reversible, not reported
rxnIds = {'EX_A'; 'R1'; 'EX_B'; 'R2'; 'R3'; 'R4'; 'R5'; 'R6'};
rxnFormulas = {'A[c] <=>'; 'A[c] -> B[c]'; 'B[c] ->'; 'C[c] -> B[c]'; 'A[c] -> D[c]'; ...
    'B[c] -> A[c]'; 'A[c] -> E[c]'; 'A[c] <=> F[c]'};
model = createModel(rxnIds, rxnIds, rxnFormulas, ...
    'lowerBoundList', [-10; 0; 0; 0; -10; -10; 0; -10], ...
    'upperBoundList', [10; 10; 10; 10; 0; 0; 0; 10], 'printLevel', 0);
expectedBlocked = {'R2'; 'R3'; 'R5'};
nRxns = numel(model.rxns);

% an infeasible copy: metabolite E only takes part in R5, which is fixed at zero, so a nonzero
% right-hand side for E cannot be met
infeasibleModel = model;
infeasibleModel.b(strcmp(infeasibleModel.mets, 'E[c]')) = 1;

% S*v = b and the bounds hold to the solvers' feasibility tolerance (1e-9 by default, glpk
% looser); 1e-6 is well above it and well below the flux scale of 1-10
fluxTol = 1e-6;

for k = 1:numel(solvers.LP)
    solverName = solvers.LP{k};
    solverOK = changeCobraSolver(solverName, 'LP', 0);
    assert(solverOK == 1);
    fprintf('   Testing findBlockedIrrRxns using %s ... \n', solverName);
    defaultFeasTol = getCobraSolverParams('LP', 'feasTol');

    %% model only: tol defaults to 10 * feasTol (lines 29-30 and 35)
    [blockedIrrRxns, sol, tolUsed] = findBlockedIrrRxns(model);
    assert(isequal(blockedIrrRxns, expectedBlocked));
    assert(sol.stat == 1);
    % the solution respects S*v = b and the bounds
    v = sol.full(1:nRxns);
    assert(norm(model.S * v - model.b, inf) < fluxTol);
    assert(all(v >= model.lb - fluxTol) && all(v <= model.ub + fluxTol));
    % the tolerance is computed from the parameter, so it compares within rounding
    assert(abs(tolUsed - 10 * defaultFeasTol) <= eps(10 * defaultFeasTol));

    %% an input tol above 10 * feasTol is kept
    [blockedIrrRxns, ~, tolUsed] = findBlockedIrrRxns(model, 1e-3);
    assert(isequal(blockedIrrRxns, expectedBlocked));
    assert(tolUsed == 1e-3);

    %% an input tol below 10 * feasTol is raised to it
    [~, ~, tolUsed] = findBlockedIrrRxns(model, 1e-15);
    assert(abs(tolUsed - 10 * defaultFeasTol) <= eps(10 * defaultFeasTol));

    %% solver parameters as parameter/value inputs set feasTol, hence the tolerance
    [blockedIrrRxns, sol, tolUsed] = findBlockedIrrRxns(model, 0, 'feasTol', 1e-8);
    assert(isequal(blockedIrrRxns, expectedBlocked));
    assert(sol.stat == 1);
    assert(abs(tolUsed - 1e-7) <= eps(1e-7));

    %% an infeasible model: a warning, an empty list and the non-optimal solution (lines 61-63)
    [blockedIrrRxns, sol] = findBlockedIrrRxns(infeasibleModel);
    assert(iscell(blockedIrrRxns) && isempty(blockedIrrRxns));
    assert(sol.stat ~= 1);
end

% restore the solver state and remove the globals created by this test
CobraSolverState.restore(initialSolverState);
newGlobals = setdiff(who('global'), globalsBefore);
if ~isempty(newGlobals)
    clear('global', newGlobals{:});
end

% change the directory
cd(currentDir)
