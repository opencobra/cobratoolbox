% The COBRAToolbox: testTransformModel2KEGG.m
%
% Purpose:
%     - test the transformModel2KEGG function
%
% Authors:
%     - Jacek Wachowiak
global CBTDIR
% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testTransformModel2KEGG'));
cd(fileDir);

% test variables
model = getDistributedModel('ecoli_core_model.mat');
Dictionary = {'0', '1'; '2', '3'};
ref_KEGGID = cell(72, 1);

% function outputs
modelKEGG = transformModel2KEGG(model, Dictionary);
try
    modelKEGG_2 = transformModel2KEGG(model);
catch ME
    assert(length(ME.message) > 0);
end

% test
assert(isequal(modelKEGG.metsAbr, model.mets));
assert(isequal(modelKEGG.metKEGGID, ref_KEGGID));

% change to old directory
cd(currentDir);
