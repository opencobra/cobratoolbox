function [modelIDsMissingInTable,incorrectIDsInTable] = testInputFiles
% Tests if the names of all reconstructed microbes are present in the input
% files for the AGORA2 pipeline.
%
% OUTPUT
% modelIDsMissingInTable       AGORA2 reconstruction IDs missing in the table
% incorrectIDsInTable          Reconstruction IDs in the table not
%                              corresponding to any reconstruction
% Almut Heinken, 09/2019

[~, infoFile, ~] = xlsread('AGORA2_infoFile.xlsx');
models=infoFile(2:end,1);

inputTables = {
    'AromaticAATable'
    'BileAcidTable'
    'CarbonSourcesTable'
    'FermentationTable'
    'GenomeAnnotation'
    'GrowthRequirementsTable'
    'PutrefactionTable'
    'uptakeTable'
    'secretionProductTable'
    };

for i = 1:length(inputTables)
    table = readtable([inputTables{i} '.txt'], 'ReadVariableNames', false, 'Delimiter', 'tab','TreatAsEmpty',['UND. -60001','UND. -2011','UND. -62011']);
    table = table2cell(table);
    notintable = setdiff(models,table(2:end,1));
    modelIDsMissingInTable.(inputTables{i})= notintable;
    incorrectIDs=setdiff(table(2:end,1),models);
    incorrectIDsInTable.(inputTables{i})= incorrectIDs;
    if ~isempty(notintable)
        warning(['Some reconstruction names are not present in table ' inputTables{i}])
    end
    if ~isempty(incorrectIDs)
        warning(['Some reconstruction IDs are incorrect in table ' inputTables{i}])
    end
end

end
