% The COBRAToolbox: testMappingInfo.m
%
% Purpose:
%     - test the mappingInfo function of the Microbiome Toolbox
%
% Authors:
%     - original version: Federico Baldini, April 2018
%

global CBTDIR

% define the features required to run the test
requiredToolboxes = { 'distrib_computing_toolbox' };

requiredSolvers = { 'ibm_cplex' };

% require the specified toolboxes and solvers, along with a UNIX OS
solversPkgs = prepareTest('requiredSolvers', requiredSolvers, 'requiredToolboxes', requiredToolboxes);

% save the current path
currentDir = pwd;

% initialize the test
cd(fileparts(which(mfilename)));

% set the tolerance
tol = 1e-8;


% path to microbe models
modPath = [CBTDIR filesep 'test' filesep 'models' 'mat'];

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
autoFix = 1;

% if outputs in open formats should be produced for each section (1=T)
compMod = 0;

% if documentations on patient health status is provided (0 not 1 yes)
patStat = 0;

% to enable also rich diet simulations
rDiet = 0;

% if if to use an external solver and save models with diet
extSolve = 0;

% the type of FVA function to use to solve
fvaType = 1;

% To tourn off the autorun to be able to manually execute each part of the pipeline.
autorun = 0;

[init,modPath,toolboxPath,resPath,dietFilePath,abunFilePath,objre,figForm,numWorkers,autoFix,compMod,patStat,rDiet,extSolve,fvaType,autorun]= initMgPipe(modPath, CBTDIR, resPath, dietFilePath, abunFilePath, objre, figForm, numWorkers, autoFix, compMod, patStat, rDiet,extSolve,fvaType,autorun);

%{
% load the model
%Either:
model = getDistributedModel('ecoli_core_model.mat'); %For all models in the test/models folder and subfolders
%or
model = readCbModel('testModel.mat','modelName','NameOfTheModelStruct'); %For all models which are part of this particular test.

%Load reference data
load('testData_functionToBeTested.mat');

% This is only necessary for tests that test a function that runs in parallel.
% create a parallel pool
% This is in try/catch as otherwise the test will error if no parallel
% toolbox is installed.
try
    parTest = true;
    poolobj = gcp('nocreate'); % if no pool, do not create new one.
    if isempty(poolobj)
        parpool(2); % launch 2 workers
    end
catch ME
    parTest = false;
    fprintf('No Parallel Toolbox found. TRying test without Parallel toolbox.\n')
end
if parTest
% if parallel toolbox has to be present (if not, this can be left out).

for k = 1:length(solverPkgs.LP)
    fprintf(' -- Running <testFile> using the solver interface: %s ... ', solverPkgs.LP{k});

    solverLPOK = changeCobraSolver(solverPkgs.LP{k}, 'LP', 0);

    if solverLPOK
        % <your test goes here>
    end
    verifyCobraFunctionError(@() testFile(wrongInput));
    % output a success message
    fprintf('Done.\n');
end
%}
% change the directory
cd(currentDir)
