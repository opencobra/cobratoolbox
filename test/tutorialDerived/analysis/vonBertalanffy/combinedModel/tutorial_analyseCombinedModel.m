%% Analyse combinedModel, input to component contribution
%% *Author: Ronan Fleming, NUI Galway, Leiden University*
%% *Reviewers:* 
%% INTRODUCTION
%% PROCEDURE
%% Configure the environment
% All the installation instructions are in a separate .md file named vonBertalanffy.md 
% in docs/source/installation
% 
% With all dependencies installed correctly, we configure our environment, verfy 
% all dependencies, and add required fields and directories to the matlab path.

aPath = which('initVonBertalanffy');
basePath = strrep(aPath,'vonBertalanffy/initVonBertalanffy.m','');
addpath(genpath(basePath))
folderPattern=[filesep 'old'];
method = 'remove';
editCobraToolboxPath(basePath,folderPattern,method)
aPath = which('initVonBertalanffy');
basePath = strrep(aPath,'vonBertalanffy/initVonBertalanffy.m','');
addpath(genpath(basePath))
folderPattern=[filesep 'new'];
method = 'add';
editCobraToolboxPath(basePath,folderPattern,method)
%%
initVonBertalanffy
%% 
% Load combined model

load('data_prior_to_componentContribution')
% Statistics on the combined model

fprintf('%u%s\n',nnz(combinedModel.trainingMetBool),' training metabolites')
fprintf('%u%s\n',nnz(combinedModel.trainingMetBool & combinedModel.groupDecomposableBool),' of which are Moiety decomposable.')
fprintf('%u%s\n',nnz(combinedModel.trainingMetBool & ~combinedModel.inchiBool),' of which have no inchi.')
fprintf('%u%s\n',nnz(combinedModel.trainingMetBool & combinedModel.inchiBool & ~combinedModel.groupDecomposableBool),' of which are not Moiety decomposable.')
fprintf('%u%s\n',nnz(combinedModel.testMetBool),' test metabolites')
fprintf('%u%s\n',nnz(combinedModel.testMetBool & combinedModel.groupDecomposableBool),' of which are Moiety decomposable.')
fprintf('%u%s\n',nnz(combinedModel.testMetBool & ~combinedModel.inchiBool),' of which have no inchi.')
fprintf('%u%s\n',nnz(combinedModel.testMetBool & combinedModel.inchiBool & ~combinedModel.groupDecomposableBool),' ... of which are not Moiety decomposable.')
fprintf('%u%s\n',size(combinedModel.S,1),' combined model metabolites.')
fprintf('%u%s\n',nnz(combinedModel.trainingMetBool & ~combinedModel.testMetBool),' ... of which are exclusively training metabolites.')
fprintf('%u%s\n',nnz(combinedModel.trainingMetBool & combinedModel.testMetBool),' ... of which are both training and test metabolites.')
fprintf('%u%s\n',nnz(~combinedModel.trainingMetBool & combinedModel.testMetBool),' ... of which are exclusively test metabolites.')
% Sparsity pattern of combinedModel.S

figure
spy(combinedModel.S);
title([int2str(size(combinedModel.S,1)) ' x ' int2str(size(combinedModel.S,2))])
xlabel('Reactions')
ylabel('Metabolites')
%%
nReactionsPerMetabolite=full(sum(combinedModel.S~=0,2));
histogram(nReactionsPerMetabolite(nReactionsPerMetabolite~=0),'BinWidth',2)
title('Number of Reactions per metabolite')
xlabel('#Metabolites')
ylabel('log(#Reactions)')
set(gca,'YScale','log')
fprintf('%u%s\n',nnz(nReactionsPerMetabolite==0),' metabolites without reactions.')
nMetabolitesPerReaction=full(sum(combinedModel.S~=0,1)');
histogram(nMetabolitesPerReaction)
title('Number of Metabolites per Reaction')
xlabel('#Reactions')
ylabel('#Metabolties')
if any(nMetabolitesPerReaction==0)
    error('combinedModel.S reaction without a metabolite')
end
%%
dX = diag(combinedModel.S*combinedModel.S');
figure
plot(sort(dX),'.')
set(gca,'YScale','log')
ylabel('log(stoichiometric degree)')
xlabel('metabolites sorted by stoichiometric degree')
nnz(dX==0)
% Sparsity pattern of combinedModel.G

figure
spy(combinedModel.G)
title([int2str(size(combinedModel.G,1)) ' x ' int2str(size(combinedModel.G,2))])
xlabel('Moieties')
ylabel('Metabolites')
nGroupPerMetabolite = full(sum(combinedModel.G~=0,2));
histogram(nGroupPerMetabolite,'BinWidth',2)
xlabel('#Moieties per metabolite')
ylabel('#Metabolites')
if any(nGroupPerMetabolite==0)
    error('Metabolite without any Moiety')
end
%%
nMetabolitePerGroup = sum(combinedModel.G~=0,1)';
if 0
    histogram(nMetabolitePerGroup);
    %set(gca,'YScale','log')
    ylim([0, 10]);
else
    histogram(nMetabolitePerGroup);
    set(gca,'YScale','log')
end
xlabel('#Metabolites per Moiety')
ylabel('log(#Moieties)')
if any(nMetabolitePerGroup==0)
    error('Moiety without metabolite')
end
% Sparsity pattern of combinedModel.StG

StG=combinedModel.S'*combinedModel.G;
figure
spy(StG)
title(['S''*G    ' int2str(size(StG,1)) ' x ' int2str(size(StG,2))])
xlabel('Moieties')
ylabel('Reactions')
nReactingMoieties=full(sum(StG~=0,2));
histogram(nReactingMoieties,'BinWidth',2)
title('Number of Reacting Moieties per reaction')
xlabel('#Reacting moieties')
ylabel('#Reactions')
fprintf('%u%s\n',nnz(nReactingMoieties==0),' reactions without reacting moieties.')
printRxnFormula(combinedModel,combinedModel.rxns(nReactingMoieties==0));
%%
nReactionsPerMoiety=full(sum(StG~=0,1)');
histogram(nReactionsPerMoiety)
set(gca,'YScale','log')
title('Number of Reactions per moiety')
xlabel('#Reactions')
ylabel('#log(Moieties)')
fprintf('%u%s%u%s\n',nnz(nReactionsPerMoiety==0),' of the ', length(nReactionsPerMoiety), ' moieties do not react in any training reaction.')
%%