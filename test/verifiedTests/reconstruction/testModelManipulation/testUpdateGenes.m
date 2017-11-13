% The COBRAToolbox: testUpdateGenes.m
%
% Purpose:
%     - testUpdateGenes tests updateGenes
%
% Authors:
%     - Uri David Akavia August 2017

global CBTDIR

% save the current path
currentDir = pwd;

fileDir = fileparts(which('testUpdateGenes'));
cd(fileDir);

model = getDistributedModel('Recon2.v04.mat');

% Check that updateGenes orders the gene list
model2 = updateGenes(model);
tmp = model;
tmp.genes = sort(tmp.genes);
assert(isequal(tmp.genes,model2.genes));

%Note the gens associated with the reaction for which we remove the gpr
geneRemoved = model.genes(model.rxnGeneMat(strcmp(model.rxns, 'OROTGLUt'), :) == 1);

% Remove one gene (by removing gene rules from one reaction)
model2 = changeGeneAssociation(model2,'OROTGLUt','');
model2 = updateGenes(model2);

assert(length(model.genes) == length(model2.genes) + 1);
geneDifference = setdiff(model.genes, model2.genes);
assert(all(strcmp(geneRemoved, geneDifference)));

% Test tolerance of capital letters and gene addition
model2 = changeGeneAssociation(model2,'OROTGLUt','(Foo AND bar) OR gene or gene2');
model2 = updateGenes(model2);
genesAddedShouldBe = {'Foo'; 'bar'; 'gene'; 'gene2'};
assert(all(strcmp(setdiff(model2.genes, model.genes), genesAddedShouldBe)));

%return to original directory
cd(currentDir)
