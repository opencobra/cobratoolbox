% The COBRAToolbox: testEcosystemScenarios.m
%
% Purpose:
%     - tests the loading of results of the Python implementation of
%       Jiménez et al. (2023) with loadEcosystemScenario, using small result
%       files of the toy community written in the formats of the Python
%       implementation (pickle, NumPy .npy and cobrapy JSON; folder
%       toyScenarios): feasibility read from the pickle, from batch files or
%       recomputed with the community model
%     - tests the analysis of several scenarios (filterEcosystemScenarios,
%       removeEcosystemPoints, selectEcosystemReactions,
%       matchEcosystemClusters, getEcosystemClusterDescriptor,
%       compareEcosystemClusters) and the plotting functions
%       (plotEcosystemGrid, plotQualitativeStateOverlap,
%       plotQuantitativeFluxCoupling)
%
% Authors:
%     - Sebastián N. Mendoza, 21/10/2026
%

global CBTDIR

% require an LP solver (only to recompute the feasibility and for the flux coupling analysis)
solvers = prepareTest('needsLP', true, 'useSolversIfAvailable', {'glpk', 'gurobi', 'ibm_cplex', 'mosek'});

% save the current path and initialize the test
currentDir = cd(fileparts(which(mfilename)));
testPath = pwd;
scenarioDir = [testPath filesep 'toyScenarios'];
tmpDir = tempname;
mkdir(tmpDir);
figureVisibility = get(0, 'DefaultFigureVisible');
set(0, 'DefaultFigureVisible', 'off');

% set the tolerance
tol = 1e-6;

% representative states of the toy community for k = 8 (notebook sup_toy_example.ipynb)
expected = {'-0', '--', '--', '--', '-', '-', '--', '0'; ...
    '0+', '0+', '0+', '0+', '0', '0', '0', '0'; ...
    '0', '0', '+', '+', '+', '0', '+', '0'; ...
    '0', '+', '+', '+', '+', '+', '0', '0'; ...
    '0', '0', '-0', '-0', '0', '0', '--', '0'; ...
    '0', '0', '-0', '--', '-', '0', '0', '0'; ...
    '-0', '--', '--', '--', '-', '-', '0', '0'; ...
    '0+', '0+', '0+', '++', '+', '0', '0', '0'};

% loading of the result files of the Python implementation
% feasibility from batch files, FVA results and community model (cobrapy JSON)
ecoFiles = loadEcosystemScenario(scenarioDir, 'toy_files', 'batchSize', 40, 'printLevel', 1);
assert(strcmp(ecoFiles.feasibilitySource, 'files') && strcmp(ecoFiles.name, 'toy_files'));
assert(isequal(ecoFiles.prefixes, {'org1'; 'org2'}) && isequal(ecoFiles.objectives, {'org1_biomass'; 'org2_biomass'}));
assert(size(ecoFiles.points, 1) == 99 && sum(ecoFiles.feasiblePoints) == 82);
assert(abs(ecoFiles.maxCommunityGrowth - 100) < tol && isequal(ecoFiles.qualPointIndex, find(ecoFiles.feasiblePoints)));
assert(numel(ecoFiles.rxn2cluster) == 8 && all(contains(ecoFiles.rxn2cluster, 'EX_')));
assert(isequal(size(ecoFiles.qualVectors), [82 8]) && isequal(size(ecoFiles.fvaResults), [82 8 2]));
assert(numel(ecoFiles.model.rxns) == 23 && numel(ecoFiles.model.mets) == 18);
% feasibility from the pickle, without FVA results nor community model
ecoPickle = loadEcosystemScenario(scenarioDir, 'toy_pickle', 'batchSize', 40, 'printLevel', 0);
assert(strcmp(ecoPickle.feasibilitySource, 'pickle') && isempty(ecoPickle.fvaResults) && isempty(ecoPickle.model));
assert(isequal(ecoPickle.feasiblePoints, ecoFiles.feasiblePoints) && isequal(ecoPickle.qualVectors, ecoFiles.qualVectors));
% the representative states of the loaded qualitative vectors are those of the notebook
ecoA = clusterEcosystemPoints(ecoFiles, 'k', 8, 'printLevel', 0);
[repTableA, repValuesA, rxnIdsA] = getEcosystemClusterReactionValues(ecoA, 'thr', 0.8);
[~, order] = sort(rxnIdsA);
assert(isequal(repTableA{order, :}, expected));
% missing files
assert(verifyCobraFunctionError('loadEcosystemScenario', 'inputs', {scenarioDir, 'missing', 'printLevel', 0}));
assert(verifyCobraFunctionError('loadEcosystemScenario', 'inputs', ...
    {scenarioDir, 'toy_recompute', 'batchSize', 40, 'loadModel', false, 'printLevel', 0}));
