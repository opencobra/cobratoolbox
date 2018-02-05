function [ReactionAbundance]=calculateReactionAbundance(abundance,modelFolder,rxnsList,numWorkers,taxonomy)
% This function calculates the total abundance of reactions of interest in
% a given microbiome sample based on the strain-level composition. Reaction
% presence or absence in each strain is derived from the reaction content 
% of the respective AGORA model. Two outputs are given: the total abundance,
% and optionally the abundance on different taxonomical levels.
% Please cite Magnusdottir et al., Nature Biotechnology. 2017
% Jan;35(1):81-89., and Heinken et al., Personalized modeling of the human 
% gut microbiome reveals distinct bile acid deconjugation and 
% biotransformation potential in healthy and IBD individuals (preprint on 
% bioRxiv, 2017) if you use this function. 
% Almut Heinken, 01/2018
% INPUT
% abundance                  Table of relative abundances with AGORA model 
% IDs of the strains as rows and sample IDs as columns
% modelFolder                Folder containing the strain-specific AGORA models
% rxnsList                   List of reactions for which the abundance
% should be calculated (if left empty: all reactions in all models)
% numWorkers                 Number of workers used for parallel pool. If
% left empty, the parallel pool will not be started. Parallellization is 
% recommended if all reactions are computed.
% taxonomy                   Table with information on the taxonomy of each
% AGORA model strain. If left empty, only the total reaction abundance will
% be computed. Needs to be in the format provided in "ModelInformation"
% spreadsheet.

% OUTPUT
% ReactionAbundance          Structure with abundance for each microbiome
% and reaction in total and if desired on taxon levels

% define reaction list if not entered
if isempty(rxnsList)
    fprintf('No reaction list entered. Abundances will be calculated for all reactions in all models. \n')
    % get model list from abundance input file
    for i=2:size(abundance,1)
        load(strcat(modelFolder,abundance{i,1}));
        rxnsList=vertcat(model.rxns,rxnsList);
    end
    rxnsList=unique(rxnsList);
end

% load the models found in the individuals and extract which reactions are
% in which model
for i=2:size(abundance,1)
    load(strcat(modelFolder,abundance{i,1},'.mat'));
    ReactionPresence{i,1}=abundance{i,1};
    for j=1:length(rxnsList)
        ReactionPresence{1,j+1}=rxnsList{j};
        if ~isempty(find(ismember(model.rxns,rxnsList{j})))
            ReactionPresence{i,j+1}=1;
        else
            ReactionPresence{i,j+1}=0;
        end
    end
end% put together a Matlab structure of the results
ReactionAbundance=struct;

% prepare table for the total abundance
for j=1:length(rxnsList)
    ReactionAbundance.('Total'){1,j+1}=rxnsList{j};
end

% extract the list of entries on each taxonomical level
if ~isempty(taxonomy)
    TaxonomyLevels={
        'Phylum'
        'Class'
        'Order'
        'Family'
        'Genus'
        };
    % find and save all entries
    phyla=unique(taxonomy(2:end,5));
    classes=unique(taxonomy(2:end,6));
    order=unique(taxonomy(2:end,7));
    order(strncmp('unclassified',order,12))=[];
    families=unique(taxonomy(2:end,8));
    families(strncmp('unclassified',families,12))=[];
    genera=unique(taxonomy(2:end,9));
    genera(strncmp('unclassified',genera,12))=[];
    TaxonomyLevels{1,2}=phyla;
    TaxonomyLevels{2,2}=classes;
    TaxonomyLevels{3,2}=order;
    TaxonomyLevels{4,2}=families;
    TaxonomyLevels{5,2}=genera;
    % define the correct columns in taxonomy table
    TaxonomyLevels{1,3}=5;
    TaxonomyLevels{2,3}=6;
    TaxonomyLevels{3,3}=7;
    TaxonomyLevels{4,3}=8;
    TaxonomyLevels{5,3}=9;
    % prepare table for the abundance on taxon levels
    for t=1:size(TaxonomyLevels,1)
        cnt=2;
        for j=1:length(rxnsList)
            for l=1:length(TaxonomyLevels{t,2})
                ReactionAbundance.(TaxonomyLevels{t,1}){1,cnt}=strcat(TaxonomyLevels{t,2}{l},'_',rxnsList{j});
                cnt=cnt+1;
            end
        end
    end
end

if ~isempty(numWorkers)
    parpool(numWorkers)
end

