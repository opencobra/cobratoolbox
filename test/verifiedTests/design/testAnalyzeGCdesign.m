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
% function operates on a not full rank matrix and therefore cannot end without an error
try
    [improvedRxns, intermediateSlns] = analyzeGCdesign(modelRed, selectedRxns, target, deletions);
catch ME
    assert(length(ME.message) > 0)
end
try
    [improvedRxns, intermediateSlns] = analyzeGCdesign(modelRed, selectedRxns, target, '');
catch ME
    assert(length(ME.message) > 0)
end
for i=2:9
  try
      [improvedRxns, intermediateSlns] = analyzeGCdesign(modelRed, selectedRxns, target, deletions, i, i);
  catch ME
      assert(length(ME.message) > 0)
  end
end

% change to old directory
cd(currentDir);
