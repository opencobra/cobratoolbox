function producetSNEPlots(propertiesFolder,infoFilePath,reconVersion,customFeatures)
% This function plots reaction presence and uptake and secretion potential
% by taxon with t-SNE.
%
% USAGE
%   producetSNEPlots(propertiesFolder,infoFilePath,reconVersion)
%
% INPUTS
% propertiesFolder      Folder where the reaction presences and uptake and
%                       secretion potential to be analyzed are stored
%                       (default: current folder)
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

% euclidean should work for most
distance='euclidean';
alg='barneshut';

currentDir=pwd;
cd(propertiesFolder)
mkdir('tSNE_Plots')
cd('tSNE_Plots')

tol=0.0000001;

% get taxonomical information
infoFile = readtable(infoFilePath, 'ReadVariableNames', false);
infoFile = table2cell(infoFile);

% define files to analyze
analyzedFiles={
    'Reaction presence' ['ReactionMetabolitePresence' filesep 'ReactionPresence_' reconVersion]
    'Metabolite presence' ['ReactionMetabolitePresence' filesep 'MetabolitePresence_' reconVersion]
    'Uptake and secretion potential' ['ComputedFluxes' filesep 'UptakeSecretion_' reconVersion]
    'Internal metabolite production' ['ComputedFluxes' filesep 'InternalProduction_' reconVersion]
    };

