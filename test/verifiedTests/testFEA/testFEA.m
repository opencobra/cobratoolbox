% The COBRAToolbox: testFEA.m
%
% Purpose:
%     - testFEA tests the Flux Enrichemnt Analysis
%     function
%
% Author:
%     - Marouen BEN GUEBILA 09/02/2017

% define global paths
global path_TOMLAB

% define the path to The COBRAToolbox
pth = which('initCobraToolbox.m');
CBTDIR = pth(1:end - (length('initCobraToolbox.m') + 1));

initTest([CBTDIR, filesep, 'test', filesep, 'verifiedTests', filesep, 'testFEA']);

load testDataFEA;
load('ecoli_core_model', 'model');

%test solver packages
solverPkgs = {'tomlab_cplex'};%,'ILOGcomplex'};

for k = 1:length(solverPkgs)
    % add the solver paths (temporary addition for CI)
    if strcmp(solverPkgs{k}, 'tomlab_cplex')
        addpath(genpath(path_TOMLAB));
    end

    resultCellFtest=FEA(1:10,model,'subSystems');
    assert(isequal(resultCellFtest,resultCellF));
    
    % remove the solver paths (temporary addition for CI)
    if strcmp(solverPkgs{k}, 'tomlab_cplex')
        rmpath(genpath(path_TOMLAB));
    end
end

% change the directory
cd(CBTDIR)