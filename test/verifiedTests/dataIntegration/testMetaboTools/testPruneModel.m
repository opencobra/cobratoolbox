% The COBRA Toolbox: testPruneModel.m
%
% Purpose:
%     - test the pruneModel function
%
% Author:
%     - Loic Marx, December 2018

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which(mfilename));
cd(fileDir);

% load reference data
load('refData_pruneModel.mat')

% define input
model = getDistributedModel('ecoli_core_model.mat');
biomassRxn = model.rxns(13);
minGrowth = 1; 

% generate data
modelPruned = pruneModel(model, minGrowth, biomassRxn);

% comparison between refData and generated data
assert(isequal(modelPruned_Ref, modelPruned))
