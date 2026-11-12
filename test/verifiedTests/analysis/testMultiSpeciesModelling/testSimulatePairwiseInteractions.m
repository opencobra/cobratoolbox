% The COBRAToolbox: testSimulatePairwiseInteractions.m
%
% Purpose:
%     - ensure that pairwise and single growth rates are predicted and
%     correctly interpreted in the function simulatePairwiseInteractions.
%
%       tests the following: if the interaction was interpreted beneficial for
%       one species,the growth rate for the species has to be at least 10% higher
%       in co-growth compared with single growth. If the interaction was
%       interpreted detrimental for one species,the growth rate for the species
%       has to be at least 10% lower in co-growth than in single growth. If the
%       interaction was considered neutral for one species, the growth rate has
%       to differ by less than 10% in co-growth compared with single growth.
%
%     - Everything the function and its parallel pool write stays in a temporary folder. Without
%       a pool, the parfor loop of the function would open one with job files under
%       ~/.matlab/local_cluster_jobs, so the test opens a pool of one worker with its job storage
%       in the temporary folder. The check for an empty CBT_LP_SOLVER calls initCobraToolbox,
%       which would write ~/.matlab/.../pathdef.m through savepath, so a stand-in is used there.
%     - Every outcome of the interpretation is reached with stand-ins for solveCobraLP, which
%       deliver prescribed growth rates and solver status from toy models: real pairs of
%       reconstructions show only a few outcomes, and some (no growth at all) never.
%
% Function under test:
%     src/analysis/multiSpecies/microbiomeModelingToolbox/pairwiseInteractionModeling/simulatePairwiseInteractions.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - optimisation; five AGORA reconstructions, because joinModelsPairwiseFromList needs
%     microbe reconstructions, and hand-written toy models. LP solver required.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Author:
%     - Almut Heinken - March 2017
%     - CI integration - Laurent Heirendt - March 2017
%     - renamed script from testSimulationPairwiseInteractions to
%       testSimulatePairwiseInteractions and adapted to the new module
%       Microbiome_Modeling_Toolbox - Almut Heinken - 02/2018
%     - Coverage completed by feature 20261104-115314-test-coverage-100, 2026-11-04.

currentDir = pwd;

fileDir = fileparts(which('testSimulatePairwiseInteractions'));
cd(fileDir);

% require an LP solver; skip gracefully if none is available. Only solvers that work here are
% tried: changeCobraSolver on a TOMLAB without licence leaves TOMLAB's gurobi.m first on the path
solvers = prepareTest('needsLP', true);
allSolvers = prepareTest('needsLP', true, 'useSolversIfAvailable', {'gurobi', 'tomlab_cplex', 'glpk'});

% work in a temporary folder, which is removed at the end or when the test fails
global CBT_LP_SOLVER
sandboxDir = tempname;
mkdir(sandboxDir);
cd(sandboxDir);
sandboxDir = pwd;  % the folder name as MATLAB reports it
startPath = path;
startSolver = CBT_LP_SOLVER;
leaveSandbox = onCleanup(@() cleanUpSandbox(currentDir, sandboxDir, startPath, startSolver));

% open a pool with its job storage in the temporary folder, see the header
if isParallelToolboxAvailable() && isempty(getParallelPool())
    poolCluster = parcluster('local');
    poolCluster.JobStorageLocation = sandboxDir;
    parpool(poolCluster, 1);
    % the sandbox is active: the job files of the pool are not in the home folder
    assert(strcmp(poolCluster.JobStorageLocation, sandboxDir));
end

% if the pairedModelInfo file does not exist yet, build the models first
if ~exist('pairedModelInfo', 'var')
    modelList={
        'Abiotrophia_defectiva_ATCC_49176';
        'Acidaminococcus_fermentans_DSM_20731';
        'Acidaminococcus_intestini_RyC_MR95';
        'Acinetobacter_calcoaceticus_PHEA_2';
        'Acinetobacter_baumannii_AB0057'
        };
    for i=1:length(modelList)
        model = getDistributedModel([modelList{i} '.mat']);
        % Save all the models into the modelFolder
        save(fullfile(sandboxDir, modelList{i}), 'model');
    end
    joinModelsPairwiseFromList(modelList, sandboxDir, 'pairwiseModelFolder', sandboxDir);
    % Load pairedModelInfo
    load('pairedModelInfo.mat');
