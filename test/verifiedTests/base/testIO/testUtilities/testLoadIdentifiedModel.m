% The COBRAToolbox: testLoadIdentifiedModel.m
%
% Purpose:
%     - test the loadIdentifiedModel function
%
% Authors:
%     - Jacek Wachowiak
%     - Coverage completed by feature 20261104-115314-test-coverage-100, 2026-11-04.
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

%% the deprecated fields of an old model: rev is removed and osense is cast to double
oldStyleFolder = tempname;
mkdir(oldStyleFolder);
oldStyleModel = struct('rxns', {{'R1'}}, 'rev', 0, 'osense', int8(-1));
save([oldStyleFolder filesep 'oldStyleModel.mat'], 'oldStyleModel');
model_3 = loadIdentifiedModel('oldStyleModel', oldStyleFolder);
assert(~isfield(model_3, 'rev'));
assert(isa(model_3.osense, 'double') && model_3.osense == -1);
assert(isequal(model_3.modelID, 'oldStyleModel'));
rmdir(oldStyleFolder, 's');

% change to old directory
cd(currentDir);
