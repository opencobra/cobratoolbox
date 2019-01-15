% The COBRA Toolbox: testextractConditionSpecificModel.m
%
% Purpose:
%     - test the extractConditionSpecificModel function
%
% Authors:
%     - Loic Marx, December 2018

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which(mfilename));
cd(fileDir);

% define the solver packages to be used to run this test, can't use
% dqq/Minos for the parallel part.
solverPkgs = prepareTest('needsLP', true, 'excludeSolvers', {'dqqMinos', 'quadMinos'});

% load reference data
load('refData_extractConditionSpecificModel.mat')

% load model
model = createToyModelForLifting(true);

% create a parallel pool
try
    minWorkers = 2;
    myCluster = parcluster(parallel.defaultClusterProfile);
    % no parallel pool
    if myCluster.NumWorkers >= minWorkers
        poolobj = gcp('nocreate');  % if no pool, do not create new one.
        if isempty(poolobj)
            parpool(minWorkers);  % launch minWorkers workers
        end
    end
catch
    % No Parallel pool.
end

% Define input
threshold = 1e-6;

% generate data
modelPruned = extractConditionSpecificModel(model, threshold);

% comparison between refData and generated data
assert(isequal(modelPruned_ref, modelPruned))

% change back to the current directory
cd(currentDir);
