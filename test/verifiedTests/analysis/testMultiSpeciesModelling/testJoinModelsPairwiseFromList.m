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
%     - Farid Zare - Feb 2024 Updated test function for latest function
%     changes

currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testJoinModelsPairwiseFromList'));
cd(fileDir);

fprintf('   Testing joinModelsPairwiseFromList.m ...\n');
% if the pairedModelInfo file does not exist yet, build the models first
if ~exist('pairedModelInfo', 'var')
    % run the script to build the pairwise models
    modelList={
        'Abiotrophia_defectiva_ATCC_49176'
        'Acidaminococcus_fermentans_DSM_20731'
        'Acidaminococcus_intestini_RyC_MR95'
        'Acinetobacter_calcoaceticus_PHEA_2'
        'Acinetobacter_baumannii_AB0057'
        };
    for i=1:length(modelList)
        model = getDistributedModel([modelList{i} '.mat']);
        % Save all the models into the modelFolder
        save(fullfile(fileDir, modelList{i}), 'model');
    end
    joinModelsPairwiseFromList(modelList, fileDir);
    % Load pairedModelInfo
    load('pairedModelInfo.mat');
end

for i = 1:size(pairedModelInfo, 1)
    load(pairedModelInfo{i,1});
    % pairedModel=pairedModels{i};
    for p = [2, 4]
        model = getDistributedModel([pairedModelInfo{i, p} '.mat']);
        tmpStr = [pairedModelInfo{i, p}, '_'];
        assert(length(model.mets) == length(find(strncmp(tmpStr, pairedModel.mets, length(tmpStr)))));
        assert(length(model.rxns) == length(find(strncmp(tmpStr, pairedModel.rxns, length(tmpStr)))));
    end
end

% test the diet call without entering any dietary constraints
assert(verifyCobraFunctionError('useDiet', 'inputs',{pairedModel,[]}))

%cleanup
clear('pairedModelInfo')
delete('Abiotrophia_defectiva_ATCC_49176.mat')
delete('Acidaminococcus_fermentans_DSM_20731.mat')
delete('Acidaminococcus_intestini_RyC_MR95.mat')
delete('Acidaminococcus_sp_D21.mat')
delete('Acinetobacter_calcoaceticus_PHEA_2.mat')
delete('pairedModelInfo.mat')
delete('pairedModel_Abiotrophia_defectiva_ATCC_49176_Acidaminococcus_fermentans_DSM_20731.mat')
delete('pairedModel_Abiotrophia_defectiva_ATCC_49176_Acidaminococcus_intestini_RyC_MR95.mat')
delete('pairedModel_Abiotrophia_defectiva_ATCC_49176_Acidaminococcus_sp_D21.mat')
delete('pairedModel_Abiotrophia_defectiva_ATCC_49176_Acinetobacter_calcoaceticus_PHEA_2.mat')
delete('pairedModel_Acidaminococcus_fermentans_DSM_20731_Acidaminococcus_intestini_RyC_MR95.mat')
delete('pairedModel_Acidaminococcus_fermentans_DSM_20731_Acidaminococcus_sp_D21.mat')
delete('pairedModel_Acidaminococcus_fermentans_DSM_20731_Acinetobacter_calcoaceticus_PHEA_2.mat')
delete('pairedModel_Acidaminococcus_intestini_RyC_MR95_Acidaminococcus_sp_D21.mat')
delete('pairedModel_Acidaminococcus_intestini_RyC_MR95_Acinetobacter_calcoaceticus_PHEA_2.mat')
delete('pairedModel_Acidaminococcus_sp_D21_Acinetobacter_calcoaceticus_PHEA_2.mat')

% output a success message
fprintf('Done.\n')

% change to the current directory
cd(currentDir)
