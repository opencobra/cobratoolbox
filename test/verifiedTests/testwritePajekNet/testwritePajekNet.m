% The COBRAToolbox: testwritePajekNet.m
%
% Purpose:
%     - testwritePajekNet tests the writePajekNet function
%       that transforms a hypergraph into a graph (Pajek format)
%
% Author:
%     - Marouen BEN GUEBILA 09/02/2017

% define global paths
global path_TOMLAB

% define the path to The COBRAToolbox
pth = which('initCobraToolbox.m');
CBTDIR = pth(1:end - (length('initCobraToolbox.m') + 1));

initTest([CBTDIR, filesep, 'test', filesep, 'verifiedTests', filesep, 'testwritePajekNet']);

load('ecoli_core_model', 'model');

%test solver packages
solverPkgs = {'tomlab_cplex'};  %,'ILOGcomplex'};

for k = 1:length(solverPkgs)

    fprintf('   Testing writePajekNet using %s ... ', solverPkgs{k});

    % add the solver paths (temporary addition for CI)
    if strcmp(solverPkgs{k}, 'tomlab_cplex')
        addpath(genpath(path_TOMLAB));
    end

    % change the COBRA solver (LP)
    solverOK = changeCobraSolver(solverPkgs{k});

    if solverOK == 1
        %load test data
        fileID = fopen('COBRAmodeltest.net', 'r');
        testData = fscanf(fileID, '%s');
        fclose(fileID);

        %call fucntion
        writePajekNet(model);

        %save produced data
        fileID = fopen('COBRAmodel.net', 'r');
        Data = fscanf(fileID, '%s');
        fclose(fileID);

        %compare with produced data
        assert(isequal(testData, Data));

        %delete data
        delete COBRAmodel.net
    end

    % remove the solver paths (temporary addition for CI)
    if strcmp(solverPkgs{k}, 'tomlab_cplex')
        rmpath(genpath(path_TOMLAB));
    end
end

% change the directory
cd(CBTDIR)
