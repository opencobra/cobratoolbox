% The COBRAToolbox: testPlanariseModel.m
%
% Purpose:
%     - test the planariseModel function
%
% Authors:
%     - Jacek Wachowiak
global CBTDIR
% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testPlanariseModel'));
cd(fileDir);

% test variables
model = getDistributedModel('ecoli_core_model.mat');

% function outputs
[modelPlane, replicateMetBool, metData, rxnData] = planariseModel(model);

% tests
assert(isequal(model.rxns, modelPlane.rxns));
assert(isequal(size(model.mets), size(replicateMetBool)));
assert(isequal(metData{1}, 'Salmon'));
assert(isequal(rxnData{1}, 'PaleBlue'));

% change to old directory
cd(currentDir);
