% The COBRAToolbox: testconvertHypergraphToBipartiteGraph.m
%
% Purpose:
%     - testconvertHypergraphToBipartiteGraph tests the convertHypergraphToBipartiteGraph
%     function and its different methods
%
% Author:
%     - original file: Marouen BEN GUEBILA - 10/02/2017
%

% define global paths
global path_TOMLAB

% define the path to The COBRAToolbox
pth = which('initCobraToolbox.m');
CBTDIR = pth(1:end - (length('initCobraToolbox.m') + 1));

initTest([CBTDIR, filesep, 'test', filesep, 'verifiedTests', filesep, 'testConvertHypergraphToBipartiteGraph']);

load testDataGraph2Hypergraph.mat;
load('ecoli_core_model', 'model');

%test solver packages
solverPkgs = {'tomlab_cplex'};%,'ILOGcomplex'};

for k = 1:length(solverPkgs)
    % add the solver paths (temporary addition for CI)
    if strcmp(solverPkgs{k}, 'tomlab_cplex')
        addpath(genpath(path_TOMLAB));
    end
    
    %silent mode
    [A,B]=convertHypergraphToBipartiteGraph(model.S,0);
    %verbose mode
    [A,B]=convertHypergraphToBipartiteGraph(model.S,1);
    %Compare test data and results
    assert(isequal(A,testA))
    assert(isequal(B,testB))

    % remove the solver paths (temporary addition for CI)
    if strcmp(solverPkgs{k}, 'tomlab_cplex')
        rmpath(genpath(path_TOMLAB));
    end
end

% change the directory
cd(CBTDIR)
