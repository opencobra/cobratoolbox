% The COBRAToolbox: testUpdateFieldOrderForType.m
%
% Purpose:
%     - updateFieldOrderForType reorders every model field associated with one type (rxns,
%       mets, genes or comps) by the given order: rows of the fields of that type, columns of
%       S for reactions, rows of S for metabolites, rows or columns of rxnGeneMat; for genes it
%       also renumbers the gene indices in the rules. Other fields are not changed. An order
%       with an index outside the field or an unknown type is rejected with an error.
%       Characterization test that PINS the current behaviour (feature
%       20261102-142225-tier2-test-pilot, Constitution Principle III characterization mode);
%       it must not change the function under test.
%     - Reference values: none. Every expected value is derived from the input model and the
%       order given (ecoli_core_model, 2026-11-02, no solver).
%
% Function under test:
%     src/reconstruction/refinement/updateFieldOrderForType.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - model manipulation, no solver; ecoli_core_model loaded through getDistributedModel.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The type proteins is accepted but always stops with an error
%       SEVERITY: unusable-option
%       TRIGGER: updateFieldOrderForType(model, 'proteins', newOrder) on a model with a proteins
%         field
%       OBSERVED: the input check accepts proteins, but getModelFieldsForType does not know the
%         type and stops with "The value of 'type' is invalid"
%       EXPECTED: the protein fields reordered, or proteins rejected by the input check of this
%         function (the help text lists only rxns, mets, comps and genes)
%       LINES: 30, 35
%     - DEFECT: An order that repeats indices is accepted
%       SEVERITY: limitation
%       TRIGGER: a newOrder of the right size whose entries are valid indices but not a
%         permutation, for example ones(numel(model.rxns), 1) for rxns
%       OBSERVED: the input check only tests that every entry is a valid index, so the call
%         returns a model whose reactions are all copies of the first reaction
%       EXPECTED: an error, because newOrder is documented as a new order of the field
%       LINES: 31
%
% Authors:
%     - Generated for feature 20261102-142225-tier2-test-pilot, 2026-11-02.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testUpdateFieldOrderForType'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox or
% particular operating system, so none is listed
prepareTest();

% load the model once (95 reactions, 72 metabolites, 137 genes, compartments c and e)
model = getDistributedModel('ecoli_core_model.mat');

% the reaction-, metabolite- and gene-sized fields of ecoli_core_model (besides S and
% rxnGeneMat, which have two dimensions)
rxnFields = {'rxns', 'lb', 'ub', 'c', 'rules', 'grRules', 'rxnNames', 'subSystems'};
metFields = {'mets', 'b', 'csense', 'metNames', 'metFormulas'};
geneFields = {'genes'};

%% reactions: every reaction field, the columns of S and the rows of rxnGeneMat are reordered

newOrder = numel(model.rxns):-1:1;
permutedModel = updateFieldOrderForType(model, 'rxns', newOrder);

% every reaction field, the columns of S and the rows of rxnGeneMat follow the new order
assert(all(cellfun(@(f) isequal(permutedModel.(f), model.(f)(newOrder, :)), rxnFields)));
assert(isequal(permutedModel.S, model.S(:, newOrder)));
assert(isequal(permutedModel.rxnGeneMat, model.rxnGeneMat(newOrder, :)));

% the rules are moved with their reactions but not rewritten, because the genes keep their order
assert(isequal(permutedModel.rules, model.rules(newOrder)));

% every other field (metabolite, gene and model-level fields) is unchanged, and no field is
% added or lost
otherFields = setdiff(fieldnames(model), [rxnFields, {'S', 'rxnGeneMat'}]);
assert(all(cellfun(@(f) isequal(permutedModel.(f), model.(f)), otherFields)));
assert(isequal(sort(fieldnames(permutedModel)), sort(fieldnames(model))));

%% metabolites: every metabolite field and the rows of S are reordered

% a cyclic shift, so that no metabolite keeps its position
newOrder = [2:numel(model.mets), 1];
permutedModel = updateFieldOrderForType(model, 'mets', newOrder);

% every metabolite field and the rows of S follow the new order
assert(all(cellfun(@(f) isequal(permutedModel.(f), model.(f)(newOrder, :)), metFields)));
assert(isequal(permutedModel.S, model.S(newOrder, :)));

% every other field is unchanged
otherFields = setdiff(fieldnames(model), [metFields, {'S'}]);
assert(all(cellfun(@(f) isequal(permutedModel.(f), model.(f)), otherFields)));

