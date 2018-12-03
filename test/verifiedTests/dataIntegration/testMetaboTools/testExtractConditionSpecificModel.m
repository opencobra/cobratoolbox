% The COBRA Toolbox: testexportSetToGAMS
%
% Purpose:
%     - test exportSetToGAMS function
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
solverPkgs = prepareTest('needsLP',true,'needsMILP',true,'needsQP',true,'useSolversIfAvailable',{'ibm_cplex'}, 'excludeSolvers',{'dqqMinos','quadMinos'}, 'minimalMatlabSolverVersion',8.0);

% load model 
model = createToyModelForLifting(false);

% create a parallel pool
try
    minWorkers = 2;
    myCluster = parcluster(parallel.defaultClusterProfile);
    %No parallel pool
    if myCluster.NumWorkers >= minWorkers
        poolobj = gcp('nocreate');  % if no pool, do not create new one.
        if isempty(poolobj)
            parpool(minWorkers);  % launch minWorkers workers
        end
    end
catch
    %No Parallel pool. Thats fine
end

% Define input 

threshold = 10e-6

modelPruned =  extractConditionSpecificModel(model,threshold);

% change back to the current directory
cd(currentDir);