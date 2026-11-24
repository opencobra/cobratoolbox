% The COBRAToolbox: testBuildRxnGeneMat.m
%
% Purpose:
%     - buildRxnGeneMat builds the nRxns x nGenes reaction-gene incidence matrix rxnGeneMat
%       from the rules field (x(i) gene indices): entry (i, j) is 1 when gene j appears in the
%       rule of reaction i. When rules is absent it is generated from grRules (generateRules)
%       or, without grRules, initialised as empty strings. This test checks hand-built rules
%       (and, or, parentheses, a two-digit index, empty rules), a model with grRules only
%       (genes known, and a gene not yet in genes, which generateRules adds), a model with
%       neither rules nor grRules, the replacement of an existing rxnGeneMat, a model without
%       genes, and the E. coli core model, whose rebuilt matrix must have the pattern of the
%       stored one. Expected matrices are written by hand from the rules.
%
% Function under test:
%     src/base/io/utilities/buildRxnGeneMat.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - model manipulation without a solver: hand-built models and the E. coli core
%     model (getDistributedModel, loaded once) as a consistency check on a real model.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-23.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testBuildRxnGeneMat'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

%% hand-built rules: and, or, parentheses, an empty rule and a two-digit gene index

% twelve genes so that x(12) must be read as gene 12, not as genes 1 and 2
geneIds = arrayfun(@(i) sprintf('g%d', i), 1:12, 'UniformOutput', false)';
model = struct('rxns', {{'R1'; 'R2'; 'R3'; 'R4'}}, 'genes', {geneIds}, ...
    'rules', {{'x(1) & x(2)'; '(x(3) | x(4)) & x(1)'; ''; 'x(12)'}});
out = buildRxnGeneMat(model);
expected = zeros(4, 12);
expected(1, [1 2]) = 1;
expected(2, [1 3 4]) = 1;
expected(4, 12) = 1;
% the matrix is sparse, sized nRxns x nGenes, and holds exactly the genes of each rule
% (integer values, so exact equality)
assert(issparse(out.rxnGeneMat));
assert(isequal(size(out.rxnGeneMat), [4 12]));
assert(isequal(full(out.rxnGeneMat), expected));
% the rules are not changed
assert(isequal(out.rules, model.rules));

%% an existing rxnGeneMat is replaced, not merged

% a wrong 4 x 12 matrix with ones everywhere must be overwritten by the rules' pattern
model.rxnGeneMat = sparse(ones(4, 12));
out = buildRxnGeneMat(model);
assert(isequal(full(out.rxnGeneMat), expected));

%% grRules only, every gene already in genes: rules are generated, then the matrix is built

modelGr = struct('rxns', {{'R1'; 'R2'; 'R3'}}, 'genes', {{'gA'; 'gB'; 'gC'}}, ...
    'grRules', {{'gA or gC'; ''; 'gB and gA'}});
out = buildRxnGeneMat(modelGr);
% generateRules writes the x(i) form with the positions of the genes in genes
assert(isequal(out.rules, {'x(1) | x(3)'; ''; 'x(2) & x(1)'}));
assert(isequal(out.genes, {'gA'; 'gB'; 'gC'}));
assert(isequal(full(out.rxnGeneMat), [1 0 1; 0 0 0; 1 1 0]));

%% grRules only, with a gene that genes does not list: generateRules adds it

% generateRules warns ("Found the following genes in grRules that were not present in
% model.genes: gD") and appends gD to genes, so the matrix gets a fourth column
modelGr.grRules{2} = 'gD';
out = buildRxnGeneMat(modelGr);
assert(isequal(out.genes, {'gA'; 'gB'; 'gC'; 'gD'}));
assert(isequal(out.rules{2}, 'x(4)'));
assert(isequal(full(out.rxnGeneMat), [1 0 1 0; 0 0 0 1; 1 1 0 0]));

%% neither rules nor grRules: rules are initialised empty and the matrix is all zero

modelNone = struct('rxns', {{'R1'; 'R2'}}, 'genes', {{'g1'; 'g2'; 'g3'}});
out = buildRxnGeneMat(modelNone);
assert(isequal(out.rules, {''; ''}));
assert(isequal(size(out.rxnGeneMat), [2 3]) && nnz(out.rxnGeneMat) == 0);

%% a model without genes gets an nRxns x 0 matrix

modelNoGenes = struct('rxns', {{'R1'; 'R2'}}, 'genes', {cell(0, 1)}, 'rules', {{''; ''}});
out = buildRxnGeneMat(modelNoGenes);
assert(isequal(size(out.rxnGeneMat), [2 0]));

%% E. coli core: the rebuilt matrix has the pattern of the stored one

% the distributed model carries rules, genes and a rxnGeneMat built by the toolbox; the
% stored values may be logical or double, so the nonzero patterns are compared
ecoli = getDistributedModel('ecoli_core_model.mat');
storedPattern = ecoli.rxnGeneMat ~= 0;
ecoli = rmfield(ecoli, 'rxnGeneMat');
ecoli = buildRxnGeneMat(ecoli);
assert(isequal(size(ecoli.rxnGeneMat), [numel(ecoli.rxns), numel(ecoli.genes)]));
assert(isequal(ecoli.rxnGeneMat ~= 0, storedPattern));
clear ecoli storedPattern

% change the directory
cd(currentDir)
