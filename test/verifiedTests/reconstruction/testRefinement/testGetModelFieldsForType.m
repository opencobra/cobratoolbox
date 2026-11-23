% The COBRAToolbox: testGetModelFieldsForType.m
%
% Purpose:
%     - getModelFieldsForType lists the fields of a model that belong to a type (rxns, mets,
%       genes, ...) with the dimension in which they match. This test checks the input errors,
%       the branch for 0 or 1 elements of the type (an empty model, one-reaction and
%       one-metabolite models, with and without another type of the same size), the branch for
%       larger models (size alone decides; a square field of the type in both dimensions or,
%       when another type has the same size, resolved by the field definitions; field names
%       starting with the type, e.g. rxnXYZ for rxns), rxnNotes as a row and as a column, and
%       the fieldSize option in its positional and its name-value form.
%     - The expected lists are derived by hand from the field definitions
%       (getDefinedFieldProperties, src/base/io/definitions/COBRA_structure_fields.tab: S is
%       mets x rxns, rxnGeneMat is rxns x genes, rxns/lb/ub/c/rules/grRules/rxnNames/subSystems
%       are rxns x 1, mets/b/csense/metNames are mets x 1, genes is genes x 1) and from the
%       documented rule "fields named e.g. rxnXYZ are associated with rxns". createModel builds
%       the fields rxns, S, lb, ub, c, mets, b, rules, genes, osenseStr, csense, rxnGeneMat and,
%       when reactions are given, metNames, subSystems, grRules and rxnNames.
%     - The former defect entry (custom fields named after the type missed for a model with one
%       or no element of the type) was fixed by feature 20261120-161825-core-blocker-fixes and
%       is tested below.
%
% Function under test:
%     src/reconstruction/refinement/getModelFieldsForType.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - model manipulation without a solver, hand-built models (createModel).
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found. (Writing this test found that a non-standard square field named after the
%     type got the dimension -1 when another type had the same size, so callers such as
%     removeRxns failed with an indexing error. The maintainer chose a guiding error instead
%     (feature 20261120-161825-core-blocker-fixes): getModelFieldsForType:ambiguousField names
%     the field and points to the standard field names; tested below.)
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.
%     - Full test after the fix (feature 20261120-161825-core-blocker-fixes), 2026-11-23.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testGetModelFieldsForType'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% a result as a sorted list of 'field/dimension' entries, so that lists compare
% independently of their order (the order is not documented) and duplicates still count
pairList = @(fields, dims) sort(strcat(fields(:), '/', arrayfun(@num2str, dims(:), 'UniformOutput', false)));

% the fields of the type in the models of createModel, derived from the field definitions
rxnFieldsOfCreateModel = {'S/2'; 'rxnGeneMat/1'; 'rxns/1'; 'lb/1'; 'ub/1'; 'c/1'; 'rules/1'; ...
    'grRules/1'; 'rxnNames/1'; 'subSystems/1'};
metFieldsOfCreateModel = {'S/1'; 'mets/1'; 'b/1'; 'csense/1'; 'metNames/1'};

% the field definitions, to check that no listed defined field belongs only to another type
definedFields = getDefinedFieldProperties();
isDefinedForOtherTypeOnly = @(field, type) any(strcmp(definedFields(:, 1), field)) && ...
    ~any(cellfun(@(x) isequal(x, type), definedFields(strcmp(definedFields(:, 1), field), 2:3)));

%% input errors: a type that is not allowed, a type missing from the model, a non-numeric size

modelTwoRxns = createModel({'R1', 'R2'}, {'r1', 'r2'}, {'a -> b', 'b -> c'}, 'printLevel', 0);
% S is a field of the model, but not one of the documented types
assert(verifyCobraFunctionError('getModelFieldsForType', 'inputs', {modelTwoRxns, 'S'}));
% comps is a documented type, but the model has no comps field
assert(verifyCobraFunctionError('getModelFieldsForType', 'inputs', {modelTwoRxns, 'comps'}));
% the fieldSize option must be numeric
assert(verifyCobraFunctionError('getModelFieldsForType', 'inputs', {modelTwoRxns, 'rxns', 'x'}));

%% empty model (fieldSize 0): every type has the same size 0

% createModel() has the fields rxns, S, lb, ub, c, mets, b, rules, genes, osenseStr, csense
% and rxnGeneMat, all of size 0 in the first dimension except osenseStr ('max', 1 x 3)
emptyModel = createModel();
% rxns: the reaction fields, S in its second and rxnGeneMat in its first dimension. mets,
% b, csense and genes also have 0 rows, but are not reaction fields, so they are not listed
[fields, dims] = getModelFieldsForType(emptyModel, 'rxns');
assert(numel(fields) == numel(dims));
assert(isequal(pairList(fields, dims), sort({'S/2'; 'rxnGeneMat/1'; 'rxns/1'; 'lb/1'; 'ub/1'; 'c/1'; 'rules/1'})));
% mets: S in its first dimension and the metabolite fields
[fields, dims] = getModelFieldsForType(emptyModel, 'mets');
assert(isequal(pairList(fields, dims), sort({'S/1'; 'mets/1'; 'b/1'; 'csense/1'})));
% genes: rxnGeneMat in its second dimension and genes
[fields, dims] = getModelFieldsForType(emptyModel, 'genes');
assert(isequal(pairList(fields, dims), sort({'rxnGeneMat/2'; 'genes/1'})));

