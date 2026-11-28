% The COBRAToolbox: testBuildEcosystemGrid.m
%
% Purpose:
%     - buildEcosystemGrid builds the regular grid of points [f, mu] over the abundance-growth
%       space of a two-member community (f from 0 to 1, mu from 0 to the maximum community
%       growth, f varying fastest), optionally without the point (0, 0), with the member
%       fractions [f, 1 - f], the maximum community growth and the grid limits, and resets
%       the analysis fields. The maximum growth is the FBA optimum of the community model,
%       with positive lower bounds set to zero unless ignoreMaintenance is false, or is given.
%       The test checks the grid, every option and the errors.
%     - Expected values are derived by hand on a six-reaction community: the pool exchange
%       EX_A_e (lb -10), member 1 (org1_Atr: A_e -> A1, org1_biomass: A1 ->) and member 2
%       (org2_Atr: A_e -> A2, org2_biomass: 2 A2 ->, org2_ATPM: A2 -> with lb 1), objective
%       org1_biomass + org2_biomass. Member 1 converts A with yield 1 and member 2 with yield
%       1/2, so the maximum community growth is 10 when the maintenance is relaxed and
%       10 - 1 = 9 when it is kept.
%
% Function under test:
%     src/analysis/ecosystem/buildEcosystemGrid.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - FBA on a six-reaction community model, every available LP solver among gurobi
%     and glpk.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-25.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testBuildEcosystemGrid'));
cd(fileDir);

% the solver set-up may create global variables; those created here are removed at the end
globalsBefore = who('global');

% require an LP solver; skip gracefully if none is available
solvers = prepareTest('needsLP', true, 'useSolversIfAvailable', {'gurobi', 'glpk'});
initialSolverState = CobraSolverState.get();

% tolerance: the maximum growth is an LP optimum (solver feasibility tolerance 1e-9 or better)
% and every grid value is a linspace of it, so 1e-6 is a wide margin
tol = 1e-6;

% the two-member community (see Purpose)
rxnIds = {'EX_A_e'; 'org1_Atr'; 'org1_biomass'; 'org2_Atr'; 'org2_biomass'; 'org2_ATPM'};
communityModel = createModel(rxnIds, rxnIds, ...
    {'A_e -> '; 'A_e -> org1_A_c'; 'org1_A_c -> '; 'A_e -> org2_A_c'; '2 org2_A_c -> '; 'org2_A_c -> '}, ...
    'lowerBoundList', [-10 0 0 0 0 1], 'upperBoundList', [1000 1000 1000 1000 1000 1000], 'printLevel', 0);
communityModel.c(:) = 0;
communityModel.c(ismember(communityModel.rxns, {'org1_biomass'; 'org2_biomass'})) = 1;
eco = struct();
eco.model = communityModel;
eco.prefixes = {'org1'; 'org2'};
eco.objectives = {'org1_biomass', 'org2_biomass'};
eco.memberRxns = {{'org1_Atr'; 'org1_biomass'}, {'org2_Atr'; 'org2_biomass'; 'org2_ATPM'}};
% analysis fields of an earlier grid, which a new grid resets
eco.feasiblePoints = true(3, 1);
eco.clusters = [1; 2; 1];

