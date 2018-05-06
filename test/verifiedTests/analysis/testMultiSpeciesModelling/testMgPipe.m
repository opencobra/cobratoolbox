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
dietFilePath = [CBTDIR filesep 'papers' filesep '2017_AGORA' filesep 'resourceForMicrobiomeModelingToolbox' filesep 'AverageEuropeanDiet'];

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

% input checker
init = initMgPipe(modPath, CBTDIR, resPath, dietFilePath, abunFilePath, objre, figForm, numWorkers, autoFix, compMod, patStat, rDiet, extSolve, fvaType, autorun);

% logical tests for outputs
assert(init && ~autorun);

% check if error is thrown when running in serial
assert(verifyCobraFunctionError('initMgPipe', 'inputs',{modPath, CBTDIR, resPath, dietFilePath, abunFilePath, objre, figForm, 1, autoFix, compMod, patStat, rDiet, extSolve, fvaType, autorun}));

% test if the function throws an error when no arguments are provided
assert(verifyCobraFunctionError('initMgPipe'))

% test with only the path to the models (throws an error that the abundance file is missing)
assert(verifyCobraFunctionError('initMgPipe', 'inputs',{modPath}));

% test if the path to the models exists (the model directory is set, but it does not exist)
assert(verifyCobraFunctionError('initMgPipe','inputs',{'/tmp/abcdef'}))

% turn all warnings off
warning('off', 'all')

% test if the resPath is set to default value
abunFilePath = [CBTDIR filesep 'papers' filesep '2018_microbiomeModelingToolbox' filesep 'examples' filesep 'normCoverage.csv'];
init = initMgPipe(modPath, CBTDIR, '', '', abunFilePath);
assert(length(lastwarn()) > 0);

% test with compMod = true
init = initMgPipe(modPath, CBTDIR, resPath, dietFilePath, abunFilePath, objre, figForm, numWorkers, autoFix, true, patStat, rDiet, extSolve, fvaType, autorun);
assert(length(lastwarn()) > 0);

% test with patStat = true
init = initMgPipe(modPath, CBTDIR, resPath, dietFilePath, abunFilePath, objre, figForm, numWorkers, autoFix, compMod, true, rDiet, extSolve, fvaType, autorun);
assert(length(lastwarn()) > 0);

% test with muted printLevel
fprintf(' > Testing printLevel = 0 ... ');
init = initMgPipe(modPath, CBTDIR, resPath, dietFilePath, abunFilePath, objre, figForm, numWorkers, autoFix, compMod, patStat, rDiet, extSolve, fvaType, autorun, 0);
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

% change the directory
cd(currentDir)
