function [rxns,subsys,subsysGenes,uSys,Nr,rxnNames]=findSubsystemOfGenes(model,genes,pseudoFlag)
%[rxns,cmptmt,cmptGenes,uComp]=findSubsystemOfGenes(model,genes,pseudoFlag)
% This function is used to find out which genes belong to which subsystem

% INPUT:
% model:    model to which genes belong to
% genes (optional): genes in question, if not provided will do it for all
% the genes
% pseudoFlag (optional): true, if pseudoDeletion; false otherwise (default)
% OUTPUT:
% rxns:     Reactions governed by these genes
% subsys:   subsystem(s) to which the gene belongs to
% subsysGenes:Which Genes are involved in each subsystem, subsystem
%           name given by the cell array, usys
% uSys:    unique subsys
%
% Written by:
% Chintan Joshi when at CSU in 2014. See figures in following publication:
% Joshi CJ and Prasad A, 2014, "Epistatic interactions among metabolic genes
% depend upon environmental conditions", Mol. BioSyst., 10, 2578– 2589.

if (nargin<2)
    genes=model.genes;
end
if (nargin<3)
    pseudoFlag=false;
end

for i=1:length(genes)
    % find the reactions that were constrained by this gene
    [cRxns,iRxns]=findRxnsConstrained(model,genes(i,1),false);
    if pseudoFlag==false
        rxns{i,1}=iRxns{1,1};
        rxnNames{i,1} = model.rxnNames(ismember(model.rxns,iRxns{1,1}));
    else
        if (~isempty(cRxns{1,1}))
            rxns{i,1}=cRxns{1,1};
            rxnNames{i,1} = model.rxnNames(ismember(model.rxns,cRxns{1,1}));
        else
            rxns{i,1}=iRxns{1,1};
            rxnNames{i,1} = model.rxnNames(ismember(model.rxns,iRxns{1,1}));
        end
    end
    for j=1:length(rxns{i,1})
        rxnInds=find(strcmp(rxns{i,1}{j,1},model.rxns)==1); % find the index of each of the reactions involved
    end
%     if ~isempty(rxnInds)
    subs{i,1}=model.subSystems(rxnInds,1); % finds the subsytem of the reaction
%     end
%     rxnInds=[];
    if length(unique(subs{i,1}))==1 % checks if all the reactions belong to the same compartment
        subsys{i,1}=unique(subs{i,1}); % if they do, stores them under one string
    else
        subsys{i,1}=subs{i,1}; % else, stores them as a second-ordered cell string
    end
end

uSys=unique(linearizeCellString(subsys));
for i=1:length(uSys)
    c=0;
    geneIdx=0;
    for j=1:length(subsys)
        indc=find(strcmp(uSys{i,:},subsys{j,1})==1);
        if (~isempty(indc))
            c=c+1;
            geneIdx(c,1)=j;
        end
    end
    subsysGenes{i,1}=genes(geneIdx,1);
end
for i=1:length(subsysGenes)
Nr(i,1)=length(subsysGenes{i,1});
end
% Nrp=Nr/sum(Nr);
[Nr,ind] = sort(Nr,'ascend');
uComp4plot = uSys(ind);
barh(Nr);
set(gca,'YAxisLocation','Right');
set(gca,'YTickLabelMode','auto');
set(gca,'YTickMode','auto');
set(gca,'YTick',[1:1:length(Nr)]);
set(gca,'YTickLabel',uComp4plot);