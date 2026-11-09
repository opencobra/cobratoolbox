% The COBRAToolbox: testUpdateGenes.m
%
% Purpose:
%     - testUpdateGenes tests updateGenes
%
% Function under test:
%     src/reconstruction/refinement/updateGenes.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - model manipulation, no solver; Recon2.v05 loaded through getDistributedModel.
%
% Coverage exemptions:
%     None besides the defective input listed below, whose lines are also reached with valid input.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: With two duplicated genes, different genes are merged
%       SEVERITY: wrong-result
%       TRIGGER: a model with two pairs of duplicates, for example model.genes = {'g1'; 'g1'; 'g2';
%         'g2'} with rules x(1), x(2), x(3), x(4) on four reactions, passed to updateGenes
%       OBSERVED: the gene list is recomputed from the input model and not from the merged one, so
%         the same two positions are merged again although they now hold other genes: the result
%         has the genes g1;g2 and g2, and three reactions with rule x(1)
%       EXPECTED: the genes g1 and g2, the first two reactions with rule x(1) and the others x(2)
%       LINES: 43
%
% Authors:
%     - Uri David Akavia August 2017
%     - Coverage completed by feature 20261104-115314-test-coverage-100, 2026-11-04.

global CBTDIR

% save the current path
currentDir = pwd;

fileDir = fileparts(which('testUpdateGenes'));
cd(fileDir);

% this test needs no solver, MATLAB toolbox or particular operating system
prepareTest();

model = getDistributedModel('Recon2.v05.mat');

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

%% two entries of the same gene are merged, and the rules follow

toyModel = createModel();
toyModel = addMultipleMetabolites(toyModel, {'A[c]', 'B[c]', 'C[c]'});
toyModel = addGenes(toyModel, {'g0', 'g1', 'g1b', 'g2'});
toyModel = addMultipleReactions(toyModel, {'R1', 'R2', 'R3', 'R4'}, toyModel.mets, ...
    [-1, 0, 1, 0; 1, -1, 0, 0; 0, 1, -1, 0], 'grRules', {'g0', 'g1', 'g1b', 'g2'});
% rename the third gene, so that g1 is listed twice
toyModel.genes{3} = 'g1';
toyModel.grRules{3} = 'g1';

toyUpdated = updateGenes(toyModel);
assert(isequal(toyUpdated.genes, {'g0'; 'g1'; 'g2'}));
assert(isequal(toyUpdated.rules, {'x(1)'; 'x(2)'; 'x(2)'; 'x(3)'}));
assert(isequal(toyUpdated.grRules, toyModel.grRules));
assert(isequal(full(toyUpdated.rxnGeneMat), [1, 0, 0; 0, 1, 0; 0, 1, 0; 0, 0, 1]));

%return to original directory
cd(currentDir)
