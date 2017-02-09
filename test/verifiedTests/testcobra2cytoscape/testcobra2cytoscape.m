% The COBRAToolbox: testcobra2cytoscape.m
%
% Purpose:
%     - testcobra2cytoscape tests the cobra2cytoscape function
%       that transforms a hypergraph into a graph (cytoscape format)
% 
%
% Author:
%     - Marouen BEN GUEBILA 09/02/2017

% define global paths
global path_TOMLAB

% define the path to The COBRAToolbox
pth = which('initCobraToolbox.m');
CBTDIR = pth(1:end - (length('initCobraToolbox.m') + 1));

initTest([CBTDIR, filesep, 'test', filesep, 'verifiedTests', filesep, 'testcobra2cytoscape']);

load('ecoli_core_model', 'model');

%test solver packages
solverPkgs = {'tomlab_cplex'};%,'ILOGcomplex'};

for k = 1:length(solverPkgs)
    % add the solver paths (temporary addition for CI)
    if strcmp(solverPkgs{k}, 'tomlab_cplex')
        addpath(genpath(path_TOMLAB));
    end
    
    %load test data
    testData=csvread('GraphMetCentrictest.csv');
    %call fucntion
    cobra2cytoscape(model)
    %save produced data
    Data=csvread('GraphMetCentrictest.csv');
    %compare with produced data
    assert(isequal(testData,Data));
    %delete data
    delete GraphMetCentric.csv
    % remove the solver paths (temporary addition for CI)
    if strcmp(solverPkgs{k}, 'tomlab_cplex')
        rmpath(genpath(path_TOMLAB));
    end
end

% change the directory
cd(CBTDIR)
