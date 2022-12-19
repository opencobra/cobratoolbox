function [overlapResults,statistic] = compareXomicsModels(multiModels, printFlag)
%Compare generated models in mets, rxns, genes
%
%USAGE:
%
%    [overlapResults,statistic] = compareXomicsModels(multiModels, printFlag)
%
%INPUT:
%    multiModels:     struct format with models that need to compare
%                      e.g.multimodels.model1
%                          multimodels.model2 ...
%    printFlag:       1 if information should be printed to a table.
%                     Default = 0
%
%OUTPUT:
%    overlapResults:  the overlapped met/rxn/gene numbers of each pair of models
%    statistic:       the overlapped porportion matrix of each pair of models
%
%EXAMPLE:
%
%    [overlapResults,statistic] = compareXomicsModels(multiModels)
%
%NOTE:
%
%    This function is used to compare generated models from xomicsToModel
%    pipeline
%
%Author(s): - Xi Luo
%           - Hanneke Leegwater (2022)

%% Check input params

if ~exist('printFlag', 'var') || isempty(printFlag)
    printFlag = 0;
elseif (~isnumeric(printFlag) & ~islogical(printFlag))
    error('printFlag should be a number or a bool')
end

%%
models=multiModels;
if isstruct(models) && length(fieldnames(models))>1
    fields=fieldnames(models);
    statMets=cell(length(fields));
    statRxns=cell(length(fields));
    statGenes=cell(length(fields));
    for i=1:length(fields)
        for j=1:length(fields)
        %mets
        overlap_mets.(fields{i}).(fields{j})=models.(fields{i}).mets(ismember(models.(fields{i}).mets,models.(fields{j}).mets));
        statMets{i,j}=sum(ismember(models.(fields{i}).mets,models.(fields{j}).mets));
        %rxns
        overlap_rxns.(fields{i}).(fields{j})=models.(fields{i}).rxns(ismember(models.(fields{i}).rxns,models.(fields{j}).rxns));
        statRxns{i,j}=sum(ismember(models.(fields{i}).rxns,models.(fields{j}).rxns));
        %genes
        overlap_genes.(fields{i}).(fields{j})=models.(fields{i}).genes(ismember(models.(fields{i}).genes,models.(fields{j}).genes));
        statGenes{i,j}=sum(ismember(models.(fields{i}).genes,models.(fields{j}).genes));
        end
    end
    colname=cell2table(fields);
    statMets=cell2table(statMets,"VariableNames",fields);
    statMets=[colname statMets];
    statRxns=cell2table(statRxns,"VariableNames",fields);
    statRxns=[colname statRxns];
    statGenes=cell2table(statGenes,"VariableNames",fields);
    statGenes=[colname statGenes];
    %all overlapped
    overlap_mets.alloverlap=models.(fields{1}).mets(ismember(models.(fields{1}).mets,models.(fields{2}).mets));
    overlap_rxns.alloverlap=models.(fields{1}).rxns(ismember(models.(fields{1}).rxns,models.(fields{2}).rxns));
    overlap_genes.alloverlap=models.(fields{1}).genes(ismember(models.(fields{1}).genes,models.(fields{2}).genes));
    for i=1:length(fields)-2
        overlap_mets.alloverlap=overlap_mets.alloverlap(ismember(overlap_mets.alloverlap,models.(fields{i+2}).mets));
        overlap_rxns.alloverlap=overlap_rxns.alloverlap(ismember(overlap_rxns.alloverlap,models.(fields{i+2}).rxns));
        overlap_genes.alloverlap=overlap_genes.alloverlap(ismember(overlap_genes.alloverlap,models.(fields{i+2}).genes));
    end
    overlapResults.mets=overlap_mets;
    overlapResults.rxns=overlap_rxns;
    overlapResults.genes=overlap_genes;
    statistic.overlapnumber_mets=statMets;
    statistic.overlapnumber_rxns=statRxns;
    statistic.overlapnumber_genes=statGenes;
    %met proportion
    metsdata=statistic.overlapnumber_mets{:,2:end};
    [max_a,index]=max(metsdata);
    xa=repmat(max_a',[1 length(statistic.overlapnumber_mets{:,1})]);
    pro=round(metsdata./xa*100,2);
    pro=num2cell(pro);
    pro=cell2table(pro,"VariableNames",fields);
    pro=[colname pro];
    statistic.overlaporportion_mets=pro;
    %rxns propotion
    metsdata=statistic.overlapnumber_rxns{:,2:end};
    [max_a,index]=max(metsdata);
    xa=repmat(max_a',[1 length(statistic.overlapnumber_rxns{:,1})]);
    pro=round(metsdata./xa*100,2);
    pro=num2cell(pro);
    pro=cell2table(pro,"VariableNames",fields);
    pro=[colname pro];
    statistic.overlaporportion_rxns=pro;
    %gene propotion
    metsdata=statistic.overlapnumber_genes{:,2:end};
    [max_a,index]=max(metsdata);
    xa=repmat(max_a',[1 length(statistic.overlapnumber_genes{:,1})]);
    pro=round(metsdata./xa*100,2);
    pro=num2cell(pro);
    pro=cell2table(pro,"VariableNames",fields);
    pro=[colname pro];
    statistic.overlaporportion_genes=pro;
else
    disp('please check the input variable')
end


%% Print tables with output if printFlag = 1
if printFlag ==1
    disp('Number of overlapping mets between models is:')
    statistic.overlapnumber_mets
    
    disp('Number of overlapping rxns between models is:')
    statistic.overlapnumber_rxns
    
    disp('Number of overlapping genes between models is:')
    statistic.overlapnumber_genes
end

