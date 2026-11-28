% The COBRAToolbox: testCheckEcosystemGridFeasibility.m
%
% Purpose:
%     - checkEcosystemGridFeasibility marks each point [f, mu] of the abundance-growth grid of a
%       two-member ecosystem as feasible when the community model, with the member growth
%       rates fixed to f*mu and (1 - f)*mu (and, by default, the member bounds scaled by the
%       member fractions), has a steady state. Points outside pointIndex are infeasible. The
%       test checks the result for every option and the errors.
%     - Expected values are derived by hand on a six-reaction community: the pool exchange
%       EX_A_e (uptake at most 10), member 1 (org1_Atr: A_e -> A1, org1_biomass: A1 ->) and
%       member 2 (org2_Atr: A_e -> A2, org2_biomass: 2 A2 ->, org2_ATPM: A2 -> with lb 1).
%       A point is feasible when the A it needs, f*mu + 2*(1 - f)*mu + m, is at most 10, with
%       the maintenance m = 1 - f when the bounds are scaled and m = 1 when they are not. On
%       the hand-built grid f in {0, 0.5, 1}, mu in {0, 5, 10} without (0, 0) the points
%       (0, 5), (0, 10) and (0.5, 10) are infeasible in both cases, and (1, 10) needs exactly
%       10 when scaled (feasible) and 11 when not (infeasible).
%
% Function under test:
%     src/analysis/ecosystem/checkEcosystemGridFeasibility.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - feasibility LPs on a six-reaction community model, every available LP solver
%     among gurobi and glpk.
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
fileDir = fileparts(which('testCheckEcosystemGridFeasibility'));
cd(fileDir);

% the solver set-up may create global variables; those created here are removed at the end
globalsBefore = who('global');

% require an LP solver; skip gracefully if none is available
solvers = prepareTest('needsLP', true, 'useSolversIfAvailable', {'gurobi', 'glpk'});
initialSolverState = CobraSolverState.get();

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
% the hand-built grid, f varying fastest, without (0, 0), and its member fractions
eco.points = [0.5, 0; 1, 0; 0, 5; 0.5, 5; 1, 5; 0, 10; 0.5, 10; 1, 10];
eco.pfractions = [eco.points(:, 1), 1 - eco.points(:, 1)];

% feasibility derived by hand (see Purpose)
expectedScaled = logical([1; 1; 0; 1; 1; 0; 0; 1]);
expectedUnscaled = logical([1; 1; 0; 1; 1; 0; 0; 0]);

for k = 1:numel(solvers.LP)
    solverOK = changeCobraSolver(solvers.LP{k}, 'LP', 0);
    if ~solverOK
        continue
    end
    fprintf('   Testing checkEcosystemGridFeasibility using %s ... \n', solvers.LP{k});

    %% defaults: bounds scaled by the member fractions, every point analysed, summary printed
    [ecoChecked, feasiblePoints] = checkEcosystemGridFeasibility(eco);
    assert(isequal(feasiblePoints, expectedScaled));
    assert(isequal(ecoChecked.feasiblePoints, expectedScaled));
    % only the field feasiblePoints is added
    assert(isequal(rmfield(ecoChecked, 'feasiblePoints'), eco));

    %% updateBounds false: the maintenance of member 2 stays 1 at every point
    [~, feasiblePoints] = checkEcosystemGridFeasibility(eco, 'updateBounds', false, 'printLevel', 0);
    assert(isequal(feasiblePoints, expectedUnscaled));

    %% the stored fractions are used: fractions of 1 leave the bounds as they are
    % and an empty pfractions falls back to [f, 1 - f]
    ecoUnitFractions = eco;
    ecoUnitFractions.pfractions = ones(8, 2);
    [~, feasiblePoints] = checkEcosystemGridFeasibility(ecoUnitFractions, 'printLevel', 0);
    assert(isequal(feasiblePoints, expectedUnscaled));
    ecoNoFractions = eco;
    ecoNoFractions.pfractions = [];
    [~, feasiblePoints] = checkEcosystemGridFeasibility(ecoNoFractions, 'printLevel', 0);
    assert(isequal(feasiblePoints, expectedScaled));

    %% pointIndex: only the listed points are analysed, the others are infeasible
    % numeric indices, then a logical mask with each point printed (printLevel 2)
    analysed = [2; 4; 6; 8];
    expectedSubset = false(8, 1);
    expectedSubset(analysed) = expectedScaled(analysed);
    [~, feasiblePoints] = checkEcosystemGridFeasibility(eco, 'pointIndex', analysed, 'printLevel', 0);
    assert(isequal(feasiblePoints, expectedSubset));
    pointMask = false(8, 1);
    pointMask(analysed) = true;
    [~, feasiblePoints] = checkEcosystemGridFeasibility(eco, 'pointIndex', pointMask, 'printLevel', 2);
    assert(isequal(feasiblePoints, expectedSubset));
end

%% errors: no grid yet, invalid inputs (no solver call is reached)
ecoNoGrid = eco;
ecoNoGrid.points = [];
assert(verifyCobraFunctionError('checkEcosystemGridFeasibility', 'inputs', {ecoNoGrid}, ...
    'testMessage', 'Grid points are not set yet! Run buildEcosystemGrid first.'));
% the input parser rejects a structure without points and a text pointIndex
assert(verifyCobraFunctionError('checkEcosystemGridFeasibility', 'inputs', {rmfield(eco, 'points')}));
assert(verifyCobraFunctionError('checkEcosystemGridFeasibility', 'inputs', {eco, 'pointIndex', 'all'}));

% restore the solver state, remove the globals created by the solver set-up, restore the
% directory
CobraSolverState.restore(initialSolverState);
newGlobals = setdiff(who('global'), globalsBefore);
for i = 1:numel(newGlobals)
    clear('global', newGlobals{i});
end
cd(currentDir)
