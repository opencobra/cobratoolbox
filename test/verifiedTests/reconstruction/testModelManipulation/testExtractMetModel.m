% The COBRAToolbox: testUpdateGenes.m
%
% Purpose:
%     - testExtractMetModel tests extractMetModel
%
% Authors:
%     - Uri David Akavia August 2017

global CBTDIR

% save the current path
currentDir = pwd;

fileDir = fileparts(which('testUpdateGenes'));
cd(fileDir);

model = getDistributedModel('Recon2.v04.mat');
%compare against explicitly loaded models to conserve the ids.
load('testExtractMetModel.mat', 'emptyModel', 'atpModel', 'pppg9Level0', 'pppg9Level1');

% Test getting level 0 (just reactions that involve a metaoblite)
model2 = extractMetModel(model, 'pppg9', 0, 1);
assert(isSameCobraModel(model2, pppg9Level0));

% Test getting level 1 (include one reaction away from reactions that involve a metaoblite)
model2 = extractMetModel(model, 'pppg9', 1, 1);
assert(isSameCobraModel(model2, pppg9Level1));

% Test asking for a very common metabolite, empty model should be returned
model2 = extractMetModel(model, 'atp', 0, 1);
assert(isSameCobraModel(model2, emptyModel));

% Test asking for a very common metabolite, with high limit on connectivity
model2 = extractMetModel(model, 'atp', 0, 1, 99999);
assert(isSameCobraModel(model2, atpModel));

%return to original directory
cd(currentDir)