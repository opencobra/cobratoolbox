% The COBRAToolbox: testEcosystemToy.m
%
% Purpose:
%     - tests the functions of src/analysis/ecosystem on the toy community of
%       Jiménez et al. (2023): construction of the community model, grid,
%       feasibility, qualitative FVA, clustering and representative states.
%       Expected values are those of the notebook sup_toy_example.ipynb.
%
% Authors:
%     - Sebastián N. Mendoza, 13/10/2026
%     - COBRA test format (prepareTest, solver loop, wrong inputs): Sebastián N. Mendoza, 19/10/2026
%

global CBTDIR

% require an LP solver (no MATLAB toolbox is needed)
solvers = prepareTest('needsLP', true, 'useSolversIfAvailable', {'glpk', 'gurobi', 'ibm_cplex', 'mosek'});

% save the current path and initialize the test
currentDir = cd(fileparts(which(mfilename)));

% set the tolerance
tol = 1e-6;

% build member models
org1 = createModel();
org1 = addReaction(org1, 'Atr', 'reactionFormula', 'A_e -> A_c', 'printLevel', 0);
org1 = addReaction(org1, 'EX_A', 'reactionFormula', 'A_e -> ', 'lowerBound', -1000, 'printLevel', 0);
org1 = addReaction(org1, 'Btr', 'reactionFormula', 'B_e -> B_c', 'printLevel', 0);
org1 = addReaction(org1, 'EX_B', 'reactionFormula', 'B_e -> ', 'printLevel', 0);
org1 = addReaction(org1, 'AE', 'reactionFormula', 'A_c -> E_c', 'printLevel', 0);
org1 = addReaction(org1, 'AD', 'reactionFormula', 'A_c -> D_c', 'printLevel', 0);
org1 = addReaction(org1, 'DG', 'reactionFormula', 'D_c -> 4 G_c', 'printLevel', 0);
org1 = addReaction(org1, 'EG', 'reactionFormula', 'E_c -> 2 G_c', 'printLevel', 0);
org1 = addReaction(org1, 'BG', 'reactionFormula', 'B_c -> 10 G_c', 'printLevel', 0);
org1 = addReaction(org1, 'Gbio', 'reactionFormula', 'G_c -> biom1_c', 'printLevel', 0);
org1 = addReaction(org1, 'biomass', 'reactionFormula', 'biom1_c -> ', 'printLevel', 0);
org1 = changeObjective(org1, 'biomass');
org2 = createModel();
org2 = addReaction(org2, 'Atr', 'reactionFormula', 'A_e -> A_c', 'printLevel', 0);
org2 = addReaction(org2, 'EX_A', 'reactionFormula', 'A_e -> ', 'lowerBound', -1000, 'printLevel', 0);
org2 = addReaction(org2, 'EX_B', 'reactionFormula', 'B_e -> ', 'printLevel', 0);
org2 = addReaction(org2, 'AB', 'reactionFormula', 'A_c -> B_c', 'printLevel', 0);
org2 = addReaction(org2, 'Btr', 'reactionFormula', 'B_c -> B_e', 'printLevel', 0);
org2 = addReaction(org2, 'BC', 'reactionFormula', 'B_c -> 10 C_c', 'printLevel', 0);
org2 = addReaction(org2, 'Cbio', 'reactionFormula', 'C_c -> biom2_c', 'printLevel', 0);
org2 = addReaction(org2, 'biomass', 'reactionFormula', 'biom2_c -> ', 'printLevel', 0);
org2 = changeObjective(org2, 'biomass');

% community model (no solver needed)
eco = createEcosystemModel({org1, org2}, {'org1', 'org2'}, 'printLevel', 0);
assert(numel(eco.model.rxns) == 23);
assert(numel(eco.exchangeInfo.mets) == 4);
assert(isequal(sort(eco.objectives), {'org1_biomass'; 'org2_biomass'}));
assert(all(ismember({'EX_A_e', 'EX_B_e', 'EX_biom1_c', 'EX_biom2_c'}, eco.model.rxns)));

% qualitative states
assert(isequal(getQualitativeFluxStates([-2 -1 -1 0 0 1 1 -1 NaN], [-1 -1 0 0 1 1 2 1 NaN], 1e-9), ...
    [-2 -3 -1 0 1 3 2 4 5]));
assert(isequal(qualitativeStateLabels([-3 -2 -1 0 1 2 3 4]), {'-', '--', '-0', '0', '0+', '++', '+', '-+'}));

% wrong inputs
assert(verifyCobraFunctionError('createEcosystemModel', 'inputs', {{org1, org2}, {'org1'}}, ...
    'testMessage', 'The number of prefixes (1) must be equal to the number of models (2).'));
assert(verifyCobraFunctionError('createEcosystemModel', 'inputs', {{org1, org2}, {'org', 'org'}}, ...
    'testMessage', 'Prefixes must be unique.'));
assert(verifyCobraFunctionError('getQualitativeFluxStates', 'inputs', {[1 2], [1 2 3], 1e-9}, ...
    'testMessage', 'minFlux and maxFlux must be numeric arrays of the same size.'));
