function [grRatio,grRateKO,grRateWT,hasEffect,delRxns,fluxSolution] = singleGeneDeletion(model,method,geneList,verbFlag)
%singleGeneDeletion Performs single gene deletion analysis using FBA, MOMA or
%linearMOMA
%
% [grRatio,grRateKO,grRateWT,delRxns,hasEffect] = singleGeneDeletion(model,method,geneList,verbFlag)
%
%INPUT
% model         COBRA model structure including gene-reaction associations
%
%OPTIONAL INPUT
% method        Either 'FBA', 'MOMA', or 'lMOMA' (Default = 'FBA')
% geneList      List of genes to be deleted (default = all genes)
% verbFlag      Verbose output (Default false)
%
%OUTPUTS
% grRatio       Computed growth rate ratio between deletion strain and wild type
% grRateKO      Deletion strain growth rates (1/h)
% grRateWT      Wild type growth rate (1/h)
% hasEffect     Does a gene deletion affect anything (i.e. are any reactions
%               removed from the model)
% delRxns       List of deleted reactions for each gene KO
% fluxSolution  FBA/MOMA/lMOMA fluxes for KO strains
%
% Markus Herrgard 8/7/06

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

nGenes = length(model.genes);
nDelGenes = length(geneList);

solWT = optimizeCbModel(model,'max','one'); % by default uses the min manhattan distance norm FBA solution.
grRateWT = solWT.f;

grRateKO = ones(nDelGenes,1)*grRateWT;
grRatio = ones(nDelGenes,1);
hasEffect = true(nDelGenes,1);
fluxSolution = zeros(length(model.rxns),nDelGenes);
delRxns = cell(nDelGenes,1);
if (verbFlag)  
    fprintf('%4s\t%4s\t%10s\t%9s\t%9s\n','No','Perc','Name','Growth rate','Rel. GR');
end
h = waitbar(0,'Single gene deletion analysis in progress ...');
for i = 1:nDelGenes
    if mod(i,10) == 0
        waitbar(i/nDelGenes,h);
    end
    [modelDel,hasEffect(i),constrRxnNames] = deleteModelGenes(model,geneList{i});
    delRxns{i} = constrRxnNames;
    if (hasEffect(i))
        switch method
            case 'lMOMA'
                solKO = linearMOMA(model,modelDel,'max');
            case 'MOMA'
                solKO = MOMA(model,modelDel,'max',false,true);
            otherwise
                solKO = optimizeCbModel(modelDel,'max');
        end
        if (solKO.stat == 1)
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
if ( regexp( version, 'R20') )
        close(h);
end

grRatio = grRateKO/grRateWT;
