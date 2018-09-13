function [grRatio, grRateKO, grRateWT, hasEffect, delRxns, fluxSolution] = singleGeneDeletion(model, method, geneList, verbFlag, uniqueGene)
% Performs single gene deletion analysis using FBA, MOMA or linearMOMA
%
% USAGE:
%
%    [grRatio, grRateKO, grRateWT, hasEffect, delRxns, fluxSolution] = singleGeneDeletion(model, method, geneList, verbFlag)
%
% INPUT:
%    model:           COBRA model structure including gene-reaction associations
%
% OPTIONAL INPUTS:
%    method:          Either 'FBA', 'MOMA' or 'lMOMA' (Default = 'FBA')
%    geneList:        List of genes to be deleted (default = all genes)
%    verbFlag:        Verbose output (Default false)
%    uniqueGene:      Run unique gene deletion (default = 0).
%
%
% OUTPUTS:
%    grRatio:         Computed growth rate ratio between deletion strain and wild type
%    grRateKO:        Deletion strain growth rates (1/h)
%    grRateWT:        Wild type growth rate (1/h)
%    hasEffect:       Does a gene deletion affect anything (i.e. are any reactions
%                     removed from the model)
%    delRxns:         List of deleted reactions for each gene `KO`
%    fluxSolution:    FBA/MOMA/lMOMA fluxes for `KO` strains
%
% .. Author:
%       - Markus Herrgard 8/7/06
%       - Aurich/Thiele 11/2015 unique gene deletion option (delete all alternate transcripts and if solKO.stat not 1 or 5, grRateKO(i) = NaN;)
%       - Karthik Raman 06/2017 speeding up gene deletion based on github.com/RamanLab/FastSL

if (nargin < 2)
    method = 'FBA';
end
if (nargin < 3)
    geneList = model.genes;
else
    if (isempty(geneList))
        geneList = model.genes;
    end
end
if (nargin < 4)
    verbFlag = false;
end


if (nargin < 5)
    uniqueGene = 0;
end

if ~isfield(model,'rxnGeneMat')
    %We need the reactionGeneMat during deleteModelGenes, so build it in
    %the beginning
    model = buildRxnGeneMat(model);
end

% initialize the non Transcript gene and the genes to Test arrays
noTransGenes = model.genes;

% overwrite them if uniqueGene is requested AND we do have a transcript
% model
if uniqueGene
    % check, whether all genes have transcripts
    % if not, we cannot do uniqueGene, if, we can.
    if all(cellfun(@(x) ~isempty(regexp(x,'\.[0-9]+$')),model.genes))
        % all genes have a transcript, so we can simply remove the
        % transcript information.
        noTransGenes = regexprep(model.genes,'(.*)\.[0-9]+$','$1');
    end
end

nDelGenes = numel(geneList);

solWT = optimizeCbModel(model,'max');
% init the vector of unused reactions
Jz = solWT.x==0;

grRateWT = solWT.f;
grRateKO = ones(nDelGenes,1)*grRateWT;
grRatio = ones(nDelGenes,1);
hasEffect = true(nDelGenes,1);
fluxSolution = zeros(length(model.rxns),nDelGenes);
delRxns = cell(nDelGenes,1);
if (verbFlag)
    fprintf('%4s\t%4s\t%10s\t%9s\t%9s\n','No','Perc','Name','Growth rate','Rel. GR');
end
showprogress(0,'Single gene deletion analysis in progress ...');
for i = 1:nDelGenes
	showprogress(i/nDelGenes);
    delGenes = model.genes(ismember(noTransGenes,geneList{i}));            
    [modelDel,hasEffect(i),constrRxnNames] = deleteModelGenes(model,delGenes);
    delRxns{i} = constrRxnNames;
    
    if (hasEffect(i)) && ~all(ismember(delRxns{i},model.rxns(Jz)))
        switch method
            case 'lMOMA'
                solKO = linearMOMA(model,modelDel,'max');
            case 'MOMA'
                solKO = MOMA(model,modelDel,'max',false,true);
            otherwise
                solKO = optimizeCbModel(modelDel, 'max');
        end
        if (solKO.stat == 1 ||solKO.stat == 5 )
            grRateKO(i) = solKO.f;
            fluxSolution(:,i) = solKO.x;
        else
            grRateKO(i) = NaN;
        end
    end
    if (verbFlag)
        fprintf('%4d\t%4.0f\t%10s\t%9.3f\t%9.3f\n',i,100*i/nDelGenes,geneList{i},grRateKO(i),grRateKO(i)/grRateWT*100);
    end
end


grRatio = grRateKO/grRateWT;
