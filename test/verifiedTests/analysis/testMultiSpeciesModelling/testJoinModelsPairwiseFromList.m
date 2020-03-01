% The COBRAToolbox: testJoinModelsPairwiseFromList.m
%
% Purpose:
%     - test that the pairwise models created by function 
%       joinModelsPairwiseFromList have all reactions of the respective
%       microbe reconstructions that were joined.
%
% Author:
%     - Almut Heinken - March 2017
%     - CI integration - Laurent Heirendt - March 2017
%     - renamed script from testBuildPairwiseModels to
%       testJoinModelsPairwiseFromList and adapted to the new module
%       Microbiome_Modeling_Toolbox - Almut Heinken - 02/2018

currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testJoinModelsPairwiseFromList'));
cd(fileDir);

% if the pairedModelInfo file does not exist yet, build the models first
if ~exist('pairedModelInfo', 'var')
    % run the script to build the pairwise models
    modelList={
        'Abiotrophia_defectiva_ATCC_49176'
        'Acidaminococcus_fermentans_DSM_20731'
        'Acidaminococcus_intestini_RyC_MR95'
        'Acidaminococcus_sp_D21'
        'Acinetobacter_calcoaceticus_PHEA_2'
        };
    for i=1:length(modelList)
        model = getDistributedModel([modelList{i} '.mat']);
        inputModels{i,1}=model;
    end
    [pairedModels,pairedModelInfo] = joinModelsPairwiseFromList(modelList,inputModels);
end

for i = 2:size(pairedModelInfo, 1)
    pairedModel=pairedModels{i};
    for p = [2, 4]
        model = getDistributedModel([pairedModelInfo{i, p} '.mat']);
        tmpStr = [pairedModelInfo{i, p}, '_'];
        assert(length(model.mets) == length(find(strncmp(tmpStr, pairedModel.mets, length(tmpStr)))));
        assert(length(model.rxns) == length(find(strncmp(tmpStr, pairedModel.rxns, length(tmpStr)))));
    end
end

% test the diet call without entering any dietary constraints
assert(verifyCobraFunctionError('useDiet', 'inputs',{pairedModel,[]}))

% change to the current directory
cd(currentDir)
