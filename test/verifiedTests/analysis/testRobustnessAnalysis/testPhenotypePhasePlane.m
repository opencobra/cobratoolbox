% The COBRAToolbox: testPhenotypePhasePlane.m
%
% Purpose:
%     - phenotypePhasePlane fixes the fluxes of two uptake reactions on a grid (reaction 1 at
%       -linspace(0, range1, nPts), reaction 2 at -linspace(0, range2, nPts)), maximises the
%       objective at each point, and returns the optimal growth rates and the shadow prices of
%       the first metabolite of each control reaction (rows: reaction 2, columns: reaction 1).
%       It switches the LP parameter primalOnly off while it solves, restores it afterwards and
%       draws three figures.
%     - The model is a hand-built network: uptakes of A and B, sinks for both, and a biomass
%       reaction A + B ->. By hand, the maximal growth at uptakes (a, b) is min(a, b); the
%       shadow price of A is the growth gained per unit of extra A uptake, 1 where A limits
%       growth (a < b) and 0 where B limits it (and the converse for B). At a = b the dual is
%       not unique, so those points are not checked. The test checks a 3 x 3 grid with every
%       available solver, the documented defaults (50 points, ranges 20) once, and the
%       restoration of primalOnly from false and from true.
%
% Function under test:
%     src/analysis/robustnessAnalysis/phenotypePhasePlane.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - one LP per grid point on a five-reaction model, every available LP solver among
%     gurobi and glpk.
%
% Coverage exemptions:
%     Line 77: reached only when primalOnly was never set in CBT_LP_PARAMS; that input is
%     skipped for the cosmetic defect below (III-Defects).
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: primalOnly is left switched on when it was not set before the call
%       SEVERITY: cosmetic
%       TRIGGER: any call while CBT_LP_PARAMS has no field primalOnly (the state after
%         initCobraToolbox), e.g. phenotypePhasePlane(model, 'EX_A', 'EX_B', 3, 2, 4) with the
%         model of this test
%       OBSERVED: (R2025a, gurobi, 2026-11-25) getCobraSolverParams('LP', 'primalOnly') is 0
%         before the call and 1 after it; the else branch sets primalOnly to true instead of
%         leaving the parameter unset. No change of later optimizeCbModel duals was seen with
%         gurobi
%       EXPECTED: the solver parameters of the session as they were before the call (the
%         comment of line 54 says the state is saved)
%       LINES: 76-77
%     - DEFECT: Fewer than three points per axis stop in the plot after every LP was solved
%       SEVERITY: limitation
%       TRIGGER: phenotypePhasePlane(model, 'EX_A', 'EX_B', 2, 1, 2) with the model of this
%         test (any nPts below 3)
%       OBSERVED: (R2025a, gurobi, 2026-11-25) error "X, Y, and Z must be at least 3-by-3."
%         from surfl at line 88; the growth rates and shadow prices are computed but not
%         returned
%       EXPECTED: nPts is documented without a lower limit: the results returned (the surface
%         plot skipped), or the minimum of 3 documented
%       LINES: 88
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-25.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testPhenotypePhasePlane'));
cd(fileDir);

% the function solves LPs: require an LP solver
globalsBefore = who('global');
solvers = prepareTest('needsLP', true, 'useSolversIfAvailable', {'gurobi', 'glpk'});
initialSolverState = CobraSolverState.get();
global CBT_LP_PARAMS

% the function draws three figures: keep them invisible
defaultVisibility = get(0, 'DefaultFigureVisible');
set(0, 'DefaultFigureVisible', 'off');

% uptakes of A and B (fixed by the function), sinks for the excess, biomass A + B ->
model = createModel({'EX_A'; 'EX_B'; 'DM_A'; 'DM_B'; 'BIO'}, {'EX_A'; 'EX_B'; 'DM_A'; 'DM_B'; 'BIO'}, ...
    {'A <=> '; 'B <=> '; 'A -> '; 'B -> '; 'A + B -> '}, ...
    'lowerBoundList', [-1000, -1000, 0, 0, 0], 'printLevel', 0);
