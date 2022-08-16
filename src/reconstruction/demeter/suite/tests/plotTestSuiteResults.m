function plotTestSuiteResults(testResultsFolder,reconVersion)

% This function prints and summarizes the results of testAllReconstructionFunctions.

%% plot the computed reconstruction features
currentDir = pwd;
cd(testResultsFolder)

%% load all test results
fields = {
    'Carbon_sources_TruePositives'
    'Carbon_sources_FalseNegatives'
    'Fermentation_products_TruePositives'
    'Fermentation_products_FalseNegatives'
    'growsOnDefinedMedium'
    'Metabolite_uptake_TruePositives'
    'Metabolite_uptake_FalseNegatives'
    'Secretion_products_TruePositives'
    'Secretion_products_FalseNegatives'
    'Bile_acid_biosynthesis_TruePositives'
    'Bile_acid_biosynthesis_FalseNegatives'
    'Drug_metabolism_TruePositives'
    'Drug_metabolism_FalseNegatives'
    'PutrefactionPathways_TruePositives'
    'PutrefactionPathways_FalseNegatives'
    'AromaticAminoAcidDegradation_TruePositives'
    'AromaticAminoAcidDegradation_FalseNegatives'
    'Mass_imbalanced'
    'Charge_imbalanced'
    'Leaking_metabolites'
    };

Results=struct;

for i=1:length(fields)
    if isfile([testResultsFolder filesep fields{i} '_' reconVersion '.txt'])
        savedResults = readtable([testResultsFolder filesep fields{i} '_' reconVersion '.txt'], 'ReadVariableNames', false, 'Delimiter','tab', 'format', 'auto');
        Results.(fields{i}) = table2cell(savedResults);
        numberRecons=size(Results.(fields{i}),1);
    else
        Results.(fields{i}) = {};
    end
end

for j=1:length(fields)
    data=Results.(fields{j});
    if size(data,2)>1
        plotdata=[];
        % if there are no entries for data
        if size(data,2)==1
            for k=1:length(data)
                plotdata(k,1)=0;
            end
            label='Number of data points';
        else
            if strcmp(fields{j},'growsOnDefinedMedium')
                plotdata=data(:,2);
                plotdata(find(strcmp(plotdata(:,1),'NA')),:)=[];
                plotdata=str2double(plotdata);
            else
                if isnumeric(data{1,2}) && ~isempty(data{1,2})
                    % if the data is fluxes-plot the values
                    plotdata=cell2mat(data(:,2));
                    if ~any(strcmp(fields{j},{'Number_genes', 'Number_reactions', 'Number_metabolites'}))
                        label='Flux (mmol*gDW-1*hr-1)';
                    else
                        label='Number of data points';
                    end
                else
                    % count the non-empty data entries
                    for k=1:size(data,1)
                        plotdata(k,1)=length(find(~cellfun(@isempty,data(k,2:end))));
                    end
                    label='Number of data points';
                end
            end
        end
        figure;
        hold on
        % need a workaround if all data is zero
        if sum(plotdata)==0
            plotdata(1,1)=0.00001;
        end
        % does not work if all values are equal or there are too few values
        try
            violinplot(plotdata, {reconVersion});
            ylabel(label)
            if contains(pwd,'_refined')
                h=title([strrep(fields{j},'_',' ') ', refined reconstructions']);
            elseif contains(pwd,'_draft')
                h=title([strrep(fields{j},'_',' ') ', draft reconstructions']);
            end
            ylim([0 max(plotdata)+1])
            set(h,'interpreter','none')
            set(gca,'TickLabelInterpreter','none')
            set(gca, 'FontSize', 12)
            print(fields{j},'-dpng','-r300')
        end
    end
end

% calculate specificity and sensitivity
features=fields;
features(cellfun(@isempty,regexp(features,strjoin({'True','False'},'|'))),:)=[];
features=strrep(features,'_FalseNegatives','');
features=strrep(features,'_FalsePositives','');
features=strrep(features,'_TruePositives','');
features=strrep(features,'_TrueNegatives','');
features=unique(features);
Table{1,1}='Feature';
Table{1,2}=strcat('Sensitivity ',reconVersion);
cnt=2;
plotdata=[];
for i=1:length(features)
    TPs=zeros(numberRecons,1);
    FNs=zeros(numberRecons,1);
    Table{cnt,1}=features{i};
    if size(Results.(strcat(features{i},'_TruePositives')),2)==1
        for j=1:size(Results.(strcat(features{i},'_TruePositives')),1)
            TPs(j,1)=0;
        end
    else
        for j=1:size(Results.(strcat(features{i},'_TruePositives')),1)
            TPs(j,1)=length(find(~cellfun(@isempty,Results.(strcat(features{i},'_TruePositives'))(j,2:end))));
        end
    end
    if size(Results.(strcat(features{i},'_FalseNegatives')),2)==1
        for j=1:size(Results.(strcat(features{i},'_FalseNegatives')),1)
            FNs(j,1)=0;
        end
    else
        for j=1:size(Results.(strcat(features{i},'_FalseNegatives')),1)
            FNs(j,1)=length(find(~cellfun(@isempty,Results.(strcat(features{i},'_FalseNegatives'))(j,2:end))));
        end
    end
    
    Sensitivity=sum(TPs)/(sum(TPs)+sum(FNs));
    if isnan(Sensitivity)
        Table{cnt,2}='N/A';
    else
        Table{cnt,2}=Sensitivity;
    end
    % to plot all results
    plotdata(i,1)=sum(FNs);
    plotdata(i,2)=sum(TPs);
    labels{i,1}=strrep(features{i},'_',' ');
    labels{i,1}=strrep(labels{i,1},'AromaticAminoAcidDegradation','Amino acid degradation');
    labels{i,1}=strrep(labels{i,1},'PutrefactionPathways','Putrefaction pathways');
    cnt=cnt+1;
