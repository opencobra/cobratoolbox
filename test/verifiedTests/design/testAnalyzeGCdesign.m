% The COBRAToolbox: testAnalyzeGCdesign.m
%
% Purpose:
%     - test the analyzeGCdesign function
%
% Authors:
%     - Jacek Wachowiak
global CBTDIR
% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testAnalyzeGCdesign'));
cd(fileDir);

% test variables
model = readCbModel([CBTDIR filesep 'test' filesep 'models' filesep 'ecoli_core_model.mat']);
selectedRxns = model.rxns(1);
target = model.rxns(2);
deletions = model.rxns(3);
modelRed = reduceModel(model);

% function outputs
% requires Global Optimization Toolbox
[improvedRxns, intermediateSlns] = analyzeGCdesign(modelRed, selectedRxns, target, deletions);

% test
assert(isequal(0, 0));

% change to old directory
cd(currentDir);