%% one-reaction model with the standard fields: only the reaction fields are listed

% 'a -> b' gives two metabolites, one reaction and no gene, so no other type has size 1
modelOneRxn = createModel({'R1'}, {'r1'}, {'a -> b'}, 'printLevel', 0);
assert(isequal(sort(fieldnames(modelOneRxn)), sort({'rxns'; 'S'; 'lb'; 'ub'; 'c'; 'mets'; 'b'; ...
    'rules'; 'genes'; 'osenseStr'; 'csense'; 'rxnGeneMat'; 'metNames'; 'subSystems'; 'grRules'; 'rxnNames'})));
[fields, dims] = getModelFieldsForType(modelOneRxn, 'rxns');
assert(isequal(pairList(fields, dims), sort(rxnFieldsOfCreateModel)));
% osenseStr ('max') also has one row, but is no reaction field; no listed field is a defined
% field of another type only
assert(~any(strcmp(fields, 'osenseStr')));
assert(~any(cellfun(@(f) isDefinedForOtherTypeOnly(f, 'rxns'), fields)));
% the two metabolites of the same model go through the branch for larger models
[fields, dims] = getModelFieldsForType(modelOneRxn, 'mets');
assert(isequal(pairList(fields, dims), sort(metFieldsOfCreateModel)));

%% one-metabolite model with the standard fields: only the metabolite fields are listed

% 'a -> ' and ' -> a' give one metabolite and two reactions, so no other type has size 1
modelOneMet = createModel({'R1', 'R2'}, {'r1', 'r2'}, {'a -> ', ' -> a'}, 'printLevel', 0);
[fields, dims] = getModelFieldsForType(modelOneMet, 'mets');
assert(isequal(pairList(fields, dims), sort(metFieldsOfCreateModel)));
assert(~any(strcmp(fields, 'osenseStr')));
assert(~any(cellfun(@(f) isDefinedForOtherTypeOnly(f, 'mets'), fields)));
[fields, dims] = getModelFieldsForType(modelOneMet, 'rxns');
assert(isequal(pairList(fields, dims), sort(rxnFieldsOfCreateModel)));

%% former defect: a custom field named after the type, for one and for two reactions

% fields named e.g. rxnXYZ are associated with rxns (documented rule); before the fix the
% branch for 0 or 1 elements required names starting with the whole type name ('rxns')
modelOneRxnCustom = modelOneRxn;
modelOneRxnCustom.rxnCustom = {'z'};
[fieldsOne, dimsOne] = getModelFieldsForType(modelOneRxnCustom, 'rxns');
assert(isequal(dimsOne(strcmp(fieldsOne, 'rxnCustom')), 1));
assert(isequal(pairList(fieldsOne, dimsOne), sort([rxnFieldsOfCreateModel; {'rxnCustom/1'}])));
% the same model with two reactions (branch for larger models) gives the same list
modelTwoRxnsCustom = modelTwoRxns;
modelTwoRxnsCustom.rxnCustom = {'z'; 'y'};
[fieldsTwo, dimsTwo] = getModelFieldsForType(modelTwoRxnsCustom, 'rxns');
assert(isequal(dimsTwo(strcmp(fieldsTwo, 'rxnCustom')), 1));
assert(isequal(pairList(fieldsOne, dimsOne), pairList(fieldsTwo, dimsTwo)));

%% one reaction: a custom field not named after the type is not listed

% with one element, many fields have one row (osenseStr, descriptions), so the branch for 0
% or 1 elements lists only defined fields and fields named after the type (comment of the
% source, lines 80-82); with two reactions the size alone decides (next section)
modelOneRxnOther = modelOneRxn;
modelOneRxnOther.otherField = {'z'};
[fields, dims] = getModelFieldsForType(modelOneRxnOther, 'rxns');
assert(isequal(pairList(fields, dims), sort(rxnFieldsOfCreateModel)));

%% one metabolite and one reaction: a non-standard 1 x 1 field named after the type

