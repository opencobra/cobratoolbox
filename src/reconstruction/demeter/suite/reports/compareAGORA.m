
%% compare two versions of AGORA

% initialize the COBRA Toolbox
initCobraToolbox

% Import file with information on AGORA including reconstruction names
currentDir = pwd;
% add subfolders to path
addpath(genpath(currentDir))

% create and define report folder
mkdir(currentDir, 'Reports')
reportFolder = strcat(currentDir, '/Reports/');

% define the folders with two versions of AGORA to combine
newFolder = 'Y:\Studies\Microbiome\Stefania\Microbiota_models\AGORA_ALL\Models\AGORA_June_2018_Update\';
previousFolder = 'Y:\Studies\Microbiome\Stefania\Microbiota_models\AGORA_ALL\Models\AGORAWithBileAcidSubsystem_17_12_11\';

% get model list from models
modelList = cellstr(ls([previousFolder, '*.mat']));

% read microbe list table
agora = readtable('input/MicrobesTable.txt', 'Delimiter', '/t');

% make an output table where changes are tracked
OutputTable = string({
    'Model_ID', 'Reaction_content', 'Metabolite_content', 'Gene_content', 'Mass_balance', 'Charge_balance', 'Metabolites_without_formulas', 'Leak_test', 'ATP_production', 'Biomass', 'Carbon_sources', 'Fermentation_products', 'Essential_nutrients', 'Nonessential_nutrients', 'Vitamin_biosynthesis', 'Vitamin_secretion', 'Bile_acid_biosynthesis'
});
% also track the changed reaction, metabolite, and gene content
AddedContentInNewVersion = {};
RemovedContentInNewVersion = {};

for i = 1:size(agora, 1)
    if any(ismember(strrep(modelList, '.mat', ''), agora.MicrobeID{i}))
        OutputTable(i + 1, 1) = agora.MicrobeID{i};
        microbeID = agora.MicrobeID{i};
        AddedContentInNewVersion{i, 1} = agora.MicrobeID{i};
        RemovedContentInNewVersion{i, 1} = agora.MicrobeID{i};
        ncbiID = agora.NCBITaxonomy(i);
        [outputFile, outputSummary, onlyInNewModel, onlyInPreviousModel] = compareVersions(previousFolder, newFolder, reportFolder, microbeID, ncbiID);
        % fill in the tables to keep track
        for j = 2:size(outputSummary, 2)
            OutputTable(i + 1, j) = outputSummary(2, j);
        end
        cnt = 2;
        for j = 1:size(onlyInNewModel, 1)
            for k = 1:size(onlyInNewModel, 2)
                if ~isempty(onlyInNewModel{j, k})
                    AddedContentInNewVersion{i, cnt} = onlyInNewModel{j, k};
                    cnt = cnt + 1;
                end
            end
        end
        cnt = 2;
        for j = 1:size(onlyInPreviousModel, 1)
            for k = 1:size(onlyInPreviousModel, 2)
                if ~isempty(onlyInPreviousModel{j, k})
                    RemovedContentInNewVersion{i, cnt} = onlyInPreviousModel{j, k};
                    cnt = cnt + 1;
                end
            end
        end
    end
    C = cellstr(OutputTable);
    xlswrite('AGORA_Comparison.xlsx', C)
    xlswrite('AGORA_AddedContentInNewVersion.xlsx', AddedContentInNewVersion)
    xlswrite('AGORA_RemovedContentInNewVersion.xlsx', RemovedContentInNewVersion)
end
