% The COBRAToolbox: testDeleteProtons.m
%
% Purpose:
%     - tests the deleteProtons function using the DAS network and a toy network with genes
%
% Function under test:
%     src/dataIntegration/chemoInformatics/deleteProtons.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - model manipulation, no solver; the toy network is hand-built.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Reactions that carried only protons are removed from the reaction fields but not from S
%       SEVERITY: wrong-result
%       TRIGGER: a model with a reaction whose only metabolites are protons, such as a proton transport
%       OBSERVED: the reaction is removed from rxns, lb, ub and the other reaction vectors, but its
%         column stays in S and rxnGeneMat as zeros, so the number of columns of S no longer equals the
%         number of reactions
%       EXPECTED: the column deleted from S and rxnGeneMat as well, as the help says the output has no
%         proton transport reactions
%       LINES: 43, 45, 50
%
% Authors:
%     - German Preciat -- August 2017
%     - Coverage completed by feature 20261104-115314-test-coverage-100, 2026-11-04.

% save the current path
currentDir = pwd;

% initialize the test
cd(fileparts(which('testDeleteProtons')));

% this test needs no solver, toolbox or particular operating system
prepareTest();

% Load reference data
load('refData_deleteProtons.mat')

% load the dopamine synthesis model
modelDir = getDistributedModelFolder('subDas.mat');
model = load([modelDir filesep 'subDas.mat']);
if isfield(model,'model')
    model=model.model;
end
%model = readCbModel('subDas.mat');

modelNew = deleteProtons(model);
assert(all(all(modelNew.S == modelNew0.S)), 'Reference S matrix does not match.')
assert(all(all(modelNew.S == modelNew0.S)), 'Reference metabolites do not match.')
assert(all(all(modelNew.S == modelNew0.S)), 'Reference metabolites formulas do not match.')
assert(all(all(modelNew.S == modelNew0.S)), 'Reference metabolites charges do not match.')

%% a model with genes keeps its reaction-gene matrix
% two protons in a linear pathway: no reaction consists of protons only, so only the proton
% rows and metabolite entries may change. The sizes differ (5 metabolites, 3 reactions,
% 2 genes) so that no field is mistaken for a field of another length.
toyModel = struct();
toyModel.mets = {'a[c]'; 'h[c]'; 'b[c]'; 'c[c]'; 'd[c]'};
toyModel.metFormulas = {'C2H4O'; 'H'; 'C2H5O'; 'C2H3O'; 'C2H4'};
toyModel.rxns = {'r1'; 'r2'; 'r3'};
toyModel.lb = [0; -10; 0];
toyModel.ub = [10; 10; 10];
toyModel.S = sparse([-1 0 0; -1 0 1; 1 -1 0; 0 1 -1; 0 0 1]);
toyModel.genes = {'g1'; 'g2'};
toyModel.rxnGeneMat = sparse([1 0; 0 1; 1 1]);

toyNew = deleteProtons(toyModel);

% the proton row and its metabolite entries are gone, the other rows are intact
assert(isequal(toyNew.mets, {'a[c]'; 'b[c]'; 'c[c]'; 'd[c]'}));
assert(isequal(toyNew.metFormulas, {'C2H4O'; 'C2H5O'; 'C2H3O'; 'C2H4'}));
assert(isequal(full(toyNew.S), full(toyModel.S([1 3 4 5], :))));
% the reaction fields are unchanged, and so is the gene association (sparse as in the input)
assert(isequal(toyNew.rxns, toyModel.rxns));
assert(isequal(toyNew.lb, toyModel.lb) && isequal(toyNew.ub, toyModel.ub));
assert(issparse(toyNew.rxnGeneMat));
assert(isequal(full(toyNew.rxnGeneMat), full(toyModel.rxnGeneMat)));

%% a dense reaction-gene matrix comes back sparse
toyModel.rxnGeneMat = full(toyModel.rxnGeneMat);
toyNew = deleteProtons(toyModel);
assert(issparse(toyNew.rxnGeneMat));
assert(isequal(full(toyNew.rxnGeneMat), toyModel.rxnGeneMat));

% change the directory
cd(currentDir)