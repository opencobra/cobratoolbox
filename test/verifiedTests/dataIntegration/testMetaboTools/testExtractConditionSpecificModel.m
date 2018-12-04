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

% generate data
modelPruned =  extractConditionSpecificModel(model, threshold);

% calculate reference data 
[minFlux,maxFlux] = fluxVariability(model, 0);
Flux = [minFlux maxFlux];  
for i = 1 : 8;% length of the model
    x = length (find (abs(Flux(i,:))<=10e-6))==2; % 10e-6 is the threshold
    Blockedrxns(i,1) = x;
end
Blocked = model.rxns(Blockedrxns);
refData = removeRxns(model,Blocked(:,1));

% comparison between refData and generated data
assert(isequal(refData, modelPruned))

% change back to the current directory
cd(currentDir);