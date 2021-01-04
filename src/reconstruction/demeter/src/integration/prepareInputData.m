function prepareInputData(infoFilePath,inputDataFolder,getComparativeGenomics)
% This function propagates available experimental data that was collected for
% AGORA2 (https://www.biorxiv.org/content/10.1101/2020.11.09.375451v1) to newly
% reconstructed strains and reads information from comparative genomic data
% in PubSEED spreadsheet format if available. It is recommended to check the
% propagated data manually afterwards.
%
% USAGE:
%
% prepareInputData(infoFilePath,inputDataFolder,getComparativeGenomics)
%
% INPUTS
% infoFilePath             File with information on reconstructions to refine
% inputDataFolder          Folder with experimental data and database files
%                          to load
% getComparativeGenomics   Boolean indicating whether PubSEED spreadsheets
%                          with information on the reconstructed strains are
%                          available and should be used
%
% .. Authors:
%       - Almut Heinken, 06/2020

%% Propagate experimental data from one strain to other strains

% Get taxonomy information on AGORA2 that will serve to inform new
% organisms
agoraInfoFile = readtable('AGORA2_infoFile.xlsx', 'ReadVariableNames', false);
agoraInfoFile = table2cell(agoraInfoFile);

% get taxonomic information of new organisms to reconstruct
infoFile = readtable(infoFilePath, 'ReadVariableNames', false);
infoFile = table2cell(infoFile);

taxa={'Phylum','Class','Order','Family','Genus','Species'};

for i=1:length(taxa)
    taxColNewOrgs=find(strcmp(infoFile(1,:),taxa{i}));
    if isempty(taxColNewOrgs)
        infoFile{1,size(infoFile,2)+1}=taxa{i};
    end
end

% add taxonomy information of new organisms to reconstruct
agora2InputFolder = fileparts(which('ReactionTranslationTable.txt'));

%% Check for duplicate and removed strains in the input files

% get list of files to check
inputDataToCheck={
    'BiosynthesisPrecursorTable'
    'BvitaminBiosynthesisTable'
    'CarbonSourcesTable'
    'drugTable'
    'FermentationTable'
    'GrowthRequirementsTable'
    'secretionProductTable'
    'strainGrowth'
    'uptakeTable'
    };

for i=1:length(inputDataToCheck)
    data=readtable([agora2InputFolder filesep inputDataToCheck{i} '.txt'], 'Delimiter', 'tab', 'ReadVariableNames', false);
    data=table2cell(data);
    checkedData = checkInputData(data,agoraInfoFile);
    writetable(cell2table(checkedData),[agora2InputFolder filesep inputDataToCheck{i}],'FileType','text','WriteVariableNames',false,'Delimiter','tab');
end

%% propagate experimental data from the input files to new strains

inputDataToCheck={
    'CarbonSourcesTable'
    'FermentationTable'
    'GrowthRequirementsTable'
    'secretionProductTable'
    'uptakeTable'
    };

for i=1:length(inputDataToCheck)
    inputData=readtable([agora2InputFolder filesep inputDataToCheck{i} '.txt'], 'Delimiter', 'tab', 'ReadVariableNames', false);
    inputData=table2cell(inputData);
    propagatedData = propagateExperimentalData(inputData, infoFile, agoraInfoFile);
    writetable(cell2table(propagatedData),[inputDataFolder filesep inputDataToCheck{i}],'FileType','text','WriteVariableNames',false,'Delimiter','tab');
end

%% propagate gram staining information
infoFile = readtable(infoFilePath, 'ReadVariableNames', false);
infoFile = table2cell(infoFile);
gramCol=find(strcmp(infoFile(1,:),'Gram Staining'));
if isempty(gramCol)
    infoFile{1,size(infoFile,2)+1}='Gram Staining';
    gramCol=find(strcmp(infoFile(1,:),'Gram Staining'));
end
taxa={'Species','Genus','Family','Order','Class','Phylum'};

agoraGramCol=find(strcmp(agoraInfoFile(1,:),'Gram Staining'));

for i=2:length(infoFile)
    for j=1:length(taxa)
        taxon=infoFile{i,find(strcmp(infoFile(1,:),taxa{j}))};
        taxCol=find(strcmp(agoraInfoFile(1,:),taxa{j}));
        taxRow=find(strcmp(agoraInfoFile(:,taxCol),taxon));
        if ~isempty(taxRow)
            infoFile{i,gramCol}=agoraInfoFile{taxRow,agoraGramCol};
            break
        end
    end
end
infoFile(:,1)=strrep(infoFile(:,1),'-','_');
infoFile=cell2table(infoFile);
if contains(infoFilePath,'xlsx')
    writetable(infoFile,infoFilePath,'FileType','spreadsheet','WriteVariableNames',false);
else
    writetable(infoFile,infoFilePath,'FileType','text','WriteVariableNames',false,'Delimiter','tab');
end

%% Map growth on defined media to in silico constraints
% Takes the growth on defined media reported by Tramontano et al. 2018 (PMID:29556107) and
% maps them into input data usable by DEMETER
inputMedia=readtable('inputMedia.txt', 'Delimiter', 'tab', 'ReadVariableNames', false);
inputMedia = table2cell(inputMedia);
strainGrowth=readtable('strainGrowth.txt', 'Delimiter', 'tab', 'ReadVariableNames', false);
strainGrowth = table2cell(strainGrowth);
mappedMedia = mapMediumData2AGORA(strainGrowth,inputMedia);

% add the data to file with growth requirement data
data=readtable([inputDataFolder filesep 'GrowthRequirementsTable.txt'], 'Delimiter', 'tab', 'ReadVariableNames', false);
data=table2cell(data);

notintable=setdiff(mappedMedia(2:end,1),data(2:end,1));
data(size(data,1)+1:size(data,1)+length(notintable),1)=notintable;
for i=2:size(mappedMedia,1)
    data(find(strcmp(data(:,1),mappedMedia{i,1})),2:size(mappedMedia,2))=mappedMedia(i,2:end);
end
writetable(cell2table(data),[inputDataFolder filesep 'GrowthRequirementsTable'],'FileType','text','WriteVariableNames',false,'Delimiter','tab');

%% Create genome annotations file with reactions from PubSeed spreadsheets if available
if getComparativeGenomics
    spreadsheetFolder=fileparts(which('B_Rib.tsv'));
    % reactions that are annotated
    writeReactionsFromPubSeedSpreadsheets(spreadsheetFolder);
    %% Gap-fill reactions formulated by comparative genomics
    GAFolder=fileparts(which('GenomeAnnotation.txt'));
    genomeAnnotation=readtable([GAFolder filesep 'GenomeAnnotation.txt'], 'Delimiter', 'tab', 'ReadVariableNames', false);
    genomeAnnotation = table2cell(genomeAnnotation);
    [gapfilledGenomeAnnotation] = gapfillRefinedGenomeReactions(genomeAnnotation);
    gapfilledGenomeAnnotation=cell2table(gapfilledGenomeAnnotation);
    writetable(cell2table(gapfilledGenomeAnnotation),[inputDataFolder filesep 'gapfilledGenomeAnnotation'],'FileType','text','WriteVariableNames',false,'Delimiter','tab');
    %% reactions that are not annotated
    unannotatedRxns=getUnannotatedReactionsFromPubSeedSpreadsheets(spreadsheetFolder);
    writetable(cell2table(unannotatedRxns),[inputDataFolder filesep 'unannotatedGenomeAnnotation'],'FileType','text','WriteVariableNames',false,'Delimiter','tab');
end

end

function [propagatedData] = propagateExperimentalData(inputData, infoFile, agoraInfoFile)
% This function propagates experimental data collected for a species to
% other strains of the same species.

% get all species
speciesCol=find(strcmp(agoraInfoFile(1,:),'Species'));
species=unique(agoraInfoFile(2:end,speciesCol));

% get new strains to add to the experimental data files
[C,IA] = setdiff(infoFile(2:end,1),inputData(2:end,1));

rowLength=size(inputData,1);
for i=1:length(C)
    inputData{rowLength+i,1}=char(C{i});
    inputData(rowLength+i,2:end)=cellstr(num2str(zeros));
end

newSpeciesCol=find(strcmp(infoFile(1,:),'Species'));
for i=1:length(species)
    newStrains=find(strcmp(infoFile(:,newSpeciesCol),species{i}));
    if ~isempty(newStrains)
        % get all strains of the species in the existing experimental data
        strains=agoraInfoFile(find(strcmp(agoraInfoFile(:,speciesCol),species{i})),1);
        % if there is more than one strain
        sumData=[];
        % find the strains in the input table with experimental data
        [C,IA,IB] = intersect(inputData(:,1),strains);
        % find the strain with the most data available
        for j=1:length(C)
            sumData(j,1)=abs(nansum(nonzeros(str2double(inputData(IA(j),2:end)))));
        end
        
        % if there is any data, propagate the experimental data from
        % the strain with the most data to any new strains from the same
        % species
        for j=1:length(newStrains)
            inputData(newStrains(j),2:end)=inputData(IA(row(1)),2:end);
        end
    end
end

% for fermentation product data: propagate taxa on the genus level if
% there are more than 10 strains and information agrees
if strcmp(inputData{1,2},'Acetate kinase (acetate producer or consumer)')
    % remove reference columns
    inputData(:,find(strncmp(inputData(1,:),'Ref',3)))=[];
    
    % get all genera
    genusCol=find(strcmp(agoraInfoFile(1,:),'Genus'));
    genera=unique(agoraInfoFile(2:end,genusCol));
    newGenusCol=find(strcmp(infoFile(1,:),'Genus'));
    for i=1:length(genera)
        newStrains=find(strcmp(infoFile(:,newGenusCol),genera{i}));
        if ~isempty(newStrains)
            % get all strains of the genus in the experimental data file
            strains=agoraInfoFile(find(strcmp(agoraInfoFile(:,genusCol),genera{i})),1);
            % if there is more than 10 strains from this genus in the
            % experimental data table so a consensus can be reached
            if length(strains)>10
                compData=[];
                % find the strains in the input table with experimental data
                [C,IA,IB] = intersect(inputData(:,1),strains);
                % find out if data agrees for all strains so the same can be
                % assumed for new organisms of the genus
                for j=1:length(C)
                    for k=2:size(inputData,2)
                        compData(j,k)=str2double(inputData{IA(j),k});
                    end
                end
                % remove the ones that do not agree for at least 90% of
                % cases
                for k=2:size(inputData,2)
                    if sum(compData(:,k)) < 0.9*length(C)
                        compData(:,k)=0;
                    end
                end
                % propagate the data to new organisms
                for j=1:length(newStrains)  
                    inputData(find(strcmp(inputData(:,1),infoFile{newStrains(j),1})),2:end)=num2cell(compData(1,2:end));
                end
            end
        end
    end
end

propagatedData=inputData;

end