end

% define the solver packages to be used to run this test
solverPkgs = allSolvers.LP;

% Feature 002: interaction interpretation is solver-independent, so validate on
% a single representative (default) LP solver in fast mode; full mode keeps the
% complete cross-solver loop.
if getCobraTestMode('isFast')
    solverPkgs = solvers.LP;
end

for p = 1:length(solverPkgs)

    solverOK = changeCobraSolver(solverPkgs{p}, 'LP', 0);

    if solverOK == 1

        fprintf('   Testing simulation of pairwise interactions using %s ... ', solverPkgs{p});
        sigD = 0.1;
        % launch the simulation for pairwise interactions
        [pairwiseInteractions]=simulatePairwiseInteractions(pwd,'sigD',sigD);

        for i = 2:size(pairwiseInteractions, 1)
            if strcmp(pairwiseInteractions{i, 8}, 'Competition')
                assert((abs(pairwiseInteractions{i, 6} / pairwiseInteractions{i, 4})) - 1 > sigD)
                assert((abs(pairwiseInteractions{i, 7} / pairwiseInteractions{i, 5})) - 1 > sigD)
                assert(strcmp(pairwiseInteractions{i, 9}, 'Competition'))
                assert(strcmp(pairwiseInteractions{i, 10}, 'Competition'))
            end
            if strcmp(pairwiseInteractions{i, 8}, 'Parasitism_Giver')
                assert((abs(pairwiseInteractions{i, 6} / pairwiseInteractions{i, 4})) - 1 > sigD)
                assert((abs(pairwiseInteractions{i, 5} / pairwiseInteractions{i, 7})) - 1 > sigD)
                assert(strcmp(pairwiseInteractions{i, 9}, 'Parasitism_Taker'))
                assert(strcmp(pairwiseInteractions{i, 10}, 'Parasitism'))
            end
            if strcmp(pairwiseInteractions{i, 8}, 'Parasitism_Taker')
                assert((abs(pairwiseInteractions{i, 4} / pairwiseInteractions{i, 6})) - 1 > sigD)
                assert((abs(pairwiseInteractions{i, 7} / pairwiseInteractions{i, 5})) - 1 > sigD)
                assert(strcmp(pairwiseInteractions{i, 9}, 'Parasitism_Giver'))
                assert(strcmp(pairwiseInteractions{i, 10}, 'Parasitism'))
            end
            if strcmp(pairwiseInteractions{i, 8}, 'Amensalism_Affected')
                assert((abs(pairwiseInteractions{i, 6} / pairwiseInteractions{i, 4})) - 1 > sigD)
                assert(1 - (abs(pairwiseInteractions{i, 5} / pairwiseInteractions{i, 7})) < sigD)
                assert(strcmp(pairwiseInteractions{i, 9}, 'Amensalism_Unaffected'))
                assert(strcmp(pairwiseInteractions{i, 10}, 'Amensalism'))
            end
            if strcmp(pairwiseInteractions{i, 8}, 'Amensalism_Unaffected')
                assert(abs(1 - (pairwiseInteractions{i, 4} / pairwiseInteractions{i, 6})) < sigD)
                assert((abs(pairwiseInteractions{i, 7} / pairwiseInteractions{i, 5})) - 1 > sigD)
                assert(strcmp(pairwiseInteractions{i, 9}, 'Amensalism_Affected'))
                assert(strcmp(pairwiseInteractions{i, 10}, 'Amensalism'))
            end
            if strcmp(pairwiseInteractions{i, 8}, 'Neutralism')
                assert(abs(1 - (pairwiseInteractions{i, 4} / pairwiseInteractions{i, 6})) < sigD)
                assert(abs(1 - (pairwiseInteractions{i, 5} / pairwiseInteractions{i, 7})) < sigD)
                assert(strcmp(pairwiseInteractions{i, 9}, 'Neutralism'))
                assert(strcmp(pairwiseInteractions{i, 10}, 'Neutralism'))
            end
            if strcmp(pairwiseInteractions{i, 8}, 'Commensalism_Taker')
                assert((abs(pairwiseInteractions{i, 4} / pairwiseInteractions{i, 6})) - 1 > sigD)
                assert(abs(1 - (pairwiseInteractions{i, 5} / pairwiseInteractions{i, 7})) < sigD)
                assert(strcmp(pairwiseInteractions{i, 9}, 'Commensalism_Giver'))
                assert(strcmp(pairwiseInteractions{i, 10}, 'Commensalism'))
            end
            if strcmp(pairwiseInteractions{i, 8}, 'Commensalism_Giver')
                assert(abs(1 - (pairwiseInteractions{i, 4} / pairwiseInteractions{i, 6})) < sigD)
                assert((abs(pairwiseInteractions{i, 5} / pairwiseInteractions{i, 7})) - 1 > sigD)
                assert(strcmp(pairwiseInteractions{i, 9}, 'Commensalism_Taker'))
                assert(strcmp(pairwiseInteractions{i, 10}, 'Commensalism'))
            end
            if strcmp(pairwiseInteractions{i, 8}, 'Mutualism')
                assert((abs(pairwiseInteractions{i, 4} / pairwiseInteractions{i, 6})) - 1 > sigD)
                assert((abs(pairwiseInteractions{i, 5} / pairwiseInteractions{i, 7})) - 1 > sigD)
                assert(strcmp(pairwiseInteractions{i, 9}, 'Mutualism'))
                assert(strcmp(pairwiseInteractions{i, 10}, 'Mutualism'))
            end
        end

    end
