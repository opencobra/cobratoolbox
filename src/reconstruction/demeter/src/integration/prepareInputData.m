function [adaptedInfoFilePath,inputDataFolder] = prepareInputData(infoFilePath,varargin)
% This function propagates available experimental data that was collected for
% AGORA2 (https://www.biorxiv.org/content/10.1101/2020.11.09.375451v1) to newly
% reconstructed strains and reads information from comparative genomic data
% in PubSEED spreadsheet format if available. It is recommended to check the
% propagated data manually afterwards.
%
% USAGE:
%   prepareInputData(infoFilePath,inputDataFolder,spreadsheetFolder)
%
% REQUIRED INPUT
% infoFilePath          File with information on reconstructions to refine
% OPTIONAL INPUTS
% inputDataFolder       Folder to save propagated data to (default: folder
%                       in current path called "InputData")
% spreadsheetFolder     Folder with comparative genomics data retrieved
%                       from PubSEED in spreadsheet format if available.
%                       For an example of the required format, see
%                       cobratoolbox/papers/2021_demeter/exampleSpreadsheets.
% OUTPUTS
% adaptedInfoFilePath   Path to file with taxonomic information adapted
%                       with gram staining information
% inputDataFolder       Folder to save propagated data to (default: folder
%                       in current path called "InputData")
%
% .. Authors:
%       - Almut Heinken, 06/2020

parser = inputParser();
parser.addRequired('infoFilePath', @ischar);
parser.addParameter('inputDataFolder', [pwd filesep 'InputData'], @ischar);
parser.addParameter('spreadsheetFolder', '', @ischar);

parser.parse(infoFilePath, varargin{:});

infoFilePath = parser.Results.infoFilePath;
inputDataFolder = parser.Results.inputDataFolder;
spreadsheetFolder = parser.Results.spreadsheetFolder;

% create the folder where propagetd experimental data will be saved
mkdir(inputDataFolder)

%% Propagate experimental data from one strain to other strains

global CBTDIR
% find the folder with information that was collected for DEMETER
demeterInputFolder = [CBTDIR filesep 'papers' filesep '2021_demeter' filesep 'input'];
% Get taxonomy information on AGORA2 that will serve to inform new
% organisms
agoraInfoFile = readtable([demeterInputFolder filesep 'AGORA2_infoFile.xlsx'], 'ReadVariableNames', false);
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

%% Check for duplicate and removed strains in the input files

% get list of files to check
inputDataToCheck={
    'CarbonSourcesTable'
    'FermentationTable'
    'GrowthRequirementsTable'
    'secretionProductTable'
    'strainGrowth'
    'uptakeTable'
    };

for i=1:length(inputDataToCheck)
    data=readtable([demeterInputFolder filesep inputDataToCheck{i} '.txt'], 'Delimiter', 'tab', 'ReadVariableNames', false);
    data=table2cell(data);
    checkedData = checkInputData(data,agoraInfoFile);
    writetable(cell2table(checkedData),[demeterInputFolder filesep inputDataToCheck{i}],'FileType','text','WriteVariableNames',false,'Delimiter','tab');
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
    inputData=readtable([demeterInputFolder filesep inputDataToCheck{i} '.txt'], 'Delimiter', 'tab', 'ReadVariableNames', false);
    inputData=table2cell(inputData);
    propagatedData = propagateExperimentalData(inputData, infoFile, agoraInfoFile);
    
    % remove organisms not in the current reconstruction resource
    [C,IA] = setdiff(propagatedData(:,1),infoFile(:,1),'stable');
    propagatedData(IA(2:end),:) = [];
    
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

for i=2:size(infoFile,1)
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

% save adapted file with taxonomic information as a text file
writetable(cell2table(infoFile),[inputDataFolder filesep 'adaptedInfoFile'],'FileType','text','WriteVariableNames',false,'Delimiter','tab');
adaptedInfoFilePath = [inputDataFolder filesep 'adaptedInfoFile.txt'];

%% Map growth on defined media to in silico constraints
% Takes the growth on defined media reported by Tramontano et al. 2018 (PMID:29556107) and
% maps them into input data usable by DEMETER
inputMedia=readtable([demeterInputFolder filesep 'inputMedia.txt'], 'Delimiter', 'tab', 'ReadVariableNames', false);
inputMedia = table2cell(inputMedia);
strainGrowth=readtable([demeterInputFolder filesep 'strainGrowth.txt'], 'Delimiter', 'tab', 'ReadVariableNames', false);
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

% remove organisms not in the current reconstruction resource
[C,IA] = setdiff(data(:,1),infoFile(:,1),'stable');
data(IA(2:end),:) = [];

writetable(cell2table(data),[inputDataFolder filesep 'GrowthRequirementsTable'],'FileType','text','WriteVariableNames',false,'Delimiter','tab');

%% Create genome annotations file with reactions from PubSeed spreadsheets if available reactions that are annotated

if ~isempty(spreadsheetFolder)
    writeReactionsFromPubSeedSpreadsheets(adaptedInfoFilePath,inputDataFolder,spreadsheetFolder);
    genomeAnnotation=readtable([inputDataFolder filesep 'GenomeAnnotation.txt'], 'Delimiter', 'tab', 'ReadVariableNames', false);
    genomeAnnotation = table2cell(genomeAnnotation);
    
    % remove organisms not in the current reconstruction resource
    [C,IA] = setdiff(genomeAnnotation(:,1),infoFile(:,1));
    genomeAnnotation(IA,:) = [];
    
    % Proceed if comparative genomics is available
    if size(genomeAnnotation,1)>0
        
        % Gap-fill reactions formulated by comparative genomics
        gapfilledGenomeAnnotation = gapfillRefinedGenomeReactions(genomeAnnotation);
        
        % remove organisms not in the current reconstruction resource
        [C,IA] = setdiff(gapfilledGenomeAnnotation(:,1),infoFile(:,1));
        gapfilledGenomeAnnotation(IA,:) = [];
        
        writetable(cell2table(gapfilledGenomeAnnotation),[inputDataFolder filesep 'gapfilledGenomeAnnotation'],'FileType','text','WriteVariableNames',false,'Delimiter','tab');
        
        % Remove reactions that are not annotated
        unannotatedRxns=getUnannotatedReactionsFromPubSeedSpreadsheets(adaptedInfoFilePath,inputDataFolder,spreadsheetFolder);
        writetable(cell2table(unannotatedRxns),[inputDataFolder filesep 'unannotatedGenomeAnnotation'],'FileType','text','WriteVariableNames',false,'Delimiter','tab');
    end
end

end

function [propagatedData] = propagateExperimentalData(inputData, infoFile, agoraInfoFile)
% This function propagates experimental data collected for a species to
% other strains of the same species.

% remove strains that are already in the AGORA2 data
[C,IA] = intersect(infoFile(:,1),agoraInfoFile(:,1),'stable');
infoFile(IA(2:end),:)=[];

% get all species
speciesCol=find(strcmp(agoraInfoFile(1,:),'Species'));
species=unique(agoraInfoFile(2:end,speciesCol));

% get new strains to add to the experimental data files
[C,IA] = setdiff(infoFile(2:end,1),inputData(2:end,1));

rowLength=size(inputData,1);
for i=1:length(C)
    inputData{rowLength+i,1}=char(C{i});
    inputData(rowLength+i,2:find(strncmp(inputData(1,:),'Ref',3))-1)=cellstr(num2str(zeros));
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
        if any(sumData)>0
            % if there is any data, propagate the experimental data from
            % the strain with the most data to the strains with no data
            % find the row with the most experimental data
            [row, col] = find(ismember(sumData, max(sumData(:))));
            % propagate the data to new strains
            [~,nsInd,~] = intersect(inputData(:,1),infoFile(newStrains,1));
            for j=1:length(newStrains)
                inputData(nsInd(j),2:end)=inputData(IA(row(1)),2:end);
            end
        end
    end
end

% for fermentation product data: propagate taxa on the genus level if
% there are more than 10 strains and information agrees
if strcmp(inputData{1,2},'Acetate kinase (acetate producer or consumer)')
    
    % find reference columns
    refCols=find(strncmp(inputData(1,:),'Ref',3));
    
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
                    for k=2:refCols(1)-1
                        compData(j,k)=str2double(inputData{IA(j),k});
                    end
                end
                % remove the ones that do not agree for at least 90% of
                % cases
                for k=2:refCols(1)-1
                    if sum(compData(:,k)) < 0.9*length(C)
                        compData(:,k)=0;
                    end
                end
                % propagate the data to new organisms
                % take the data from the strain with the most data
                [C,IAsum]=max(sum(compData,2));
                for j=1:length(newStrains)
                    inputData(find(strcmp(inputData(:,1),infoFile{newStrains(j),1})),2:refCols(1)-1)=num2cell(compData(1,2:end));
                    % propagate references
                    inputData(find(strcmp(inputData(:,1),infoFile{newStrains(j),1})),refCols(1):refCols(end))=inputData(IAsum(1),refCols(1):refCols(end));
                end
            end
        end
    end
end

propagatedData=inputData;

end
