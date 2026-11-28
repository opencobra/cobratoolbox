% The COBRAToolbox: testDoubleProductionEnvelope.m
%
% Purpose:
%     - doubleProductionEnvelope(model, deletions, prod1, prod2, biomassRxn, geneDelFlag, nPts)
%       knocks out reactions (or genes, with deleteModelGenes), finds the largest flux of prod1
%       and of prod2 with the biomass reaction fixed at 0, fixes both products on an
%       nPts x nPts grid from 0 to those maxima, maximises growth at each point
%       (y(j, i) for x1(i), x2(j)) and draws the surface. The test checks the grid and the
%       growth rates against a hand derivation (growth = 10 - x1 - x2 where feasible) and the
%       labels of the plot.
%
% Function under test:
%     src/design/doubleProductionEnvelope.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - up to 400 LPs on a hand-built seven-reaction model, every available LP solver
%     among gurobi and glpk; the surface is drawn into an invisible figure.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: An infeasible knock-out strain stops the function with a solver error
%       SEVERITY: limitation
%       TRIGGER: model = createModel({'EX_A'; 'R1'; 'R2'; 'R5'; 'EX_D'; 'BIO'; 'ATPM'; 'EX_P';
%         'EX_Q'}, {'EX_A'; 'R1'; 'R2'; 'R5'; 'EX_D'; 'BIO'; 'ATPM'; 'EX_P'; 'EX_Q'}, {'A <=> ';
%         'A -> B'; 'A -> B + P'; 'D -> P'; 'D <=> '; 'B -> '; 'B -> '; 'P <=> '; 'Q <=> '},
%         'lowerBoundList', [-10 0 0 0 -5 0 1 0 0], 'upperBoundList', 1000 * ones(1, 9));
%         model = changeObjective(model, 'BIO'); figure('Visible', 'off');
%         doubleProductionEnvelope(model, {'R1'; 'R2'}, 'EX_P', 'EX_Q', 'BIO', false, 3)
%       OBSERVED: (R2025a, gurobi, 2026-11-25) "Gurobi error 10003: Element 0 of a double
%         array is Nan." from solveCobraLP called at line 72: the strain cannot carry the ATPM
%         flux, so the LPs of lines 52 and 58 are infeasible (f = NaN), the grid of lines 62-63
%         is NaN and line 72 passes NaN bounds to the solver
%       EXPECTED: a clear error or an empty envelope for a strain without a feasible flux
%       LINES: 52-53, 58-59, 62-63, 72
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-25.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testDoubleProductionEnvelope'));
cd(fileDir);

% require an LP solver; skip gracefully if none is available
solvers = prepareTest('needsLP', true, 'useSolversIfAvailable', {'gurobi', 'glpk'});
globalsBefore = who('global');
initialSolverState = CobraSolverState.get();

% Network: uptake of A (EX_A, at most 10); R1: A -> B and growth biomass_SC4_bal: B ->
% (objective; the default name of the biomassRxn input); R2: A -> P with secretion EX_P;
% R3: A -> Q (gene g3) with secretion EX_Q. With biomass fixed at 0 both products reach 10;
% with EX_P = x1 and EX_Q = x2 fixed, growth is 10 - x1 - x2 when this is >= 0 and the LP is
% infeasible (f = NaN) otherwise.
rxnIds = {'EX_A'; 'R1'; 'biomass_SC4_bal'; 'R2'; 'EX_P'; 'R3'; 'EX_Q'};
model = createModel(rxnIds, rxnIds, {'A <=> '; 'A -> B'; 'B -> '; 'A -> P'; 'P <=> '; ...
    'A -> Q'; 'Q <=> '}, 'lowerBoundList', [-10 0 0 0 0 0 0], ...
    'upperBoundList', 1000 * ones(1, 7), 'grRuleList', {''; ''; ''; ''; ''; 'g3'; ''}, ...
    'printLevel', 0);
model = changeObjective(model, 'biomass_SC4_bal');

% tolerance: fluxes are at most 10 and come from LP vertices; 1e-6 is far above the solvers'
% feasibility tolerances and the rounding of linspace
tol = 1e-6;