assert(verifyCobraFunctionError('clusterEcosystemPoints', 'inputs', {eco}));
modelNoBounds = rmfield(org1, 'lb');
assert(verifyCobraFunctionError('createEcosystemModel', 'inputs', {{modelNoBounds, org2}, {'org1', 'org2'}}));
modelTwoObjectives = org1;
modelTwoObjectives.c(1:2) = 1;
assert(verifyCobraFunctionError('createEcosystemModel', 'inputs', {{modelTwoObjectives, org2}, {'org1', 'org2'}}));
assert(verifyCobraFunctionError('setEcosystemPoolBounds', 'inputs', {eco, {'A_e'}}));
assert(verifyCobraFunctionError('setEcosystemPoolBounds', 'inputs', {1, {'A_e'}, [0 1]}));
assert(verifyCobraFunctionError('setEcosystemPoolBounds', 'inputs', {eco, 1, [0 1]}));
assert(verifyCobraFunctionError('setEcosystemPoolBounds', 'inputs', {eco, {'A_e'}, [0 1 2]}));
assert(verifyCobraFunctionError('setEcosystemPoolBounds', 'inputs', {eco, {'A_e', 'B_e', 'C_e'}, [0 1; 0 1]}));
assert(verifyCobraFunctionError('setEcosystemPoolBounds', 'inputs', {eco, {'A_e'}, [0 1], [1 2]}));
assert(verifyCobraFunctionError('setEcosystemPoolBounds', 'inputs', {eco, {'A_e'}, [1 0]}));
warningState = warning('off', 'all');
lastwarn('');
ecoPool = setEcosystemPoolBounds(eco, 'missing_e', [0 1]);
assert(~isempty(lastwarn()) && isequal(ecoPool.model.lb, eco.model.lb));
warning(warningState);
ecoNoGrid = eco;
ecoNoGrid.points = [];
assert(verifyCobraFunctionError('checkEcosystemGridFeasibility', 'inputs', {ecoNoGrid}));
assert(verifyCobraFunctionError('ecosystemQualitativeFVA', 'inputs', {ecoNoGrid}));
% verbose construction with metabolite and reaction annotations; the exchange
% metabolite A_e has different formulas in the two members (conflict)
org1Annotated = org1;
org1Annotated.metFormulas = repmat({'C'}, numel(org1.mets), 1);
org1Annotated.metCharges = zeros(numel(org1.mets), 1);
org1Annotated.rxnNames = org1.rxns;
org1Annotated.subSystems = repmat({'S1'}, numel(org1.rxns), 1);
org1Annotated.modelID = 'org1';
org2Annotated = org2;
org2Annotated.metFormulas = repmat({'H'}, numel(org2.mets), 1);
if isfield(org2Annotated, 'metNames')
    org2Annotated = rmfield(org2Annotated, 'metNames');
end
ecoAnnotated = createEcosystemModel({org1Annotated, org2Annotated}, {'org1', 'org2'}, 'communityName', 'toy', ...
    'communityID', 'toy', 'printLevel', 1);
assert(any(strcmp(ecoAnnotated.conflicts, 'A_e')) && numel(ecoAnnotated.model.rxns) == 23);

% representative states of the notebook
expected = {'-0', '--', '--', '--', '-', '-', '--', '0'; ...
    '0+', '0+', '0+', '0+', '0', '0', '0', '0'; ...
    '0', '0', '+', '+', '+', '0', '+', '0'; ...
    '0', '+', '+', '+', '+', '+', '0', '0'; ...
    '0', '0', '-0', '-0', '0', '0', '--', '0'; ...
    '0', '0', '-0', '--', '-', '0', '0', '0'; ...
    '-0', '--', '--', '--', '-', '-', '0', '0'; ...
    '0+', '0+', '0+', '++', '+', '0', '0', '0'};

