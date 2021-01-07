function [Statistics,significantFeatures] = performStatisticalAnalysis(sampleData,sampleInformation,stratification)
% This function determines if there is a significant difference between
% features computed for two or more groups in a cohort of samples. If the
% cohort contains two groups, the Wilcoxon rank sum test is used. If the
% cohort contains three or more groups, the Kruskal Wallis test is used.
%
% USAGE
% [Statistics,significantFeatures] = performStatisticalAnalysis(sampleData,sampleInformation,stratification)
%
% INPUTS
% sampleData           Table with input data to analyze (e.g., fluxes) with
%                      computed features as rows and sample IDs as columns
% sampleInformation    Table with information on analyzed samples including
%                      group classification with sample IDs as rows
% stratification       Column header(s) containing the desired group
%                      classification(s) in sampleInformation table
%
% OUTPUTS
% Statistics           Table with results of statistical tests for each
%                      computed feature
% significantFeatures  Table with input data reduced to only features that
%                      were statistically significant

% AUTHOR
%       - Almut Heinken, 12/2020

    stratCol=find(strcmp(sampleInformation(1,:),stratification));
    
    groups=unique(sampleInformation(2:end,stratCol));
    % delete empty columns in the data
    sampleData{1,1}='Averages';
    delIndices =cellfun(@isempty, sampleData(1,:));
    sampleData(:,delIndices)=[];
    % delete columns that are all zeros
    cnt=1;
    delArray=[];
    for i=2:size(sampleData,2)
        if abs(sum(str2double(sampleData(2:end,i))))<0.0000001
            delArray(1,cnt)=i;
            cnt=cnt+1;
        end
    end
    sampleData(:,delArray)=[];
    
    
    % Fill out table header
    if length(groups)==2
        Statistics={'Feature','Description','p_value','Decision','Rank sum statistic','Z-statistics'};
    elseif length(groups)>2
        Statistics={'Feature','Description','p_value','Decision','Degrees of freedom','Chi-sq'};
    end
    cnt=size(Statistics,2)+1;
    for i=1:length(groups)
        Statistics{1,cnt}=['Average_',groups{i}];
        cnt=cnt+1;
        Statistics{1,cnt}=['StandardDeviation_',groups{i}];
        cnt=cnt+1;
    end
    
    for j=2:size(sampleData,1)
        if ~isempty(find(strcmp(sampleInformation(:,1),sampleData{j,1})))
            group{j-1,1}=sampleInformation{find(strcmp(sampleInformation(:,1),sampleData{j,1})),stratCol};
        end
    end
    
    %% calculate the statistics
    for i=2:size(sampleData,2)
        Statistics{i,1}=sampleData{1,i};
        dataAll=str2double(sampleData(2:end,i));
        
        % separate data by group
        for j=1:length(groups)
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
            Statistics{i,3}=p;
            Statistics{i,4}=h;
            Statistics{i,5}=stats.ranksum;
            Statistics{i,6}=stats.zval;
            
        elseif length(groups)>2
            % use Kruskal Wallis test
            [p,ANOVATAB] = kruskalwallis(dataAll,group);
            close all
            Statistics{i,3}=p;
            if ANOVATAB{2,6} ==0
                Statistics{i,4}='0';
            else
                Statistics{i,4}='1';
            end
            Statistics{i,5}=ANOVATAB{2,3};
            Statistics{i,6}=ANOVATAB{2,5};
        end
        
        for j=1:length(groups)
            findCol=find(strcmp(Statistics(1,:),['Average_',groups{j}]));
            Statistics{i,findCol}=mean(dataGrouped{j});
            findCol=find(strcmp(Statistics(1,:),['StandardDeviation_',groups{j}]));
            Statistics{i,findCol}=std(dataGrouped{j});
        end
    end
    
    %% correct for false discovery (FDR) rate
    pAverages=cell2mat(Statistics(2:end,3));
    fdr = mafdr(pAverages,'BHFDR', true);
    Statistics(2:end,3)=num2cell(fdr);
    
    for i=2:size(Statistics,1)
        if Statistics{i,3} <0.05
            Statistics{i,4} = 1;
        else
            Statistics{i,4} = 0;
        end
    end
    
    %% save only the significant entries as a spreadsheet
    nsMets={};
    cnt=1;
    for i=2:length(Statistics)
        if Statistics{i,4}==0
            nsMets{cnt,1}=Statistics{i,1};
            cnt=cnt+1;
        end
    end
    [C,ia,ib] = intersect(sampleData(1,:),nsMets);
    significantFeatures=sampleData;
    significantFeatures(:,ia)=[];
    
    %% add reaction/metabolite annotations if possible
    metaboliteDatabase = readtable('MetaboliteDatabase.txt', 'Delimiter', 'tab','TreatAsEmpty',['UND. -60001','UND. -2011','UND. -62011'], 'ReadVariableNames', false);
    metaboliteDatabase=table2cell(metaboliteDatabase);
    reactionDatabase = readtable('ReactionDatabase.txt', 'Delimiter', 'tab','TreatAsEmpty',['UND. -60001','UND. -2011','UND. -62011'], 'ReadVariableNames', false);
    reactionDatabase=table2cell(reactionDatabase);
    
    significantFeatures(1,:)=strrep(significantFeatures(1,:),'EX_','');
    significantFeatures(1,:)=strrep(significantFeatures(1,:),'(e)','');
    significantFeatures(1,:)=strrep(significantFeatures(1,:),'[fe]','');
    for i=2:size(Statistics,1)
        feat=Statistics{i,1};
        if contains(feat,'[fe]')
            feat=strrep(feat,'EX_','');
            feat=strrep(feat,'[fe]','');
        end
        if ~isempty(find(strcmp(metaboliteDatabase(:,1),feat)))
            Statistics{i,2}=metaboliteDatabase{find(strcmp(metaboliteDatabase(:,1),feat)),2};
        elseif ~isempty(find(strcmp(reactionDatabase(:,1),feat)))
            Statistics{i,2}=reactionDatabase{find(strcmp(reactionDatabase(:,1),feat)),2};
        else
            Statistics{i,2}='NA';
        end
    end

end