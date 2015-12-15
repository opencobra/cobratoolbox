function [results ListResults] = findRxnsFromGenes(model, genes, numericFlag, ListResultsFlag)
%findRxnsFromGenes print every reaction associated with a gene of interest
%
% [results ListResults] = findRxnsFromGenes(model, genes, numericFlag,ListResultsFlag)
%
%INPUTS
% model                 COBRA model structure
% genes                 string of single gene or cell array of multiple
%                       genes for which rxns are desired.
%
%OPTIONAL INPUTS
% numericFlag             1 if using Human Recon  (Default = 0)
% ListResultsFlag       1 if you want to output ListResults (Default = 0)
%
%OPUTPUTS
% results               structure containing cell arrays for each gene.
%                       Each cell array has one column of rxn abbreviations
%                       and one column containing the reaction formulae
% ListResults           same as above, but in a cell array
% 
% by Nathan Lewis 02/16/08
% edited 04/05/09 (MUCH faster now -- NL)
% edited 06/11/10 (yet even faster now -- NL)
% edited interface for backward compatibility (Ronan, Ines)

if nargin==4
   warning('3rd argument is numericFlag, currently redundant, will be depreciated')
end

if nargin< 3
    numericFlag = 0;
    ListResultsFlag = 0;
end

if ~iscell(genes)
    gene = genes;
    clear genes
    genes{1} = gene;
    clear gene
end
if iscell(genes{1})
    for i = 1:length(genes)
        gene(i) = genes{i};
    end
    clear genes
    genes = gene;
    clear gene
end
model.genes = regexprep(model.genes,'-','_DASH_');
model.genes = regexprep(model.genes,'\.','_POINT_');
genes = regexprep(genes,'-','_DASH_');
genes = regexprep(genes,'\.','_POINT_');

%find where the genes are located in the rxnGeneMat
GeneID(1) = 0;
for j = 1:length(genes)
    Ind = find(~cellfun('isempty', regexp(model.genes,cat(2,'^',genes{j},'$'))));
    
            if ~isempty(Ind)
                GeneID(j) = Ind;
            end

end
if min(GeneID) == 0
    warning('A gene was not found in the model!')
    results = struct([]);
    if max(GeneID) ==0,results = struct([]);ListResults = {};
    return
    end
    Ind = find(GeneID==0);
    GeneID(Ind) = [];
    genes(Ind) = [];
end
results = struct([]);
for i = 1:length(GeneID)
    
    k=1;
    Ind_rxns = find(model.rxnGeneMat(:,GeneID(i))==1);
    for j=1:length(Ind_rxns)
%         if model.rxnGeneMat(j,GeneID(i))==1
            if isempty(results)
                results = struct;
            end
			%Ensures that geneids can become field names for structures
            if regexp(genes{i},'[^a-zA-Z0-9_]')
				tempGene = regexprep(genes{i},'[^a-zA-Z0-9_]','_');
            else tempGene = genes{i};
            end
			
			%If gene starts with a digit it cannot be a field name, prepend gene_ to correct
			if regexp(tempGene,'^\d')
				tempGene = cat(2,'gene_',tempGene);
			end
			
            results.(tempGene){k,1} = model.rxns(Ind_rxns(j));
            results.(tempGene)(k,2) = printRxnFormula(model,model.rxns(Ind_rxns(j)),0);
            if isfield(model,'subSystems')
                results.(tempGene)(k,3) = model.subSystems(Ind_rxns(j));
            end
            if isfield(model,'rxnNames')
            results.(tempGene){k,4} = model.rxnNames{Ind_rxns(j)};
            end
            k=k+1;
%         end
    end
end
ListResults = {};
if isempty(results)
    warning('Your gene was not associated with any reactions!')
    ListResults = {};
else
    if ListResultsFlag ==1
    tmp = fieldnames(results);
    
    for i = 1:length(tmp) 
        tmp2 = results.(tmp{i});
        ListResults(end+1:end+length(tmp2(:,1)),1:4) = tmp2;
        ListResults(end-length(tmp2(:,1))+1:end,5) = tmp(i);
    end
    
   
    for j = 1:length(ListResults(:,1))
        ListResults(j,1) = ListResults{j,1};
    end
    
    end
    
end