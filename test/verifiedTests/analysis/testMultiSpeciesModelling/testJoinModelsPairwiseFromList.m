% The COBRAToolbox: testJoinModelsPairwiseFromList.m
%
% Purpose:
%     - test that the pairwise models created by function
%       joinModelsPairwiseFromList have all reactions of the respective
%       microbe reconstructions that were joined.
%     - test the optional inputs, every error for wrong inputs, the reuse of pairwise models
%       that already exist and the intermediate save after 1000 pairs, on toy models.
%     - Everything the function and its parallel pool write stays in a temporary folder. Without
%       a pool, the parfor loop of the function would open one with job files under
%       ~/.matlab/local_cluster_jobs, so the test opens a pool of one worker with its job storage
%       in the temporary folder. The check for an empty CBT_LP_SOLVER calls initCobraToolbox,
%       which would write ~/.matlab/.../pathdef.m through savepath, so a stand-in is used there.
%       The branch that opens a pool of numWorkers needs no open pool, so stand-ins of
%       getParallelPool and openParallelPool record the request instead.
%
% Function under test:
%     src/analysis/multiSpecies/microbiomeModelingToolbox/pairwiseInteractionModeling/joinModelsPairwiseFromList.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - optimisation solver selected for the workers; five AGORA reconstructions, because
%     the function is meant for microbe reconstructions, and toy models. LP solver required.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Two models whose file names start with the same model name stop the function
%       SEVERITY: error
%       TRIGGER: a modelFolder holding toyA.mat and toyA2.mat, with toyA in modelList
%       OBSERVED: the search by name prefix returns both files, models{findModID,1} expands to two
%         arguments of contains, and the call stops with "Incorrect number of arguments"
%       EXPECTED: the file named exactly after the model is used
%       LINES: 111, 113-114, 139, 141-142, 157, 159-160
%
% Author:
%     - Almut Heinken - March 2017
%     - CI integration - Laurent Heirendt - March 2017
%     - renamed script from testBuildPairwiseModels to
%       testJoinModelsPairwiseFromList and adapted to the new module
%       Microbiome_Modeling_Toolbox - Almut Heinken - 02/2018
%     - Farid Zare - Feb 2024 Updated test function for latest function
%     changes
%     - Coverage completed by feature 20261104-115314-test-coverage-100, 2026-11-04.

currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testJoinModelsPairwiseFromList'));
cd(fileDir);

% an LP solver is selected on the workers of the parfor loop
solvers = prepareTest('needsLP', true);

fprintf('   Testing joinModelsPairwiseFromList.m ...\n');

% work in a temporary folder, which is removed at the end or when the test fails
global CBT_LP_SOLVER
sandboxDir = tempname;
mkdir(sandboxDir);
cd(sandboxDir);
sandboxDir = pwd;  % the folder name as MATLAB reports it
startPath = path;
startSolver = CBT_LP_SOLVER;
jobFolder = fullfile(sandboxDir, 'poolJobs');
leaveSandbox = onCleanup(@() cleanUpSandbox(currentDir, sandboxDir, jobFolder, startPath, startSolver));

% open a pool with its job storage in the temporary folder, see the header
if isParallelToolboxAvailable() && isempty(getParallelPool())
    mkdir(jobFolder);
    poolCluster = parcluster('local');
    poolCluster.JobStorageLocation = jobFolder;
    parpool(poolCluster, 1);
    % the sandbox is active: the job files of the pool are not in the home folder
    assert(strcmp(poolCluster.JobStorageLocation, jobFolder));
end

% if the pairedModelInfo file does not exist yet, build the models first
if ~exist('pairedModelInfo', 'var')
    % run the script to build the pairwise models
    modelList={
        'Abiotrophia_defectiva_ATCC_49176';
        'Acidaminococcus_fermentans_DSM_20731';
        'Acidaminococcus_intestini_RyC_MR95';
        'Acinetobacter_calcoaceticus_PHEA_2';
        'Acinetobacter_baumannii_AB0057'
        };
    modelFolder = fullfile(sandboxDir, 'models');
    mkdir(modelFolder);
    for i=1:length(modelList)
        model = getDistributedModel([modelList{i} '.mat']);
        % Save all the models into the modelFolder
        save(fullfile(modelFolder, modelList{i}), 'model');
    end
    % without pairwiseModelFolder the pairwise models go to the current folder
    joinModelsPairwiseFromList(modelList, modelFolder);
    % Load pairedModelInfo
    load('pairedModelInfo.mat');
end

% five models give ten pairs, each listed once
assert(size(pairedModelInfo, 1) == 10);

