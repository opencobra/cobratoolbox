% The COBRAToolbox: testNeighborRxn2data.m
%
% Purpose:
%     - testNeighborRxn2data tests the functionality of neighborRxn2data in
%       the rBioNet extension
%
% Authors:
%     - Stefania Magnusdottir April 2017
%

global CBTDIR

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testNeighborRxn2data'));
cd(fileDir);

% load E. coli model
model = getDistributedModel('ecoli_core_model.mat');

% equires EC number field
model.rxnECNumbers = cell(size(model.rxns));%requires EC number field
data = neighborRxn2data(model, 1);

% test that output is not empty
assert(~isempty(data))

% test that output has 6 columns
assert(size(data, 2) == 6)

% test that reactions are reported correctly to be in model
assert(sum(cell2mat(data(:, 4))) == length(find(ismember(model.rxns, data(:, 1)))))

% change the directory
cd(currentDir)
