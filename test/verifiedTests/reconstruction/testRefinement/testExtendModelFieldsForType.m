% The COBRAToolbox: testExtendModelFieldsForType.m
%
% Purpose:
%     - extendModelFieldsForType(model, type, ...) extends every field associated with a type
%       (rxns, mets, genes, ...) from originalSize (default numel(model.(type)) - 1) to
%       targetSize (default numel(model.(type))) entries. Standard fields get the default of
%       COBRA_structure_fields.tab (e.g. lb -1000, ub 1000, rxnNames = the new reaction id,
%       csense 'E'); other fields get '' (cell), 0 (numeric), false (logical), ' ' (char) or
%       a default table row (NaN, '' and false); struct fields are removed (with a warning,
%       except pseudoisomers); fields with no entry in any dimension are resized only. The
%       test appends ids to a hand-built model and checks every extended field against these
%       values, the excludeFields, originalSize and targetSize options and the errors.
%
% Function under test:
%     src/reconstruction/refinement/extendModelFieldsForType.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - hand-built models (createModel); no solver.
%
% Coverage exemptions:
%     Lines 146-148: unreachable by any input; they are inside "if 0" (debugging code).
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-23.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testExtendModelFieldsForType'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% two reactions, four metabolites and three genes, so that no other type has the size of
% the reactions (2) and fields are associated by size alone
baseModel = createModel({'R1', 'R2'}, {'n1', 'n2'}, {'a[c] -> b[c]', 'b[c] -> c[c] + d[c]'}, ...
    'grRuleList', {'g1', 'g2 and g3'}, 'printLevel', 0);
assert(numel(baseModel.mets) == 4 && numel(baseModel.genes) == 3);

% fields without a definition in COBRA_structure_fields.tab, one per kind
baseModel.rxnCustomCell = {'x'; 'y'};
baseModel.rxnCustomNum = [5; 6];
baseModel.rxnCustomLogical = [true; true];
baseModel.rxnCustomChar = 'pq';
baseModel.rxnCustomTable = table([1; 2], {'u'; 'v'}, [true; false], ...
    'VariableNames', {'num', 'txt', 'flag'});
baseModel.rxnCustomStruct = struct('s', {1; 2});
baseModel.pseudoisomers = struct('s', {1; 2});

%% a third reaction id is appended: every reaction field gets one default entry

model = baseModel;
model.rxns{3, 1} = 'R3';
lastwarn('');
model = extendModelFieldsForType(model, 'rxns');
% defined fields: S gets a zero column (sparse), the bounds and c the defaults
assert(issparse(model.S) && isequal(size(model.S), [4, 3]) && nnz(model.S(:, 3)) == 0);
assert(isequal(model.S(:, 1:2), baseModel.S));
assert(isequal(model.lb, [baseModel.lb; -1000]) && isequal(model.ub, [baseModel.ub; 1000]));
assert(isequal(model.c, [baseModel.c; 0]));
% cell defaults: '' for rules and grRules, the reaction id for rxnNames (model.rxns{i})
assert(isequal(model.rules, [baseModel.rules; {''}]));
assert(isequal(model.grRules, [baseModel.grRules; {''}]));
assert(isequal(model.rxnNames, {'n1'; 'n2'; 'R3'}));
assert(isequal(model.subSystems{3}, {''}));
% rxnGeneMat (sparse logical in the definitions) gets an empty row
assert(isequal(size(model.rxnGeneMat), [3, 3]) && nnz(model.rxnGeneMat(3, :)) == 0);
assert(isequal(full(model.rxnGeneMat(1:2, :)), full(baseModel.rxnGeneMat)));
% undefined fields: '' (cell), 0 (numeric), false (logical), ' ' (char, second dimension)
assert(isequal(model.rxnCustomCell, {'x'; 'y'; ''}));
assert(isequal(model.rxnCustomNum, [5; 6; 0]));
assert(isequal(full(model.rxnCustomLogical), [true; true; false]));
assert(islogical(model.rxnCustomLogical));
assert(isequal(model.rxnCustomChar, 'pq '));
% a table gets a default row: NaN for numbers, '' in cells, false for logicals
assert(height(model.rxnCustomTable) == 3);
assert(isequal(model.rxnCustomTable(1:2, :), baseModel.rxnCustomTable));
assert(isnan(model.rxnCustomTable.num(3)));
assert(isequal(model.rxnCustomTable.txt{3}, ''));
assert(isequal(model.rxnCustomTable.flag(3), false));
% struct fields are removed; only rxnCustomStruct raises the (visible) warning
assert(~isfield(model, 'rxnCustomStruct') && ~isfield(model, 'pseudoisomers'));
assert(strcmp(lastwarn, 'Cannot extend field, so removing it: rxnCustomStruct'));
% fields of other types are unchanged
assert(isequal(model.mets, baseModel.mets) && isequal(model.genes, baseModel.genes));
assert(isequal(model.b, baseModel.b) && isequal(model.csense, baseModel.csense));

