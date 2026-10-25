% The COBRAToolbox: testRemoveFieldEntriesForType.m
%
% Purpose:
%     - removeFieldEntriesForType removes the entries at given indices from every field of a model
%     that belongs to a type (reactions, metabolites, genes, compartments, ...). When genes are
%     removed it also deletes them from the gene reaction rules, renumbers the remaining genes in
%     the rules and rewrites the gene reaction rules that changed.
%       Characterization test that PINS the current behaviour (feature
%       20261021-112509-recon-ci-scalability, Constitution Principle III characterization mode);
%       it must not change the function under test. It is the reference that the runtime
%       enhancement of the gene branch is checked against.
%
% Function under test:
%     src/reconstruction/refinement/removeFieldEntriesForType.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - model manipulation on a hand-built model, no solver.
%
% Coverage exemptions:
%     Lines 86 and 87 and line 173, the path for a model that has gene reaction rules but no
%     rules field (generateRules and the removal of the generated field): see the known defect
%     below.
%     Lines 215 and 216, the second pass of normalizeRules: the rules it normalises are written by
%     FormulaParser.toString, which no tried input leaves with brackets that need a second pass.
%
% Known defects documented (NOT tested, NOT fixed here):
%     DEFECT: removing genes from a model that has grRules but no rules field fails
%       SEVERITY: error
%       TRIGGER: removeFieldEntriesForType(model, genesToRemove, 'genes', numel(model.genes)) on a
%         model without model.rules and with model.grRules
%       OBSERVED: the function builds model.rules, removes the field again at its end of the genes
%         branch, and then reads model.rules to rewrite grRules: error 'Unrecognized field name
%         "rules"'
%       EXPECTED: the gene reaction rules are rewritten and the model has no rules field
%       LINES: 86-87, 173, 190-196
%
% Authors:
%     - Generated for feature 20261021-112509-recon-ci-scalability, 2026-10-22.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testRemoveFieldEntriesForType'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed
prepareTest();

% four metabolites, five reactions, six genes
%   r1 x(1)   r2 x(2) & x(3)   r3 (x(3) | x(4)) & x(5)   r4 x(5) | x(6)   r5 no gene
model.mets = {'a[c]'; 'b[c]'; 'c[c]'; 'd[c]'};
model.rxns = {'r1'; 'r2'; 'r3'; 'r4'; 'r5'};
model.S = sparse([-1  0  0  0  1; ...
                   1 -1 -1  0  0; ...
                   0  1  0 -1  0; ...
                   0  0  1  1 -1]);
model.lb = zeros(5, 1);
model.ub = 10 * ones(5, 1);
model.c = zeros(5, 1);
model.rxnNames = {'one'; 'two'; 'three'; 'four'; 'five'};
model.genes = {'g1'; 'g2'; 'g3'; 'g4'; 'g5'; 'g6'};
model.rules = {'x(1)'; 'x(2) & x(3)'; '(x(3) | x(4)) & x(5)'; 'x(5) | x(6)'; ''};
model.grRules = {'g1'; 'g2 and g3'; '(g3 or g4) and g5'; 'g5 or g6'; ''};
model = buildRxnGeneMat(model);

%% nothing to remove returns the model as it is

assert(isequaln(removeFieldEntriesForType(model, [], 'rxns', 5), model));
assert(isequaln(removeFieldEntriesForType(model, false(5, 1), 'rxns', 5), model));
assert(isequaln(removeFieldEntriesForType(model, false(6, 1), 'genes', 6), model));

%% reactions: numeric and logical indices remove the same entries

keep = [2 3 4];
fromNumeric = removeFieldEntriesForType(model, [1 5], 'rxns', 5);
fromLogical = removeFieldEntriesForType(model, logical([1 0 0 0 1]), 'rxns', 5);
assert(isequaln(fromNumeric, fromLogical));
assert(isequal(fromNumeric.rxns, {'r2'; 'r3'; 'r4'}));
assert(isequal(fromNumeric.S, model.S(:, keep)) && issparse(fromNumeric.S));
assert(isequal(fromNumeric.lb, model.lb(keep)) && isequal(fromNumeric.ub, model.ub(keep)));
assert(isequal(fromNumeric.rxnNames, model.rxnNames(keep)));
assert(isequal(fromNumeric.rules, model.rules(keep)) && isequal(fromNumeric.grRules, model.grRules(keep)));
% the reaction gene matrix loses the rows of the removed reactions and keeps its columns
assert(isequal(size(fromNumeric.rxnGeneMat), [3 6]));
% fields of other types are untouched
assert(isequal(fromNumeric.mets, model.mets) && isequal(fromNumeric.genes, model.genes));

