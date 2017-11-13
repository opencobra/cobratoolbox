% The COBRAToolbox: testOutputHypergraph.m
%
% Purpose:
%     - test the outputHypergraph function
%
% Authors:
%     - Jacek Wachowiak
global CBTDIR
% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testOutputHypergraph'));
cd(fileDir);

% test variables
testModel = getDistributedModel('ecoli_core_model.mat');
testFileName = 'testData_outputHypergraph.txt';
testWeights = zeros(95);

% function outputs
outputHypergraph(testModel, testWeights, testFileName);
testsFile = textread('testData_outputHypergraph.txt');
modelFile = textread('refData_outputHypergraph.txt');

% test
assert(isequal(testsFile, modelFile))

% remove the test file
delete testData_outputHypergraph.txt

% change to old directory
cd(currentDir);