assert(verifyCobraFunctionError('loadEcosystemScenario', 'inputs', {scenarioDir, 'toy_pickle', 'printLevel', 0}));
copyfile(fullfile(scenarioDir, 'toy_pickle*'), tmpDir);
delete(fullfile(tmpDir, 'toy_pickle_qFVA_feasibleOnly_40_80.npy'));
assert(verifyCobraFunctionError('loadEcosystemScenario', 'inputs', {tmpDir, 'toy_pickle', 'batchSize', 40, 'printLevel', 0}));

% selection of scenarios from the table of simulations
names = {'Alpha', 'Substrate combination', 'input constraint', 'Input Fe', 'Energy level', 'Filename', 'Objective'};
simulations = cell2table({ ...
    '0,2', '0.5_Fe_medium_0.5_S_medium', 'biocons', '0,5', 'Medium', 'sce_a02_biocons_50Fe_50S', ''; ...
    '0,4', '0.5_Fe_medium_0.5_S_medium', 'biocons', '0,5', 'Medium', 'sce_a04_biocons_50Fe_50S', ''; ...
    '0,2', '0.5_Fe_medium_0.5_S_medium', 'uncons', '0,5', 'Medium', 'sce_a02_uncons_50Fe_50S', ''; ...
    '0,2', '0.5_Fe_medium_0.5_S_medium', 'biocons', '0,5', 'Medium', 'sce_a02_biocons_50Fe_50S_maxATP', 'maxATP'; ...
    '0,2', '0.75_Fe_high_0.25_S_high', 'biocons', '0,75', 'High', 'sce_a02_biocons_75Fe_25S', ''; ...
    '0', '0.25_Fe_low_0.75_S_low', 'biocons', '0,25', 'Low', 'sce_a0_biocons_25Fe_75S', ''}, 'VariableNames', names);
scenarios = filterEcosystemScenarios(simulations, struct('alpha', 0.2, 'cons', {{'biocons'}}, ...
    'energy', {{'Medium'}}, 'subCombs', [0.5 0.5]));
assert(isequal(scenarios, {'sce_a02_biocons_50Fe_50S'}));
scenarios = filterEcosystemScenarios(simulations, struct('alpha', 0.2, 'obj', {{'maxATP'}}));
assert(isequal(scenarios, {'sce_a02_biocons_50Fe_50S_maxATP'}));
scenarios = filterEcosystemScenarios(simulations, struct('flag', {{'uncons'}}));
assert(isequal(scenarios, {'sce_a00_biocons_25Fe_75S'; 'sce_a02_biocons_50Fe_50S'; 'sce_a04_biocons_50Fe_50S'; ...
    'sce_a02_biocons_75Fe_25S'}));