%% genes: the gene list, the columns of rxnGeneMat and the gene indices of the rules change

newOrder = numel(model.genes):-1:1;
permutedModel = updateFieldOrderForType(model, 'genes', newOrder);

% the gene list and the columns of rxnGeneMat follow the new order
assert(all(cellfun(@(f) isequal(permutedModel.(f), model.(f)(newOrder, :)), geneFields)));
assert(isequal(permutedModel.rxnGeneMat, model.rxnGeneMat(:, newOrder)));

% the rules are renumbered: written with gene names, every rule is the rule of the input
% model, so every GPR is unchanged; the gene names in grRules are not touched
permutedGenes = permutedModel.genes;
inputGenes = model.genes;
namedRules = regexprep(permutedModel.rules, 'x\((\d+)\)', '${permutedGenes{str2double($1)}}');
expectedNamedRules = regexprep(model.rules, 'x\((\d+)\)', '${inputGenes{str2double($1)}}');
assert(isequal(namedRules, expectedNamedRules));
assert(isequal(permutedModel.grRules, model.grRules));

% the renumbered rules agree with rxnGeneMat: each rule uses exactly the genes of its row
for k = 1:numel(permutedModel.rxns)
    ruleGeneIdx = unique(str2double(regexp(permutedModel.rules{k}, '(?<=x\()\d+(?=\))', 'match')));
    assert(isequal(reshape(ruleGeneIdx, [], 1), reshape(find(permutedModel.rxnGeneMat(k, :)), [], 1)));
end

% every reaction and metabolite field is unchanged except the rules
otherFields = setdiff(fieldnames(model), [geneFields, {'rxnGeneMat', 'rules'}]);
assert(all(cellfun(@(f) isequal(permutedModel.(f), model.(f)), otherFields)));

%% genes of a model without rules: only the gene fields are reordered

modelWithoutRules = rmfield(model, 'rules');
newOrder = numel(model.genes):-1:1;
permutedModel = updateFieldOrderForType(modelWithoutRules, 'genes', newOrder);

% the gene list and rxnGeneMat are reordered and no rules field is created
assert(isequal(permutedModel.genes, model.genes(newOrder)));
assert(isequal(permutedModel.rxnGeneMat, model.rxnGeneMat(:, newOrder)));
assert(~isfield(permutedModel, 'rules'));

%% compartments: the compartment fields are reordered

% ecoli_core_model has no compartment fields; add the two compartments of its metabolites
modelWithComps = model;
modelWithComps.comps = {'c'; 'e'};
modelWithComps.compNames = {'cytosol'; 'extracellular space'};
permutedModel = updateFieldOrderForType(modelWithComps, 'comps', [2, 1]);

% both compartment fields are swapped and every other field is unchanged
assert(isequal(permutedModel.comps, {'e'; 'c'}));
assert(isequal(permutedModel.compNames, {'extracellular space'; 'cytosol'}));
assert(isequal(rmfield(permutedModel, {'comps', 'compNames'}), model));

%% the identity order returns the model unchanged

assert(isequal(updateFieldOrderForType(model, 'rxns', 1:numel(model.rxns)), model));
assert(isequal(updateFieldOrderForType(model, 'mets', 1:numel(model.mets)), model));
assert(isequal(updateFieldOrderForType(model, 'genes', 1:numel(model.genes)), model));

%% invalid orders and types are rejected with an error

% an index outside the field
assert(verifyCobraFunctionError('updateFieldOrderForType', 'inputs', ...
    {model, 'rxns', [0, 2:numel(model.rxns)]}));
assert(verifyCobraFunctionError('updateFieldOrderForType', 'inputs', ...
    {model, 'mets', [2:numel(model.mets), numel(model.mets) + 1]}));

% an order that is shorter than the field (documented: it must have the size of the field)
assert(verifyCobraFunctionError('updateFieldOrderForType', 'inputs', {model, 'rxns', 1:10}));

% a type that is not one of rxns, mets, comps and genes
assert(verifyCobraFunctionError('updateFieldOrderForType', 'inputs', ...
    {model, 'reactions', 1:numel(model.rxns)}));

% a type whose field is not in the model
assert(verifyCobraFunctionError('updateFieldOrderForType', 'inputs', {model, 'comps', [1, 2]}));

% change the directory
cd(currentDir)
