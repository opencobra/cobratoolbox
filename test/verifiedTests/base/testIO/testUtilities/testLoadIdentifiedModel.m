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
directory = [CBTDIR filesep 'test' filesep 'models' filesep 'mat'];
filename = 'iAF1260';
filename_2 = 'ecoli_core_model';

% function outputs
model = loadIdentifiedModel(filename, directory);

% run without directory argument
cd(directory);
model_2 = loadIdentifiedModel(filename_2);
cd(fileDir);

% test
assert(isequal(model.modelID, filename));
assert(isequal(model_2.modelID, 'model'));

% change to old directory
cd(currentDir);
