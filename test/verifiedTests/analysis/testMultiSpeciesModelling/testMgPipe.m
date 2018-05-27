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
prepareTest('requiredToolboxes',requiredToolboxes);

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
assert(length(lastwarn()) > 0);

% test with compMod = true
init = initMgPipe(modPath, CBTDIR, resPath, dietFilePath, abunFilePath, indInfoFilePath, objre, figForm, numWorkers, autoFix, true, rDiet, extSolve, fvaType, autorun);
assert(length(lastwarn()) > 0);

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
    assert(length(lastwarn()) > 0)
warning('on', 'all');

% change the directory
cd(currentDir)

% test getMappingInfo
[reac,micRea,binOrg,patOrg,reacPat,reacNumb,reacSet,reacTab,reacAbun,reacNumber]=getMappingInfo(models,abunFilePath,indNumb);

assert(exist('reac', 'var') == 1)
assert(exist('micRea', 'var') == 1)
assert(exist('binOrg', 'var') == 1)
assert(exist('patOrg', 'var') == 1)
assert(exist('reacPat', 'var') == 1)
assert(exist('reacNumb', 'var') == 1)
assert(exist('reacSet', 'var') == 1)
assert(exist('reacTab', 'var') == 1)
assert(exist('reacAbun', 'var') == 1)
assert(exist('reacNumber', 'var') == 1)

% test checkNomenConsist
[autoStat,fixVec,organisms]=checkNomenConsist(organisms,autoFix);

assert(exist('autoStat', 'var') == 1)
assert(exist('fixVec', 'var') == 1)
assert(length(organisms) == 5)

% test fastSetupCreator

setup=fastSetupCreator(models, organisms, {},objre);
 
assert(exist('setup', 'var') == 1)
assert(strcmp(class(setup),'struct') == 1)
assert(size(setup.S,2) == length(setup.rxns))
assert(length(setup.lb) == length(setup.rxns))
assert(length(setup.c) == length(setup.rxns))
assert(length(setup.mets) == length(setup.metNames)) 
 
assert(length(setup.rxns(strmatch('EX',setup.rxns))) /2 == length(setup.rxns(strmatch('DUt',setup.rxns)))) 
assert(length(setup.rxns(strmatch('EX',setup.rxns))) /2 == length(setup.rxns(strmatch('UFEt',setup.rxns)))) 
assert(length(setup.rxns(strmatch('DUt',setup.rxns)))== length(setup.rxns(strmatch('UFEt',setup.rxns))))

for k = 1:5
assert(length(strmatch(organisms(k),setup.rxns)) > 0) 
end

% test createdModels
[createdModels]=createPersonalizedModel(abunFilePath,resPath,setup,sampName,organisms,indNumb);
assert(size(createdModels,1)== 5)
assert(strcmp(createdModels(2,1),'Test1'))
assert(strcmp(createdModels(5,1),'Test4'))

microbiota_model=load(strcat(resPath,'microbiota_model_samp_Test1')); 
microbiota_model=microbiota_model.microbiota_model;
%assert(size(microbiota_model.A,1)> size(microbiota_model.S,1))
%assert(length(microbiota_model.csense) == size(microbiota_model.A,1))
assert(any(ismember('EX_microbeBiomass[fe]',microbiota_model.rxns)) > 0)
assert(any(ismember('EX_microbeBiomass[fe]',microbiota_model.rxns)) > 0)
assert(any(ismember('EX_microbeBiomass[fe]',microbiota_model.rxns)) > 0)
assert(length(microbiota_model.rxns(strmatch('DUt',microbiota_model.rxns)))== length(microbiota_model.rxns(strmatch('UFEt',microbiota_model.rxns)))-1)
assert(microbiota_model.A(1,1) == -0.3000)
assert(microbiota_model.A(2,1) == -0.2000)
assert(microbiota_model.A(3,1) == -0.1000)
assert(microbiota_model.A(4,1) == -0.2000)
assert(microbiota_model.A(5,1) == -0.2000)
assert(microbiota_model.A(6,1) == 1)

% test createdModels
[ID,fvaCt,nsCt,presol,inFesMat]=microbiotaModelSimulator(resPath,setup,sampName,dietFilePath,rDiet,0,extSolve,indNumb,fvaType);

assert(exist('ID', 'var') == 1)
assert(exist('fvaCt', 'var') == 1)
assert(exist('nsCt', 'var') == 1)
assert(exist('inFesMat', 'var') == 1)
assert(size(presol,1)==5)
assert(sum(cell2mat(presol(:,1)))==4)

%erasing all testing files
cd(resPath)
delete *.mat

