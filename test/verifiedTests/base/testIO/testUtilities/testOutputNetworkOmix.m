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
model = readCbModel([CBTDIR filesep 'test' filesep 'models' filesep 'ecoli_core_model.mat']);

% function
outputNetworkOmix(model)

% test
assert(isequal(0, 0))

% change to old directory
cd(currentDir);
