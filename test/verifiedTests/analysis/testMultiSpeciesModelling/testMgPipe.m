% The COBRAToolbox: testMgPipe.m
%
% Purpose:
%     - test the mappingInfo function of the Microbiome Toolbox
%
% Authors:
%     - original version: Federico Baldini & Laurent Heirendt, April 2018
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
abunFilePath='normCoverageReduced.csv';

% path to the file with dietary information
dietFilePath='AverageEuropeanDiet';

% path to the file with information on individuals (default=none)
indInfoFilePath='';

% number of cores dedicated for parallelization 
numWorkers = 2;

% name of objective function of organisms 
objre={'EX_biomass(e)'};

%the output is vectorized picture, change to '-dpng' for .png
figForm = '-depsc';

% autofix for names mismatch
autoFix = 1;
 
% if documentations on patient health status is provided (0 not 1 yes)
patStat = 0; 

% to enable also rich diet simulations (default=false)
rDiet = 0; 

% to enable personalized diet simulayions (default=false)
pDiet = 0;

% if if to use an external solver and save models with diet
extSolve = 0; 

% the type of FVA function to use to solve
fvaType = 1; 

% set the lower bound on biomass in community models (default=0)
lowerBMBound=0;

% set if diet should be adapted with human-derived metabolites
% (default=true)
adaptDiet=1;

% set if existing results should be overwritten (default=false)
repeatSim=1;

% turn all warnings off
warning('off', 'all')

% define default path to results
resPath = [CBTDIR filesep '.tmp'];

% adding a filesep at the end of the path
if ~strcmpi(resPath(end), filesep)
    resPath = [resPath filesep];
end

% test getIndividualSizeName
[indNumb, sampName, organisms] = getIndividualSizeName(abunFilePath);

assert(indNumb == 4)
assert(length(sampName) == 4)
assert(length(organisms) == 30)

% test detectOutput
mapP = detectOutput(resPath, 'mapInfo.mat');
assert(isempty(mapP));

%% run the complete pipeline
% path to the file with abundance information.
abunFilePath='testData_normCoverageReduced.csv';

% test complete pipeline run
[init, netSecretionFluxes, netUptakeFluxes, Y] = initMgPipe(modPath, abunFilePath, 'dietFilePath', dietFilePath, 'numWorkers', numWorkers);

%% test each function separately

load([resPath filesep 'mapInfo.mat']);

% load the models
[indNumb, sampName, organisms] = getIndividualSizeName(abunFilePath);
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

% test if the path to the models exists (the model directory is set, but it does not exist)
assert(verifyCobraFunctionError('initMgPipe','inputs',{'/tmp/abcdef'}))

% test with compMod = true
compMod = true;
init = initMgPipe(modPath, abunFilePath, 'dietFilePath', dietFilePath, 'numWorkers', numWorkers, 'compMod', compMod);
assert(init && ~isempty(lastwarn()));

% test with muted printLevel
fprintf(' > Testing printLevel = false ... ');
printLevel=false;
init = initMgPipe(modPath, abunFilePath, 'dietFilePath', dietFilePath, 'numWorkers', numWorkers, 'printLevel', printLevel);
assert(init);
fprintf('Done.\n');

% turn warning back on
warning('on', 'all');

% test getMappingInfo
[reac,micRea,binOrg,patOrg,reacPat,reacNumb,reacSet,reacTab,reacAbun,reacNumber]=getMappingInfo(models,abunFilePath,indNumb);

% test plotMappingInfo
cd(resPath)
[PCoA]=plotMappingInfo(resPath,patOrg,reacPat,reacTab,reacNumber,indInfoFilePath,figForm);
assert(length(PCoA(1,:))<2)
assert(length(PCoA(:,1))==4)
assert(2==exist('Heatmap.eps','file'))
assert(2==exist('Metabolic_Diversity.eps','file'))
delete Metabolic_Diversity.eps Heatmap.eps

% test plotMappingInfo with annotation
[PCoA]=plotMappingInfo(resPath,patOrg,reacPat,reacTab,reacNumber,indInfoFilePath,figForm,sampName, organisms);
assert(length(PCoA(1,:))<2)
assert(length(PCoA(:,1))==4)
assert(2==exist('Heatmap.eps','file'))
assert(2==exist('Metabolic_Diversity.eps','file'))
delete Metabolic_Diversity.eps Heatmap.eps

% test checkNomenConsist
[autoStat,fixVec,organisms]=checkNomenConsist(organisms,autoFix);

assert(length(organisms) == 5)

% test fastSetupCreator

setup = fastSetupCreator(models, organisms, {},objre);

assert(isstruct(setup))
assert(size(setup.S,2) == length(setup.rxns))
assert(length(setup.lb) == length(setup.rxns))
assert(length(setup.c) == length(setup.rxns))
assert(length(setup.mets) == length(setup.metNames))

assert(length(setup.rxns(strmatch('EX',setup.rxns))) /2 == length(setup.rxns(strmatch('DUt',setup.rxns))))
assert(length(setup.rxns(strmatch('EX',setup.rxns))) /2 == length(setup.rxns(strmatch('UFEt',setup.rxns))))
assert(length(setup.rxns(strmatch('DUt',setup.rxns))) == length(setup.rxns(strmatch('UFEt',setup.rxns))))

