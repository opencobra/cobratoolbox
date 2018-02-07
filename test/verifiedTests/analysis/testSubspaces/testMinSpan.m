% The COBRAToolbox: testMinSpan.m
%
% Purpose:
%     - test the ability to determine the MinSpan vectors of the
%       E.coli core model
%
% Authors:
%     - Original test file: Aarash Bordbar
%     - CI integration: Sylvain Arreckx, June 2017

global CBTDIR

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testMinSpan'));
cd(fileDir);

% load the model
model = getDistributedModel('ecoli_core_model.mat');

% Remove biomass equation for MinSpan calculation
bmName = {'Biomass_Ecoli_core_w_GAM'};
model = removeRxns(model, bmName);

[m, n] = size(model.S);
assert(m == 72 & n == 94, 'Unable to setup input for MinSpan determination');

% Setup parameters and run detMinSpan
params.saveIntV = 0; % Do not save intermediate output

%This test runs fluxVariability. So we have to start te parallel pool
%before the solver is set.
%The following can be done with any allowed solver, but e.g. pdco will fail, so we will run a few others.
% create a parallel pool
try
    %Shut down any existing pool
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


changeCobraSolver('gurobi', 'all', 0);

if changeCobraSolver('gurobi', 'MILP', 0)
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
        disp('Trying non parallel run')
    end
    minSpanVectors = detMinSpan(model, params);
    
    % Check size of vectors and number of entries
    [r, c] = size(minSpanVectors);
    numEntries = nnz(minSpanVectors);
    
    assert(r == 94 & c == 23, 'MinSpan vector matrix wrong size');
    assert(numEntries == 479, 'MinSpan vector matrix is not minimal');
else
    fprintf(' > Skipping testMinSpan as Gurobi is not installed.\n');
end
