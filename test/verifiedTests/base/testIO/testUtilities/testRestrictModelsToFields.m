% The COBRAToolbox: testRestrictModelsToFields.m
%
% Purpose:
%     - test the restrictModelsToFields function
%
% Authors:
%     - Jacek Wachowiak
global CBTDIR
% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testRestrictModelsToFields'));
cd(fileDir);

% test variables
models = readCbModel([CBTDIR filesep 'test' filesep 'models' filesep 'ecoli_core_model.mat']);
fieldNames = fieldnames(models);

% function outputs
restrictedModels = restrictModelsToFields(models, fieldNames);

% test
assert(isequal(restrictedModels, models));

% change to old directory
cd(currentDir);