end

%% wrong input: a folder without pairedModelInfo.mat is refused
emptyFolder = fullfile(sandboxDir, 'empty');
mkdir(emptyFolder);
assert(verifyCobraFunctionError('simulatePairwiseInteractions', 'inputs', {emptyFolder}, ...
    'testMessage', 'Pairwise models have not been created. Please run joinModelsPairwiseFromList first.'));

%% stand-in for solveCobraLP that delivers prescribed growth rates
% The toy paired models have the biomass reactions org1_biomass and org2_biomass. Their other
% reactions only carry numbers in their upper bounds: the paired growth of both organisms, the
% single growth of both organisms and the solver status. The stand-in tells the three problems
% of one pair apart by the objective.
standInDir = fullfile(sandboxDir, 'standIns');
mkdir(standInDir);
fid = fopen(fullfile(standInDir, 'solveCobraLP.m'), 'w');
fprintf(fid, '%s\n', ...
    'function solution = solveCobraLP(problem, varargin)', ...
    '% stand-in written by testSimulatePairwiseInteractions', ...
    'numbers = full(problem.ub);', ...
    'solution.stat = numbers(7);', ...
    'solution.full = zeros(size(problem.c));', ...
    'if nnz(problem.c) == 2', ...
    '    solution.full(1:2) = numbers(3:4);', ...
    'elseif problem.c(1) ~= 0', ...
    '    solution.full(1) = numbers(5);', ...
    'else', ...
    '    solution.full(2) = numbers(6);', ...
    'end', ...
    'end');
fclose(fid);
addpath(standInDir);
rehash path
% the sandbox is active: the calls below reach the stand-in
assert(startsWith(which('solveCobraLP'), standInDir));