%% excludeFields: the listed fields keep their size

model = baseModel;
model = rmfield(model, {'rxnCustomStruct', 'pseudoisomers'});
model.rxns{3, 1} = 'R3';
model = extendModelFieldsForType(model, 'rxns', 'excludeFields', {'rxnCustomNum', 'lb'});
assert(isequal(model.rxnCustomNum, [5; 6]) && isequal(model.lb, baseModel.lb));
assert(isequal(model.ub, [baseModel.ub; 1000]));

%% originalSize and targetSize: two reactions appended at once

model = baseModel;
model = rmfield(model, {'rxnCustomStruct', 'pseudoisomers'});
model.rxns(3:4, 1) = {'R3'; 'R4'};
model = extendModelFieldsForType(model, 'rxns', 'originalSize', 2, 'targetSize', 4);
% the default of rxnNames is evaluated for each new index i (model.rxns{i})
assert(isequal(model.rxnNames, {'n1'; 'n2'; 'R3'; 'R4'}));
assert(isequal(model.lb, [baseModel.lb; -1000; -1000]));
assert(isequal(size(model.S), [4, 4]) && nnz(model.S(:, 3:4)) == 0);
assert(isequal(model.rxnCustomNum, [5; 6; 0; 0]));
assert(height(model.rxnCustomTable) == 4);

%% metabolites: b, csense (char 'E') and metNames are extended, S gets a zero row

model = baseModel;
model = rmfield(model, {'rxnCustomStruct', 'pseudoisomers'});
model.mets{5, 1} = 'e[c]';
model = extendModelFieldsForType(model, 'mets');
assert(isequal(size(model.S), [5, 2]) && nnz(model.S(5, :)) == 0);
assert(isequal(model.b, [baseModel.b; 0]));
assert(isequal(model.csense, [baseModel.csense; 'E']));
assert(isequal(model.metNames{5}, 'e[c]'));
% reaction fields are unchanged
assert(isequal(model.rxnCustomNum, [5; 6]) && isequal(model.lb, baseModel.lb));

%% fields with no entry in any dimension are only resized (first gene of an empty model)

% createModel() has 0 reactions and genes and a 0 x 0 sparse rxnGeneMat (genes in the
% second dimension); the custom 0 x 0 gene fields are associated in the first dimension
emptyModel = createModel();
emptyModel.geneCustomFull = zeros(0, 0);
emptyModel.geneCustomSparse = sparse(0, 0);
emptyModel.genes = {'g1'};
extendedModel = extendModelFieldsForType(emptyModel, 'genes');
assert(issparse(extendedModel.rxnGeneMat) && isequal(size(extendedModel.rxnGeneMat), [0, 1]));
assert(~issparse(extendedModel.geneCustomFull) && isequal(size(extendedModel.geneCustomFull), [1, 0]));
assert(issparse(extendedModel.geneCustomSparse) && isequal(size(extendedModel.geneCustomSparse), [1, 0]));
% a full 0 x 0 rxnGeneMat stays full
emptyModel = createModel();
emptyModel.rxnGeneMat = zeros(0, 0);
emptyModel.genes = {'g1'};
extendedModel = extendModelFieldsForType(emptyModel, 'genes');
assert(~issparse(extendedModel.rxnGeneMat) && isequal(size(extendedModel.rxnGeneMat), [0, 1]));

%% errors: a table in the second dimension, an unknown type, a model without the type

% a 1 x 2 table of a model with two reactions matches the reactions in its second dimension
model = baseModel;
model = rmfield(model, {'rxnCustomTable', 'rxnCustomStruct', 'pseudoisomers'});
model.rxnWideTable = table(1, 2);
model.rxns{3, 1} = 'R3';
assert(verifyCobraFunctionError('extendModelFieldsForType', 'inputs', {model, 'rxns'}, ...
    'testMessage', ['Requested the extension of a table field (rxnWideTable) in the second ', ...
    'dimension. This is impossible, as the type of the new Variable and its name are unknown']));
% 'proteins' is not one of the types; the model has no field 'evars'
model.proteins = {'p1'};
assert(verifyCobraFunctionError('extendModelFieldsForType', 'inputs', {model, 'proteins'}));
assert(verifyCobraFunctionError('extendModelFieldsForType', 'inputs', {model, 'evars'}));

% change the directory
cd(currentDir)
