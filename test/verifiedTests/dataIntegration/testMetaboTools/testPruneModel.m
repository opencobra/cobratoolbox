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

% retrieve the default biomass reaction
biomassRxn = checkObjective(model);
biomassRxn = biomassRxn{1};

minGrowth = 1; % this value is for testing only

% generate data
[modelUpdated, modelPruned, Ex_Rxns] = pruneModel(model, minGrowth, biomassRxn);

% if biomassRxn is not define
[modelUpdated_2inputs, modelPruned_2inputs, Ex_Rxns_2inputs] = pruneModel(model, minGrowth);

% comparison between refData and generated data
assert(isequal(modelUpdated_ref, modelUpdated))
assert(isequal(modelPruned_ref, modelPruned))
assert(isequal(Ex_Rxns_ref, Ex_Rxns))

% comparison between refData and data generated without the biomassRxn input
assert(isequal(modelUpdated_ref, modelUpdated_2inputs))
assert(isequal(modelPruned_ref, modelPruned_2inputs))
assert(isequal(Ex_Rxns_ref, Ex_Rxns_2inputs))
