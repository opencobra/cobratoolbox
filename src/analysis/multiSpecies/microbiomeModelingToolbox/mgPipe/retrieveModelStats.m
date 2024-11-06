function [modelStats,summary,statistics]=retrieveModelStats(modelPath, modelList, abunFilePath, numWorkers, infoFilePath)
% This function retrieves statistics on the number of reactions and
% metabolites across microbiome models. If a file with stratification
% information on individuals is provided, it will also determine if
% reaction and metabolites numbers are significantly different between
% groups.
%
% USAGE:
%
%   [modelStats,summary,statistics]=retrieveModelStats(modelPath, modelList, numWorkers, infoFilePath)
%
% INPUTS
% modelPath:        Path to models for which statistics should be retrieved
% modelList:        Cell array with names of models for which statistics
%                   should be retrieved
% abunFilePath:     char with path and name of file from which to retrieve 
%                   abundance information
% numWorkers:       integer indicating the number of cores to use for parallelization
%
% OPTIONAL INPUT:
% infoFilePath:     char with path to stratification criteria if available
%
% OUTPUT
% modelStats:       Reaction and metabolite numbers for each model
% summary:          Table with average, median, minimal, and maximal
%                   reactions and metabolites
%
% OPTIONAL OUTPUT:
% statistics:       If info file with stratification is provided, will
%                   determine if there is a significant difference.
%
% .. Author:
%       - Almut Heinken, 02/2021


% set parallel pool
if numWorkers > 1
    poolobj = gcp('nocreate');
    if isempty(poolobj)
        parpool(numWorkers)
    end
end

% get the number of reactions and metabolites per model
dataTmp={};
parfor i=1:length(modelList)
    modelLoaded=load([modelPath filesep modelList{i} '.mat']);
    fnames=fieldnames(modelLoaded);
    model=modelLoaded.(fnames{1});
    dataTmp{i}(1)=length(model.rxns);
    dataTmp{i}(2)=length(model.mets);
end

for i=1:length(modelList)
    data(i,1)=dataTmp{i}(1);
    data(i,2)=dataTmp{i}(2);
end

% add the number of microbes per sample
tol=0.0000001;

abundance = readInputTableForPipeline(abunFilePath);
abundance(1,:) = strrep(abundance(1,:),'-','_');
abundance(1,:) = strrep(abundance(1,:),'.','_');
for i=1:length(modelList)
    samp=strrep(modelList{i},'.mat','');
    samp=strrep(samp,'microbiota_model_samp_','');
    ind=find(strcmp(abundance(1,:),samp));
    if contains(version,'(R202') % for Matlab R2020a and newer
        abun=cell2mat(abundance(2:end,ind));
    else
        abun=str2double(abundance(2:end,ind));
    end
    data(i,3)=length(find(abun(:,1) > tol));
end

statistics={};

% save the summary as a summary
summary={'','Reactions','Metabolites','Microbes'
    'Mean','','',''
    'Median','','',''
    'Min','','',''
    'Max','','',''
    };

for i=1:3
    summary{2,i+1}=num2str(mean(data(:,i)));
    summary{3,i+1}=num2str(median(data(:,i)));
    summary{4,i+1}=num2str(min(data(:,i)));
    summary{5,i+1}=num2str(max(data(:,i)));
end

% print a table with model IDs and stats
modelStats={'ModelIDs','Reactions','Metabolites','Microbes'};
modelStats(2:length(modelList)+1,1)=modelList;
modelStats(:,1)=strrep(modelStats(:,1),'microbiota_model_samp_','');
modelStats(:,1)=strrep(modelStats(:,1),'microbiota_model_diet_','');
modelStats(2:end,2:4)=num2cell(data);

% create violin plot of model stats
if nargin <5
    % have reactions and metabolites in one plot
    % does not work if all data points are the same
    if ~numel(unique(data(:,1)))==1 && ~numel(unique(data(:,2)))==1 && ~numel(unique(data(:,3)))==1
        figure
        subplot(1,2,1)
        violinplot(data(:,1:2),{'Reactions','Metabolites'});
        set(gca, 'FontSize', 12)
        subplot(1,2,2)
        violinplot(data(:,3),{'Microbes'});
        set(gca, 'FontSize', 12)
        sgtitle('Reaction, metabolite and microbe numbers in microbiome models')
        print('MicrobiomeModel_Sizes','-dpng','-r300')
    end
    
else
    % perform statistical analysis if file with stratification is provided
    infoFile = readInputTableForPipeline(infoFilePath);
    
    % remove individuals not in simulations
    modelList=strrep(modelList,'microbiota_model_samp_','');
    modelList=strrep(modelList,'microbiota_model_diet_','');
    [C,IA] = setdiff(infoFile(:,1),modelList);
    infoFile(IA,:)=[];
    
    % get the number of conditions
    groups=unique(infoFile(:,2));
    
    % Fill out table header
    if length(groups)==2
        statistics={'Feature','p_value','Decision','Rank sum statistic','Z-statistics'};
    elseif length(groups)>2
        statistics={'Feature','p_value','Decision','Degrees of freedom','Chi-sq'};
    end
    statistics{2,1}='Reactions';
    statistics{3,1}='Metabolites';
    statistics{4,1}='Microbes';
    
    for i=1:3
        % separate data by group
        dataAll=data(:,i);
        for j=1:length(groups)
            group=groups{j};
            dataGrouped{j}=dataAll;
            delInd=find(~strcmp(group,groups{j}));
            dataGrouped{j}(delInd,:)=[];
        end
        
        if length(groups)==2
            % use Wilcoxon rank sum test
            [p,h,stats] = ranksum(dataGrouped{1},dataGrouped{2},'method','approximate');
            if isnan(p)
                p=1;
            end
            statistics{i+1,2}=p;
            statistics{i+1,3}=h;
            statistics{i+1,4}=stats.ranksum;
            statistics{i+1,5}=stats.zval;
            
        elseif length(groups)>2
            % use Kruskal Wallis test
            [p,ANOVATAB] = kruskalwallis(dataAll,group);
            close all
            statistics{i+1,2}=p;
            if ANOVATAB{2,6} ==0
                statistics{i+1,3}='0';
            else
                statistics{i+1,3}='1';
            end
            statistics{i+1,4}=ANOVATAB{2,3};
            statistics{i+1,5}=ANOVATAB{2,5};
        end
    end
    
    % plot reactions and metabolites separately with group classification
    figure
    subplot(1,3,1)
    violinplot(data(:,1),infoFile(:,2));
    title('Reactions')
    set(gca, 'FontSize', 12)
    subplot(1,3,2)
    violinplot(data(:,2),infoFile(:,2));
    title('Metabolites')
    set(gca, 'FontSize', 12)
    % does not work if all data points are the same
    if ~numel(unique(data(:,3)))==1
        subplot(1,3,3)
        violinplot(data(:,3),infoFile(:,2));
        title('Microbes')
    end
    set(gca, 'FontSize', 12)
    hold on
    sgtitle('Reaction, metabolite and microbe numbers in microbiome models')
    print('MicrobiomeModel_Sizes','-dpng','-r300')
end

end