for k = 1:length(solvers.LP)
    solverOK = changeCobraSolver(solvers.LP{k}, 'LP', 0);
    if ~solverOK
        continue
    end
    fprintf('   Testing doubleProductionEnvelope using %s ... \n', solvers.LP{k});

    %% no deletions, 3 x 3 grid: the hand-derived envelope
    % x1 = x2 = [0 5 10]; y(j, i) = 10 - x1(i) - x2(j) for x1 + x2 <= 10, NaN (infeasible LP)
    % beyond; rows of y follow x2 and columns follow x1
    figHandle = figure('Visible', 'off');
    [x1, x2, y] = doubleProductionEnvelope(model, {}, 'EX_P', 'EX_Q', 'biomass_SC4_bal', ...
        false, 3);
    assert(max(abs(x1 - [0 5 10])) < tol && max(abs(x2 - [0 5 10])) < tol);
    expectedY = [10 5 0; 5 0 NaN; 0 NaN NaN];
    assert(isequal(isnan(y), isnan(expectedY)));
    assert(max(abs(y(~isnan(expectedY)) - expectedY(~isnan(expectedY)))) < tol);
    % the surface is drawn with transparency 0.4 and labels built from the product names
    axesHandle = get(figHandle, 'CurrentAxes');
    surfaceHandle = findobj(axesHandle, 'Type', 'surface');
    assert(numel(surfaceHandle) == 1);
    assert(abs(get(surfaceHandle, 'FaceAlpha') - 0.4) < tol);
    assert(strcmp(get(get(axesHandle, 'XLabel'), 'String'), 'EX\_P (mmol/gDW h)'));
    assert(strcmp(get(get(axesHandle, 'YLabel'), 'String'), 'EX\_Q (mmol/gDW h)'));
    assert(strcmp(get(get(axesHandle, 'ZLabel'), 'String'), 'Growth Rate (1/h)'));
    close(figHandle);

    %% default biomassRxn ('biomass_SC4_bal'), geneDelFlag (false) and nPts (20)
    % a 20 x 20 grid from 0 to 10 for both products; the same formula holds at every point
    % (points with x1 + x2 = 10 up to rounding give growth 0)
    figHandle = figure('Visible', 'off');
    [x1, x2, y] = doubleProductionEnvelope(model, {}, 'EX_P', 'EX_Q');
    assert(numel(x1) == 20 && numel(x2) == 20 && isequal(size(y), [20, 20]));
    assert(max(abs(x1 - linspace(0, 10, 20))) < tol && max(abs(x2 - linspace(0, 10, 20))) < tol);
    [X1, X2] = meshgrid(x1, x2);
    productSum = X1 + X2;
    feasiblePoints = productSum <= 10 + 1e-9;
    assert(all(isnan(y(~feasiblePoints))));
    assert(~any(isnan(y(feasiblePoints))));
    assert(max(abs(y(feasiblePoints) - max(10 - productSum(feasiblePoints), 0))) < tol);
    close(figHandle);

    %% reaction deletion: R3 knocked out, so Q cannot be made
    % x2 is all zeros and every row of y is 10 - x1
    figHandle = figure('Visible', 'off');
    [x1, x2, y] = doubleProductionEnvelope(model, {'R3'}, 'EX_P', 'EX_Q', 'biomass_SC4_bal', ...
        false, 3);
    assert(max(abs(x1 - [0 5 10])) < tol && max(abs(x2)) < tol);
    assert(max(max(abs(y - repmat([10 5 0], 3, 1)))) < tol);
    close(figHandle);

    %% gene deletion: g3 is the only gene of R3, so deleting it gives the same envelope
    figHandle = figure('Visible', 'off');
    [x1, x2, y] = doubleProductionEnvelope(model, {'g3'}, 'EX_P', 'EX_Q', 'biomass_SC4_bal', ...
        true, 3);
    assert(max(abs(x1 - [0 5 10])) < tol && max(abs(x2)) < tol);
    assert(max(max(abs(y - repmat([10 5 0], 3, 1)))) < tol);
    close(figHandle);
end

% restore the solver state and remove the globals created by this test
CobraSolverState.restore(initialSolverState);
newGlobals = setdiff(who('global'), globalsBefore);
for iGlobal = 1:numel(newGlobals)
    clear('global', newGlobals{iGlobal});
end

% change the directory
cd(currentDir)