% 'a -> ' gives one metabolite and one reaction, so another type has the same size 1.
% metaData is no COBRA field, but its name starts with 'met' and its first dimension is 1,
% so it is listed as a metabolite field: this follows the documented rule ("fields named e.g.
% rxnXYZ are associated with rxns"); a field that is not a standard COBRA field is the
% user's responsibility (accepted by the maintainer, feature 20261120-161825-core-blocker-fixes)
modelOneEach = createModel({'R1'}, {'r1'}, {'a -> '}, 'printLevel', 0);
modelOneEach.metaData = struct();
[fields, dims] = getModelFieldsForType(modelOneEach, 'mets');
assert(isequal(pairList(fields, dims), sort([metFieldsOfCreateModel; {'metaData/1'}])));
% for rxns the same field is not listed, as its name does not start with 'rxn'
[fields, dims] = getModelFieldsForType(modelOneEach, 'rxns');
assert(isequal(pairList(fields, dims), sort(rxnFieldsOfCreateModel)));

%% two reactions, no other type of size 2: size decides, a square field in both dimensions

% three metabolites, two reactions, no gene: any field with one dimension of size 2 belongs
% to rxns, whatever its name; a 2 x 2 field matches in both dimensions (a rxns x rxns field)
modelSquare = modelTwoRxns;
modelSquare.otherField = [1; 2];
modelSquare.rxnPairMat = eye(2);
[fields, dims] = getModelFieldsForType(modelSquare, 'rxns');
assert(isequal(pairList(fields, dims), sort([rxnFieldsOfCreateModel; {'otherField/1'; 'rxnPairMat/1'; 'rxnPairMat/2'}])));
% the same fields do not have the size of the three metabolites
[fields, dims] = getModelFieldsForType(modelSquare, 'mets');
assert(isequal(pairList(fields, dims), sort(metFieldsOfCreateModel)));

%% two metabolites and two reactions: the definitions and the name prefix decide

% 'a -> b' and 'b -> ' give two metabolites and two reactions, so S is square and the
% metabolites have the size of the reactions. S matches in both dimensions and is resolved by
% its definition (mets x rxns); undefined fields are listed only when named after the type.
modelSameSize = createModel({'R1', 'R2'}, {'r1', 'r2'}, {'a -> b', 'b -> '}, 'printLevel', 0);
assert(isequal(size(modelSameSize.S), [2, 2]));
modelSameSize.rxnCustom = {'x'; 'y'};
modelSameSize.metCustom = {'u'; 'v'};
modelSameSize.otherField = [1; 2];
[fields, dims] = getModelFieldsForType(modelSameSize, 'rxns');
assert(isequal(pairList(fields, dims), sort([rxnFieldsOfCreateModel; {'rxnCustom/1'}])));
[fields, dims] = getModelFieldsForType(modelSameSize, 'mets');
assert(isequal(pairList(fields, dims), sort([metFieldsOfCreateModel; {'metCustom/1'}])));

% a non-standard square field named after the type (rxnPairMat, 2 x 2) has the size of rxns in
% both dimensions, and the metabolites have the same size: which dimension belongs to rxns
% cannot be determined, so the documented error names the field and points to the standard
% field names; a caller that changes the model (removeRxns) stops with the same error
modelAmbiguous = modelSameSize;
modelAmbiguous.rxnPairMat = eye(2);
errorId = '';
errorMessage = '';
try
    getModelFieldsForType(modelAmbiguous, 'rxns');
catch ME
    errorId = ME.identifier;
    errorMessage = ME.message;
end
assert(strcmp(errorId, 'getModelFieldsForType:ambiguousField'));
assert(contains(errorMessage, 'rxnPairMat') && contains(errorMessage, 'getDefinedFieldProperties') ...
    && contains(errorMessage, 'COBRAModelFields.rst'));
assert(verifyCobraFunctionError('removeRxns', 'inputs', {modelAmbiguous, 'R1'}, 'outputArgCount', 1));
% for mets, rxnPairMat is not named after the type, so it is not listed and raises nothing
[fields, dims] = getModelFieldsForType(modelAmbiguous, 'mets');
assert(isequal(pairList(fields, dims), sort([metFieldsOfCreateModel; {'metCustom/1'}])));

%% rxnNotes: listed in the dimension that has the size of rxns

% rxnNotes is defined as rxns x 1; the source always adds it to the fields it checks, so a
% row of notes is listed in its second dimension, and a column is listed once (not twice)
modelNotes = modelTwoRxns;
modelNotes.rxnNotes = {'n1', 'n2'};
[fields, dims] = getModelFieldsForType(modelNotes, 'rxns');
assert(isequal(pairList(fields, dims), sort([rxnFieldsOfCreateModel; {'rxnNotes/2'}])));
modelNotes.rxnNotes = {'n1'; 'n2'};
[fields, dims] = getModelFieldsForType(modelNotes, 'rxns');
assert(isequal(pairList(fields, dims), sort([rxnFieldsOfCreateModel; {'rxnNotes/1'}])));

%% fieldSize option: the size before rxns was extended, positional and name-value forms

% rxns has three entries, the other reaction fields still two; with fieldSize 2 the fields
% of the two original reactions are listed (not rxns), in both forms of the option
modelExtended = modelTwoRxns;
modelExtended.rxns{3, 1} = 'R3';
expectedOriginal = sort(setdiff(rxnFieldsOfCreateModel, {'rxns/1'}));
[fields, dims] = getModelFieldsForType(modelExtended, 'rxns', 2);
assert(isequal(pairList(fields, dims), expectedOriginal));
[fields, dims] = getModelFieldsForType(modelExtended, 'rxns', 'fieldSize', 2);
assert(isequal(pairList(fields, dims), expectedOriginal));
% without the option the size is numel(rxns) = 3, the size of the three metabolites, and
% only rxns has it among the reaction fields
[fields, dims] = getModelFieldsForType(modelExtended, 'rxns');
assert(isequal(pairList(fields, dims), {'rxns/1'}));

% change the directory
cd(currentDir)
