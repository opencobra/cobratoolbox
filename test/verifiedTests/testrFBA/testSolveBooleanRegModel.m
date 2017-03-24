% The COBRAToolbox: testSolveBooleanRegModel.m
%
% Purpose:
%     - testrFBA tests the SolveBooleanRegModel function and its different outputs
%
% Author:
%     - Marouen BEN GUEBILA - 31/01/2017


% define global paths
global TOMLAB_PATH

% save the current path
currentDir = pwd;

% initialize the test
initTest(fileparts(which(mfilename)));

% solver packages
solverPkgs = {'tomlab_cplex'};

% load model and test data
load('modelReg.mat');
load('refData_solveBooleanRegModel.mat');

 for k = 1:length(solverPkgs)
    % add the solver paths (temporary addition for CI)
    if strcmp(solverPkgs{k}, 'tomlab_cplex')
        addpath(genpath(TOMLAB_PATH));
    end

    solverLPOK = changeCobraSolver(solverPkgs{k}, 'LP', 0);
    
    if solverLPOK
         %Assert
        [rFBAsol2test,finalInputs1Statestest,finalInputs2Statestest] = solveBooleanRegModel(modelReg,rFBAsol1,inputs1state,inputs2state);
        assert(isequal(rFBAsol2test,rFBAsol2))
        assert(isequal(finalInputs1Statestest,finalInputs1States))
        assert(isequal(finalInputs2Statestest,finalInputs2States))
    end

    % remove the solver paths (temporary addition for CI)
    if strcmp(solverPkgs{k}, 'tomlab_cplex')
        rmpath(genpath(TOMLAB_PATH));
    end

    fprintf('Done.\n');
 end

 % change the directory
 cd(currentDir)
