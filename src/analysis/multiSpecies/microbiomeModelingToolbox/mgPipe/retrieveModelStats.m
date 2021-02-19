function [modelStats,summary,statistics]=retrieveModelStats(modelPath, modelList, infoFilePath)
% This function retrieves statistics on the number of reactions and
% metabolites across microbiome models. If a file with stratification
% information on individuals is provided, it will also determine if
% reaction and metabolites numbers are significantly different between
% groups.
%
% USAGE:
%
%   [modelStats,summary,statistics]=retrieveModelStats(modelPath, modelList, infoFilePath)
%
% INPUTS
% modelPath:        Path to models for which statistics should be retrieved
% modelList:        Cell array with names of models for which statistics
%                   should be retrieved
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

% get the number of reactions and metabolites per model
for i=1:length(modelList)
    load([modelPath filesep modelList{i} '.mat']);
    data(i,1)=length(microbiota_model.rxns);
    data(i,2)=length(microbiota_model.mets);
end

statistics={};

% save the summary as a summary
summary={'','Reactions','Metabolites'
    'Mean','',''
    'Median','',''
    'Min','',''
    'Max','',''
    };

for i=1:2
    summary{2,i+1}=num2str(mean(data(:,i)));
    summary{3,i+1}=num2str(median(data(:,i)));
    summary{4,i+1}=num2str(min(data(:,i)));
    summary{5,i+1}=num2str(max(data(:,i)));
end

% print a table with model IDs and stats
modelStats={'ModelIDs','Reactions','Metabolites'};
modelStats(2:length(modelList)+1,1)=modelList;
modelStats(:,1)=strrep(modelStats(:,1),'microbiota_model_samp_','');
modelStats(:,1)=strrep(modelStats(:,1),'microbiota_model_diet_','');
modelStats(2:end,2:3)=num2cell(data);

% create violin plot of model stats
if nargin <3
    % have reactions and emtabolites in one plot
    figure
    violinplot(data,{'Reactions','Metabolites'});
    set(gca, 'FontSize', 12)
    box on
    title('Reaction and metabolite numbers in microbiome models')
    print('MicrobiomeModel_Sizes','-dpng','-r300')
    
else
    % perform statistical analysis if file with stratification is provided
    infoFile = table2cell(readtable(infoFilePath));
    
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
    
    for i=1:2
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
    subplot(1,2,1)
    violinplot(data(:,1),infoFile(:,2));
    title('Reactions')
    set(gca, 'FontSize', 12)
    box on
    subplot(1,2,2)
    violinplot(data(:,2),infoFile(:,2));
    title('Metabolites')
    set(gca, 'FontSize', 12)
    box on
    hold on
    suptitle('Reaction and metabolite numbers in microbiome models')
    print('MicrobiomeModel_Sizes','-dpng','-r300')
end

end
