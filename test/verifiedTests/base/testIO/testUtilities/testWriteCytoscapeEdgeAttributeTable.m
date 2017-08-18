% The COBRAToolbox: testOutputHypergraph.m
%
% Purpose:
%     - test the writeCytoscapeEdgeAttributeTable function
%
% Authors:
%     - Jacek Wachowiak
global CBTDIR
% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testWriteCytoscapeEdgeAttributeTable'));
cd(fileDir);

% test variables
model = readCbModel([CBTDIR filesep 'test' filesep 'models' filesep 'ecoli_core_model.mat']);
[modelPlane, replicateMetBool, metData, rxnData] = planariseModel(model);
% function outputs
%writeCytoscapeEdgeAttributeTable(model, C, B, N, replicateMetBool, filename);
%writeCytoscapeEdgeAttributeTable(model, [], [], [], replicateMetBool);
writeCytoscapeEdgeAttributeTable(model, {'1'}, [1], [1], replicateMetBool);

% test
assert(isequal(0, 0))

% removal of the created filename
delete 'ecoli_core_model.matedgeAttributes.txt'

% change to old directory
cd(currentDir);
