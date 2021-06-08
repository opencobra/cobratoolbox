% The COBRAToolbox: testMgPipe.m
%
% Purpose:
%     - test the mappingInfo function of the Microbiome Toolbox
%
% Authors:
%     - original version: Federico Baldini & Laurent Heirendt, April 2018
%       - Almut Heinken, December 2020: adapted to recent changes in mgPipe
%

global CBTDIR

% define the features required to run the test
requiredToolboxes = { 'distrib_computing_toolbox' };

% test Requirements
prepareTest('requiredToolboxes',requiredToolboxes, 'requiredSolvers', {'ibm_cplex'});

% save the current path
currentDir = pwd;

% initialize the test
cd(fileparts(which(mfilename)));
modPath = [CBTDIR filesep 'test' filesep 'models' filesep 'mat'];

% path to the file with abundance information.
abunFilePath='testData_normCoverageReduced.csv';

% path to the file with dietary information
dietFilePath='AverageEuropeanDiet';

% path to the file with information on individuals (default=none)
indInfoFilePath='';

% to define whether uptake and secretion profiles should be recrutied
computeProfiles = true;

resPath = [pwd filesep 'Results'];

% number of cores dedicated for parallelization 
numWorkers = 2;

% name of objective function of organisms 
objre={'EX_biomass(e)'};

% if documentations on patient health status is provided (0 not 1 yes)
patStat = 0; 

% to enable also rich diet simulations (default=false)
rDiet = 0; 

% to enable personalized diet simulayions (default=false)
pDiet = 0;

% set the lower bound on biomass in community models (default=0)
lowerBMBound=0;

% set if diet should be adapted with human-derived metabolites
% (default=true)
adaptDiet=1;

% set if existing results should be overwritten (default=false)
repeatSim=1;

% turn all warnings off
warning('off', 'all')

% test getIndividualSizeName
[sampNames, organisms, exMets] = getIndividualSizeName(abunFilePath,modPath);

assert(length(sampNames) == 4)
assert(length(organisms) == 5)

%% run the complete pipeline
% path to the file with abundance information.
abunFilePath='testData_normCoverageReduced.csv';

% test complete pipeline run
[init, netSecretionFluxes, netUptakeFluxes, Y] = initMgPipe(modPath, abunFilePath, computeProfiles, 'dietFilePath', dietFilePath, 'numWorkers', numWorkers, 'resPath', resPath);

assert(init)

% test detectOutput
mapP = detectOutput(resPath, 'mapInfo.mat');
assert(~isempty(mapP));

%% test each function separately

load(['Results' filesep 'mapInfo.mat']);

% load the models
[sampNames, organisms] = getIndividualSizeName(abunFilePath,modPath);
models = loadUncModels(modPath, organisms, objre);

assert(length(models) == 5);

assert(verifyCobraFunctionError('loadUncModels', 'inputs', {}));
assert(verifyCobraFunctionError('loadUncModels', 'inputs', {modPath, ''}));

warning('off', 'all');
loadUncModels(modPath, organisms);
assert(~isempty(lastwarn()))
warning('on', 'all');

% logical tests for outputs
assert(init && ~isempty(lastwarn()));

% test if the function throws an error when no arguments are provided
assert(verifyCobraFunctionError('initMgPipe'))

% test with only the path to the models (throws an error that the abundance file is missing)
assert(verifyCobraFunctionError('initMgPipe', 'inputs',{modPath}));

% cleanup
delete simRes.mat
delete rDiet_allFlux.csv

% cleanup
delete simRes.mat

% testing with rich diet
[init, netSecretionFluxes, netUptakeFluxes, Y] = initMgPipe(modPath, abunFilePath, computeProfiles, 'resPath',resPath,'numWorkers',numWorkers, 'rDiet', true);
assert(init)


% cleanup
delete simRes.mat
clear ID fvaCt nsCt presol inFesMat
cd(resPath)
delete *.mat
rmdir([resPath filesep 'modelStorage'],'s')

%% verify that mgPipe also works with a single microbiome model with one strain

abunFilePath='testData_normCoverage_one_model.csv';

[init, netSecretionFluxes, netUptakeFluxes, Y] = initMgPipe(modPath, abunFilePath, computeProfiles, 'resPath',resPath,'numWorkers',numWorkers,'resPath',resPath);

assert(init)

% cleanup
rmdir(resPath,'s')
