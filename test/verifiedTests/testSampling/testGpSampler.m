% The COBRAToolbox: testGpSampler.m
%
% Purpose:
%     - tests the gpSampler function using the E. coli Core Model
%

% define global paths
global path_TOMLAB
global path_GUROBI

% save the current path
currentDir = pwd;

% initialize the test
initTest(fileparts(which(mfilename)));

% load the model
load('ecoli_core_model.mat', 'model');

% define the number of sample points
samplePoints = [5, 190];

% define the solver packages to be used to run this test
solverPkgs = {'gurobi6', 'tomlab_cplex', 'glpk'};

for k = 1:length(solverPkgs)
    % add the solver paths (temporary addition for CI)
    if strcmp(solverPkgs{k}, 'tomlab_cplex')
        addpath(genpath(path_TOMLAB));
    elseif strcmp(solverPkgs{k}, 'gurobi6')
        addpath(genpath(path_GUROBI));
    end

    % set the solver
    solverOK = changeCobraSolver(solverPkgs{k});

    if solverOK == 1
        fprintf('   Testing readSBML using %s ... \n', solverPkgs{k});

        for i = 1:length(samplePoints)
            % call sampler
            [sampleStructOut, mixedFrac] = gpSampler(model, samplePoints(i), [], 2);

            % check
            [errorsA, errorsLUB, stuckPoints] = verifyPoints(sampleStructOut);

            assert(all(~any(errorsA)));
            assert(~any(errorsLUB));
            assert(~any(stuckPoints));
        end

        % print a line for success of loop i
        fprintf(' Done.\n');
    end

    % remove the solver paths (temporary addition for CI)
    if strcmp(solverPkgs{k}, 'tomlab_cplex')
        rmpath(genpath(path_TOMLAB));
    elseif strcmp(solverPkgs{k}, 'gurobi6')
        rmpath(genpath(path_GUROBI));
    end
end

% change the directory
cd(currentDir)