%% fields that are excluded are kept

kept = removeFieldEntriesForType(model, [1 5], 'rxns', 5, 'excludeFields', {'rxnNames'});
assert(isequal(kept.rxnNames, model.rxnNames));
assert(isequal(kept.rxns, {'r2'; 'r3'; 'r4'}));

%% metabolites

fewerMets = removeFieldEntriesForType(model, 4, 'mets', 4);
assert(isequal(fewerMets.mets, {'a[c]'; 'b[c]'; 'c[c]'}));
assert(isequal(fewerMets.S, model.S(1:3, :)));
assert(isequal(fewerMets.rxns, model.rxns));

%% genes: the rules lose the removed genes and the remaining genes are renumbered

% genes g2 and g4 are removed: r2 keeps g3, r3 keeps g3 and g5 and the genes g3, g5, g6 move up
fromNumeric = removeFieldEntriesForType(model, [2 4], 'genes', 6);
fromLogical = removeFieldEntriesForType(model, logical([0 1 0 1 0 0]), 'genes', 6);
assert(isequaln(fromNumeric, fromLogical));
assert(isequal(fromNumeric.genes, {'g1'; 'g3'; 'g5'; 'g6'}));
assert(isequal(fromNumeric.rules, {'x(1)'; 'x(2)'; 'x(2) & x(3)'; 'x(3) | x(4)'; ''}));
assert(isequal(fromNumeric.grRules, {'g1'; 'g3'; 'g3 and g5'; 'g5 or g6'; ''}));
% the reaction gene matrix loses the columns of the removed genes
assert(isequal(full(fromNumeric.rxnGeneMat), full(model.rxnGeneMat(:, [1 3 5 6]))));
% reactions are not touched
assert(isequal(fromNumeric.rxns, model.rxns) && isequal(fromNumeric.S, model.S));

%% genes: a rule whose only gene is removed becomes empty, and a gene that no rule uses can go

fewer = removeFieldEntriesForType(model, 1, 'genes', 6);
assert(isequal(fewer.genes, {'g2'; 'g3'; 'g4'; 'g5'; 'g6'}));
assert(isempty(fewer.rules{1}));
assert(isequal(fewer.rules(2:4), {'x(1) & x(2)'; '(x(2) | x(3)) & x(4)'; 'x(4) | x(5)'}));
assert(isempty(fewer.grRules{1}));

%% genes: surplus brackets around a single gene are removed from the rules

% (x(2) | x(3)) loses x(3) and would leave (x(2)), which is normalised to x(2)
bracket = model;
bracket.rules = {'x(1)'; '(x(2) | x(3)) & x(1)'; 'x(3)'; 'x(5)'; ''};
bracket.grRules = {'g1'; '(g2 or g3) and g1'; 'g3'; 'g5'; ''};
bracket = buildRxnGeneMat(bracket);
result = removeFieldEntriesForType(bracket, 3, 'genes', 6);
assert(strcmp(result.rules{2}, 'x(2) & x(1)') || strcmp(result.rules{2}, 'x(1) & x(2)'));
assert(isequal(result.genes, {'g1'; 'g2'; 'g4'; 'g5'; 'g6'}));

%% genes: rules that do not satisfy the field definition are refused

invalid = model;
invalid.rules = {1; 2; 3; 4; 5};
errorMessage = '';
try
    removeFieldEntriesForType(invalid, 2, 'genes', 6);
catch exception
    errorMessage = exception.message;
end
assert(startsWith(errorMessage, 'Rules field does not satisfy the field definitions'));

%% invalid arguments are rejected by the argument parser

% a type that does not exist
errorIdentifier = '';
try
    removeFieldEntriesForType(model, 1, 'nothing', 5);
catch exception
    errorIdentifier = exception.identifier;
end
assert(strcmp(errorIdentifier, 'MATLAB:InputParser:ArgumentFailedValidation'));
% a model without the field of the type
errorIdentifier = '';
try
    removeFieldEntriesForType(rmfield(model, 'genes'), 1, 'genes', 6);
catch exception
    errorIdentifier = exception.identifier;
end
assert(strcmp(errorIdentifier, 'MATLAB:InputParser:ArgumentFailedValidation'));
% indices that are neither logical nor numeric
errorIdentifier = '';
try
    removeFieldEntriesForType(model, 'r1', 'rxns', 5);
catch exception
    errorIdentifier = exception.identifier;
end
assert(strcmp(errorIdentifier, 'MATLAB:InputParser:ArgumentFailedValidation'));

% return to the original directory
cd(currentDir)
