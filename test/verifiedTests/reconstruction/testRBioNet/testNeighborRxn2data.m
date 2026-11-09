% The COBRAToolbox: testNeighborRxn2data.m
%
% Purpose:
%     - testNeighborRxn2data tests the functionality of neighborRxn2data in
%       the rBioNet extension
%
% Function under test:
%     src/reconstruction/rBioNet/neighborRxn2data.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - model manipulation, no solver; ecoli_core_model loaded through getDistributedModel.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Stefania Magnusdottir April 2017
%     - Coverage completed by feature 20261104-115314-test-coverage-100, 2026-11-04.
%

global CBTDIR

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testNeighborRxn2data'));
cd(fileDir);

% this test needs no solver, MATLAB toolbox or particular operating system
prepareTest();

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

%% a reaction of common metabolites only has no neighbours

assert(isempty(neighborRxn2data(model, find(strcmp(model.rxns, 'H2Ot')))));

%% a reaction whose metabolite occurs nowhere else has no neighbours

modelIsolated = addReaction(model, 'isolatedRxn', 'isolatedMet[c] -> ');
assert(isempty(neighborRxn2data(modelIsolated, find(strcmp(modelIsolated.rxns, 'isolatedRxn')))));

%% neighbours in the model and in the rBioNet reaction database are listed

% PGI gets another name in the model, so that the database reaction PGI, which shares both of its
% metabolites, is not a reaction of the model
modelCopy = removeRxns(model, 'PGI');
modelCopy = addReaction(modelCopy, 'PGIcopy', 'g6p[c] <=> f6p[c]');
modelCopy.rxnECNumbers = strcat('ec_', modelCopy.rxns);
modelCopy.rxnKEGGID = strcat('kegg_', modelCopy.rxns);
data = neighborRxn2data(modelCopy, find(strcmp(modelCopy.rxns, 'PGIcopy')));
database = load('rxn.mat');

% PFK has f6p[c] in the model: it is listed as in the model, with the fields of the model
modelRow = data(strcmp(data(:, 1), 'PFK'), :);
assert(strcmp(modelRow{2}, 'f6p[c]'));
assert(modelRow{4} == true);
assert(strcmp(modelRow{5}, 'ec_PFK'));
assert(strcmp(modelRow{6}, 'kegg_PFK'));

% PGI is only in the database and shares two metabolites: both are named
pgiRow = data(strcmp(data(:, 1), 'PGI'), :);
pgiDatabase = database.rxn(strcmp(database.rxn(:, 1), 'PGI'), :);
assert(isequal(sort(strsplit(pgiRow{2}, ', ')), {'f6p[c]', 'g6p[c]'}));
assert(strcmp(pgiRow{3}, pgiDatabase{3}));
assert(pgiRow{4} == false);
assert(isequal(pgiRow{5}, pgiDatabase{8}));
assert(isequal(pgiRow{6}, pgiDatabase{9}));

% HEX1 is only in the database and shares one metabolite
hexRow = data(strcmp(data(:, 1), 'HEX1'), :);
assert(strcmp(hexRow{2}, 'g6p[c]'));
assert(hexRow{4} == false);

% each reaction is listed once
assert(numel(unique(data(:, 1))) == size(data, 1));

% change the directory
cd(currentDir)