for k = 1:numel(solvers.LP)
    solverOK = changeCobraSolver(solvers.LP{k}, 'LP', 0);
    if ~solverOK
        continue
    end
    fprintf('   Testing buildEcosystemGrid using %s ... \n', solvers.LP{k});

    %% defaults: 10 x 10 grid without (0, 0), maintenance relaxed (maximum growth 10)
    ecoGrid = buildEcosystemGrid(eco);
    assert(abs(ecoGrid.maxCommunityGrowth - 10) < tol);
    % 100 points minus the dropped origin, f varying fastest: the first row of the grid
    % (mu = 0) without (0, 0), then f = 0 at the second value of mu
    assert(isequal(size(ecoGrid.points), [99, 2]));
    assert(max(abs(ecoGrid.points(1:9, 1) - (1:9)' / 9)) < tol && all(ecoGrid.points(1:9, 2) == 0));
    assert(max(abs(ecoGrid.points(10, :) - [0, 10 / 9])) < tol);
    assert(max(abs(ecoGrid.points(end, :) - [1, 10])) < tol);
    % the fractions are [f, 1 - f]; the limits are the minimum and maximum of the points
    assert(isequal(ecoGrid.pfractions, [ecoGrid.points(:, 1), 1 - ecoGrid.points(:, 1)]));
    assert(isequal(ecoGrid.limits, [min(ecoGrid.points, [], 1); max(ecoGrid.points, [], 1)]));
    assert(max(max(abs(ecoGrid.limits - [0, 0; 1, 10]))) < tol);
    % the analysis fields are reset and the input fields kept
    assert(isempty(ecoGrid.feasiblePoints) && isempty(ecoGrid.qualVectors) && isempty(ecoGrid.qualPointIndex));
    assert(isempty(ecoGrid.fvaResults) && isempty(ecoGrid.clusters) && isempty(ecoGrid.k));
    assert(isequal(ecoGrid.model, eco.model) && isequal(ecoGrid.memberRxns, eco.memberRxns));

    %% ignoreMaintenance false keeps the maintenance (maximum growth 9); dropZero false
    % keeps (0, 0): a 3 x 3 grid with f in {0, 0.5, 1} and mu in {0, 4.5, 9}, limits [0 0; 1 9]
    ecoGrid = buildEcosystemGrid(eco, 'numPoints', 3, 'ignoreMaintenance', false, ...
        'dropZero', false, 'printLevel', 0);
    assert(abs(ecoGrid.maxCommunityGrowth - 9) < tol);
    expectedPoints = [0, 0; 0.5, 0; 1, 0; 0, 4.5; 0.5, 4.5; 1, 4.5; 0, 9; 0.5, 9; 1, 9];
    assert(max(max(abs(ecoGrid.points - expectedPoints))) < tol);
    assert(isequal(ecoGrid.limits(1, :), [0, 0]) && abs(ecoGrid.limits(2, 2) - 9) < tol && ecoGrid.limits(2, 1) == 1);

    %% the relaxed community model is infeasible: error with its status
    % org1_Atr is forced to run backwards (flux -5), which needs org1_A_c that nothing makes;
    % the bound is negative, so relaxing the maintenance does not remove it
    ecoInfeasible = eco;
    ecoInfeasible.model = changeRxnBounds(communityModel, 'org1_Atr', -5, 'b');
    assert(verifyCobraFunctionError('buildEcosystemGrid', 'inputs', {ecoInfeasible, 'printLevel', 0}, ...
        'testMessage', 'The relaxed community model is infeasible or unbounded (stat = 0).'));
end

%% a given maximum growth is used without a solver: a 2 x 2 grid up to 4, without (0, 0)
% the limits are then those of the three remaining points
ecoGrid = buildEcosystemGrid(eco, 'numPoints', 2, 'maxCommunityGrowth', 4, 'printLevel', 0);
assert(isequal(ecoGrid.points, [1, 0; 0, 4; 1, 4]));
assert(isequal(ecoGrid.pfractions, [1, 0; 0, 1; 1, 0]));
assert(ecoGrid.maxCommunityGrowth == 4 && isequal(ecoGrid.limits, [0, 0; 1, 4]));

%% errors: a community of three members, invalid inputs
ecoThree = eco;
ecoThree.prefixes = {'org1'; 'org2'; 'org3'};
assert(verifyCobraFunctionError('buildEcosystemGrid', 'inputs', {ecoThree, 'maxCommunityGrowth', 4}, ...
    'testMessage', 'Only communities of two members are supported.'));
% the input parser rejects a structure without a model, a grid of one point and a
% non-positive maximum growth
assert(verifyCobraFunctionError('buildEcosystemGrid', 'inputs', {rmfield(eco, 'model')}));
assert(verifyCobraFunctionError('buildEcosystemGrid', 'inputs', {eco, 'numPoints', 1}));
assert(verifyCobraFunctionError('buildEcosystemGrid', 'inputs', {eco, 'maxCommunityGrowth', 0}));

% restore the solver state, remove the globals created by the solver set-up, restore the
% directory
CobraSolverState.restore(initialSolverState);
newGlobals = setdiff(who('global'), globalsBefore);
for i = 1:numel(newGlobals)
    clear('global', newGlobals{i});
end
cd(currentDir)