for i=2:size(abundance,2)
    %% calculate reaction abundance for the samples one by one
    fprintf(['Calculating reaction abundance for sample ',num2str(i-1),' of ' num2str(size(abundance,2)-1) '.. \n'])
    ReactionAbundance.('Total'){i,1}=abundance{1,i};
    if ~isempty(taxonomy)
        for t=1:size(TaxonomyLevels,1)
            ReactionAbundance.(TaxonomyLevels{t,1}){i,1}=abundance{1,i};
        end
    end
    % use parallel pool if workers specified as input
    if ~isempty(numWorkers)
        % create tables in which abundances for each individual for
        % all reactions/taxa are stored
        totalAbun=zeros(length(rxnsList),1);
        if ~isempty(taxonomy)
            phylumAbun=zeros(length(rxnsList),length(TaxonomyLevels{1,2}));
            classAbun=zeros(length(rxnsList),length(TaxonomyLevels{2,2}));
            orderAbun=zeros(length(rxnsList),length(TaxonomyLevels{3,2}));
            familyAbun=zeros(length(rxnsList),length(TaxonomyLevels{4,2}));
            genusAbun=zeros(length(rxnsList),length(TaxonomyLevels{5,2}));
        end
        parfor j=1:length(rxnsList)
            % store the abundance for each reaction and taxon separately in a
            % temporary file to enable parallellization
            if ~isempty(taxonomy)
                tmpPhyl=zeros(length(rxnsList),length(TaxonomyLevels{1,2}));
                tmpClass=zeros(length(rxnsList),length(TaxonomyLevels{2,2}));
                tmpOrder=zeros(length(rxnsList),length(TaxonomyLevels{3,2}));
                tmpFamily=zeros(length(rxnsList),length(TaxonomyLevels{4,2}));
                tmpGenus=zeros(length(rxnsList),length(TaxonomyLevels{5,2}));
            end
            for k=2:size(abundance,1)
                % check if the reaction is present in the strain
                if  ReactionPresence{k,j+1}==1
                    % calculate total abundance
                    totalAbun(j)=totalAbun(j)+abundance{k,i};
                    if ~isempty(taxonomy)
                        % calculate phylum abundance
                        t=1;
                        findTax=taxonomy(find(strcmp(abundance{k,1},taxonomy(:,3))),TaxonomyLevels{t,3});
                        if any(strcmp(findTax,TaxonomyLevels{t,2}))
                            taxonCol=find(strcmp(findTax,TaxonomyLevels{t,2}));
                            tmpPhyl(1,taxonCol)=tmpPhyl(1,taxonCol)+abundance{k,i};
                        end
                        % calculate class abundance
                        t=2;
                        findTax=taxonomy(find(strcmp(abundance{k,1},taxonomy(:,3))),TaxonomyLevels{t,3});
                        if any(strcmp(findTax,TaxonomyLevels{t,2}))
                            taxonCol=find(strcmp(findTax,TaxonomyLevels{t,2}));
                            tmpClass(1,taxonCol)=tmpClass(1,taxonCol)+abundance{k,i};
                        end
                        % calculate order abundance
                        t=3;
                        findTax=taxonomy(find(strcmp(abundance{k,1},taxonomy(:,3))),TaxonomyLevels{t,3});
                        if any(strcmp(findTax,TaxonomyLevels{t,2}))
                            taxonCol=find(strcmp(findTax,TaxonomyLevels{t,2}));
                            tmpOrder(1,taxonCol)=tmpOrder(1,taxonCol)+abundance{k,i};
                        end
                        % calculate family abundance
                        t=4;
                        findTax=taxonomy(find(strcmp(abundance{k,1},taxonomy(:,3))),TaxonomyLevels{t,3});
                        if any(strcmp(findTax,TaxonomyLevels{t,2}))
                            taxonCol=find(strcmp(findTax,TaxonomyLevels{t,2}));
                            tmpFamily(1,taxonCol)=tmpFamily(1,taxonCol)+abundance{k,i};
                        end
                        % calculate class abundance
                        t=5;
                        findTax=taxonomy(find(strcmp(abundance{k,1},taxonomy(:,3))),TaxonomyLevels{t,3});
                        if any(strcmp(findTax,TaxonomyLevels{t,2}))
                            taxonCol=find(strcmp(findTax,TaxonomyLevels{t,2}));
                            tmpGenus(1,taxonCol)=tmpGenus(1,taxonCol)+abundance{k,i};
                        end
                    end
                end
            end
            if ~isempty(taxonomy)
                phylumAbun(j,:)=tmpPhyl(1,:);
                classAbun(j,:)=tmpClass(1,:);
                orderAbun(j,:)=tmpOrder(1,:);
                familyAbun(j,:)=tmpFamily(1,:);
                genusAbun(j,:)=tmpGenus(1,:);
            end
        end
    else
        % create tables in which abundances for each individual for
        % all reactions/taxa are stored
        % no parallellization-takes longer
        totalAbun=zeros(length(rxnsList),1);
        if ~isempty(taxonomy)
            phylumAbun=zeros(length(rxnsList),length(TaxonomyLevels{1,2}));
            classAbun=zeros(length(rxnsList),length(TaxonomyLevels{2,2}));
            orderAbun=zeros(length(rxnsList),length(TaxonomyLevels{3,2}));
            familyAbun=zeros(length(rxnsList),length(TaxonomyLevels{4,2}));
            genusAbun=zeros(length(rxnsList),length(TaxonomyLevels{5,2}));
        end
        for j=1:length(rxnsList)
            for k=2:size(abundance,1)
                % check if the reaction is present in the strain
                if  ReactionPresence{k,j+1}==1
                    % calculate total abundance
                    totalAbun(j)=totalAbun(j)+abundance{k,i};
                    if ~isempty(taxonomy)
                        % calculate phylum abundance
                        t=1;
                        findTax=taxonomy(find(strcmp(abundance{k,1},taxonomy(:,3))),TaxonomyLevels{t,3});
                        if any(strcmp(findTax,TaxonomyLevels{t,2}))
                            taxonCol=find(strcmp(findTax,TaxonomyLevels{t,2}));
                            phylumAbun(j,taxonCol)=phylumAbun(j,taxonCol)+abundance{k,i};
                        end
                        % calculate class abundance
                        t=2;
                        findTax=taxonomy(find(strcmp(abundance{k,1},taxonomy(:,3))),TaxonomyLevels{t,3});
                        if any(strcmp(findTax,TaxonomyLevels{t,2}))
                            taxonCol=find(strcmp(findTax,TaxonomyLevels{t,2}));
                            classAbun(j,taxonCol)=classAbun(j,taxonCol)+abundance{k,i};
                        end
                        % calculate order abundance
                        t=3;
                        findTax=taxonomy(find(strcmp(abundance{k,1},taxonomy(:,3))),TaxonomyLevels{t,3});
                        if any(strcmp(findTax,TaxonomyLevels{t,2}))
                            taxonCol=find(strcmp(findTax,TaxonomyLevels{t,2}));
                            orderAbun(j,taxonCol)=orderAbun(j,taxonCol)+abundance{k,i};
                        end
                        % calculate family abundance
                        t=4;
                        findTax=taxonomy(find(strcmp(abundance{k,1},taxonomy(:,3))),TaxonomyLevels{t,3});
                        if any(strcmp(findTax,TaxonomyLevels{t,2}))
                            taxonCol=find(strcmp(findTax,TaxonomyLevels{t,2}));
                            familyAbun(j,taxonCol)=familyAbun(j,taxonCol)+abundance{k,i};
                        end
                        % calculate class abundance
                        t=5;
                        findTax=taxonomy(find(strcmp(abundance{k,1},taxonomy(:,3))),TaxonomyLevels{t,3});
                        if any(strcmp(findTax,TaxonomyLevels{t,2}))
                            taxonCol=find(strcmp(findTax,TaxonomyLevels{t,2}));
                            genusAbun(j,taxonCol)=genusAbun(j,taxonCol)+abundance{k,i};
                        end
                    end
                end
            end
        end
    end
    %% store the abundances total and on taxonomic levels calculated for the individual in the output structure
    for j=1:length(rxnsList)
        ReactionAbundance.('Total'){i,j+1}=totalAbun(j);
        % abundance on taxon levels
    end
    if ~isempty(taxonomy)
        % phylum abundance
        t=1;
        cnt=2;
        for j=1:length(rxnsList)
            for l=1:length(TaxonomyLevels{t,2})
                ReactionAbundance.(TaxonomyLevels{t}){i,cnt}=phylumAbun(j,l);
                cnt=cnt+1;
            end
        end
        % class abundance
        t=2;
        cnt=2;
        for j=1:length(rxnsList)
            for l=1:length(TaxonomyLevels{t,2})
                ReactionAbundance.(TaxonomyLevels{t}){i,cnt}=classAbun(j,l);
                cnt=cnt+1;
            end
        end
        % order abundance
        t=3;
        cnt=2;
        for j=1:length(rxnsList)
            for l=1:length(TaxonomyLevels{t,2})
                ReactionAbundance.(TaxonomyLevels{t}){i,cnt}=orderAbun(j,l);
                cnt=cnt+1;
            end
        end
        % family abundance
        t=4;
        cnt=2;
        for j=1:length(rxnsList)
            for l=1:length(TaxonomyLevels{t,2})
                ReactionAbundance.(TaxonomyLevels{t}){i,cnt}=familyAbun(j,l);
                cnt=cnt+1;
            end
        end
        % genus abundance
        t=5;
        cnt=2;
        for j=1:length(rxnsList)
            for l=1:length(TaxonomyLevels{t,2})
                ReactionAbundance.(TaxonomyLevels{t}){i,cnt}=genusAbun(j,l);
                cnt=cnt+1;
            end
        end
    end
end

% finally, delete empty columns to avoid unneccessarily big file sizes
fprintf('Finalizing the output file... \n')

fNames=fieldnames(ReactionAbundance);
for i=1:length(fNames)
    cnt=1;
    delArray=[];
    for j=2:size(ReactionAbundance.(fNames{i}),2)
        cValues=string(ReactionAbundance.(fNames{i})(2:end,j));
        cTotal=sum(str2double(cValues));
        if cTotal < 0.000000001
            delArray(1,cnt)=j;
            cnt=cnt+1;
        end
    end
    if ~isempty(delArray)
    ReactionAbundance.(fNames{i})(:,delArray)=[];
    end
end

end