for k=1:size(analyzedFiles,1)
    DataToAnalyze = readtable([propertiesFolder filesep analyzedFiles{k,2} '.txt'], 'ReadVariableNames', false);
    DataToAnalyze = table2cell(DataToAnalyze);
    DataToAnalyze=DataToAnalyze';
    
    [C,I]=setdiff(DataToAnalyze(1,:),infoFile(:,1),'stable');
    DataToAnalyze(:,I(2:end))=[];
    
    % can only be performed if there are enough strains with taxonomical information
    if size(DataToAnalyze,2) >= 10
        
        rp=str2double(DataToAnalyze(2:end,2:end));
        orgs=DataToAnalyze(1,2:end)';
        
        taxonlevels={
            'Phylum'
            'Class'
            'Order'
            'Family'
            'Genus'
            'Species'
            };
        
        Summary=struct;
        for i=1:length(taxonlevels)
            % plot on different taxon levels
            taxa={};
            taxcol=find(strcmp(infoFile(1,:),taxonlevels{i}));
            for j=2:size(DataToAnalyze,2)
                if ~any(strcmp(infoFile(:,1),DataToAnalyze{1,j}))
                    taxa{j-1,1}='N/A';
                else
                    taxa{j-1,1}=infoFile{find(strcmp(infoFile(:,1),DataToAnalyze{1,j})),taxcol};
                end
            end
            
            data=rp';
            red_orgs=orgs;
            
            % remove entries that are all zeros
            toDel=sum(data,1)<tol;
            data(:,toDel)=[];
            
            % remove entries that are NaNs
            findnans=any(isnan(data));
            data(:,findnans==1)=[];
            
            % remove unclassified organisms
            data(find(strcmp(taxa,'N/A')),:)=[];
            red_orgs(strcmp(taxa,'N/A'),:)=[];
            taxa(find(strcmp(taxa,'N/A')),:)=[];
            
            
            % remove unclassified organisms
            data(find(strncmp(taxa,'unclassified',length('unclassified'))),:)=[];
            red_orgs(find(strncmp(taxa,'unclassified',length('unclassified'))),:)=[];
            taxa(find(strncmp(taxa,'unclassified',length('unclassified'))),:)=[];
            
            
            if i==6
                % remove unclassified species
                toDel=[];
                cnt=1;
                for j=1:size(data,1)
                    if strcmp(taxa{j,1}(length(taxa{j,1})-2:length(taxa{j,1})),' sp')
                        toDel(cnt)=j;
                        cnt=cnt+1;
                    end
                end
                data(toDel,:)=[];
                red_orgs(toDel,:)=[];
                taxa(toDel,:)=[];
            end
            
            % remove taxa with too few members
            [uniqueXX, ~, J]=unique(taxa) ;
            occ = histc(J, 1:numel(uniqueXX));
            
            if length(uniqueXX) >15
                % sort by number of entries and remove the ones with the least
                % entries
                [B,I]=sort(occ,'descend');
                uniqueXX=uniqueXX(I);
                
                if sum(B==1) > length(B)-15
                    % remove all that are just one entry
                    uniqueXX(B==1)=[];
                else
                    % remove all but 15 highest
                    uniqueXX=uniqueXX(1:15);
                end
                
                [C,IA]=setdiff(taxa,uniqueXX);
                data(find(ismember(taxa,C)),:)=[];
                red_orgs(ismember(taxa,C),:)=[];
                taxa(find(ismember(taxa,C)),:)=[];
            end
            
            if size(data,1)>10
                
                % adjust perplicity to number of variables
                if size(data,1) > 150
                    perpl=50;
                elseif size(data,1) >= 50
                    perpl=30;
                elseif size(data,1) >= 20
                    perpl=10;
                else
                    perpl=5;
                end
                
                Y = tsne(data,'Distance',distance,'Algorithm',alg,'Perplexity',perpl);
                Summary.(taxonlevels{i})(:,1)=red_orgs;
                Summary.(taxonlevels{i})(:,2)=taxa;
                Summary.(taxonlevels{i})(:,3:size(Y,2)+2)=cellstr(string(Y));
                
                if size(data,1) == size(Y,1) && size(Y,2) > 1
                    f=figure;
                    cols=hsv(length(unique(taxa)));
                    % define markers to better distinguish groups
                    cmarkers='';
                    for j=1:7:length(unique(taxa))
                        cmarkers=[cmarkers '+o*xsdp'];
                    end
                    cmarkers=cmarkers(1:length(unique(taxa)));
                    h=gscatter(Y(:,1),Y(:,2),taxa,cols,cmarkers);
                    hold on
                    set(h,'MarkerSize',6)
                    title(analyzedFiles{k,1})
                    plottitle=strrep(reconVersion,'_refined','');
                    plottitle=strrep(plottitle,'_draft','');
                    suptitle(plottitle)
                    
                    h=legend('Location','northeastoutside');
                    if length(uniqueXX) < 12
                        set(h,'FontSize',11)
                    elseif length(uniqueXX) < 20
                        set(h,'FontSize',9)
                    else
                        set(h,'FontSize',6)
                    end
                    
                    f.Renderer='painters';
                    print([taxonlevels{i} '_' strrep(analyzedFiles{k,1},' ','_') '_' reconVersion],'-dpng','-r300')
                else
                    warning('Not enough strains with available organism information. Cannot cluster based on taxonomy.')
                end
            end
        end
        save(['Summary_' reconVersion],'Summary');
        
        % if the data should be clustered by any custom features from the info file
        if nargin > 3
            for i=1:length(customFeatures)
                % plot on different taxon levels
                feats={};
                cuscol=find(strcmp(infoFile(1,:),customFeatures{i}));
                if ~isempty(cuscol)
                    for j=2:size(DataToAnalyze,2)
                        if ~any(strcmp(infoFile(:,1),DataToAnalyze{1,j}))
                            feats{j-1,1}='N/A';
                        else
                            feats{j-1,1}=infoFile{find(strcmp(infoFile(:,1),DataToAnalyze{1,j})),cuscol};
                        end
                    end
                    
                    data=rp';
                    red_orgs=orgs;
                    
                    % remove organisms with no data
                    data(find(strcmp(taxa,'N/A')),:)=[];
                    red_orgs(strcmp(taxa,'N/A'),:)=[];
                    taxa(find(strcmp(taxa,'N/A')),:)=[];
                    
                    if size(data,1) >= 10
                        
                        %     % remove features with too few members
                        %     [uniqueXX, ~, J]=unique(feats) ;
                        %     occ = histc(J, 1:numel(uniqueXX));
                        %         toofew=uniqueXX(occ<sum(occ)/2000);
                        %     data(find(ismember(feats,toofew)),:)=[];
                        %     red_orgs(ismember(feats,toofew),:)=[];
                        %     feats(find(ismember(feats,toofew)),:)=[];
                        
                        Y = tsne(data,'Distance',distance,'Algorithm',alg,'Perplexity',perpl);
                        Summary.(strrep(customFeatures{i},' ','_'))(:,1)=red_orgs;
                        Summary.(strrep(customFeatures{i},' ','_'))(:,2)=feats;
                        Summary.(strrep(customFeatures{i},' ','_'))(:,3:4)=cellstr(string(Y));
                        
                        f=figure;
                        h=gscatter(Y(:,1),Y(:,2),feats);
                        set(h,'MarkerSize',10)
                        title(analyzedFiles{k,1})
                        h=legend('Location','northeastoutside');
                        set(h,'FontSize',9)
                        f.Renderer='painters';
                        print([customFeatures{i} '_' strrep(analyzedFiles{k,1},' ','_') '_' reconVersion],'-dpng','-r300')
                    else
                        warning('Not enough strains with available organism information. Cannot cluster based on features.')
                    end
                end
            end
            save(['Summary_' reconVersion],'Summary');
        end
    end
end
cd(currentDir)

end