model = changeObjective(model, 'BIO');

% grid values of the 3 x 3 runs: uptake of A along the columns, of B along the rows
uptakeA = [0, 1, 2];
uptakeB = [0, 2, 4];
[gridA, gridB] = meshgrid(uptakeA, uptakeB);
expectedGrowth = min(gridA, gridB);
aLimits = gridA < gridB;
bLimits = gridB < gridA;

% growth rates and duals are vertex values of small LPs; 1e-6 is well above the solvers'
% feasibility and optimality tolerances (1e-9)
tol = 1e-6;

for k = 1:numel(solvers.LP)
    solverName = solvers.LP{k};
    solverOK = changeCobraSolver(solverName, 'LP', 0);
    assert(solverOK == 1);
    fprintf('   Testing phenotypePhasePlane using %s ... \n', solverName);

    %% 3 x 3 grid, primalOnly set to false before the call (lines 55-56, 74-75)
    changeCobraSolverParams('LP', 'primalOnly', false);
    [growthRates, shadowPrices1, shadowPrices2] = phenotypePhasePlane(model, 'EX_A', 'EX_B', 3, 2, 4);
    % the growth rates are min(uptake of A, uptake of B), rows = reaction 2
    assert(isequal(size(growthRates), [3, 3]));
    assert(max(abs(growthRates(:) - expectedGrowth(:))) < tol);
    % the shadow price of A is 1 where A limits growth and 0 where B limits it; conversely for B
    assert(all(abs(shadowPrices1(aLimits) - 1) < tol));
    assert(all(abs(shadowPrices1(bLimits)) < tol));
    assert(all(abs(shadowPrices2(bLimits) - 1) < tol));
    assert(all(abs(shadowPrices2(aLimits)) < tol));
    % primalOnly is back to its value before the call, and the three figures exist
    assert(CBT_LP_PARAMS.primalOnly == false);
    assert(all(ishghandle([1, 2, 3])));
    close([1, 2, 3]);

    %% primalOnly set to true before the call: it is restored to true
    changeCobraSolverParams('LP', 'primalOnly', true);
    % (three points per axis: fewer stop in the plot, see the limitation in the header)
    [growthRates, shadowPrices1] = phenotypePhasePlane(model, 'EX_A', 'EX_B', 3, 1, 2);
    % uptakes [0 0.5 1] for A and [0 1 2] for B: growth min(a, b); at a = 1, b = 2 A limits
    % growth, so its shadow price is computed (primalOnly is off during the solves) and is 1
    [smallGridA, smallGridB] = meshgrid([0, 0.5, 1], [0, 1, 2]);
    assert(max(abs(growthRates(:) - min(smallGridA(:), smallGridB(:)))) < tol);
    assert(abs(shadowPrices1(3, 3) - 1) < tol);
    assert(CBT_LP_PARAMS.primalOnly == true);
    close([1, 2, 3]);
end

%% documented defaults: 50 points per axis, ranges 20 (one solver; 2500 LPs)
changeCobraSolver(solvers.LP{1}, 'LP', 0);
changeCobraSolverParams('LP', 'primalOnly', false);
growthRates = phenotypePhasePlane(model, 'EX_A', 'EX_B');
[gridA, gridB] = meshgrid(linspace(0, 20, 50), linspace(0, 20, 50));
assert(isequal(size(growthRates), [50, 50]));
assert(max(abs(growthRates(:) - min(gridA(:), gridB(:)))) < tol);
close([1, 2, 3]);

% restore the figure visibility, the solver state and remove the globals created by this test
set(0, 'DefaultFigureVisible', defaultVisibility);
CobraSolverState.restore(initialSolverState);
newGlobals = setdiff(who('global'), globalsBefore);
if ~isempty(newGlobals)
    clear('global', newGlobals{:});
end

% change the directory
cd(currentDir)
