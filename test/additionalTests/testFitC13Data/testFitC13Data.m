% The COBRAToolbox: testFitC13Data.m
%
% Purpose:
%     - testFitC13Data tests the basic functionality of fitC13Data
%
% Authors:
%     - Original file: Jan Schellenberger
%     - CI integration: Laurent Heirendt March 2017
%


% Check Requirements
solvers = prepareTest('needsLP', true, 'needsNLP', true);

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testFitC13Data'));
cd(fileDir);

majorIterationLimit = 10000;  % fitting length
model = readCbModel('model.mat');  % loads modelWT
load('expdata.mat', 'expdata');  % load data
load('point.mat', 'v0');  % load initial point

% create a parallel pool
try
    % Shut down any existing pool
    minWorkers = 2;
    myCluster = parcluster(parallel.defaultClusterProfile);

    if myCluster.NumWorkers >= minWorkers
        poolobj = gcp('nocreate');  % if no pool, do not create new one.
        if isempty(poolobj)
            parpool(minWorkers);  % launch minWorkers workers
        end
    end
catch
    disp('Trying Non Parallel')
end
%This should, under normal circumstances be matlab and an efficient LP
%solver
changeCobraSolver(solvers.NLP{1}, 'NLP', 0);
changeCobraSolver(solvers.LP{1}, 'LP', 0);

generateIsotopomerSolver(model, 'xglcDe', expdata, 'true');
expdata.inputfrag = convertCarbonInput(expdata.input);  % generate inputFragments (required for EMU solver)

% start from a different point
output = scoreC13Fit(v0.^2, expdata, model);

initial_score = output.error;

% output a success message
fprintf('Done.\n');

fprintf('   Testing fitC13Data ... \n');

[vout, rout] = fitC13Data(v0, expdata, model, majorIterationLimit);

output = scoreC13Fit(vout, expdata, model);
final_score = output.error;

assert(final_score < initial_score)

% output a success message
fprintf('Done.\n');

% change the directory
cd(currentDir)
