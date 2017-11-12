% The COBRAToolbox: testFitC13Data.m
%
% Purpose:
%     - testFitC13Data tests the basic functionality of fitC13Data
%
% Authors:
%     - Original file: Jan Schellenberger
%     - CI integration: Laurent Heirendt March 2017
%
% Note:
%     - The tomlab_snopt solver must be tested with a valid license

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testFitC13Data'));
cd(fileDir);

majorIterationLimit = 10000; % fitting length
load('model.mat', 'model'); % loads modelWT
load('expdata.mat', 'expdata'); % load data
load('point.mat', 'v0'); % load initial point

% Note: the glpk solver is sufficient, no need to run multiple solvers
fprintf('   Preparing the model using glpk ... ');

changeCobraSolver('glpk');

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

% define the solver packages to be used to run this test
solverPkgs = {'matlab'}; % tomlab_snopt

if ~all(ismember(solverPkgs,'matlab'))
    %Test this only if matlab is the only solver set here.
    v = ver;
    optPres = any(strcmp('Global Optimization Toolbox', {v.Name})) && license('test','Optimization_Toolbox');    
    assert(optPres,sprintf('The Optimization Toolbox is not installed or not licensed on your system.\nThis function might work with other non linear solvers, but they are not tested.'))
end

for k = 1:length(solverPkgs)

    % change the COBRA solver (NLP)
    solverOK = changeCobraSolver(solverPkgs{k}, 'NLP');
    
    if solverOK == 1
        fprintf('   Testing fitC13Data using %s ... ', solverPkgs{k});

        [vout, rout] = fitC13Data(v0, expdata, model, majorIterationLimit);

        output = scoreC13Fit(vout, expdata, model);
        final_score = output.error;

        assert(final_score < initial_score)

        % output a success message
        fprintf('Done.\n');
    end
end

% change the directory
cd(currentDir)