end
% remove drug metabolism-better plot separately
[C,IA]=intersect(labels,{'Drug metabolism'});
labels(IA)=[];
plotdata(IA,:)=[];

% remove entries with no experimental data
delInd=find(sum(plotdata,2)==0);
labels(delInd)=[];
plotdata(delInd,:)=[];

% worksround if there is only one row in plotdata
if size(plotdata,1) == 1
    plotdata(2,:) = NaN;
end

figure;
hold on
h=bar(plotdata);
barvalues(h)
h(1).FaceColor = [1 0 0];
h(2).FaceColor = [0 0 1];
set(findall(gcf,'-property','FontSize'),'FontSize',12)
xticklabels(labels);
set(gca,'XTick',1:numel(plotdata))
xtickangle(45)
set(gca,'YTickLabel',[])
ylabel('Total number of model predictions')
legend('Number of false negatives','Number of true positives')
set(gca,'TickLabelInterpreter','none')
set(gca,'FontSize',10)
if contains(pwd,'_refined')
    title('Features succesfully and unsuccessfully captured by refined reconstructions')
elseif contains(pwd,'_draft')
    title('Features succesfully and unsuccessfully captured by draft reconstructions')
end
print('FN_vs_TPs','-dpng','-r300')

close all

Table=cell2table(Table);
writetable(Table,[reconVersion '_Properties'],'FileType','spreadsheet','WriteVariableNames',false);

%% summarize more features
% report all unbalanced reactions
if size(Results.Mass_imbalanced,2)>1 || size(Results.Charge_imbalanced,2)>1
    Mass_imbalanced=Results.Mass_imbalanced(:,2:end);
%     Mass_imbalanced(cellfun(@isempty,Mass_imbalanced)==1)=[];
    Charge_imbalanced=Results.Charge_imbalanced(:,2:end);
%     Charge_imbalanced(cellfun(@isempty,Charge_imbalanced)==1)=[];
    Unbalanced_reactions=unique([Mass_imbalanced,Charge_imbalanced]);
    Unbalanced_reactions=cell2table(Unbalanced_reactions);
    writetable(Unbalanced_reactions,'Unbalanced_reactions','FileType','text','WriteVariableNames',false);
end
% report all leaking metabolites
if size(Results.Leaking_metabolites,2)>1
    Leaking_metabolites=Results.Leaking_metabolites(:,2:end);
    Leaking_metabolites(cellfun(@isempty,Leaking_metabolites)==1)=[];
    Leaking_metabolites=cell2table(Leaking_metabolites);
    writetable(Leaking_metabolites,'Leaking_metabolites','FileType','text','WriteVariableNames',false);
end

%% print percentage of reconstructions agreeing with data
Percentages={'Feature','StrainsWithData','PercentAgreeing'};
features={
    'Carbon_sources'
    'Fermentation_products'
    'PutrefactionPathways'
    'Secretion_products'
    'Metabolite_uptake'
    'AromaticAminoAcidDegradation'
    'Bile_acid_biosynthesis'
    'Drug_metabolism'
    'growsOnDefinedMedium'
    };
for i=1:length(features)
    Percentages{i+1,1} = features{i};
    cntData=0;
    cntAgreeing=0;
    if i < length(features)
        for j=1:size(Results.(strcat(features{i},'_TruePositives')),1)
            if size(Results.(strcat(features{i},'_TruePositives')),2) > 1
                if ~isempty(Results.(strcat(features{i},'_TruePositives')){j,2})
                    cntData=cntData+1;
                else
                    if size(Results.(strcat(features{i},'_FalseNegatives')),2) > 1
                        if ~isempty(Results.(strcat(features{i},'_FalseNegatives')){j,2})
                            cntData=cntData+1;
                        end
                    end
                end
            else
                if size(Results.(strcat(features{i},'_FalseNegatives')),2) > 1
                    if ~isempty(Results.(strcat(features{i},'_FalseNegatives')){j,2})
                        cntData=cntData+1;
                    end
                end
            end
            TP=length(find(~cellfun(@isempty,Results.(strcat(features{i},'_TruePositives'))(j,2:end))));
            if size(Results.(strcat(features{i},'_FalseNegatives')),2) > 1
                FN=length(find(~cellfun(@isempty,Results.(strcat(features{i},'_FalseNegatives'))(j,2:end))));
            else
                FN = 0;
            end
            if TP > 0 && FN == 0
                cntAgreeing=cntAgreeing+1;
            end
        end
    else
        growth=length(find(str2double(Results.(features{i})(:,2))==1));
        nogrowth=length(find(str2double(Results.(features{i})(:,2))==0));
        cntData=growth+nogrowth;
        cntAgreeing=growth;
    end
    Percentages{i+1,2} = cntData;
    Percentages{i+1,3} = cntAgreeing/cntData;
end
Percentages=cell2table(Percentages);
writetable(Percentages,[reconVersion '_PercentagesAgreement'],'FileType','spreadsheet','WriteVariableNames',false);

cd(currentDir)
end