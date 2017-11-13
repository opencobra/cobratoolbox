% The COBRAToolbox: testConvertModelToEX.m
%
% Purpose:
%     - test the convertModelToEX function
%
% Authors:
%     - Jacek Wachowiak
global CBTDIR
% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testConvertModelToEX'));
cd(fileDir);

% test variables
model = getDistributedModel('ecoli_core_model.mat');
filename = 'testData_convertModelToEX.txt';
rxnzero = 0;
filename_2 = 'testData_convertModelToEX_2.txt';
rxnzero_2 = 1;

% function outputs
convertModelToEX(model, filename, rxnzero);
% another call with arguments checking special options
model.ub(20) = -1;
model.lb(20) = -1;
convertModelToEX(model, filename_2, rxnzero_2);

% test - taking the first ~1000 elements without the difference in the second line
testFile = fopen('testData_convertModelToEX.txt', 'r');
testVar = fscanf(testFile, '%c');
testVar = testVar(19:1000);
fclose(testFile);
testFile_2 = fopen('testData_convertModelToEX_2.txt', 'r');
testVar_2 = fscanf(testFile_2, '%c');
testVar_2 = testVar_2(22:1003);
fclose(testFile_2);

assert(isequal(testVar, testVar_2));

% delete test files
delete testData_convertModelToEX.txt;
delete testData_convertModelToEX_2.txt;

% change to old directory
cd(currentDir);
