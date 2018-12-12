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
minGrowth = 1; % this value is for testing only 

% generate data
[modelUpdated, modelPruned, Ex_Rxns] = pruneModel(model, minGrowth, biomassRxn);

% comparison between refData and generated data
assert(isequal(modelUpdated_ref, modelUpdated))
assert(isequal(modelPruned_ref, modelPruned))
assert(isequal(Ex_Rxns_ref, Ex_Rxns))
