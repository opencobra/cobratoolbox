function [optGeneSol] = GetOptGeneSol(model, targetRxn, substrateRxn, generxnList, population, x, scores, isGeneList)
% Saves the solution from optGene and `optGeneR` in same format as `OptKnock`
%
% USAGE:
%
%    [optGeneSol] = GetOptGeneSol(model, targetRxn, substrateRxn, generxnList, population, x, scores, isGeneList)
%
% INPUTS:
%    model:
%    targetRxn:
%    substrateRxn:
%    generxnList:
%    population:
%    x:                 The best solution
%    scores:
%    isGeneList:
%
% OUTPUT:
%    optGeneSol:        Solution in the desired format

writeDirect = 'C:\';
% writeDirect where the files should be saved
optGeneSol = struct();
% from user input
optGeneSol.substrateRxn = substrateRxn;
optGeneSol.targetRxn = targetRxn;

% for no genes or reactions found
if sum(x) == 0
    save (strcat(writeDirect, 'optGeneSol--target-', char(targetRxn),...
        '--sub-',char(substrateRxn),'--KOs-0-no_solution_better_than_WT'...
        ), 'optGeneSol')
    return;
end

% from OptGene
if isGeneList
    optGeneSol.geneList = generxnList(logical(x));
    optGeneSol.numDel = length(optGeneSol.geneList);
    [tmp,tmp2,optGeneSol.rxnList] = deleteModelGenes(model,optGeneSol.geneList); %finds just the reactions that are KOed b/c of gene removal
else
    optGeneSol.rxnList = generxnList(logical(x));
    optGeneSol.numDel = length(optGeneSol.rxnList);
end
optGeneSol.obj = min(scores);
optGeneSol.population = population;
optGeneSol.scores = scores;

%check the result from Opt...
[growthRate,minProd,maxProd] = testOptKnockSol(model,optGeneSol.targetRxn,optGeneSol.rxnList);
if (optGeneSol.obj - maxProd) / maxProd < .001 % acculacy must be within .1%
    slnCheck = 'valid_sln';
else slnCheck = 'unsound_sln';
end
if (maxProd - minProd) / maxProd < .001 % acculacy must be within .1%
    slnType = 'unique_point';
else slnType = 'non_unique';
end

% storage
if isGeneList
    save (strcat(writeDirect, 'optGeneSol--genes--target-', optGeneSol.targetRxn,...
        '--sub-',optGeneSol.substrateRxn,'--KOs-',num2str(optGeneSol.numDel),...
        '--yield-',num2str(optGeneSol.obj),...
        '--',slnCheck,'--',slnType,'--GR-',num2str(growthRate),...
        '--10CC.mat'...
        ), 'optGeneSol')
else
    save (strcat(writeDirect, 'optGeneSol--rxns--target-', char(optGeneSol.targetRxn),...
        '--sub-',char(optGeneSol.substrateRxn),'--KOs-',num2str(optGeneSol.numDel),...
        '--yield-',num2str(optGeneSol.obj),...
        '--',slnCheck,'--',slnType,'--GR-',num2str(growthRate),...
        '--10CC.mat'...
        ), 'optGeneSol')
end
