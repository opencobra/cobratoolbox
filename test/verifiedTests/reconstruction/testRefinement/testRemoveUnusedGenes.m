% The COBRAToolbox: testRemoveUnusedGenes.m
%
% Purpose:
%     - [modelNew, unusedGenes] = removeUnusedGenes(model) removes the genes that no reaction
%       uses (all-zero columns of rxnGeneMat), with the gene fields (genes, geneNames,
%       rxnGeneMat) and the indices in rules updated; missing rules and rxnGeneMat fields are
%       built from grRules and rules, and a model without genes gets them from grRules (with a
%       warning). Expected values are read from the hand-built gene-reaction rules.
%
% Function under test:
%     src/reconstruction/refinement/removeUnusedGenes.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - model manipulation on a hand-built model with three reactions and four genes; no
%     solver (the ledger listed the row as Tier 3; the function calls no solver).
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-25.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testRemoveUnusedGenes'));
cd(fileDir);

prepareTest();

% hand-built model: R1 needs g1 and g2, R2 has no rule, R3 needs g4; g3 is used by no reaction
model.S = sparse([-1 0 0; 1 -1 0; 0 1 -1]);
model.mets = {'A'; 'B'; 'C'};
model.rxns = {'R1'; 'R2'; 'R3'};
model.lb = zeros(3, 1);
model.ub = 10 * ones(3, 1);
model.c = [0; 0; 1];
model.b = zeros(3, 1);
model.csense = repmat('E', 3, 1);
model.osenseStr = 'max';
model.genes = {'g1'; 'g2'; 'g3'; 'g4'};
model.geneNames = {'gene one'; 'gene two'; 'gene three'; 'gene four'};
model.grRules = {'g1 and g2'; ''; 'g4'};
model.rules = {'x(1) & x(2)'; ''; 'x(4)'};
model.rxnGeneMat = sparse([1 1 0 0; 0 0 0 0; 0 0 0 1]);

% the genes each rule refers to, as names, read from the x(i) indices of the rules
ruleGenes = @(m) cellfun(@(r) m.genes(cellfun(@str2double, regexp(r, '(?<=x\()\d+(?=\))', 'match'))), ...
    m.rules, 'UniformOutput', false);
% the expected rule genes: g1 and g2 for R1, none for R2, g4 for R3
expectedRuleGenes = @(names) isequal(names{1}, {'g1'; 'g2'}) && isempty(names{2}) && isequal(names{3}, {'g4'});

%% complete gene fields: g3 is removed and the rules point to the renumbered genes
[modelNew, unusedGenes] = removeUnusedGenes(model);
assert(isequal(unusedGenes, {'g3'}));
assert(isequal(modelNew.genes, {'g1'; 'g2'; 'g4'}));
assert(isequal(modelNew.geneNames, {'gene one'; 'gene two'; 'gene four'}));
assert(isequal(full(modelNew.rxnGeneMat), [1 1 0; 0 0 0; 0 0 1]));
assert(expectedRuleGenes(ruleGenes(modelNew)));
% the reaction and metabolite fields are untouched
assert(isequal(modelNew.S, model.S) && isequal(modelNew.rxns, model.rxns) && isequal(modelNew.grRules, model.grRules));

%% no rxnGeneMat: it is built from the rules, with the same result
[modelNew, unusedGenes] = removeUnusedGenes(rmfield(model, 'rxnGeneMat'));
assert(isequal(unusedGenes, {'g3'}));
assert(isequal(modelNew.genes, {'g1'; 'g2'; 'g4'}));
assert(isequal(full(modelNew.rxnGeneMat), [1 1 0; 0 0 0; 0 0 1]));
assert(expectedRuleGenes(ruleGenes(modelNew)));

%% no rules and no rxnGeneMat: the rules are built from grRules, with the same result
[modelNew, unusedGenes] = removeUnusedGenes(rmfield(model, {'rules', 'rxnGeneMat'}));
assert(isequal(unusedGenes, {'g3'}));
assert(isequal(modelNew.genes, {'g1'; 'g2'; 'g4'}));
assert(isequal(full(modelNew.rxnGeneMat), [1 1 0; 0 0 0; 0 0 1]));
assert(expectedRuleGenes(ruleGenes(modelNew)));

%% no gene fields at all: a warning, and the genes are those of grRules, none of them unused
% (the warning 'Model did not contain a genes field...' is expected here)
modelWithoutGenes = rmfield(model, {'genes', 'geneNames', 'rules', 'rxnGeneMat'});
[modelNew, unusedGenes] = removeUnusedGenes(modelWithoutGenes);
assert(isempty(unusedGenes));
assert(isequal(sort(modelNew.genes), {'g1'; 'g2'; 'g4'}));
assert(expectedRuleGenes(ruleGenes(modelNew)));
assert(isequal(full(modelNew.rxnGeneMat ~= 0), [ismember(modelNew.genes', {'g1', 'g2'}); false(1, 3); strcmp(modelNew.genes', 'g4')]));

% change the directory
cd(currentDir)