%% every outcome of the interpretation, with paired and single growth of both organisms
sigD = 0.1;
% paired 1, paired 2, single 1, single 2, solver status, outcome 1, outcome 2, total outcome
scenarios = {
    1,   1,   1, 1, 1, 'Neutralism',            'Neutralism',            'Neutralism'
    1,   2,   1, 1, 1, 'Commensalism_Giver',    'Commensalism_Taker',    'Commensalism'
    1, 0.5,   1, 1, 1, 'Amensalism_Unaffected', 'Amensalism_Affected',   'Amensalism'
    1,   0,   1, 0, 1, 'No_Result',             'No_Result',             'No_Result'
    2,   1,   1, 1, 1, 'Commensalism_Taker',    'Commensalism_Giver',    'Commensalism'
    2,   2,   1, 1, 1, 'Mutualism',             'Mutualism',             'Mutualism'
    2, 0.5,   1, 1, 1, 'Parasitism_Taker',      'Parasitism_Giver',      'Parasitism'
    2,   0,   1, 0, 1, 'No_Result',             'No_Result',             'No_Result'
    0.5, 1,   1, 1, 1, 'Amensalism_Affected',   'Amensalism_Unaffected', 'Amensalism'
    0.5, 2,   1, 1, 1, 'Parasitism_Giver',      'Parasitism_Taker',      'Parasitism'
    0.5, 0.5, 1, 1, 1, 'Competition',           'Competition',           'Competition'
    0.5, 0,   1, 0, 1, 'No_Result',             'No_Result',             'No_Result'
    0,   1,   0, 1, 1, 'No_Result',             'No_Result',             'No_Result'
    1,   1,   1, 1, 0, 'Infeasible',            'Infeasible',            'Infeasible'
    };
nScenarios = size(scenarios, 1);
toyFolder = fullfile(sandboxDir, 'toyPairs');
mkdir(toyFolder);
pairedModelInfo = cell(nScenarios, 5);
for i = 1:nScenarios
    pairedModel = buildToyPairedModel(cell2mat(scenarios(i, 1:5)));
    pairedModelInfo(i, :) = {sprintf('pairedModel_%d.mat', i), 'org1', 'biomass', 'org2', 'biomass'};
    save(fullfile(toyFolder, pairedModelInfo{i, 1}), 'pairedModel');
end
save(fullfile(toyFolder, 'pairedModelInfo.mat'), 'pairedModelInfo');

[pairwiseInteractions, pairwiseSolutions] = simulatePairwiseInteractions(toyFolder, ...
    'sigD', sigD, 'saveSolutionsFlag', true);

% the outcomes in the table are the expected ones, for each organism and for the pair
assert(isequal(pairwiseInteractions(2:end, 8:10), scenarios(:, 6:8)));
% the growth rates are reported as they were delivered, feasible or not
feasible = cell2mat(scenarios(:, 5)) == 1;
assert(isequal(cell2mat(pairwiseInteractions([false; feasible], 4:7)), cell2mat(scenarios(feasible, 1:4))));

% the solutions are stored per pair: the paired, the first and the second single solve
assert(isequal(pairwiseSolutions(1, :), {'pairedModelID', 'PairwiseSolution', ...
    'SingleModel1Solution', 'SingleModel2Solution'}));
