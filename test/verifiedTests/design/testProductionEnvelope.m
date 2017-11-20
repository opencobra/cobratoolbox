% The COBRAToolbox: testProductionEnvelope.m
%
% Purpose:
%     - test the productionEnvelope function
%
% Authors:
%     - Jacek Wachowiak
global CBTDIR
% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testProductionEnvelope'));
cd(fileDir);

% test variables
model = readCbModel('ecoli_core_model.mat');
model.lb(36) = 0; % Set anaerobic conditions
biomassRxn = model.rxns{13};
targetRxn = model.rxns{20};
deletions = model.rxns(23);
deletions2 = model.genes(23);

% reference data


% function outputs
[biomassValues, targetValues, lineHandle] = productionEnvelope(model, deletions, 'k', targetRxn, biomassRxn)
[biomassValues2, targetValues2, lineHandle2] = productionEnvelope(model, deletions2, 'k', targetRxn, biomassRxn, 1)

% tests

pause(3);
close all hidden force

% change to old directory
cd(currentDir);
