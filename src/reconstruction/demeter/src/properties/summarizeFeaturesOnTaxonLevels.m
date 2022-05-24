function summarizeFeaturesOnTaxonLevels(propertiesFolder,infoFilePath,reconVersion,customFeatures)
% This function summarizes calculated features of the reconstruction
% resource, if taxonomical information is provided, on the species, genus,
% family, order, class, and phylum level. A custom feature 
% (.e.g, gram status, source of the strains) can also be used to summarize
% the data. In this case, the spreadsheet with strain information needs to
% contain a column with this information.
%
% USAGE
%   summarizeFeaturesOnTaxonLevels(propertiesFolder,infoFilePath,reconVersion,customFeatures)
%
% INPUTS                                                                                                                                                                                          Folder with COBRA models to be analyzed
% propertiesFolder      Folder where the retrieved reaction presences will
%                       be stored (default: current folder)
% infoFilePath          Path to spreadsheet with taxonomical information of
%                       the refined strains
% reconVersion          Name assigned to the reconstruction resource
% OPTIONAL INPUT
% customFeatures        Features other than taxonomy to cluster microbes
%                       by. Need to be a table header in the file with
%                       information on reconstructions.
%
%   - AUTHOR
%   Almut Heinken, 06/2020

% define the files to load
files = {
    'ReactionPresence_',['Refined' filesep 'ReactionMetabolitePresence' filesep 'reactionPresence_' reconVersion '_refined.txt']
    'MetabolitePresence_',['Refined' filesep 'ReactionMetabolitePresence' filesep 'metabolitePresence_' reconVersion '_refined.txt']
    'UptakeSecretion_',['Refined' filesep 'ComputedFluxes' filesep 'UptakeSecretion_' reconVersion '_refined_qualitative.txt']
    'InternalProduction_',['Refined' filesep 'ComputedFluxes' filesep 'InternalProduction_' reconVersion '_refined_qualitative.txt']
    };

% get taxonomical information
infoFile = readInputTableForPipeline(infoFilePath);

% if taxonomic information is available, calculate on different taxon levels

for f=1:size(files,1)
    data = readInputTableForPipeline([propertiesFolder filesep files{f,2}]);
    if size(infoFile,1)>2
        taxLevels={'Species','Genus','Family','Order','Class','Phylum'};
        for i=1:length(taxLevels)
            dataByTaxon=data(1,:);
            taxCol=find(strcmp(infoFile(1,:),taxLevels{i}));
            getTax=unique(infoFile(2:end,taxCol));
            getTax(find(strncmp(getTax,'unclassified',length('unclassified'))),:)=[];
            dataByTaxon(2:size(getTax)+1,1)=getTax;
            for j=1:length(getTax)
                getStrains=infoFile(find(strcmp(infoFile(:,taxCol),getTax{j})),1);
                taxonSummary=[];
                for k=1:length(getStrains)
                    findModel=find(strcmp(data(:,1),getStrains{k}));
                    taxonSummary(k,1:size(data,2)-1)=str2double(data(findModel,2:end));
                end
                for l=2:size(dataByTaxon,2)
                    if sum(taxonSummary(:,l-1))>0
                        dataByTaxon{j+1,l}='1';
                    else
                        dataByTaxon{j+1,l}='0';
                    end
                end
            end
            writetable(cell2table(dataByTaxon),[files{i,1} taxLevels{i} '_' reconVersion],'FileType','text','WriteVariableNames',false,'Delimiter','tab');
        end
    end

    % if the data should be clustered by any custom features from the info file
    if nargin > 3
        for i=1:length(customFeatures)
            % skip if file already exists
            if ~isfile(['data_' customFeatures{i} '_' reconVersion '.txt'])

                dataByFeature=data(1,:);
                taxCol=find(strcmp(infoFile(1,:),customFeatures{i}));
                getTax=unique(infoFile(2:end,taxCol));
                getTax(find(strncmp(getTax,'unclassified',length('unclassified'))),:)=[];
                dataByFeature(2:size(getTax)+1,1)=getTax;
                for j=1:length(getTax)
                    getStrains=infoFile(find(strcmp(infoFile(:,taxCol),getTax{j})),1);
                    featureSummary=[];
                    for k=1:length(getStrains)
                        findModel=find(strcmp(data(:,1),getStrains{k}));
                        if contains(version,'(R202') % for Matlab R2020a and newer
                            featureSummary(k,1:size(data,2)-1)=cell2mat(data(findModel,2:end));
                        else
                            featureSummary(k,1:size(data,2)-1)=str2double(data(findModel,2:end));
                        end
                    end
                    for l=2:size(dataByFeature,2)
                        if sum(featureSummary(:,l-1))>0
                            dataByFeature{j+1,l}='1';
                        else
                            dataByFeature{j+1,l}='0';
                        end
                    end
                end
                writetable(cell2table(dataByFeature),[files{i,1} customFeatures{i} '_' reconVersion],'FileType','text','WriteVariableNames',false,'Delimiter','tab');
            end
        end
    end
end

end