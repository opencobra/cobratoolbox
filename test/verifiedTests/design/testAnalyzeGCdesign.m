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
modelRed = reduceModel(model);
selectedRxns = modelRed.rxns(20);
target = modelRed.rxns(20);
deletions = modelRed.rxns(60:87);

% function outputs
% function operates on a not full rank matrix and therefore cannot end without an error
changeCobraSolver('gurobi', 'QP');

[improvedRxns, intermediateSlns] = analyzeGCdesign(modelRed, selectedRxns, target, deletions)

for i=2:9
      [improvedRxns, intermediateSlns] = analyzeGCdesign(modelRed, selectedRxns, target, deletions, i, i)
end

% change to old directory
cd(currentDir);
