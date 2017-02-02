% The COBRAToolbox: testSolveBooleanRegModel.m
%
% Purpose:
%     - testrFBA tests the SolveBooleanRegModel function and its different outputs
%
% Author:
%     - Marouen BEN GUEBILA - 31/01/2017
 
  
% define global paths
global path_TOMLAB

% define the path to The COBRAToolbox
pth = which('initCobraToolbox.m');
CBTDIR = pth(1:end - (length('initCobraToolbox.m') + 1));
 
initTest([CBTDIR, filesep, 'test', filesep, 'verifiedTests', filesep, 'testrFBA']);

%Solver packages
solverPkgs = {'tomlab_cplex'};

load modelReg;
load testDataSolveBooleanRegModel;
 

 for k =1:length(solverPkgs)
    % add the solver paths (temporary addition for CI)
    if strcmp(solverPkgs{k}, 'tomlab_cplex')
        addpath(genpath(path_TOMLAB));
    end
        
    solverLPOK = changeCobraSolver(solverPkgs{k});
    if solverLPOK
         %Assert
        [rFBAsol2test,finalInputs1Statestest,finalInputs2Statestest] =...
            solveBooleanRegModel(modelReg,rFBAsol1,inputs1state,inputs2state); 
        assert(isequal(rFBAsol2test,rFBAsol2))
        assert(isequal(finalInputs1Statestest,finalInputs1States))
        assert(isequal(finalInputs2Statestest,finalInputs2States))
    end
    
    % remove the solver paths (temporary addition for CI)
    if strcmp(solverPkgs{k}, 'tomlab_cplex')
        rmpath(genpath(path_TOMLAB));
    end
    
    fprintf('Done.\n');
 end

 
 % change the directory
 cd(CBTDIR) 