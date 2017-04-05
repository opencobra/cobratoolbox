% The COBRAToolbox: testdynamicRFBA.m
%
% Purpose:
%     - testrFBA tests the dynamicRFBA function and its different outputs
%
% Author:
%     - Marouen BEN GUEBILA - 31/01/2017

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testdynamicRFBA'));
cd(fileDir);

%load model and test data
load('modelReg.mat');
load('refData_dynamicRFBA.mat');

%Solver packages
solverPkgs = {'tomlab_cplex'};
%QP solvers
QPsolverPkgs = {'tomlab_cplex'};

for k =1:length(solverPkgs)

    solverLPOK = changeCobraSolver(solverPkgs{k},'LP', 0);

    for j=1:length(QPsolverPkgs)%QP solvers

        solverQPOK = changeCobraSolver(QPsolverPkgs{j}, 'QP', 0);

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

    fprintf('Done.\n');
end

 % change the directory
 cd(currentDir)
