function summarizeFeaturesOnTaxonLevels(propertiesFolder,infoFilePath,reconVersion,customFeatures)
% This function summarizes calculated features of the reconstruction 
% resource, if taxonomical information is provided, on the species, genus, 
% family, order, class, and phylum level.
%
% USAGE
%   summarizeFeaturesOnTaxonLevels(propertiesFolder,infoFilePath)
%
% INPUTS                                                                                                                                                                                          Folder with COBRA models to be analyzed
% propertiesFolder      Folder where the retrieved reaction presences will
%                       be stored (default: current folder)
% infoFilePath          Path to spreadsheet with taxonomical information of
%                       the refined strains
% reconVersion          Name assigned to the reconstruction resource
%
%   - AUTHOR
%   Almut Heinken, 06/2020

mkdir([propertiesFolder filesep 'ReactionPresence'])
currentDir=pwd;
cd([propertiesFolder filesep 'ReactionPresence'])

dInfo = dir(modelFolder);
modelList={dInfo.name};
modelList=modelList';
modelList(~contains(modelList(:,1),'.mat'),:)=[];
modelList(:,1)=strrep(modelList(:,1),'.mat','');

% Load reaction database
fileDir = fileparts(which('ReactionTranslationTable.txt'));
reactionDatabase = readtable([fileDir filesep 'ReactionDatabase.txt'], 'Delimiter', 'tab','TreatAsEmpty',['UND. -60001','UND. -2011','UND. -62011'], 'ReadVariableNames', false);
reactionDatabase=table2cell(reactionDatabase);
reactionDatabase(:,2:10)=[];

if ~isempty(infoFilePath)
    infoFile = readtable(infoFilePath, 'ReadVariableNames', false);
    infoFile = table2cell(infoFile);
else
    infoFile = readtable('AGORA2_infoFile.xlsx', 'ReadVariableNames', false);
    infoFile = table2cell(infoFile);
end

[C,I]=setdiff(infoFile(:,1),modelList(:,1),'stable');
infoFile(I(2:end),:)=[];

% if taxonomic information is available, calculate on different taxon levels

