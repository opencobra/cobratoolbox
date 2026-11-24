% The COBRAToolbox: testAddGenes.m
%
% Purpose:
%     - addGenes(model, geneIDs, fieldName, value, ...) appends genes to a model. Values given
%       for gene fields extend an existing field, or create a field defined in
%       COBRA_structure_fields.tab with its default for the old genes; rxnGeneMat and fields
%       that are neither defined nor present are skipped with a warning. All other gene
%       fields are extended with their defaults (rxnGeneMat gets empty columns). Duplicate
%       ids, ids already in the model and values of the wrong size are errors.
%     - Expected values come from the documentation and the defaults of
%       COBRA_structure_fields.tab (proteins 'COBRAProtein<i>', geneNames model.genes{i}).
%
% Function under test:
%     src/reconstruction/refinement/addGenes.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - hand-built models (createModel); no solver.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: A single gene id given as a character array is stored as a column of characters
%       SEVERITY: limitation
%       TRIGGER: addGenes(model, 'g5') for a model with genes {'g1'}
%       OBSERVED: (R2025a, 2026-11-23) model.genes becomes {'g1'; ['g'; '5']}: columnVector turns
%         the char id into a 2 x 1 char array, which is appended as one cell
%       EXPECTED: model.genes = {'g1'; 'g5'} ("Add Genes (or a single gene)"); the documented
%         form, a cell array of ids, works and is tested below
%       LINES: 54
%     - DEFECT: The error messages name reactions instead of genes
%       SEVERITY: cosmetic
%       TRIGGER: addGenes(model, {'g1'}) with g1 in the model; addGenes(model,
%         {'g3', 'g4', 'g5'}, 'geneNames', {'a', 'b'})
%       OBSERVED: (R2025a, 2026-11-23) "Duplicate Reaction ID detected." and "Size of field
%         geneNames does not fit to the rxnList size"
%       EXPECTED: messages about gene ids and the size of the gene list
%       LINES: 40, 66
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-23.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testAddGenes'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% three reactions, four metabolites and two genes, so that the gene counts used below (2 and
% 5) never equal the size of another type
baseModel = createModel({'R1', 'R2', 'R3'}, {'R1', 'R2', 'R3'}, ...
    {'a[c] -> b[c]', 'b[c] -> c[c] + d[c]', 'd[c] -> '}, 'grRuleList', {'g1', 'g2', ''}, ...
    'printLevel', 0);
baseModel.geneNames = {'N1'; 'N2'};
assert(isequal(baseModel.genes, {'g1'; 'g2'}) && ~isfield(baseModel, 'proteins'));
assert(isequal(size(baseModel.rxnGeneMat), [3, 2]));

%% three genes with an existing and a new defined field; skipped fields warn

lastwarn('');
model = addGenes(baseModel, {'g3', 'g4', 'g5'}, 'geneNames', {'N3', 'N4', 'N5'}, ...
    'proteins', {'P3'; 'P4'; 'P5'}, 'rxnGeneMat', [1, 1, 1], 'unknownField', [1, 2, 3]);
assert(isequal(model.genes, {'g1'; 'g2'; 'g3'; 'g4'; 'g5'}));
% an existing field is extended with the given values
assert(isequal(model.geneNames, {'N1'; 'N2'; 'N3'; 'N4'; 'N5'}));
% a defined field that was absent is created: its default 'COBRAProtein<i>' for old genes
assert(isequal(model.proteins, {'COBRAProtein1'; 'COBRAProtein2'; 'P3'; 'P4'; 'P5'}));
% rxnGeneMat is not set from the input: three empty columns; the old ones are kept
assert(isequal(size(model.rxnGeneMat), [3, 5]) && nnz(model.rxnGeneMat(:, 3:5)) == 0);
assert(isequal(full(model.rxnGeneMat(:, 1:2)), full(baseModel.rxnGeneMat)));
% an undefined absent field is not created; the last skipped field gives the last warning
assert(~isfield(model, 'unknownField'));
assert(strcmp(lastwarn, 'Field unknownField is excluded.'));
% the rules do not change
assert(isequal(model.rules, baseModel.rules) && isequal(model.grRules, baseModel.grRules));

%% genes without further fields: every gene field gets its default

model = addGenes(baseModel, {'g3'});
assert(isequal(model.genes, {'g1'; 'g2'; 'g3'}));
assert(isequal(model.geneNames, {'N1'; 'N2'; 'g3'}));
assert(isequal(size(model.rxnGeneMat), [3, 3]));

%% a model without a genes field: the field is created

noGeneModel = rmfield(baseModel, {'genes', 'rxnGeneMat', 'geneNames'});
model = addGenes(noGeneModel, {'gA', 'gB'});
assert(isequal(model.genes, {'gA'; 'gB'}));

%% duplicate ids, ids in the model and values of the wrong size are errors

assert(verifyCobraFunctionError('addGenes', 'inputs', {baseModel, {'g1'}}, ...
    'testMessage', 'Duplicate Reaction ID detected.'));
assert(verifyCobraFunctionError('addGenes', 'inputs', {baseModel, {'g7', 'g7'}}, ...
    'testMessage', 'Duplicate Reaction ID detected.'));
% a value fits when one of its dimensions equals the number of genes: two names for three
% genes do not
assert(verifyCobraFunctionError('addGenes', 'inputs', ...
    {baseModel, {'g3', 'g4', 'g5'}, 'geneNames', {'a', 'b'}}, ...
    'testMessage', 'Size of field geneNames does not fit to the rxnList size'));

% change the directory
cd(currentDir)
