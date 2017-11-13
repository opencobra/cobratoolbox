% The COBRAToolbox: testModel2data.m
%
% Purpose:
%     - testModel2data tests the functionality of the rBioNet functions
%     model2data and data2model
%
% Authors:
%     - Stefania Magnusdottir April 2017
%

global CBTDIR

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testModel2data'));
cd(fileDir);

% set paths to rBioNet database
comp_path = [fileDir, filesep 'compartments.mat'];
met_path = [fileDir, filesep 'metab.mat'];
rxn_path = [fileDir, filesep 'rxn.mat'];
save([fileDir, filesep 'rBioNetSettingsDB.mat'], 'comp_path', 'met_path', 'rxn_path')

% load E. coli model
model = getDistributedModel('ecoli_core_model.mat');
modelEcore = model;

% model to data
modelData = model2data(modelEcore, 1);

% data to model
modelTest = data2model(modelData{1, 1}, modelData{1, 2});

% test that the models have the same reactions
[cR, tR, eR] = intersect(modelTest.rxns, modelEcore.rxns);
assert(length(cR) == length(modelTest.rxns))
assert(length(cR) == length(modelEcore.rxns))

% test that the models have the same metabolites
[cM, tM, eM] = intersect(modelTest.mets, modelEcore.mets);
assert(length(cM) == length(modelTest.mets))
assert(length(cM) == length(modelEcore.mets))

% test that the S matrices are identical
assert(isequal(modelTest.S(tM, tR), modelEcore.S(eM, eR)))

% delete the file
delete('rBioNetSettingsDB.mat');

% change the directory
cd(currentDir)
