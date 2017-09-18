function [optGeneSol] = GetOptGeneSol(model, targetRxn, substrateRxn, generxnList, population, x, scores, isGeneList, saveFile, outputFolder)
% Saves the solution from optGene and `optGeneR` in same format as `OptKnock`
%
% USAGE:
%
%    [optGeneSol] = GetOptGeneSol(model, targetRxn, substrateRxn, generxnList, population, x, scores, isGeneList)
%
% INPUTS:
%    model:           model structure
%    targetRxn:       target reactions
%    substrateRxn:    substrate reactions
%    generxnList:     List of genes or `rxns` which can be knocked out
%    population:      population matrix
%    x:               the best solution
%    scores:          an array of scores
%    isGeneList:      boolean
%    saveFile:        boolean. Default = false;
%    outputFolder:    char. Default = pwd;
%
% OUTPUT:
%    optGeneSol:      Solution in the desired format

if nargin < 9 || isempty(saveFile)
    saveFile = 0;
end
if nargin < 10 || isempty(outputFolder)
    outputFolder = 'optGeneResults';
end

if ~isdir(outputFolder)
    mkdir(outputFolder);
end

writeDirect = [pwd filesep outputFolder filesep];

% writeDirect where the files should be saved
optGeneSol = struct();
% from user input
optGeneSol.substrateRxn = substrateRxn;
optGeneSol.targetRxn = targetRxn;

% for no genes or reactions found
if sum(x) == 0
    if saveFile
        save (strcat(writeDirect, 'optGeneSol--target-', char(targetRxn),...
            '--sub-',char(substrateRxn),'--KOs-0-no_solution_better_than_WT'...
            ), 'optGeneSol')
    end
    return;
end

% from OptGene
if isGeneList
    optGeneSol.geneList = generxnList(logical(x));
    optGeneSol.numDel = length(optGeneSol.geneList);
    [~,~,optGeneSol.rxnList] = deleteModelGenes(model,optGeneSol.geneList); %finds just the reactions that are KOed b/c of gene removal
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
    if saveFile
        save (strcat(writeDirect, 'optGeneSol--genes--target-', optGeneSol.targetRxn,...
            '--sub-',optGeneSol.substrateRxn,'--KOs-',num2str(optGeneSol.numDel),...
            '--yield-',num2str(optGeneSol.obj),...
            '--',slnCheck,'--',slnType,'--GR-',num2str(growthRate),...
            '--10CC.mat'...
            ), 'optGeneSol')
    end
else
    if saveFile
        save (strcat(writeDirect, 'optGeneSol--rxns--target-', char(optGeneSol.targetRxn),...
            '--sub-',char(optGeneSol.substrateRxn),'--KOs-',num2str(optGeneSol.numDel),...
            '--yield-',num2str(optGeneSol.obj),...
            '--',slnCheck,'--',slnType,'--GR-',num2str(growthRate),...
            '--10CC.mat'...
            ), 'optGeneSol')
    end
end
