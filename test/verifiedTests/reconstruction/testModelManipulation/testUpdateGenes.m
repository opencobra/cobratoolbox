% The COBRAToolbox: testUpdateGenes.m
%
% Purpose:
%     - testUpdateGenes tests updateGenes
%
% Authors:
%     - Uri David Akavia August 2017

% save the current path
currentDir = pwd;

fileDir = fileparts(which('testUpdateGenes'));
cd(fileDir);

modelDirectory = strcat('..', filesep, '..', filesep, '..', filesep, 'models', filesep);

model = readCbModel(strcat(modelDirectory, 'Recon2.v04.mat'));

% Check that updateGenes doesn't change the model
model2 = updateGenes(model);
tmp = model;
tmp.genes = sort(tmp.genes);
assert(isSameCobraModel(tmp, model2));

% Remove one gene (by removing gene rules from one reaction)
model2.grRules{strcmp(model.rxns, 'OROTGLUt')} = '';
geneRemoved = model.genes(model.rxnGeneMat(strcmp(model.rxns, 'OROTGLUt'), :) == 1);
model2 = updateGenes(model2);

assert(length(model.genes) == length(model2.genes) + 1);
geneDifference = setdiff(model.genes, model2.genes);
assert(all(strcmp(geneRemoved, geneDifference)));

% Test tolerance of capital letters and gene addition
model2.grRules{strcmp(model.rxns, 'OROTGLUt')} = '(Foo AND bar) OR gene or gene2';
model2 = updateGenes(model2);
genesAddedShouldBe = {'Foo'; 'bar'; 'gene'; 'gene2'};
assert(all(strcmp(setdiff(model2.genes, model.genes), genesAddedShouldBe)));

%return to original directory
cd(currentDir)
