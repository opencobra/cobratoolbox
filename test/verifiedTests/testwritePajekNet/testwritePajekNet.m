% The COBRAToolbox: testwritePajekNet.m
%
% Purpose:
%     - testwritePajekNet tests the writePajekNet function
%       that transforms a hypergraph into a graph (Pajek format)
%
% Author:
%     - Marouen BEN GUEBILA 09/02/2017

% save the current path
currentDir = pwd;

% initialize the test
cd(fileparts(which(mfilename)));

load('ecoli_core_model', 'model');

%test solver packages
solverPkgs = {'tomlab_cplex'};

for k = 1:length(solverPkgs)

    fprintf('   Testing writePajekNet using %s ... ', solverPkgs{k});

    % change the COBRA solver (LP)
    solverOK = changeCobraSolver(solverPkgs{k}, 'LP', 0);

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
end

% change the directory
cd(currentDir)
