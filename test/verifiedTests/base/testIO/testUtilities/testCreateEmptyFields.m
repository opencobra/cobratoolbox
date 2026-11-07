% The COBRAToolbox: testCreateEmptyFields.m
%
% Purpose:
%     - createEmptyFields adds the named fields to a model, filled with the default value of their
%       definition and sized by the fields their dimensions refer to (a dimension that refers to
%       a field the model lacks is 0, an undefined dimension is 1). The definitions of the
%       toolbox are used unless fieldDefinitions are given. A field that exists already is
%       overwritten with the defaults.
%       Characterization test that PINS the current behaviour (feature
%       20261102-142225-tier2-test-pilot, Constitution Principle III characterization mode);
%       it must not change the function under test.
%     - Reference values: none are needed; the sizes follow from the field definitions and the
%       model, and the defaults are those of src/base/io/definitions/COBRA_structure_fields.tab.
%
% Function under test:
%     src/base/io/utilities/createEmptyFields.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - model manipulation, no solver; ecoli_core_model loaded through getDistributedModel.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: A field whose default refers to another field the model lacks cannot be created
%       SEVERITY: error
%       TRIGGER: createEmptyFields(model, 'proteinNames') on a model with genes but without
%         proteins, for example ecoli_core_model
%       OBSERVED: the default model.proteins{i} is evaluated and the call stops with
%         Unrecognized field name "proteins"
%       EXPECTED: the field created, as the help text states for every field defined in the
%         toolbox (for example with empty entries, or after creating proteins first)
%       LINES: 82, 86
%     - DEFECT: The default of comps cannot be evaluated
%       SEVERITY: error
%       TRIGGER: createEmptyFields(model, 'comps') on a model that has comps
%       OBSERVED: the default ['C' num2str{i}] of the field definitions brace-indexes a function
%         call and the call stops with a MATLAB error; without comps in the model the dimension is
%         0 and the default is never evaluated
%       EXPECTED: identifiers C1, C2, ... as for the other identifier fields
%       LINES: 82, 86
%     - DEFECT: A cell field with a computed default fills only its first column
%       SEVERITY: limitation
%       TRIGGER: fieldDefinitions for a cell field with two dimensions above 1 and a default
%         other than '', for example {'rxnGeneLabels', 'rxns', 'genes', '', '''x''', false,
%         'cell', false}
%       OBSERVED: the default is assigned to the first xdim linear entries only, so 95 of the
%         95 x 137 entries are 'x' and the rest stay empty; a default of '' fills every entry
%       EXPECTED: every entry set to the default
%       LINES: 85-88
%
% Authors:
%     - Generated for feature 20261102-142225-tier2-test-pilot, 2026-11-02.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testCreateEmptyFields'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox or
% particular operating system, so none is listed
prepareTest();

% load the model once (95 reactions, 72 metabolites, 137 genes, compartments c and e)
model = getDistributedModel('ecoli_core_model.mat');
nRxns = numel(model.rxns);
nMets = numel(model.mets);
nGenes = numel(model.genes);

%% a single field name given as text, with a default computed from another field

emptyModel = createEmptyFields(rmfield(model, 'metNames'), 'metNames');

% metNames has one entry per metabolite, each set to the metabolite identifier; the other
% fields are unchanged
assert(isequal(emptyModel.metNames, model.mets));
assert(isequal(rmfield(emptyModel, 'metNames'), rmfield(model, 'metNames')));

%% cell fields: an empty-text default and computed defaults

fieldNames = {'rules', 'metFormulas', 'rxnNames', 'subSystems'};
emptyModel = createEmptyFields(rmfield(model, fieldNames), fieldNames);

% the fields have one row per reaction or metabolite
assert(isequal(size(emptyModel.rules), [nRxns, 1]) && isequal(size(emptyModel.rxnNames), [nRxns, 1]));
assert(isequal(size(emptyModel.subSystems), [nRxns, 1]));
assert(isequal(size(emptyModel.metFormulas), [nMets, 1]));

% the default '' fills every entry; rxnNames defaults to the reaction identifiers; subSystems
% defaults to a cell holding '' for every reaction
assert(all(cellfun(@(x) ischar(x) && isempty(x), emptyModel.rules)));
assert(all(cellfun(@(x) ischar(x) && isempty(x), emptyModel.metFormulas)));
assert(isequal(emptyModel.rxnNames, model.rxns));
assert(all(cellfun(@(x) isequal(x, {''}), emptyModel.subSystems)));

