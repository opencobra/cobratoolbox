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

% path to microbe models
modPath = [CBTDIR filesep 'test' filesep 'models' filesep 'mat'];

% path where to save results
resPath= [CBTDIR filesep '.tmp'] ;

% path to and name of the file with dietary information.
dietFilePath=[CBTDIR filesep 'papers' filesep '2018_microbiomeModelingToolbox' filesep 'resources' filesep 'AverageEuropeanDiet'];

% path to and name of the file with abundance information.
abunFilePath=[CBTDIR filesep 'papers' filesep '2018_microbiomeModelingToolbox' filesep 'examples' filesep 'normCoverage.csv'];

% name of objective function of organisms
objre={'EX_biomass(e)'};

%the output is vectorized picture, change to '-dpng' for .png
figForm = '-depsc';

% number of cores dedicated for parallelization
numWorkers = 2;

% autofix for names mismatch
autoFix = true;

% if outputs in open formats should be produced for each section (1=T)
compMod = false;

% if documentations on patient health status is provided (0 not 1 yes)
patStat = false;

% to enable also rich diet simulations
rDiet = false;

% if if to use an external solver and save models with diet
extSolve = false;

% the type of FVA function to use to solve
fvaType = true;

% To tourn off the autorun to be able to manually execute each part of the pipeline.
autorun = false;

% stratification criteria
indInfoFilePath = 'nostrat';

% input checker
init = initMgPipe(modPath, CBTDIR, resPath, dietFilePath, abunFilePath, indInfoFilePath, objre, figForm, numWorkers, autoFix, compMod, rDiet, extSolve, fvaType, autorun);

% logical tests for outputs
assert(init && ~autorun);

% check if error is thrown when running in serial
assert(verifyCobraFunctionError('initMgPipe', 'inputs',{modPath, CBTDIR, resPath, dietFilePath, abunFilePath, indInfoFilePath, objre, figForm, 1, autoFix, compMod, rDiet, extSolve, fvaType, autorun}));

% test if the function throws an error when no arguments are provided
assert(verifyCobraFunctionError('initMgPipe'))

% test with only the path to the models (throws an error that the abundance file is missing)
assert(verifyCobraFunctionError('initMgPipe', 'inputs',{modPath}));

% test if the path to the models exists (the model directory is set, but it does not exist)
assert(verifyCobraFunctionError('initMgPipe','inputs',{'/tmp/abcdef'}))

% turn all warnings off
warning('off', 'all')

% adding a filesep at the end of the path
if ~strcmpi(resPath(end), filesep)
    resPath = [resPath filesep];
end

% test if the resPath is set to default value
abunFilePath = [CBTDIR filesep 'papers' filesep '2018_microbiomeModelingToolbox' filesep 'examples' filesep 'normCoverage.csv'];
init = initMgPipe(modPath, CBTDIR, '', '', abunFilePath);
assert(~isempty(lastwarn()));

% test with compMod = true
init = initMgPipe(modPath, CBTDIR, resPath, dietFilePath, abunFilePath, indInfoFilePath, objre, figForm, numWorkers, autoFix, true, rDiet, extSolve, fvaType, autorun);
assert(~isempty(lastwarn()));

% test with muted printLevel
fprintf(' > Testing printLevel = 0 ... ');
init = initMgPipe(modPath, CBTDIR, resPath, dietFilePath, abunFilePath, indInfoFilePath, objre, figForm, numWorkers, autoFix, compMod, rDiet, extSolve, fvaType, autorun, 0);
assert(init && ~autorun);
fprintf('Done.\n');

% turn warning back on
warning('on', 'all');

% test getIndividualSizeName
abunFilePath = which('normCoverageReduced.csv');
[indNumb, sampName, organisms] = getIndividualSizeName(abunFilePath);

assert(indNumb == 4)
assert(length(sampName) == 4)
assert(length(organisms) == 30)

% test detectOutput
mapP = detectOutput(resPath, 'mapInfo.mat');
assert(isempty(mapP));

% load the models
abunFilePath = which('testData_normCoverageReduced.csv');
[indNumb, sampName, organisms] = getIndividualSizeName(abunFilePath);
models = loadUncModels(modPath, organisms, objre);

assert(length(models) == 5);

assert(verifyCobraFunctionError('loadUncModels', 'inputs', {}));
assert(verifyCobraFunctionError('loadUncModels', 'inputs', {modPath, ''}));

warning('off', 'all');
    loadUncModels(modPath, organisms);
    assert(~isempty(lastwarn()))
warning('on', 'all');

% change the directory
cd(currentDir)

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
[ID, fvaCt, ~, presol]=microbiotaModelSimulator(resPath,setup,sampName,dietFilePath,rDiet,0,extSolve,indNumb,fvaType);

assert(size(presol,1) == 5)
assert(sum(cell2mat(presol(:,1))) == 4)

% test mgSimResCollect
[Fsp,Y]= mgSimResCollect(resPath,ID,sampName,rDiet,0,indNumb,indInfoFilePath,fvaCt,figForm);
assert(length(Fsp(1,:))==indNumb+1)
assert(isempty(Y))
assert(length(Fsp(:,1))==length(ID)+1)
assert(exist('standard.csv','file') == 2)
assert(exist('ID.csv','file') == 2)

% cleanup
delete standard.csv ID.csv
delete simRes.mat

% test extractFullRes
[ID, fvaCt, nsCt] = microbiotaModelSimulator(resPath,setup,sampName,dietFilePath,1,0,extSolve,indNumb,fvaType);
finRes=extractFullRes(resPath,ID,'rDiet',sampName,fvaCt,nsCt);
assert(exist('rDiet_allFlux.csv','file') == 2)
assert(length((finRes(:,1))) == length(ID)+1)
assert(length((finRes(1,:))) == length(sampName)*4+1)
finRes = extractFullRes(resPath,ID,'sDiet',sampName,fvaCt,nsCt);
assert(finRes==0)

% cleanup
delete simRes.mat
delete rDiet_allFlux.csv


% testing with fluxVar function and not fastFVA
[~,~,~,presol,~]=microbiotaModelSimulator(resPath,setup,sampName,dietFilePath,rDiet,0,extSolve,indNumb,0);
assert(size(presol,1)==5)
assert(sum(cell2mat(presol(:,1)))==4)

% cleanup
delete simRes.mat

% testing with rich diet
[~,fvaCt]=microbiotaModelSimulator(resPath,setup,sampName,dietFilePath,1,0,extSolve,indNumb,fvaType);
for i = 1:4
    assert(~isempty(fvaCt{1,i}))
end

% cleanup
delete simRes.mat

% testing extsolve
microbiotaModelSimulator(resPath,setup,sampName,dietFilePath,1,0,1,indNumb,fvaType);
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