simulationsNumeric = simulations;
simulationsNumeric.Alpha = [0.2; 0.4; 0.2; 0.2; 0.2; 0];
assert(numel(filterEcosystemScenarios(simulationsNumeric, struct())) == 5);
% as in the original notebook, a filter without matches (substrate combination) is ignored
scenarios = filterEcosystemScenarios(simulations, struct('subCombs', [0.3 0.7], 'energy', {{'Medium'}}));
assert(isequal(scenarios, {'sce_a02_biocons_50Fe_50S'; 'sce_a02_uncons_50Fe_50S'; 'sce_a04_biocons_50Fe_50S'}));
assert(isempty(filterEcosystemScenarios(simulations, struct('cons', {{'missing'}}, 'flag', {{'sce'}}))));
assert(verifyCobraFunctionError('filterEcosystemScenarios', 'inputs', {simulations}));
assert(verifyCobraFunctionError('filterEcosystemScenarios', 'inputs', {{1}, struct()}));
assert(verifyCobraFunctionError('filterEcosystemScenarios', 'inputs', {simulations(:, 1:3), struct()}));
assert(verifyCobraFunctionError('filterEcosystemScenarios', 'inputs', {simulations, 1}));

% analysis of several scenarios
% removal of points and selection of reactions
ecoRemoved = removeEcosystemPoints(ecoFiles, ecoFiles.qualPointIndex(1:5));
assert(sum(ecoRemoved.feasiblePoints) == 77 && isequal(size(ecoRemoved.qualVectors), [77 8]));
assert(isequal(size(ecoRemoved.fvaResults), [77 8 2]) && isempty(ecoRemoved.clusters));
pointMask = false(99, 1);
pointMask(ecoFiles.qualPointIndex(1:5)) = true;
assert(isequal(removeEcosystemPoints(ecoFiles, pointMask).qualVectors, ecoRemoved.qualVectors));
ecoSelected = selectEcosystemReactions(ecoFiles, ecoFiles.rxn2cluster(1:3));
assert(isequal(size(ecoSelected.qualVectors), [82 3]) && isequal(size(ecoSelected.fvaResults), [82 3 2]));
rxnMask = false(8, 1);
rxnMask(1:3) = true;
assert(isequal(selectEcosystemReactions(ecoFiles, rxnMask).rxn2cluster, ecoFiles.rxn2cluster(1:3)));
assert(verifyCobraFunctionError('removeEcosystemPoints', 'inputs', {ecoFiles}));
assert(verifyCobraFunctionError('removeEcosystemPoints', 'inputs', {struct('points', 1), 1}));
assert(verifyCobraFunctionError('removeEcosystemPoints', 'inputs', {setfield(ecoFiles, 'feasiblePoints', []), 1}));
assert(verifyCobraFunctionError('removeEcosystemPoints', 'inputs', {ecoFiles, true(3, 1)}));
assert(verifyCobraFunctionError('removeEcosystemPoints', 'inputs', {ecoFiles, 1000}));
assert(verifyCobraFunctionError('selectEcosystemReactions', 'inputs', {ecoFiles}));
assert(verifyCobraFunctionError('selectEcosystemReactions', 'inputs', {struct('points', 1), {'EX_A_e'}}));
assert(verifyCobraFunctionError('selectEcosystemReactions', 'inputs', {ecoFiles, true(3, 1)}));
assert(verifyCobraFunctionError('selectEcosystemReactions', 'inputs', {ecoFiles, {'missingReaction'}}));
% clusters of a second clustering matched to those of the first one
ecoB = clusterEcosystemPoints(ecoPickle, 'k', 5, 'printLevel', 0);
[~, repValuesB, rxnIdsB] = getEcosystemClusterReactionValues(ecoB, 'thr', 0.8);
[newClusters, refValues, clusterMap] = matchEcosystemClusters(repValuesA, rxnIdsA, repValuesB, rxnIdsB, ecoB.clusters);
assert(numel(newClusters) == 82 && all(~isnan(newClusters)) && size(refValues, 1) == numel(rxnIdsA));
assert(isequal(newClusters, clusterMap(ecoB.clusters)) && size(refValues, 2) >= size(repValuesA, 2));
[newClusters, refValues] = matchEcosystemClusters(repValuesA, rxnIdsA, repValuesA, rxnIdsA, ecoA.clusters);
assert(isequal(newClusters, ecoA.clusters) && isequal(refValues, repValuesA));
assert(verifyCobraFunctionError('matchEcosystemClusters', 'inputs', {repValuesA, rxnIdsA, repValuesB, rxnIdsB}));
assert(verifyCobraFunctionError('matchEcosystemClusters', 'inputs', {repValuesA, rxnIdsA(1), repValuesB, rxnIdsB, ecoB.clusters}));
assert(verifyCobraFunctionError('matchEcosystemClusters', 'inputs', {repValuesA, rxnIdsA, repValuesB, rxnIdsB(1), ecoB.clusters}));
assert(verifyCobraFunctionError('matchEcosystemClusters', 'inputs', {repValuesA, rxnIdsA, repValuesB, rxnIdsB, {1}}));
warningState = warning('off', 'all');
lastwarn('');
matchEcosystemClusters(repValuesA, rxnIdsA, repValuesB(1, :), {'otherReaction'}, ecoB.clusters);
assert(~isempty(lastwarn()));
warning(warningState);
% cluster descriptors and comparison of clusters
descriptor = getEcosystemClusterDescriptor(repValuesA, rxnIdsA, 'c3');
assert(height(descriptor) == numel(rxnIdsA) && isequal(descriptor, getEcosystemClusterDescriptor(repValuesA, rxnIdsA, 3)));
assert(all(diff(descriptor.diff(~isnan(descriptor.diff))) <= 0));
assert(verifyCobraFunctionError('getEcosystemClusterDescriptor', 'inputs', {repValuesA, rxnIdsA}));
assert(verifyCobraFunctionError('getEcosystemClusterDescriptor', 'inputs', {'x', rxnIdsA, 1}));
assert(verifyCobraFunctionError('getEcosystemClusterDescriptor', 'inputs', {repValuesA, rxnIdsA(1), 1}));
assert(verifyCobraFunctionError('getEcosystemClusterDescriptor', 'inputs', {repValuesA, rxnIdsA, 'c99'}));
compTable = compareEcosystemClusters(repValuesA, rxnIdsA, 3, 4);
assert(isequal(compTable, compareEcosystemClusters(repValuesA, rxnIdsA, 'c3', 'c4')));
assert(isequal(compTable, compareEcosystemClusters(repTableA, {}, 'c3', 'c4')));
assert(verifyCobraFunctionError('compareEcosystemClusters', 'inputs', {repValuesA, rxnIdsA, 3, 3}, ...
    'testMessage', 'The two clusters must be different.'));
