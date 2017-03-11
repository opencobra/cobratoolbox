% The COBRAToolbox: testoptimizeRegModel.m
%
% Purpose:
%     - testrFBA tests the optimizeRegModel function and its different outputs
%
% Author:
%     - Marouen BEN GUEBILA - 31/01/2017


% define global paths
global path_TOMLAB

% define the path to The COBRAToolbox
pth = which('initCobraToolbox.m');
CBTDIR = pth(1:end - (length('initCobraToolbox.m') + 1));

initTest([CBTDIR, filesep, 'test', filesep, 'verifiedTests', filesep, 'testrFBA']);

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
        addpath(genpath(path_TOMLAB));
    end

    for j=1:length(QPsolverPkgs)%QP solvers
        solverLPOK = changeCobraSolver(solverPkgs{k},'LP');
        solverQPOK = changeCobraSolver(QPsolverPkgs{j},'QP');
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
        rmpath(genpath(path_TOMLAB));
    end

    fprintf('Done.\n');
end

 % change the directory
 cd(CBTDIR)
