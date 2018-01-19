% The COBRAToolbox: testSampleCbModel.m
%
% Purpose:
%     - tests the sampleCbModel function using the E. coli Core Model
%

%Check Requirements
solvers = COBRARequisitesFullfilled('needsUnix',true, 'needsLP',true);


% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testSampleCbModel'));
cd(fileDir);
% define the samplers
samplers = {'ACHR', 'CHRR','CHRR_EXP'}; %'MFE'

% create a parallel pool (if possible)
try
    minWorkers = 2;
    myCluster = parcluster(parallel.defaultClusterProfile);
    
    if myCluster.NumWorkers >= minWorkers
        poolobj = gcp('nocreate');  % if no pool, do not create new one.
        if isempty(poolobj)
            parpool(minWorkers);  % launch minWorkers workers
        end
    end
catch
    %No pool
end

fprintf('   Testing sampleCbModel ... \n', );

% set the solver
solverOK = changeCobraSolver(solvers.LP, 'LP', 0);

% Load model
model = getDistributedModel('ecoli_core_model.mat');

for i = 1:length(samplers)
    
    samplerName = samplers{i};
    
    switch samplerName
        case 'ACHR'
            fprintf('\nTesting the artificial centering hit-and-run (ACHR) sampler\n.');
            
            options.nFiles = 4;
            options.nStepsPerPoint = 5;
            options.nPointsReturned = 20;
            options.nPointsPerFile = 5;
            options.nFilesSkipped = 0;
            options.nWarmupPoints = 200;
            
            [modelSampling, samples, volume] = sampleCbModel(model, 'EcoliModelSamples', 'ACHR', options);
            
            % check if sample files created
            assert(exist('EcoliModelSamples_1.mat', 'file') == 2 && exist('EcoliModelSamples_2.mat', 'file') == 2 && exist('EcoliModelSamples_3.mat', 'file') == 2 && exist('EcoliModelSamples_4.mat', 'file') == 2)
            removedRxns = find(~ismember(model.rxns, modelSampling.rxns));
            assert(all(removedRxns == [26; 27; 29; 34; 45; 47; 52; 63]))
            
        case 'CHRR'
            fprintf('\nTesting the coordinate hit-and-run with rounding (CHRR) sampler\n.');
            
            options.nStepsPerPoint = 1;
            options.nPointsReturned = 10;
            options.toRound = 1;
            
            [modelSampling, samples, volume] = sampleCbModel(model, 'EcoliModelSamples', 'CHRR', options);
            
            assert(norm(samples) > 0)
        case 'CHRR_EXP'
            fprintf('\nTesting the coordinate hit-and-run with rounding (CHRR) sampler, with exponential target distribution.\n.');
            
            options.nStepsPerPoint = 1;
            options.nPointsReturned = 10;
            options.toRound = 1;
            numRxns = length(model.c);
            options.lambda = 0*model.c + 1;
            
            [modelSampling, samples, volume] = sampleCbModel(model, 'EcoliModelSamples', 'CHRR_EXP', options);
            
            assert(norm(samples) > 0)
            
    end
end

% print a line for success of loop i
fprintf(' Done.\n');

% change the directory
cd(currentDir)
