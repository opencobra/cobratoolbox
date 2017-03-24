% The COBRAToolbox: testoptimizeRegModel.m
%
% Purpose:
%     - testrFBA tests the optimizeRegModel function and its different outputs
%
% Author:
%     - Marouen BEN GUEBILA - 31/01/2017


% define global paths
global TOMLAB_PATH

% save the current path
currentDir = pwd;

% initialize the test
initTest(fileparts(which(mfilename)));

% load model and test data
load('modelReg.mat');
load('refData_optimizeRegModel.mat');

%set tolerance
tol = 1e-4;
% solver packages
solverPkgs = {'tomlab_cplex'};

% QP solvers
QPsolverPkgs = {'tomlab_cplex'};

for k =1:length(solverPkgs)
    % add the solver paths (temporary addition for CI)
    if strcmp(solverPkgs{k}, 'tomlab_cplex')
        addpath(genpath(TOMLAB_PATH));
    end

    for j=1:length(QPsolverPkgs)%QP solvers
        
        solverLPOK = changeCobraSolver(solverPkgs{k}, 'LP', 0);
        solverQPOK = changeCobraSolver(QPsolverPkgs{j}, 'QP', 0);

        if solverLPOK && solverQPOK
             %Without initial state
            [FBAsolstest,DRgenestest,constrainedRxnstest,cycleStarttest,statestest] = optimizeRegModel(modelReg);
            assert(isequal(cycleStart,cycleStarttest))
            assert(isequal(DRgenestest,DRgenes))
            assert(isequal(constrainedRxnstest,constrainedRxns))
            assert(isequal(statestest,states))
            %only compare objective because solution may vary
            assert( FBAsolstest{1}.f - FBAsols{1}.f < tol)

            %With initial state
            initialStates = false.*ones(length(modelReg.regulatoryGenes)+length(modelReg.regulatoryInputs1)+length(modelReg.regulatoryInputs2),1);
            [FBAsolstest,DRgenestest,constrainedRxnstest,cycleStarttest,statestest] = optimizeRegModel(modelReg,initialStates);
            assert(isequal(cycleStart,cycleStarttest))
            assert(isequal(DRgenestest,DRgenes))
            assert(isequal(constrainedRxnstest,constrainedRxns))
            assert(isequal(statestest,states))
            %only compare objective because solution may vary
            assert( FBAsolstest{1}.f - FBAsols{1}.f < tol)
        end
    end

    % remove the solver paths (temporary addition for CI)
    if strcmp(solverPkgs{k}, 'tomlab_cplex')
        rmpath(genpath(TOMLAB_PATH));
    end

    fprintf('Done.\n');
end

 % change the directory
 cd(currentDir)
