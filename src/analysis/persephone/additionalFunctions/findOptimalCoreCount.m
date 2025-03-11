function [totalFBAtime, timeTable] = findOptimalCoreCount(modelDir,solver)
% This function finds the optimal number of workers for the HM models being investigated
% INPUT:
% modelPath             Path to folder with COBRA models
% OPTIONAL INPUT
% subSetSize            Size of the random subset of models used for testing
%
% OUTPUT
% fig                   Figure showing the average speedup factor for each tested
%                       configuration of workers.


% Initialise cobratoolbox if needed
global CBT_LP_SOLVER
if isempty(CBT_LP_SOLVER)
    initCobraToolbox
end

% Set solver 
changeCobraSolver(solver,'LP');

% Step 1: Generate the paths to a random subset of N models to investigate

% Find model paths
modelNames = what(modelDir).mat;
modelPaths = append(modelDir, filesep, modelNames);
modelNames = string(erase(modelNames,'.mat'));

% Make sure that N is equal or smaller to the number of available cores
cores = feature('numCores');
disp(append("This computer has ", string(cores), " available cores"))

% Calculate the size of the subset by finding the largest number that is a
% power of 2 that is smaller than the number of available cores.
N = 2^floor(log2(cores));

% Define the number of workers to be tested
numWorkers = [1 cumprod(factor(N))];

disp("The following matlab worker configurations are tested: ")
disp(numWorkers)

% Select a random subset of size N
randomSelection = randperm(numel(modelPaths), N);
subsetPaths = modelPaths(randomSelection);
subsetModelNames = modelNames(randomSelection);

disp("The following subset of models is randomly chosen: ")
disp(subsetModelNames)

% Step 2: Load models and investigate their times to solve

% Load models
disp('Load models:')
modelSet = cell(length(subsetPaths),1);
for i = 1:length(subsetPaths)
    
    disp(append("Load model: ", subsetModelNames(i)))
    modelSet{i} = loadMinimalWBM(subsetPaths{i});
end

% Store environment variables and paths


% Preallocate table with times
timeTable = zeros(numel(subsetPaths),length(numWorkers)+1);
timeTable = array2table(timeTable,'VariableNames',["ID" string(numWorkers)]);
timeTable.ID = extractAfter(subsetPaths,'muWBM_');

% Create table for total FBA times
variables = {'Workers','FBA times','FBA times max variation','Median load times','Load corrected FBA times', 'Time per FBA', 'Relative speedup from paralellisation'};
totalFBAtime = array2table(zeros(length(numWorkers),length(variables)));
totalFBAtime.Properties.VariableNames = variables;
totalFBAtime.Workers = numWorkers';

environment = getEnvironment();
disp('Start for loop')
for i=1:length(numWorkers)

    disp(append("Test ", string(numWorkers(i)), " workers"))
    
    poolobj = gcp('nocreate');
    if ~isempty(poolobj)
        if poolobj.NumWorkers ~= numWorkers(i)
    
            % Delete previous pool
            delete(poolobj)
    
            % Create new pool
            parpool(numWorkers(i))
        end
    end
    currWorkers = numWorkers(i);
    
    setupTime = zeros(length(subsetPaths),1);
    fbaTime = zeros(length(subsetPaths),1);
    tStart = tic;
    parfor j=1:length(subsetPaths)
        tic
        % Set environment
        restoreEnvironment(environment);
        changeCobraSolver(solver, 'LP', 0, -1);

        model = modelSet{j};

        % Prepare model
        model.osenseStr = 'max';

        % Store time to setup model
        setupTime(j) = toc;
        
        % Solve model
        disp(strcat("Test model: ", string(model.ID), " on ", string(currWorkers), " worker(s)"))
        tic
        optimizeWBModel(model);
        fbaTime(j) = toc;
    end
    solveTime = toc(tStart);

    % Update timetable
    timeTable{:,i+1} = fbaTime;

    % Store FBA times and info
    disp('Store timed info')
    totalFBAtime.('FBA times')(i) = solveTime;
    totalFBAtime.('FBA times max variation')(i) = max(pdist(fbaTime));
    totalFBAtime.('Median load times')(i) = median(setupTime);
    totalFBAtime.('Load corrected FBA times')(i) = totalFBAtime.('FBA times')(i) - totalFBAtime.('Median load times')(i);
end

totalFBAtime.('Time per FBA') = totalFBAtime.('Load corrected FBA times') / length(subsetPaths);
totalFBAtime.('Relative speedup from paralellisation') = totalFBAtime.('Load corrected FBA times')(1)./totalFBAtime.('Load corrected FBA times');

end

function model = loadMinimalWBM(modPath)
% This function loads the smallest possible combination of WBM model fields
% needed to perform FBA and check model feasibility on the diet. Loading
% the minimal model can decrease loading times by 6X.
% INPUT: path to WBM to load
% OUTPUT: minimal WBM
% Author: Tim Hensen

% Load model
model = load(modPath,'ID','S','ub','lb','rxns','mets','c','d','csense','dsense','osenseStr','sex', 'SetupInfo', 'C');

% If any fields are missing, load the full model
fieldsToCheck = {'ID','S','ub','lb','rxns','mets','c','d','csense','dsense','osenseStr', 'C'};
if any(~matches(fieldsToCheck,fieldnames(model)))
    % Load model
    model = load(modPath);
    % Check if model is a structured array or is nested
    if isscalar(fieldnames(model))
        model=model.(string(fieldnames(model)));
    end
end
end