function curationStatus = getCurationStatus(infoFilePath,inputDataFolder,getComparativeGenomics)
% This function retrieves for each organism in a reconstruction resource
% whether the strain was refined based on experimental data and/or
% comparative genomic data. For experimental data, 2 indicates that the
% reconstruction was refined against available experimental data for the
% strain, 1 indicates that published studied were available for the strain 
% but no suitable data was found or all findings were negative, and 0
% indicates that no experimental data was available. For comparative
% genomic data, 2 indicates that genome annotations were refined for all 
% subsystems, 1 indicates that certain subsystems were refined, and 0
% indicates that no comparative genomic refinement was performed.
% the file with curation status information will be saved as a file called
% curationStatus.txt in the inputDataFolder.
%
% USAGE:
%
%           curationStatus = getCurationStatus(infoFilePath,inputDataFolder,getComparativeGenomics)
%
% INPUTS
% infoFilePath:             File with information on reconstructions to refine
% inputDataFolder:          Folder with experimental data and database files to
% getComparativeGenomics:   Boolean indicating whether PubSEED spreadsheets 
%                           with information on the reconstructed strains are 
%                           available
%
% OUTPUT
% curationStatus:           Table with curation status of each model
%
% .. Authors:
%       - Almut Heinken, 12/2020

% get file with information on reconstructed organisms
infoFile = readtable(infoFilePath, 'ReadVariableNames', false);
infoFile = table2cell(infoFile);

% load experimental data
inputDataToCheck={
    'CarbonSourcesTable'  'Carbon sources status'  
    'FermentationTable' 'Fermentation products status'
    'NutrientRequirementsTable' 'Growth requirements status'
    'secretionProductTable' 'Secretion products status'
    'uptakeTable'   'Metabolite uptake status'
    };

for i = 1:length(inputDataToCheck)
    curationStatus{1,i+1} = inputDataToCheck{i,2};
    inputData = readtable([inputDataFolder filesep inputDataToCheck{i,1} '.txt'], 'Delimiter', 'tab', 'ReadVariableNames', false);
    inputData = table2cell(inputData);
    newCol = size(infoFile,2)+1;
    infoFile{1,newCol} = inputDataToCheck{i,2};
    refCols=find(strncmp(inputData(1,:),'Ref',3));
    for j=2:size(infoFile,1)
        curationStatus{j,1}=infoFile{i,1};
        findRow = find(strcmp(inputData(:,1),infoFile{j,1}));
        if abs(sum(str2double(inputData(findRow,2:min(refCols)-1)))) > 0
            curationStatus{j,i+1} = 2;
        elseif ~isempty(inputData{findRow,min(refCols)})
            curationStatus{j,i+1} = 1;
        else
            curationStatus{j,i+1} = 0;
        end
    end
end

writetable(cell2table(curationStatus),[inputDataFolder filesep 'curationStatus.txt'],'FileType','text','WriteVariableNames',false,'Delimiter','tab');

if getComparativeGenomics
    % under construction-need to fill in
end

end
