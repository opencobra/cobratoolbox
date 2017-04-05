% The COBRAToolbox: testBuildPairwiseModels.m
%
% Purpose:
%     - test that the pairwise models created by script BuildPairwiseModels have
%       all reactions of the respective microbe reconstructions that were joined.
%
% Author:
%     - Almut Heinken - March 2017
%     - CI integration - Laurent Heirendt - March 2017

currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testBuildPairwiseModels'));
cd(fileDir);

% run the script to build the pairwisemodels
if exist('pairedModelsList.mat', 'file') ~= 2
    buildPairwiseModels
end

load pairedModelsList;

for i = 2:size(pairedModelsList, 1)
    load(pairedModelsList{i, 1});
    for p = [2, 5]
        load(pairedModelsList{i, p});
        tmpStr = [pairedModelsList{i, p}, '_'];
        assert(length(model.mets) == length(find(strncmp(tmpStr, pairedModel.mets, length(tmpStr)))));
        assert(length(model.rxns) == length(find(strncmp(tmpStr, pairedModel.rxns, length(tmpStr)))));
    end
end

% test the diet call with an unknown diet
try
    useDiet_AGORA_pairedModels(pairedModel, 'unknownDiet')
catch ME
    assert(length(ME.message) > 0)
end

% change to the current directory
cd(currentDir)
