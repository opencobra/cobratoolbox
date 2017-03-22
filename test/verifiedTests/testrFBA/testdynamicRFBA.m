% The COBRAToolbox: testdynamicRFBA.m
%
% Purpose:
%     - testrFBA tests the dynamicRFBA function and its different outputs
%
% Author:
%     - Marouen BEN GUEBILA - 31/01/2017

% define global paths
global TOMLAB_PATH

% save the current path
currentDir = pwd;

% initialize the test
initTest(fileparts(which(mfilename)));

%load model and test data
load('modelReg.mat');
load('refData_dynamicRFBA.mat');

%Solver packages
solverPkgs = {'tomlab_cplex'};
%QP solvers
QPsolverPkgs = {'tomlab_cplex'};

for k =1:length(solverPkgs)
    % add the solver paths (temporary addition for CI)
    if strcmp(solverPkgs{k}, 'tomlab_cplex')
        addpath(genpath(TOMLAB_PATH));
    end

    solverLPOK = changeCobraSolver(solverPkgs{k},'LP');
    for j=1:length(QPsolverPkgs)%QP solvers
        solverQPOK = changeCobraSolver(QPsolverPkgs{j},'QP');
        if solverLPOK && solverQPOK
            substrateRxns ={'EX_glc(e)' 'EX_ac(e)'};
            initConcentrations = [10.8; 1];
            initBiomass = 0.001;
            timeStep = 1/100;
            nSteps = 200;

             %Assert
            [concentrationMatrixtest,excRxnNamestest,timeVectest,biomassVectest,drGenestest,constrainedRxnstest,statestest] = ...
                dynamicRFBA(modelReg,substrateRxns,initConcentrations,initBiomass,timeStep,nSteps);

            tol = eps(0.5);%set tolerance
            %assertions
            assert(any(any(abs(concentrationMatrixtest-concentrationMatrix) < tol)))
            assert(isequal(excRxnNamestest,excRxnNames))
            assert(isequal(timeVectest,timeVec))
            assert(any(abs(biomassVectest-biomassVec) < tol))
            assert(isequal(drGenestest,drGenes))
            assert(isequal(constrainedRxnstest,constrainedRxns))
            assert(isequal(statestest,states))
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
