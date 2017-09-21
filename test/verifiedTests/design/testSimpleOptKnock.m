% The COBRAToolbox: testSimpleOptKnock.m
%
% Purpose:
%     - test the simpleOptKnock function
%
% Authors:
%     - Jacek Wachowiak
global CBTDIR
% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testSimpleOptKnock'));
cd(fileDir);

% test variables
model = readCbModel([CBTDIR filesep 'test' filesep 'models' filesep 'ecoli_core_model.mat']);
targetRxn = model.rxns(2);

% function outputs
[wtRes, delRes] = simpleOptKnock(model, targetRxn)
[wtRes, delRes] = simpleOptKnock(model, targetRxn, model.rxns, 1, 0.05, 1)

% test for the successful removal of the files
assert(isequal(0, 0));

% change to old directory
cd(currentDir);
