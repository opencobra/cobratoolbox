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

model = getDistributedModel('ecoli_core_model.mat');

%additional calls to check all options
notShownMets_cell = cell(9, 1);
notShownMets_cell{1} = outputNetworkCytoscape(model, 'data');
notShownMets_cell{2} = outputNetworkCytoscape(model, 'data', [], [], [], [], 0); %up to 8
notShownMets_cell{3} = outputNetworkCytoscape(model, 'data', model.rxns, {'1'}, model.mets, {'1'}, 0);
notShownMets_cell{4} = outputNetworkCytoscape(model, 'data', model.rxns, ['1'], model.mets, ['1'], 0);
notShownMets_cell{5} = outputNetworkCytoscape(model, 'data', model.rxns, ['1', '2'], model.mets, [], 0);
notShownMets_cell{6} = outputNetworkCytoscape(model, 'data', model.rxns, {'1', '2'}, model.mets, {'1', '2'}, 0);
notShownMets_cell{7} = outputNetworkCytoscape(model, 'data', model.rxns, ['1'], model.mets, ['1', '2'], 0);
notShownMets_cell{8} = outputNetworkCytoscape(model, 'data', model.rxns, [], model.mets, ['1'], 0);
notShownMets_cell{9} = outputNetworkCytoscape(model, 'data', model.rxns, ['1'], model.mets, [], 0);

%call function
notShownMets = outputNetworkCytoscape(model, 'data', model.rxns, [], model.mets, [], 100);
testFiles = {'test.sif', 'test_edgeType.noa', 'test_nodeComp.noa', 'test_nodeType.noa', 'test_subSys.noa'};

%additional tests
assert(isequal(notShownMets_cell{1}, []));
for i=2:9
  assert(isequal(notShownMets_cell{i}, model.mets));
end

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
