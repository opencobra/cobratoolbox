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

initTest(fileparts(which(mfilename)))

% run the script to build the pairwisemodels
if exist('pairedModelsList.mat', 'file') ~= 2
    buildPairwiseModels
end

load pairedModelsList;

for i = 2:size(pairedModelsList, 1)
    load(pairedModelsList{i, 1});
    load(pairedModelsList{i, 2});
    assert(length(model.mets) == length(strmatch(strcat(pairedModelsList{i, 2}, '_'), pairedModel.mets)))
    assert(length(model.rxns) == length(strmatch(strcat(pairedModelsList{i, 2}, '_'), pairedModel.rxns)))

    load(pairedModelsList{i, 5});
    assert(length(model.mets) == length(strmatch(strcat(pairedModelsList{i, 5}, '_'), pairedModel.mets)))
    assert(length(model.rxns) == length(strmatch(strcat(pairedModelsList{i, 5}, '_'), pairedModel.rxns)))
end

% change to the current directory
cd(currentDir)
