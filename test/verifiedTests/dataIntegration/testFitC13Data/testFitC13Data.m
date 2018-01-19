% The COBRAToolbox: testFitC13Data.m
%
% Purpose:
%     - testFitC13Data tests the basic functionality of fitC13Data
%
% Authors:
%     - Original file: Jan Schellenberger
%     - CI integration: Laurent Heirendt March 2017
%


%Check Requirements
solvers = COBRARequisitesFullfilled('needsLP',true,'needsNLP',true);


% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testFitC13Data'));
cd(fileDir);

majorIterationLimit = 10000; % fitting length
model = readCbModel('model.mat'); % loads modelWT
load('expdata.mat', 'expdata'); % load data
load('point.mat', 'v0'); % load initial point

%The following can be done with any allowed solver, but e.g. pdco will fail, so we will run a few others.

changeCobraSolver(solvers.NLP,'NLP',0);
changeCobraSolver(solvers.LP,'LP',0);

generateIsotopomerSolver(model, 'xglcDe', expdata, 'true');
expdata.inputfrag = convertCarbonInput(expdata.input); % generate inputFragments (required for EMU solver)

% start from a different point
output = scoreC13Fit(v0.^2,expdata,model);

initial_score = output.error;

% output a success message
fprintf('Done.\n');

% create a parallel pool
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
    disp('Trying Non Parallel')
end

fprintf('   Testing fitC13Data ... \n');

[vout, rout] = fitC13Data(v0, expdata, model, majorIterationLimit);

output = scoreC13Fit(vout, expdata, model);
final_score = output.error;

assert(final_score < initial_score)

% output a success message
fprintf('Done.\n');

% change the directory
cd(currentDir)