for k = 1:numel(solvers.LP)
    fprintf(' -- Running testEcosystemToy using the solver interface: %s ... ', solvers.LP{k});
    solverOK = changeCobraSolver(solvers.LP{k}, 'LP', 0);
    if solverOK
        % simulation conditions and grid
        ecoK = setEcosystemPoolBounds(eco, {'A_e'}, [-10 1000], -20);
        ecoK = setEcosystemPoolBounds(ecoK, {'B_e'}, [0 1000], -20);
        ecoK = setEcosystemClusterReactions(ecoK, 'printLevel', 0);
        assert(numel(ecoK.rxn2cluster) == 23);
        ecoK = buildEcosystemGrid(ecoK, 'numPoints', 10, 'printLevel', 0);
        assert(size(ecoK.points, 1) == 99);
        assert(abs(ecoK.maxCommunityGrowth - 100) < tol);
        ecoK = checkEcosystemGridFeasibility(ecoK, 'printLevel', 0);
        assert(sum(ecoK.feasiblePoints) == 82);

        % qualitative FVA of the exchange reactions, clustering and representative states
        ecoK.rxn2cluster = ecoK.rxn2cluster(contains(ecoK.rxn2cluster, 'EX_'));
        ecoK = ecosystemQualitativeFVA(ecoK, 'printLevel', 0);
        ecoK = clusterEcosystemPoints(ecoK, 'k', 8, 'printLevel', 0);
        [repTable, repValues, rxnIds] = getEcosystemClusterReactionValues(ecoK, 'thr', 0.8);
        assert(isequal(rxnIds, {'EX_A_e'; 'EX_B_e'; 'EX_biom1_c'; 'EX_biom2_c'; 'org1_EX_A'; 'org1_EX_B'; 'org2_EX_A'; 'org2_EX_B'}));
        assert(isequal(repTable{:, :}, expected));
        compTable = compareEcosystemClusters(repValues, rxnIds, 'c3', 'c4');
        assert(isequal(compTable.Properties.RowNames, {'org1_EX_B'; 'org2_EX_B'}));
        assert(isequal(compTable{:, :}, {'-0', '--'; '0+', '++'}));

        % quantitative flux coupling at a single point
        qfca = quantitativeFluxCoupling(ecoK, 0.2, 60, {'org1_EX_A', 'org2_EX_A'}, 'nSteps', 5, 'printLevel', 0);
        assert(height(qfca) == 10);
        assert(strcmp(qfca.point{1}, '[0.222, 55.556]'));

        % options: subsets of points (logical indices), reaction lists, verbose output
        pointMask = false(size(ecoK.points, 1), 1);
        pointMask(ecoK.qualPointIndex(1:3)) = true;
        ecoSubset = checkEcosystemGridFeasibility(ecoK, 'pointIndex', pointMask, 'updateBounds', false, 'printLevel', 2);
        assert(isequal(ecoSubset.feasiblePoints(pointMask), ecoK.feasiblePoints(pointMask)));
        ecoSubset = ecosystemQualitativeFVA(ecoK, 'pointIndex', pointMask, 'rxnList', {'EX_A_e', 'EX_B_e'}, ...
            'updateBounds', false, 'threads', 1, 'printLevel', 2);
        assert(isequal(size(ecoSubset.qualVectors), [3 2]));
        ecoNoFeasibility = ecoK;
        ecoNoFeasibility.feasiblePoints = [];
        ecoNoFeasibility = ecosystemQualitativeFVA(ecoNoFeasibility, 'rxnList', {'EX_A_e'}, 'printLevel', 1);
        % infeasible points of the full grid get the qualitative state 5
        assert(size(ecoNoFeasibility.qualVectors, 1) == size(ecoK.points, 1));
        assert(all(ecoNoFeasibility.qualVectors(~ecoK.feasiblePoints) == 5));
        assert(all(ecoNoFeasibility.qualVectors(ecoK.feasiblePoints) ~= 5));
        ecoNoReactions = ecoK;
        ecoNoReactions.rxn2cluster = {};
        ecoNoReactions = ecosystemQualitativeFVA(ecoNoReactions, 'pointIndex', ecoK.qualPointIndex(1), 'printLevel', 1);
        assert(numel(ecoNoReactions.rxn2cluster) == 23);
        assert(verifyCobraFunctionError('ecosystemQualitativeFVA', 'inputs', {ecoK, 'rxnList', {'missing'}, 'printLevel', 0}));
        ecoSelected = setEcosystemClusterReactions(ecoK, 'rxnList', {'EX_A_e', 'EX_B_e'}, 'printLevel', 1);
        assert(isequal(ecoSelected.rxn2cluster, {'EX_A_e'; 'EX_B_e'}));
        ecoAll = setEcosystemClusterReactions(ecoK, 'printLevel', 1);
        assert(numel(ecoAll.rxn2cluster) == 23);
        assert(verifyCobraFunctionError('setEcosystemClusterReactions', 'inputs', {ecoK, 'rxnList', {'missing'}}));
        % representative states of selected reactions, clusters without points and wrong inputs
        repTableSubset = getEcosystemClusterReactionValues(ecoK, 'thr', 0.8, 'changing', false, 'rxnList', {'EX_A_e', 'EX_B_e'});
        assert(height(repTableSubset) == 2);
        ecoGap = ecoK;
        ecoGap.clusters(ecoGap.clusters == 2) = 9;
        ecoGap.k = [];
        repTableGap = getEcosystemClusterReactionValues(ecoGap, 'thr', 0.8, 'changing', false);
        assert(width(repTableGap) == 9);
        assert(verifyCobraFunctionError('getEcosystemClusterReactionValues', 'inputs', {ecoK, 'rxnList', {'missing'}}));
        assert(verifyCobraFunctionError('getEcosystemClusterReactionValues', 'inputs', {setfield(ecoK, 'clusters', [])}));
        assert(verifyCobraFunctionError('getEcosystemClusterReactionValues', 'inputs', {setfield(ecoK, 'clusters', [1; 2])}));
    end
    fprintf('Done.\n');
end

% change the directory
cd(currentDir)
