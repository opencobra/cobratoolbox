% The COBRAToolbox: testAddMultipleMetabolites.m
%
% Purpose:
%     - addMultipleMetabolites(model, metIDs, fieldName, value, ...) appends metabolites to a
%       model. Values given for metabolite fields extend an existing field, or create a field
%       defined in COBRA_structure_fields.tab with its default for the old metabolites; the
%       S field and fields that are neither defined nor present are skipped (with a warning
%       when printLevel > 0). All other metabolite fields are extended with their defaults
%       (S gets zero rows, b zeros, csense 'E', metNames the id). Duplicate ids, ids already in
%       the model and ids of constraints are errors.
%     - Expected values come from the documentation and the defaults of
%       COBRA_structure_fields.tab (metCharges NaN, metNames model.mets{i}, b 0, csense 'E').
%
% Function under test:
%     src/reconstruction/refinement/addMultipleMetabolites.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - hand-built models (createModel); no solver.
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
fileDir = fileparts(which('testAddMultipleMetabolites'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% three metabolites and two reactions; metCustom is a metabolite field without definition
baseModel = createModel({'R1', 'R2'}, {'R1', 'R2'}, {'a[c] -> b[c]', 'b[c] -> c[c]'}, ...
    'printLevel', 0);
baseModel.metNames = {'A'; 'B'; 'C'};
baseModel.metCustom = [1; 2; 3];
assert(~isfield(baseModel, 'metCharges'));

%% two metabolites with an existing, a new defined and a custom field (printLevel 0)

lastwarn('');
model = addMultipleMetabolites(baseModel, {'d[c]', 'e[c]'}, 'metNames', {'D', 'E'}, ...
    'metCharges', [1, 2], 'metCustom', [4, 5], 'S', [1, 1], 'unknownField', 1);
assert(isequal(model.mets, {'a[c]'; 'b[c]'; 'c[c]'; 'd[c]'; 'e[c]'}));
% an existing field is extended with the given values (rows or columns)
assert(isequal(model.metNames, {'A'; 'B'; 'C'; 'D'; 'E'}));
assert(isequal(model.metCustom, [1; 2; 3; 4; 5]));
% a defined field that was absent is created: its default NaN for the old metabolites
assert(isequal(model.metCharges(4:5), [1; 2]) && all(isnan(model.metCharges(1:3))));
% S is never set from the input: two zero rows; an undefined absent field is not created
assert(isequal(size(model.S), [5, 2]) && nnz(model.S(4:5, :)) == 0);
assert(isequal(model.S(1:3, :), baseModel.S));
assert(~isfield(model, 'unknownField'));
% the remaining metabolite fields get their defaults
assert(isequal(model.b, zeros(5, 1)));
assert(numel(model.csense) == 5 && all(model.csense == 'E'));
% with printLevel 0 the skipped fields raise no warning
assert(isempty(lastwarn));

%% printLevel 3: messages, and a visible warning for each skipped field

% 'printLevel' is the last pair, so the last warning is the one for unknownField: the
% printLevel pair itself is skipped without a warning
lastwarn('');
model = addMultipleMetabolites(baseModel, {'d[c]'}, 'metFormulas', {'C2H6O'}, 'S', 1, ...
    'unknownField', 1, 'printLevel', 3);
assert(strcmp(lastwarn, 'Field unknownField is excluded'));
assert(isequal(model.metFormulas(4), {'C2H6O'}) && numel(model.metFormulas) == 4);
% the new metabolite's name defaults to its id
assert(isequal(model.metNames, {'A'; 'B'; 'C'; 'd[c]'}));

%% duplicate ids, ids in the model and ids of constraints are errors

assert(verifyCobraFunctionError('addMultipleMetabolites', 'inputs', {baseModel, {'z', 'z'}}, ...
    'testMessage', 'Duplicate Metabolite ID in the given IDs detected.'));
assert(verifyCobraFunctionError('addMultipleMetabolites', 'inputs', ...
    {baseModel, {'z', 'a[c]'}}, 'testMessage', ...
    sprintf('The following Metabolite ID(s) are already present in the model:\na[c]')));
% a hand-built constraint k1 shares the id space of the metabolites
constrainedModel = baseModel;
constrainedModel.C = sparse([1, 0]);
constrainedModel.d = 0;
constrainedModel.dsense = 'L';
constrainedModel.ctrs = {'k1'};
assert(verifyCobraFunctionError('addMultipleMetabolites', 'inputs', ...
    {constrainedModel, {'k1'}}, 'testMessage', ...
    sprintf('The following Metabolite ID(s) are already present Ids of constraints in the model:\nk1')));

% change the directory
cd(currentDir)
