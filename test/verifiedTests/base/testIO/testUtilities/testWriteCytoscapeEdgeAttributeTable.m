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
model = readCbModel([CBTDIR filesep 'test' filesep 'models' filesep 'mat' filesep 'ecoli_core_model.mat']);
[modelPlane, replicateMetBool, metData, rxnData] = planariseModel(model);
C = cell(95, 1);
C{1} = '1';
B = ones(95);
B_2 = zeros(95);
N = zeros(95, 1);

% function outputs
writeCytoscapeEdgeAttributeTable(model, [], [], [], replicateMetBool);
writeCytoscapeEdgeAttributeTable(model, C, B, N, replicateMetBool);
model = rmfield(model, 'description');
writeCytoscapeEdgeAttributeTable(model, C, B_2, N, replicateMetBool);

% tests
refFile = fopen('refData_edgeAttributes.txt', 'r');
refVar = fscanf(refFile, '%c');
fclose(refFile);
testFile = fopen('edgeAttributes.txt', 'r');
testVar = fscanf(testFile, '%c');
fclose(testFile);

assert(isequal(refVar, testVar))

refFile_2 = fopen('refData_ecoli_core_model_edgeAttributes.txt', 'r');
refVar_2 = fscanf(refFile_2, '%c');
fclose(refFile_2);
testFile_2 = fopen('ecoli_core_model_edgeAttributes.txt', 'r');
testVar_2 = fscanf(testFile_2, '%c');
fclose(testFile_2);

assert(isequal(refVar_2, testVar_2))

% removal of the created files
delete 'ecoli_core_model_edgeAttributes.txt';
delete 'edgeAttributes.txt';

% change to old directory
cd(currentDir);