assert(verifyCobraFunctionError('compareEcosystemClusters', 'inputs', {repValuesA, rxnIdsA, 3}));
assert(verifyCobraFunctionError('compareEcosystemClusters', 'inputs', {'x', rxnIdsA, 3, 4}));
assert(verifyCobraFunctionError('compareEcosystemClusters', 'inputs', {repValuesA, rxnIdsA(1), 3, 4}));
assert(verifyCobraFunctionError('compareEcosystemClusters', 'inputs', {repValuesA, rxnIdsA, 'c99', 4}));

% plots
modes = {'none', 'feasible', 'cluster', 'communityGrowth', 'memberFraction', 'qualState', 'values'};
for m = 1:numel(modes)
    [ax, plottedPoints, plottedColors] = plotEcosystemGrid(ecoA, 'toPlot', modes{m}, 'rxn', ecoA.rxn2cluster{1}, ...
        'values', (1:82)', 'fracPrefix', 'org2', 'title', modes{m});
    assert(isgraphics(ax, 'axes') && size(plottedPoints, 2) == 2);
    if strcmp(modes{m}, 'none')
        assert(size(plottedPoints, 1) == 99 && isempty(plottedColors));
    else
        assert(numel(plottedColors) == size(plottedPoints, 1));
    end
end
for cmap = {'tab20', 'tab20c', 'parula', [1 0 0; 0 0 1]}
    plotEcosystemGrid(ecoA, 'toPlot', 'cluster', 'colormap', cmap{1}, 'showColorbar', false);
end
figure;
ax = axes();
[axOut, plottedPoints] = plotEcosystemGrid(ecoA, 'toPlot', 'cluster', 'clusters', ecoB.clusters, 'axes', ax, ...
    'saveFile', fullfile(tmpDir, 'grid'));
assert(axOut == ax && size(plottedPoints, 1) == 82 && exist(fullfile(tmpDir, 'grid.png'), 'file') == 2);
assert(verifyCobraFunctionError('plotEcosystemGrid', 'inputs', {ecoFiles, 'toPlot', 'cluster'}));
assert(verifyCobraFunctionError('plotEcosystemGrid', 'inputs', {ecoA, 'toPlot', 'cluster', 'clusters', [1 2]}));
assert(verifyCobraFunctionError('plotEcosystemGrid', 'inputs', {ecoA, 'toPlot', 'qualState', 'rxn', 'missing'}));
assert(verifyCobraFunctionError('plotEcosystemGrid', 'inputs', {ecoA, 'toPlot', 'values', 'values', [1 2]}));
assert(verifyCobraFunctionError('plotEcosystemGrid', 'inputs', {ecoA, 'toPlot', 'memberFraction', 'fracPrefix', 'org3'}));
assert(verifyCobraFunctionError('plotEcosystemGrid', 'inputs', {setfield(ecoA, 'feasiblePoints', []), 'toPlot', 'feasible'}));
assert(verifyCobraFunctionError('plotEcosystemGrid', 'inputs', {setfield(ecoA, 'points', [])}));
% overlap of the qualitative states of two reactions in two scenarios
[fig, stateCodes, stateLabels] = plotQualitativeStateOverlap({ecoFiles, ecoPickle}, ecoFiles.rxn2cluster(1:2), ...
    'titles', {'files', 'pickle'}, 'saveFile', fullfile(tmpDir, 'overlap'));
assert(isgraphics(fig, 'figure') && numel(stateCodes) == numel(stateLabels) && exist(fullfile(tmpDir, 'overlap.png'), 'file') == 2);
[~, stateCodesStruct] = plotQualitativeStateOverlap(ecoFiles, ecoFiles.rxn2cluster{1}, 'colormap', 'tab20', 'showColorbar', false);
assert(~isempty(stateCodesStruct));
assert(verifyCobraFunctionError('plotQualitativeStateOverlap', 'inputs', {{ecoFiles}, {'missing'}}));

for k = 1:numel(solvers.LP)
    fprintf(' -- Running testEcosystemScenarios using the solver interface: %s ... ', solvers.LP{k});
    solverOK = changeCobraSolver(solvers.LP{k}, 'LP', 0);
    if solverOK
        % feasibility recomputed with the community model of the JSON file
        ecoRecomputed = loadEcosystemScenario(scenarioDir, 'toy_recompute', 'batchSize', 40, 'printLevel', 0);
        assert(strcmp(ecoRecomputed.feasibilitySource, 'recomputed'));
        assert(isequal(ecoRecomputed.feasiblePoints(:), ecoFiles.feasiblePoints(:)));
        assert(isequal(ecoRecomputed.qualVectors, ecoFiles.qualVectors));
        % quantitative flux coupling of the loaded scenario and its plot
        qfca = quantitativeFluxCoupling(ecoFiles, [0.3 0.6], 50, {'org1_EX_A', 'org2_EX_A'}, 'nSteps', 4, 'printLevel', 0);
        assert(height(qfca) > 0);
        fig = plotQuantitativeFluxCoupling(qfca, 'colWrap', 2);
        assert(isgraphics(fig, 'figure'));
    end
    fprintf('Done.\n');
end

% close the figures and restore the settings
close all
set(0, 'DefaultFigureVisible', figureVisibility);
rmdir(tmpDir, 's');

% change the directory
cd(currentDir)