% the fields that were not named are unchanged
assert(isequal(rmfield(emptyModel, fieldNames), rmfield(model, fieldNames)));

%% numeric and character fields, including a field without dimensions

fieldNames = {'lb', 'metCharges', 'csense', 'osenseStr'};
emptyModel = createEmptyFields(rmfield(model, {'lb', 'csense', 'osenseStr'}), fieldNames);

% the numeric defaults are -1000 for lb and NaN for metCharges, one entry per reaction or
% metabolite (constants of the definitions, so equality is exact)
assert(isequal(emptyModel.lb, -1000 * ones(nRxns, 1)));
assert(isequal(size(emptyModel.metCharges), [nMets, 1]) && all(isnan(emptyModel.metCharges)));

% csense is a character column of 'E'; osenseStr has no dimensions, which count as 1, so it is
% the default text 'max'
assert(isequal(emptyModel.csense, repmat('E', nMets, 1)));
assert(isequal(emptyModel.osenseStr, 'max'));

%% sparse and sparse-logical fields; a dimension that refers to a missing field is 0

fieldNames = {'rxnGeneMat', 'C', 'E', 'd'};
emptyModel = createEmptyFields(rmfield(model, 'rxnGeneMat'), fieldNames);

% rxnGeneMat is a sparse logical reactions x genes matrix without entries
assert(issparse(emptyModel.rxnGeneMat) && islogical(emptyModel.rxnGeneMat));
assert(isequal(size(emptyModel.rxnGeneMat), [nRxns, nGenes]) && nnz(emptyModel.rxnGeneMat) == 0);

% the model has no ctrs and no evars, so C is 0 x reactions, E is metabolites x 0 and d is 0 x 1
assert(issparse(emptyModel.C) && isequal(size(emptyModel.C), [0, nRxns]));
assert(issparse(emptyModel.E) && isequal(size(emptyModel.E), [nMets, 0]));
assert(isequal(size(emptyModel.d), [0, 1]));

%% an existing field is overwritten with the defaults

emptyModel = createEmptyFields(model, {'lb', 'rules'});

% the bounds and rules of the model are replaced; everything else is unchanged
assert(isequal(emptyModel.lb, -1000 * ones(nRxns, 1)));
assert(all(cellfun(@isempty, emptyModel.rules)) && numel(emptyModel.rules) == nRxns);
assert(isequal(rmfield(emptyModel, {'lb', 'rules'}), rmfield(model, {'lb', 'rules'})));

%% explicit field definitions create fields the toolbox does not define

% the columns of a definition are those returned by getDefinedFieldProperties: name, first and
% second dimension, check, default, basic flag, type, FBA flag
fieldDefinitions = {'rxnScore', 'rxns', NaN, '', 7, false, 'numeric', false; ...
    'geneFlag', NaN, 'genes', '', 1, false, 'sparselogical', false; ...
    'unusedLabels', 'noSuchField', 'noOtherField', '', '''x''', false, 'cell', false};
emptyModel = createEmptyFields(model, {'rxnScore', 'geneFlag', 'unusedLabels'}, fieldDefinitions);

% a dimension NaN counts as 1, a field name gives that field's length, and a missing field 0
assert(isequal(emptyModel.rxnScore, 7 * ones(nRxns, 1)));
assert(issparse(emptyModel.geneFlag) && islogical(emptyModel.geneFlag));
assert(isequal(size(emptyModel.geneFlag), [1, nGenes]) && all(emptyModel.geneFlag));
assert(iscell(emptyModel.unusedLabels) && isequal(size(emptyModel.unusedLabels), [0, 0]));

% empty field definitions fall back to the definitions of the toolbox
assert(isequal(createEmptyFields(model, {'lb'}, {}), createEmptyFields(model, {'lb'})));

%% field names without a definition stop the call

% an empty list of names gives no definition at all
assert(verifyCobraFunctionError('createEmptyFields', 'inputs', {model, {}}, ...
    'testMessage', 'Supplied Field name invalid.'));

% a name the toolbox does not define is rejected by getDefinedFieldProperties
assert(verifyCobraFunctionError('createEmptyFields', 'inputs', {model, {'noSuchField'}}));

% change the directory
cd(currentDir)
