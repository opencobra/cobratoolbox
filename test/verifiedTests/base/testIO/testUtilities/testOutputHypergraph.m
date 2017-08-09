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
fileDir = fileparts(which('outputHypergraph'));
cd(fileDir);

% test variables
testModel = readCbModel([CBTDIR filesep 'test' filesep 'models' filesep 'Recon2.v04.mat']);
testFileName = 'testData_outputHypergraph.txt';
testWeights = zeros(7440);

% function outputs
outputHypergraph(testModel, testWeights, testFileName);
testsFile = textread('testData_outputHypergraph.txt');
modelFile = textread('refData_outputHypergraph.txt');

% test
assert(isequal(testsFile, modelFile))

% change to old directory
cd(currentDir);