for i = 1:size(pairedModelInfo, 1)
    load(pairedModelInfo{i,1});
    % pairedModel=pairedModels{i};
    for p = [2, 4]
        model = getDistributedModel([pairedModelInfo{i, p} '.mat']);
        tmpStr = [pairedModelInfo{i, p}, '_'];
        assert(length(model.mets) == length(find(strncmp(tmpStr, pairedModel.mets, length(tmpStr)))));
        assert(length(model.rxns) == length(find(strncmp(tmpStr, pairedModel.rxns, length(tmpStr)))));
    end
end

% test the diet call without entering any dietary constraints
assert(verifyCobraFunctionError('useDiet', 'inputs',{pairedModel,[]}))

clear('pairedModelInfo', 'pairedModel', 'model')

%% the optional inputs set the biomass reactions, the coupling and the output folder
toyFolder = fullfile(sandboxDir, 'toyModels');
pairFolder = fullfile(sandboxDir, 'toyPairs');
mkdir(toyFolder);
mkdir(pairFolder);
saveToyModel(toyFolder, 'toyA', 'bio1');
saveToyModel(toyFolder, 'toyB', 'bio2');
saveToyModel(toyFolder, 'noBiomass', 'growth');
fid = fopen(fullfile(toyFolder, 'notAModel.txt'), 'w');
fclose(fid);

toyPair = {'toyA'; 'toyB'};
joinModelsPairwiseFromList(toyPair, toyFolder, 'biomasses', {'bio1'; 'bio2'}, 'c', 200, 'u', 0.5, ...
    'pairwiseModelFolder', pairFolder);
saved = load(fullfile(pairFolder, 'pairedModelInfo.mat'));
pairName = 'pairedModel_toyA_toyB.mat';
assert(isequal(saved.pairedModelInfo, {pairName, 'toyA', 'bio1', 'toyB', 'bio2'}));
pairedToy = load(fullfile(pairFolder, pairName));
pairedToy = pairedToy.pairedModel;
% each microbe keeps its reactions under its name tag, and shares the lumen exchange reaction
assert(all(ismember({'toyA_A_t'; 'toyA_bio1'; 'toyB_A_t'; 'toyB_bio2'; 'EX_a[u]'}, pairedToy.rxns)));
% each reaction is coupled to the biomass reaction of its microbe with the given factor c: the
% coupling row of toyA_A_t has 1 for the reaction and +-200 for the biomass reaction
biomassColumn = strcmp(pairedToy.rxns, 'toyA_bio1');
couplingRows = pairedToy.C(:, strcmp(pairedToy.rxns, 'toyA_A_t')) ~= 0;
assert(any(couplingRows));
assert(all(abs(pairedToy.C(couplingRows, biomassColumn)) == 200));
% and the threshold is the given u
assert(all(abs(pairedToy.d) == 0.5));

% without the input biomasses, the reaction starting with bio is taken
joinModelsPairwiseFromList(toyPair, toyFolder);
saved = load(fullfile(sandboxDir, 'pairedModelInfo.mat'));
assert(isequal(saved.pairedModelInfo, {pairName, 'toyA', 'bio1', 'toyB', 'bio2'}));
pairedToy = load(fullfile(sandboxDir, pairName));
% the coupling defaults are c = 400 and u = 0
assert(all(abs(nonzeros(pairedToy.pairedModel.C(:, strcmp(pairedToy.pairedModel.rxns, 'toyA_bio1')))) == 400));
assert(all(pairedToy.pairedModel.d == 0));
delete(fullfile(sandboxDir, pairName));

%% wrong inputs stop the function with a message
biomassesOfTwo = {'bio1'; 'bio2'};
wrongFormat = 'No model in correct format found in folder!';
notFound = 'Model to load not found in folder!';
wrongBiomass = 'Defined biomass objective functions are not correct!';
wrongInputs = {
    % without the input biomasses, the biomass reactions are read from the models
    {'notAModel'; 'toyA'}, {}, wrongFormat
    {'absent'; 'toyA'}, {}, notFound
    {'noBiomass'; 'toyA'}, {}, 'Please define the biomass objective functions for each model manually through the biomasses input parameter.'
    % the number of biomass reactions has to fit
    toyPair, {'bio1'}, 'Length of biomasses input is not equal to modelList input!'
    % the first model of a pair
    {'notAModel'; 'toyB'}, biomassesOfTwo, wrongFormat
    {'absent'; 'toyB'}, biomassesOfTwo, notFound
    toyPair, {'wrong'; 'bio2'}, wrongBiomass
    % the second model of a pair
    {'toyA'; 'notAModel'}, biomassesOfTwo, wrongFormat
    {'toyA'; 'absent'}, biomassesOfTwo, notFound
    toyPair, {'bio1'; 'wrong'}, wrongBiomass
    };
