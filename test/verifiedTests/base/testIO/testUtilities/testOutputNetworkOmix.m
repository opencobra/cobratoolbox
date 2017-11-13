% The COBRAToolbox: testOutputNetworkOmix.m
%
% Purpose:
%     - test the outputNetworkOmix function
%
% Authors:
%     - Jacek Wachowiak
global CBTDIR
% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testOutputNetworkOmix'));
cd(fileDir);

% test variables
model = getDistributedModel('ecoli_core_model.mat');
model_2 = model;
model_2.description = struct('name', 'ecoli_core_model_mat');

% function
outputNetworkOmix(model)
outputNetworkOmix(model_2)

% removal of the test filesep
delete 'ecoli_core_model_mat.txt'

% change to old directory
cd(currentDir);
