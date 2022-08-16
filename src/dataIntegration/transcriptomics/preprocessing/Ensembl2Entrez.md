# Converting Ensembl ID to Entrez ID for  Transcriptomic Dataset in Modelling
Author: "Yanjun Liu"
Date: "4/12/2022"

# Introduction

This file provides two methods for conversion of Ensembl ID to Entrez ID. 
1) Convert Ensembl ID to Entren ID directly
or
2) Find Ensembl ID for genes in Recon3D, then map the raw data with genes in Recon3D by Ensembl ID

## The First Method 
The following scripts are written in **MATLAB**
```
% Load rawCounts associated with Ensemble ID
rawCounts = readtable('/Users/username/raw_counts.txt');
GeneList = rawCounts(:,1);
if iscell(GeneList)
  EnsembleID=GeneList.rowname;
else
  EnsembleID=cellstr(GeneList.rowname);
end

% Look for corresponding Entrez ID for every gene
NewList=cell(length(EnsembleID),1);
for i=1:length(EnsembleID)
try
info=webread(['https://rest.ensembl.org/xrefs/id/',EnsembleID{i},'?']);
 if length(info)==1
     NewList{i}='';
  else
    for k = 1:length(info)
     if strcmp(info{k}.dbname,'EntrezGene')
        NewList{i}=info{k}.primary_id;
     end
    end
  end
 catch
  NewList{i}='';
 end
end

%Count mapped genes
num_nonblank = sum(~cellfun(@isempty,NewList))

% Output the converted result
entrez_merge_ensemble=table(EnsembleID,NewList);
entrez_merge_ensemble.Properties.VariableNames{1}='rowname';
outPutCounts=join(entrez_merge_ensemble,rawCounts);
writetable(outPutCounts,"GeneList_with_entrez.csv")
```
For the first method, there is a mismatch between two kinds of gene IDs. The reason for the mismatch is that the majority of Ensembl gene IDs without an equivalent in the other databases are mainly pseudogenes or non-coding RNAs. Here provides a second method to conduct the ID conversion. 


## The Second Method 
### Step 1: Convert Entrez ID to Ensembl ID for genes included in the Recon 3D 

##This process is conducted in **R** using the **biomaRt** package
```
## Load raw data
entrezGene <- read.table("/Users/username/Recon3D_301/entrezList.csv" )

## Intall package  
if (!requireNamespace("BiocManager", quietly = TRUE))
install.packages("BiocManager") 
BiocManager::install("biomaRt") library(biomaRt)install.packages("biomart")
library("biomaRt") 

## Set up databases and datasets
listMarts()
ensembl <- useMart("ensembl",dataset="hsapiens_gene_ensembl")                                                                         
filters = listFilters(ensembl)

## Convert ID
genes <- getBM(filters="entrezgene_id", attributes=c("ensembl_gene_id","entrezgene_id"), values=entrezGene, mart=ensembl)

## Output                                                                                                               
print(genes)
path_out = '/Users/username/'
fileName = paste (path_out,'entrez2ensemblforRecon3.csv',sep='')
write.csv(genes,fileName)
```

### Step 2: Map gene data with genes in Recon 3D, based on the Ensembl ID
The following scripts are written with **Matlab**
```
% Load raw counts associated with Ensemble ID
rawCounts = readtable('/Users/username/raw_counts.txt');

% Load gene list for genes included in Recon3D with Ensembl ID and Entrez ID
genesinRecon = readtable(/Users/username/entrez2ensemblforRecon3.csv');
rawCounts.Properties.VariableNames(1)={'ensembl_gene_id'};

% Map genes in rawCounts with that in Recon3D
mapped=rawCounts(ismember(rawCounts.ensembl_gene_id,genesinRecon.ensembl_gene_id),:);
converted_rawCounts=innerjoin(mapped,genesinRecon);

% Organise data and output data
converted_rawCounts=movevars(converted_rawCounts,'entrezgene_id','after','ensembl_gene_id');
converted_rawCounts=removevars(converted_rawCounts,'Var1');
writetable(converted_rawCounts,'Ensemble2Entrez2.csv')
```

### Step 3: Use the successfully mapped genes as  the input data for model

The raw data derived from the RNA sequencing contains genes and expression values for all genes sequenced in the sample. Nevertheless, only metabolic genes are necessary for the construction of a genome-scale metabolic model. It would be convenient to reduce the size of transcriptomic data by mapping with genes in Recon.