assert(isequal(pairwiseSolutions(2:end, 1), pairedModelInfo(:, 1)));
for i = 1:nScenarios
    assert(isequal(pairwiseSolutions{i + 1, 2}(1:2), cell2mat(scenarios(i, 1:2))'));
    assert(pairwiseSolutions{i + 1, 3}(1) == scenarios{i, 3});
    assert(pairwiseSolutions{i + 1, 4}(2) == scenarios{i, 4});
end

% without the flag no solutions are returned
[~, pairwiseSolutions] = simulatePairwiseInteractions(toyFolder);
assert(isempty(pairwiseSolutions));

%% with numWorkers, a pool of that size is requested when none is open
poolStandInDir = fullfile(sandboxDir, 'poolStandIns');
mkdir(poolStandInDir);
fid = fopen(fullfile(poolStandInDir, 'getParallelPool.m'), 'w');
fprintf(fid, '%s\n', 'function pool = getParallelPool()', 'pool = [];', 'end');
fclose(fid);
fid = fopen(fullfile(poolStandInDir, 'openParallelPool.m'), 'w');
fprintf(fid, '%s\n', 'function pool = openParallelPool(varargin)', ...
    'setappdata(0, ''requestedPool'', varargin);', 'pool = [];', 'end');
fclose(fid);
addpath(poolStandInDir);
rehash path
assert(startsWith(which('openParallelPool'), poolStandInDir));
pairwiseInteractions = simulatePairwiseInteractions(toyFolder, 'numWorkers', 2);
assert(isequal(getappdata(0, 'requestedPool'), {2}));
assert(isequal(pairwiseInteractions(2:end, 8:10), scenarios(:, 6:8)));
rmappdata(0, 'requestedPool');
rmpath(poolStandInDir);
rehash path

%% without a solver in the session, the toolbox is initialized first
% a stand-in, see the header: the real initCobraToolbox writes to the MATLAB preferences folder
sessionSolver = CBT_LP_SOLVER;
initStandInDir = fullfile(sandboxDir, 'initStandIn');
mkdir(initStandInDir);
fid = fopen(fullfile(initStandInDir, 'initCobraToolbox.m'), 'w');
fprintf(fid, '%s\n', 'function initCobraToolbox(varargin)', 'global CBT_LP_SOLVER', ...
    sprintf('CBT_LP_SOLVER = ''%s'';', sessionSolver), 'end');
fclose(fid);
addpath(initStandInDir);
rehash path
% the sandbox is active: nothing below can reach the real initCobraToolbox
assert(startsWith(which('initCobraToolbox'), initStandInDir));
CBT_LP_SOLVER = [];
pairwiseInteractions = simulatePairwiseInteractions(toyFolder);
assert(strcmp(CBT_LP_SOLVER, sessionSolver));
assert(isequal(pairwiseInteractions(2:end, 8:10), scenarios(:, 6:8)));
rmpath(initStandInDir);
rehash path

%% more than 1000 pairs: the intermediate results are saved to the current folder
pairedModelInfo = repmat(pairedModelInfo(1, :), 1001, 1);
save(fullfile(toyFolder, 'pairedModelInfo.mat'), 'pairedModelInfo');
pairwiseInteractions = simulatePairwiseInteractions(toyFolder);
assert(size(pairwiseInteractions, 1) == 1002);
assert(all(strcmp(pairwiseInteractions(2:end, 10), 'Neutralism')));
backup = load(fullfile(sandboxDir, 'growthRates.mat'));
assert(numel(backup.growthRates) == 1001);
assert(exist(fullfile(sandboxDir, 'solutionsTmp.mat'), 'file') == 2);

% leave and remove the temporary folder; the stand-ins go with it
clear leaveSandbox
assert(~startsWith(which('solveCobraLP'), sandboxDir));

% output a success message
fprintf('Done.\n');

% change to the current directory
cd(currentDir)


function pairedModel = buildToyPairedModel(numbers)
    % toy paired model, see the section on the stand-in for solveCobraLP. numbers holds the paired
    % growth of both organisms, their single growth and the solver status
    pairedModel = struct('S', sparse(1, 7), 'mets', {{'A[c]'}}, 'b', 0, 'csense', 'E', ...
        'rxns', {{'org1_biomass'; 'org2_biomass'; 'paired1'; 'paired2'; 'single1'; 'single2'; 'status'}}, ...
        'lb', zeros(7, 1), 'ub', [1; 1; numbers(:)], 'c', zeros(7, 1), 'osenseStr', 'max', ...
        'genes', {cell(0, 1)}, 'rules', {repmat({''}, 7, 1)});
end


function cleanUpSandbox(startDir, sandboxDir, startPath, startSolver)
    % closes a pool whose job files are in the temporary folder, restores the path and the solver
    % of the session and removes the temporary folder, also when the test fails
    global CBT_LP_SOLVER
    cd(startDir);
    path(startPath);
    rehash path
    CBT_LP_SOLVER = startSolver;
    pool = getParallelPool();
    if ~isempty(pool) && strcmp(pool.Cluster.JobStorageLocation, sandboxDir)
        delete(pool);
    end
    if isappdata(0, 'requestedPool')
        rmappdata(0, 'requestedPool');
    end
    rmdir(sandboxDir, 's');
end