if size(infoFile,1)>2
    taxLevels={'Species','Genus','Family','Order','Class','Phylum'};
    
    for i=1:length(taxLevels)
        % skip if file already exists
        if ~isfile(['ReactionPresence_' taxLevels{i} '_' reconVersion '.txt.'])
            ReactionPresenceByTaxon=ReactionPresence(1,:);
            taxCol=find(strcmp(infoFile(1,:),taxLevels{i}));
            getTax=unique(infoFile(2:end,taxCol));
            getTax(find(strncmp(getTax,'unclassified',length('unclassified'))),:)=[];
            ReactionPresenceByTaxon(2:size(getTax)+1,1)=getTax;
            for j=1:length(getTax)
                getStrains=infoFile(find(strcmp(infoFile(:,taxCol),getTax{j})),1);
                taxonSummary=[];
                for k=1:length(getStrains)
                    findModel=find(strcmp(ReactionPresence(:,1),getStrains{k}));
                    taxonSummary(k,1:size(ReactionPresence,2)-1)=str2double(ReactionPresence(findModel,2:end));
                end
                for l=2:size(ReactionPresenceByTaxon,2)
                    if sum(taxonSummary(:,l-1))>0
                        ReactionPresenceByTaxon{j+1,l}='1';
                    else
                        ReactionPresenceByTaxon{j+1,l}='0';
                    end
                end
            end
            % create reduced info file on taxon level for plotting the data in R
            infoFileReduced=infoFile;
            infoFileReduced(:,1:taxCol-1)=[];
            [C,IA,IC] = unique(infoFileReduced(:,1),'stable');
            infoFileReduced=infoFileReduced(IA,:);
            infoFileReduced=cell2table(infoFileReduced);
            writetable(infoFileReduced,['Taxonomy_' taxLevels{i} '_' reconVersion],'FileType','text','WriteVariableNames',false,'Delimiter','tab');
            
            ReactionPresenceByTaxon=cell2table(ReactionPresenceByTaxon);
            writetable(ReactionPresenceByTaxon,['ReactionPresence_' taxLevels{i} '_' reconVersion],'FileType','text','WriteVariableNames',false,'Delimiter','tab');
            
            % save the ones that are specific to few taxa
            ReactionPresenceByTaxon=table2cell(ReactionPresenceByTaxon);
            delArray=[];
            cnt=1;
            %     if i==1 || i==2
            %         rarityCutoff=3;
            %     else
            rarityCutoff=1;
            %     end
            for l=2:size(ReactionPresenceByTaxon,2)
                if sum(str2double(ReactionPresenceByTaxon(2:end,l)))>rarityCutoff
                    delArray(cnt,1)=l;
                    cnt=cnt+1;
                end
            end
            ReactionPresenceByTaxon(:,delArray)=[];
            % remove taxa that do not have these reactions
            delArray=[];
            cnt=1;
            for l=2:size(ReactionPresenceByTaxon,1)
                if sum(str2double(ReactionPresenceByTaxon(l,2:end)))==0
                    delArray(cnt,1)=l;
                    cnt=cnt+1;
                end
            end
            ReactionPresenceByTaxon(delArray,:)=[];
            if size(ReactionPresenceByTaxon,2)>2
                % get and plot stats on unique reaction subsystems
                for j=2:size(ReactionPresenceByTaxon,1)
                    rxns=ReactionPresenceByTaxon(1,find(strcmp(ReactionPresenceByTaxon(j,:),'1')));
                    subs={};
                    if ~isempty(rxns)
                        for k=1:length(rxns)
                            subs{k,1}=reactionDatabase{find(strcmp(reactionDatabase(:,1),rxns{k})),2};
                        end
                    end
                    % remove exchange/demand and transport reactions
                    subs(find(strcmp(subs(:,1),'Exchange/demand reaction')),:)=[];
                    subs(find(strcmp(subs(:,1),'Transport, extracellular')),:)=[];
                    subs(find(strcmp(subs(:,1),'Transport, periplasmatic')),:)=[];
                    % only create a plot if a certain number of reactions is unique
                    if length(subs)>3
                        [unSubs, ~, J]=unique(subs);
                        cnt_subs = histc(J, 1:numel(unSubs));
                        % workaround if there are too many entries
                        if length(cnt_subs)>20
                            [B,I]=sort(cnt_subs,'descend');
                            unSubs=unSubs(I);
                            sumall=sum(B(21:end));
                            B(11:end)=[];
                            unSubs(21:end)=[];
                            [B,I]=sort(B,'ascend');
                            unSubs=unSubs(I);
                            unSubs{length(unSubs),1}='Others';
                            B(length(B),1)=sumall;
                        else
                            [B,I]=sort(cnt_subs,'ascend');
                            unSubs=unSubs(I);
                        end
                        f = figure;
                        h=pie(B,cellstr(num2str(B)));
                        set(findobj(h,'type','text'),'fontsize',10);
                        h=title(ReactionPresenceByTaxon{j,1}, 'FontSize', 12, 'FontWeight', 'bold');
                        set(h,'interpreter','none')
                        h=legend(unSubs,'Location','eastoutside','Orientation','vertical');
                        set(h,'interpreter','none')
                        set(findobj(h,'type','text'),'fontsize',10);
                        f.Renderer='painters';
                        print('-bestfit',['Tmp_images_' lower(taxLevels{i}) '_' strrep(ReactionPresenceByTaxon{j,1},'/','_')],'-dpdf','-r300')
                        append_pdfs('Unique_reactions_by_subsystem.pdf',['Tmp_images_' lower(taxLevels{i}) '_' strrep(ReactionPresenceByTaxon{j,1},'/','_') '.pdf']);
                    end
                end
                close all
            end
        end
    end
    
    % if the data should be clustered by any custom features from the info file
    if ~isempty(customFeatures)
        for i=1:length(customFeatures)
            % skip if file already exists
            if ~isfile(['ReactionPresence_' customFeatures{i} '_' reconVersion '.txt'])
                
                ReactionPresenceByFeature=ReactionPresence(1,:);
                taxCol=find(strcmp(infoFile(1,:),customFeatures{i}));
                getTax=unique(infoFile(2:end,taxCol));
                getTax(find(strncmp(getTax,'unclassified',length('unclassified'))),:)=[];
                ReactionPresenceByFeature(2:size(getTax)+1,1)=getTax;
                for j=1:length(getTax)
                    getStrains=infoFile(find(strcmp(infoFile(:,taxCol),getTax{j})),1);
                    featureSummary=[];
                    for k=1:length(getStrains)
                        findModel=find(strcmp(ReactionPresence(:,1),getStrains{k}));
                        featureSummary(k,1:size(ReactionPresence,2)-1)=str2double(ReactionPresence(findModel,2:end));
                    end
                    for l=2:size(ReactionPresenceByFeature,2)
                        if sum(featureSummary(:,l-1))>0
                            ReactionPresenceByFeature{j+1,l}='1';
                        else
                            ReactionPresenceByFeature{j+1,l}='0';
                        end
                    end
                end
                % create reduced info file on taxon level for plotting the data in R
                infoFileReduced=infoFile;
                infoFileReduced(:,1:taxCol-1)=[];
                [C,IA,IC] = unique(infoFileReduced(:,1),'stable');
                infoFileReduced=infoFileReduced(IA,:);
                infoFileReduced=cell2table(infoFileReduced);
                writetable(infoFileReduced,['Taxonomy_' customFeatures{i} '_' reconVersion],'FileType','text','WriteVariableNames',false,'Delimiter','tab');
                
                ReactionPresenceByFeature=cell2table(ReactionPresenceByFeature);
                writetable(ReactionPresenceByFeature,['ReactionPresence_' customFeatures{i} '_' reconVersion],'FileType','text','WriteVariableNames',false,'Delimiter','tab');
                
                % save the ones that are specific to few taxa
                ReactionPresenceByFeature=table2cell(ReactionPresenceByFeature);
                delArray=[];
                cnt=1;
                %     if i==1 || i==2
                %         rarityCutoff=3;
                %     else
                rarityCutoff=1;
                %     end
                for l=2:size(ReactionPresenceByFeature,2)
                    if sum(str2double(ReactionPresenceByFeature(2:end,l)))>rarityCutoff
                        delArray(cnt,1)=l;
                        cnt=cnt+1;
                    end
                end
                ReactionPresenceByFeature(:,delArray)=[];
                % remove taxa that do not have these reactions
                delArray=[];
                cnt=1;
                for l=2:size(ReactionPresenceByFeature,1)
                    if sum(str2double(ReactionPresenceByFeature(l,2:end)))==0
                        delArray(cnt,1)=l;
                        cnt=cnt+1;
                    end
                end
                ReactionPresenceByFeature(delArray,:)=[];
                if size(ReactionPresenceByFeature,2)>2
                    % get and plot stats on unique reaction subsystems
                    for j=2:size(ReactionPresenceByFeature,1)
                        rxns=ReactionPresenceByFeature(1,find(strcmp(ReactionPresenceByFeature(j,:),'1')));
                        subs={};
                        if ~isempty(rxns)
                            for k=1:length(rxns)
                                subs{k,1}=reactionDatabase{find(strcmp(reactionDatabase(:,1),rxns{k})),2};
                            end
                        end
                        % remove exchange/demand and transport reactions
                        subs(find(strcmp(subs(:,1),'Exchange/demand reaction')),:)=[];
                        subs(strcmp(subs(:,1),'Transport, extracellular'),:)=[];
                        subs(find(strcmp(subs(:,1),'Transport, periplasmatic')),:)=[];
                        % only create a plot if a certain number of reactions is unique
                        if length(subs)>3
                            [unSubs, ~, J]=unique(subs);
                            cnt_subs = histc(J, 1:numel(unSubs));
                            % workaround if there are too many entries
                            if length(cnt_subs)>20
                                [B,I]=sort(cnt_subs,'descend');
                                unSubs=unSubs(I);
                                sumall=sum(B(21:end));
                                B(11:end)=[];
                                unSubs(21:end)=[];
                                [B,I]=sort(B,'ascend');
                                unSubs=unSubs(I);
                                unSubs{length(unSubs),1}='Others';
                                B(length(B),1)=sumall;
                            else
                                [B,I]=sort(cnt_subs,'ascend');
                                unSubs=unSubs(I);
                            end
                            f = figure;
                            h=pie(B,cellstr(num2str(B)));
                            set(findobj(h,'type','text'),'fontsize',10);
                            h=title(ReactionPresenceByFeature{j,1}, 'FontSize', 12, 'FontWeight', 'bold');
                            set(h,'interpreter','none')
                            h=legend(unSubs,'Location','eastoutside','Orientation','vertical');
                            set(h,'interpreter','none')
                            set(findobj(h,'type','text'),'fontsize',10);
                            f.Renderer='painters';
                            print('-bestfit',['Unique_reactions_by_subsystem_' lower(customFeatures{i}) '_' strrep(ReactionPresenceByFeature{j,1},'/','_')],'-dpdf','-r300')
                            append_pdfs('Unique_reactions_by_subsystem.pdf',['Unique_reactions_by_subsystem_'  lower(customFeatures{i}) '_' strrep(ReactionPresenceByFeature{j,1},'/','_') '.pdf']);
                        end
                    end
                    close all
                end
            end
        end
    end
end

cd(currentDir)

end