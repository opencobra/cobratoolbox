% The COBRAToolbox: testOutputNetworkCytoscape.m
%
% Purpose:
%     - testtestoutputNetworkCytoscape tests the testoutputNetworkCytoscape function
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

initTest([CBTDIR, filesep, 'test', filesep, 'verifiedTests', filesep, 'testOutputNetworkCytoscape']);

load('ecoli_core_model', 'model');

%test solver packages
solverPkgs = {'tomlab_cplex'};%,'ILOGcomplex'};

for k = 1:length(solverPkgs)
    fprintf('   Testing outputNetworkCytoscape using %s ... ', solverPkgs{k});

    % add the solver paths (temporary addition for CI)
    if strcmp(solverPkgs{k}, 'tomlab_cplex')
        addpath(genpath(path_TOMLAB));
    end

    %call function
    notShownMets = outputNetworkCytoscape(model, 'data', model.rxns, [], model.mets, [], 100);

    testFiles = {'test.sif', 'test_edgeType.noa', 'test_nodeComp.noa', 'test_nodeType.noa', 'test_subSys.noa'};

    %call test
    for j = 1:length(testFiles)
        str = testFiles{j};

        %load test data
        fileID = fopen(str, 'r');
        testData = fscanf(fileID, '%s');
        fclose(fileID);

        %save produced data
        str2 = strrep(str, 'test', 'data');
        fileID = fopen(str2, 'r');
        Data = fscanf(fileID, '%s');
        fclose(fileID);

        %compare with produced data
        assert(isequal(testData,Data));

        %delete file
        delete(str2);
    end

    % remove the solver paths (temporary addition for CI)
    if strcmp(solverPkgs{k}, 'tomlab_cplex')
        rmpath(genpath(path_TOMLAB));
    end
end

% change the directory
cd(CBTDIR)
