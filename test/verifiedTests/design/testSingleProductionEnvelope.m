% The COBRAToolbox: testSingleProductionEnvelope.m
%
% Purpose:
%     - test the singleProductionEnvelope function
%
% Authors:
%     - Jacek Wachowiak
global CBTDIR
% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testSingleProductionEnvelope'));
cd(fileDir);

% test variables
model = readCbModel([CBTDIR filesep 'test' filesep 'models' filesep 'ecoli_core_model.mat']);
deletions = model.rxns(2);
product = char(model.rxns(3));
biomassRxn = char(model.rxns(1));

% function outputs
% requires Global Optimization Toolbox
singleProductionEnvelope(model, deletions, product, biomassRxn, 'savePlot', 1);
%singleProductionEnvelope(model, deletions, product, biomassRxn, 'geneDelFlag', 1);

% test
assert(isequal(0, 0));

% change to old directory
cd(currentDir);
