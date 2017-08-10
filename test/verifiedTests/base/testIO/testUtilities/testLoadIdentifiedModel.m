% The COBRAToolbox: testLoadIdentifiedModel.m
%
% Purpose:
%     - test the loadIdentifiedModel function
%
% Authors:
%     - Jacek Wachowiak
global CBTDIR
% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testLoadIdentifiedModel'));
cd(fileDir);

% test variables
directory = [CBTDIR filesep 'test' filesep 'models'];
filename = 'ecoli_core_model';
% function outputs
model = loadIdentifiedModel(filename ,directory)
% test
assert(isequal(model.modelID, filename))
% change to old directory
cd(currentDir);
