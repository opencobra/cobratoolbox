function [translatedAbundances,normalizedAbundances,unmappedRows]=translateMetagenome2AGORA(MetagenomeAbundancePath,sequencingDepth)
% Translates organism identifiers in a published metagenomic or 16S rRNA
% data file with organism abundances (retrieved e.g., from  MetaPhlAn) to
% AGORA pan-model IDs. This will not catch every case since the format of
% input files with abundance data greatly varies. Feel free to modify this
% function and submit a pull request to enable more input files to be
% translated to AGORA. Moreover, slight spelling variations in taxa across
% input files may  result to taxa not being mapped. Check the unmappedRows
% output to identify these cases and modify the function accordingly.
% Pan-models that can be used to create microbiome models in mgPipe can be
% created with the function createPanModels.
%
% USAGE:
%
%   [translatedAbundances,normalizedAbundances,unmappedRows]=translateMetagenome2AGORA(MetagenomeAbundancePath,sequencingDepth)
%
% INPUT:
%   MetagenomeAbundancePath   String containing the path to csv file with
%                             organism abundance data retrieved from
%                             16S rRNA or metagenomic samples (example:
%                             'SRP065497_taxonomy_abundances_v3.0.csv').
%
% OPTIONAL INPUT:
%   sequencingDepth           Sequencing depth on the taxonomical level
%                             in the input data (e.g., genus, species).
%                             Allowed inputs are 'p__', 'c__', 'o__',
%                             'f__', 'g__', 's__'. Default: 's__'
%
% OUTPUTS:
%   translatedAbundances      Abundances with organism names from the
%                             input file translated to AGORA pan-model IDs
%   normalizedAbundances      Translated abundances normalized so they sum
%                             up to 1 for each sample
%   unmappedRows              Taxa on the selected taxonomical level that
%                             could not be mapped to AGORA pan-models
%
% .. Author: Almut Heinken, 02/2019


if nargin <2
    sequencingDepth='s__';
end

% read the csv file with the abundance data
metagenome_abundance = readtable(MetagenomeAbundancePath, 'ReadVariableNames', false,'FileType','text','delimiter','tab');
metagenome_abundance = table2cell(metagenome_abundance);
metagenome_abundance{1,1}='';

% list the taxonomical levels
taxLevels={
    'Phylum'
    'Class'
    'Order'
    'Family'
    'Genus'
    'Species'
    };

[~, infoFile, ~] = xlsread('AGORA_infoFile.xlsx');  % create the pan-models

% List all taxa in the AGORA resource
agoraTaxa={};
for i=1:length(taxLevels)
    % gets all pan-model IDs
    findTaxCol = find(strcmp(infoFile(1, :), taxLevels{i}));
    allTaxa = unique(infoFile(2:end, findTaxCol));
    allTaxa(:,1)=strrep(allTaxa(:,1),' ','_');
    allTaxa(:,1)=strcat('pan',allTaxa(:,1));
    agoraTaxa=vertcat(agoraTaxa,allTaxa);
end
allTaxa = unique(infoFile(2:end, find(strcmp(infoFile(1, :), 'ModelAGORA'))));
agoraTaxa=vertcat(allTaxa,agoraTaxa);

% format the input file so it can be matched
metagenome_abundance(:,1)=strrep(metagenome_abundance(:,1),';','|');

% match different phrasing
% This may not catch all cases! Feel free to add additional cases of
% mismatching nomenclature and submit a pull request.
metagenome_abundance(:,1)=strrep(metagenome_abundance(:,1),'Candidatus_','');
metagenome_abundance(:,1)=strrep(metagenome_abundance(:,1),'_Family_XI_Incertae_Sedis',' Incertae Sedis XI');
metagenome_abundance(:,1)=strrep(metagenome_abundance(:,1),'_Family_XIII_Incertae_Sedis',' Incertae Sedis XIII');
metagenome_abundance(:,1)=strrep(metagenome_abundance(:,1),'typhimurium','enterica');
metagenome_abundance(:,1)=strrep(metagenome_abundance(:,1),'[','');
metagenome_abundance(:,1)=strrep(metagenome_abundance(:,1),']','');
metagenome_abundance(:,1)=strrep(metagenome_abundance(:,1),'-','_');

% remove all rows that are not of the desired sequencing depth and edit the
% taxon descriptions to enable mapping to AGORA
delRows=[];
cnt=1;
for i=2:size(metagenome_abundance,1)
    findSDepth=strsplit(metagenome_abundance{i,1},'|');
    if length(findSDepth)>1
        if strncmp(findSDepth{1,end},sequencingDepth,3) && length(findSDepth{1,end})>3
            % if the genus information is missing on the species level
            if strcmp(sequencingDepth,'s__')
                sname=strrep(findSDepth{1,end},sequencingDepth,'');
                gname=strrep(findSDepth{1,end-1},'g__','');
                if ~strncmp(gname,sname,length(gname)) && isempty(strfind(sname,'_'))
                    metagenome_abundance{i,1}=strcat(gname,'_',sname);
                else
                    metagenome_abundance{i,1}=findSDepth{1,end};
                end
            end
        else
            delRows(cnt,1)=i;
            cnt=cnt+1;
        end
    end
end
metagenome_abundance(delRows,:)=[];

% Remove unclassified organisms
agoraTaxa(strncmp('unclassified', agoraTaxa, 12)) = [];
metagenome_abundance(~cellfun(@isempty, strfind(metagenome_abundance(:,1),'_uncl')),:) = [];

% replace unknown species with pan-genus model
metagenome_abundance(:,1)=strrep(metagenome_abundance(:,1),'_cf','');

% match and find overlapping IDs
metagenome_abundance(:,1)=strrep(metagenome_abundance(:,1),sequencingDepth,'');
metagenome_abundance(:,1)=strrep(metagenome_abundance(:,1),' ','_');
metagenome_abundance(2:end,1)=strcat('pan',metagenome_abundance(2:end,1));

% remove and report taxa in abundance data table that could not be found in
% AGORA
[unmappedRows,IA] = setdiff(metagenome_abundance(:,1),agoraTaxa);
IA(1,:)=[];
metagenome_abundance(IA,:)=[];
translatedAbundances=metagenome_abundance;

% normalize the abundances so that sum for each individual is 1
normalizedAbundances=translatedAbundances;
for i=2:size(translatedAbundances,2)
    for j=2:size(translatedAbundances,1)
        normalizedAbundances{j,i}=num2str(str2double(translatedAbundances(j,i))/sum(str2double(translatedAbundances(2:end,i))));
    end
end

end 