for k = 1:5
    assert(~isempty(strmatch(organisms(k),setup.rxns)))
end

% test createdModels
[createdModels]=createPersonalizedModel(abunFilePath,resPath,setup,sampName,organisms,indNumb);
assert(size(createdModels,1) == 5)
assert(strcmp(createdModels(2,1),'Test1'))
assert(strcmp(createdModels(5,1),'Test4'))

microbiota_model = load(strcat(resPath,'microbiota_model_samp_Test1'));
microbiota_model = microbiota_model.microbiota_model;
assert(any(ismember('EX_microbeBiomass[fe]',microbiota_model.rxns)) > 0)
assert(any(ismember('EX_microbeBiomass[fe]',microbiota_model.rxns)) > 0)
assert(any(ismember('EX_microbeBiomass[fe]',microbiota_model.rxns)) > 0)
assert(length(microbiota_model.rxns(strmatch('DUt',microbiota_model.rxns)))== length(microbiota_model.rxns(strmatch('UFEt',microbiota_model.rxns)))-1)
assert(microbiota_model.S(1,1) == -0.3000)
assert(microbiota_model.S(2,1) == -0.2000)
assert(microbiota_model.S(3,1) == -0.1000)
assert(microbiota_model.S(4,1) == -0.2000)
assert(microbiota_model.S(5,1) == -0.2000)
assert(microbiota_model.S(6,1) == 1)

% test simulation
includeHumanMets = 1;
[ID, fvaCt, nsCt, presol, inFesMat] = microbiotaModelSimulator(resPath, setup, sampName, dietFilePath, rDiet, pDiet, extSolve, patNumb, fvaType, includeHumanMets, lowerBMBound, repeatSim);
assert(size(presol,1) == 5)
assert(sum(cell2mat(presol(:,1))) == 4)

% test mgSimResCollect
[netSecretionFluxes, netUptakeFluxes, Y] = mgSimResCollect(resPath, ID, sampName, rDiet, pDiet, patNumb, indInfoFilePath, fvaCt, nsCt, figForm);
assert(length(netSecretionFluxes(1,:))==indNumb+1)
assert(length(netSecretionFluxes(:,1))==length(ID)+1)
assert(exist('inputDiet_net_secretion_fluxes.csv','file') == 2)
assert(exist('ID.csv','file') == 2)

% cleanup
delete inputDiet_net_secretion_fluxes.csv ID.csv
delete simRes.mat

% test rich diet simulations and extractFullRes
rDiet=1;
repeatSim=1;
[ID, fvaCt, nsCt, presol, inFesMat] = microbiotaModelSimulator(resPath, setup, sampName, dietFilePath, rDiet, pDiet, extSolve, patNumb, fvaType, includeHumanMets, lowerBMBound, repeatSim);
finRes=extractFullRes(resPath,ID,'rDiet',sampName,fvaCt,nsCt);
assert(exist('rDiet_allFlux.csv','file') == 2)
assert(length((finRes(:,1))) == length(ID)+1)
assert(length((finRes(1,:))) == length(sampName)*4+1)
finRes = extractFullRes(resPath,ID,'pDiet',sampName,fvaCt,nsCt);
assert(finRes==0)

% cleanup
delete simRes.mat
delete rDiet_allFlux.csv


% testing with fluxVariability instead of fastFVA
fvaType=0;
[ID, fvaCt, nsCt, presol, inFesMat] = microbiotaModelSimulator(resPath, setup, sampName, dietFilePath, rDiet, pDiet, extSolve, patNumb, fvaType, includeHumanMets, lowerBMBound, repeatSim);
assert(size(presol,1)==5)
assert(sum(cell2mat(presol(:,1)))==4)

% cleanup
delete simRes.mat

% testing with rich diet
[ID, fvaCt, nsCt, presol, inFesMat] = microbiotaModelSimulator(resPath, setup, sampName, dietFilePath, rDiet, pDiet, extSolve, patNumb, fvaType, includeHumanMets, lowerBMBound, repeatSim);
for i = 1:4
    assert(~isempty(fvaCt{1,i}))
end

% cleanup
delete simRes.mat

% testing extsolve
[ID, fvaCt, nsCt, presol, inFesMat] = microbiotaModelSimulator(resPath, setup, sampName, dietFilePath, 1, 0, 1, patNumb, fvaType, includeHumanMets, lowerBMBound, repeatSim);
cd(resPath)
if exist('Rich','dir') == 7
    cd Rich
    assert(2==exist('microbiota_model_richD_Test4.mat','file'))
    assert(2==exist('microbiota_model_richD_Test3.mat','file'))
    assert(2==exist('microbiota_model_richD_Test2.mat','file'))
    assert(2==exist('microbiota_model_richD_Test1.mat','file'))
    cd(resPath)
    rmdir('Rich','s')
end

% cleanup
clear ID fvaCt nsCt presol inFesMat
cd(resPath)
delete *.mat
