% The COBRAToolbox: testOutputNetworkCytoscape.m
%
% Purpose:
%     - testtestoutputNetworkCytoscape tests the testoutputNetworkCytoscape function
%       that transforms a hypergraph into a graph (cytoscape format)
%
%
% Author:
%     - Marouen BEN GUEBILA 09/02/2017

global CBTDIR

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testOutputNetworkCytoscape'));
cd(fileDir);

load([CBTDIR, filesep, 'test' filesep 'models' filesep 'ecoli_core_model.mat'], 'model');

%additional tests to check all options
outputNetworkCytoscape(model, 'data');
outputNetworkCytoscape(model, 'data', [], [], [], [], 0); %up to 8
outputNetworkCytoscape(model, 'data', model.rxns, {'1'}, model.mets, {'1'}, 0);
outputNetworkCytoscape(model, 'data', model.rxns, ['1'], model.mets, ['1'], 0);
outputNetworkCytoscape(model, 'data', model.rxns, ['1', '2'], model.mets, [], 0);
outputNetworkCytoscape(model, 'data', model.rxns, {'1', '2'}, model.mets, {'1', '2'}, 0);
outputNetworkCytoscape(model, 'data', model.rxns, ['1'], model.mets, ['1', '2'], 0);
outputNetworkCytoscape(model, 'data', model.rxns, [], model.mets, ['1'], 0);
outputNetworkCytoscape(model, 'data', model.rxns, ['1'], model.mets, [], 0);
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

% change the directory
cd(currentDir)