for i = 1:size(wrongInputs, 1)
    assert(verifyCobraFunctionError('joinModelsPairwiseFromList', 'inputs', ...
        {wrongInputs{i, 1}, toyFolder, 'biomasses', wrongInputs{i, 2}}, ...
        'testMessage', wrongInputs{i, 3}));
end

%% with numWorkers, a pool of that size is requested when none is open
if ~isempty(ver('parallel'))
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
    % the sandbox is active: nothing below can open a real pool
    assert(startsWith(which('openParallelPool'), poolStandInDir));
    joinModelsPairwiseFromList(toyPair, toyFolder, 'numWorkers', 2, 'pairwiseModelFolder', pairFolder);
    assert(isequal(getappdata(0, 'requestedPool'), {2}));
    rmappdata(0, 'requestedPool');
    rmpath(poolStandInDir);
    rehash path
end

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
joinModelsPairwiseFromList(toyPair, toyFolder, 'biomasses', biomassesOfTwo, 'pairwiseModelFolder', pairFolder);
assert(strcmp(CBT_LP_SOLVER, sessionSolver));
rmpath(initStandInDir);
rehash path

%% pairs that exist are kept, and the list of pairs is saved after every 1000 pairs
% 46 models give 1035 pairs. All pairs but the last exist already, as empty files, so only the
% last one is built. It fails because c is not a number but a vector, so the final save of the
% function is never reached: what is on disk then is the intermediate list of 1000 pairs.
manyToys = arrayfun(@(i) sprintf('toy%02d', i), (1:46)', 'UniformOutput', false);
manyFolder = fullfile(sandboxDir, 'manyToys');
manyPairFolder = fullfile(sandboxDir, 'manyPairs');
mkdir(manyFolder);
mkdir(manyPairFolder);
pairNames = cell(0, 1);
for i = 1:numel(manyToys)
    saveToyModel(manyFolder, manyToys{i}, 'bio1');
    for k = i + 1:numel(manyToys)
        pairNames{end + 1, 1} = ['pairedModel_' manyToys{i} '_' manyToys{k} '.mat']; %#ok<SAGROW>
    end
end
assert(numel(pairNames) == 1035);
for i = 1:numel(pairNames) - 1
    fid = fopen(fullfile(manyPairFolder, pairNames{i}), 'w');
    fclose(fid);
end
assert(verifyCobraFunctionError('joinModelsPairwiseFromList', 'inputs', ...
    {manyToys, manyFolder, 'biomasses', repmat({'bio1'}, 46, 1), 'c', [1 2 3], ...
    'pairwiseModelFolder', manyPairFolder}));
saved = load(fullfile(manyPairFolder, 'pairedModelInfo.mat'));
assert(size(saved.pairedModelInfo, 1) == 1000);
assert(isequal(saved.pairedModelInfo(:, 1), pairNames(1:1000)));
% the existing pairs were not touched
existingPairs = dir(fullfile(manyPairFolder, 'pairedModel_*.mat'));
assert(numel(existingPairs) == 1034);
assert(all([existingPairs.bytes] == 0));

% leave and remove the temporary folder; the stand-ins go with it
clear leaveSandbox
assert(~exist(sandboxDir, 'dir'));

% output a success message
fprintf('Done.\n')

% change to the current directory
cd(currentDir)


function saveToyModel(folder, modelName, biomassName)
    % a microbe with an exchange, a transport and a biomass reaction
    rxnIDs = {'EX_a(e)'; 'A_t'; biomassName};
    model = createModel(rxnIDs, rxnIDs, {'a[e] <=>'; 'a[e] <=> a[c]'; 'a[c] ->'});
    model.lb(3) = 0;
    save(fullfile(folder, modelName), 'model');
end


function cleanUpSandbox(startDir, sandboxDir, jobFolder, startPath, startSolver)
    % closes a pool whose job files are in the temporary folder, restores the path and the solver
    % of the session and removes the temporary folder, also when the test fails
    global CBT_LP_SOLVER
    cd(startDir);
    path(startPath);
    rehash path
    CBT_LP_SOLVER = startSolver;
    pool = getParallelPool();
    if ~isempty(pool) && strcmp(pool.Cluster.JobStorageLocation, jobFolder)
        delete(pool);
    end
    if isappdata(0, 'requestedPool')
        rmappdata(0, 'requestedPool');
    end
    rmdir(sandboxDir, 's');
end
