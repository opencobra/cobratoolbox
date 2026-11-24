% The COBRAToolbox: testAddCOBRAVariables.m
%
% Purpose:
%     - addCOBRAVariables(model, idList, ...) appends extra variables to a model: their ids
%       (evars), bounds (evarlb, evarub, defaults -1000 and 1000), objective coefficients
%       (evarc, default 0) and, when names are given or the field exists, evarNames (default:
%       the ids). Missing fields are created (E, evars, evarlb, evarub, evarc, and D when the
%       model has constraints) and E (mets x evars) and D (ctrs x evars) get zero columns for
%       the new variables. Ids already used by a reaction or a variable are errors.
%     - Expected values come from the documentation and the defaults of
%       COBRA_structure_fields.tab (evarNames default: model.evars{i}).
%
% Function under test:
%     src/reconstruction/refinement/addCOBRAVariables.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - hand-built models (createModel); no solver.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: A single name given as a character array is rejected
%       SEVERITY: limitation
%       TRIGGER: addCOBRAVariables(model, 'v1', 'Names', 'Variable one')
%       OBSERVED: (R2025a, 2026-11-23) "The value of 'Names' is invalid. Invalid data type.
%         Argument must be numeric, char, or logical." from the input parser: the validator
%         evaluates numel(idList == 1), and == is not defined for the cell idList
%       EXPECTED: one variable named 'Variable one', as the char branch of the validator
%         intends; the documented form, a cell array of names, works and is tested below
%       LINES: 79
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-23.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testAddCOBRAVariables'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% four metabolites and three reactions, so that the variable counts used below (2 and 3)
% never equal the size of another type
baseModel = createModel({'R1', 'R2', 'R3'}, {'R1', 'R2', 'R3'}, ...
    {'a[c] -> b[c]', 'b[c] -> c[c] + d[c]', 'd[c] -> '}, 'printLevel', 0);
assert(numel(baseModel.mets) == 4 && ~isfield(baseModel, 'evars'));

%% first variables, defaults: the variable fields are created, no names and no D

model = addCOBRAVariables(baseModel, {'v1', 'v2'});
assert(isequal(model.evars, {'v1'; 'v2'}));
assert(isequal(model.evarlb, [-1000; -1000]) && isequal(model.evarub, [1000; 1000]));
assert(isequal(model.evarc, [0; 0]));
% E: one zero column per variable for each metabolite
assert(isequal(size(model.E), [4, 2]) && nnz(model.E) == 0);
% no names were given and the model has no constraints
assert(~isfield(model, 'evarNames') && ~isfield(model, 'D'));
% the reaction and metabolite fields are unchanged
assert(isequal(model.S, baseModel.S) && isequal(model.rxns, baseModel.rxns));

%% names given for a model with variables but no evarNames: the field is created

model = addCOBRAVariables(model, {'v3'}, 'Names', {'Third'});
% the existing variables get their default names (their ids)
assert(isequal(model.evarNames, {'v1'; 'v2'; 'Third'}));
assert(isequal(model.evars, {'v1'; 'v2'; 'v3'}) && isequal(size(model.E), [4, 3]));

%% a model with constraints: D is created; scalar bounds and coefficients are expanded

% one hand-built constraint (C, d, dsense, ctrs)
constrainedModel = baseModel;
constrainedModel.C = sparse([1, 0, 0]);
constrainedModel.d = 0;
constrainedModel.dsense = 'L';
constrainedModel.ctrs = {'k1'};
model = addCOBRAVariables(constrainedModel, {'v1', 'v2'}, 'lb', 0, 'ub', [5, 6], 'c', 1, ...
    'Names', {'V1', 'V2'});
assert(isequal(model.evarlb, [0; 0]) && isequal(model.evarub, [5; 6]));
assert(isequal(model.evarc, [1; 1]));
assert(isequal(model.evarNames, {'V1'; 'V2'}));
% D: one zero column per variable for the constraint
assert(isequal(size(model.D), [1, 2]) && nnz(model.D) == 0);
assert(isequal(size(model.E), [4, 2]));

%% a single id as a character array; existing names are extended with the id

model = addCOBRAVariables(model, 'v3');
assert(isequal(model.evars, {'v1'; 'v2'; 'v3'}));
assert(isequal(model.evarNames, {'V1'; 'V2'; 'v3'}));
assert(isequal(model.evarlb, [0; 0; -1000]) && isequal(model.evarub, [5; 6; 1000]));
assert(isequal(model.evarc, [1; 1; 0]));
assert(isequal(size(model.D), [1, 3]) && isequal(size(model.E), [4, 3]));

%% ids of existing variables or reactions are errors

assert(verifyCobraFunctionError('addCOBRAVariables', 'inputs', {model, {'v1'}}, ...
    'testMessage', sprintf('The following IDs are already IDs of variables:\nv1\n')));
assert(verifyCobraFunctionError('addCOBRAVariables', 'inputs', {model, {'R1', 'v9'}}, ...
    'testMessage', sprintf('The following IDs are already IDs of reactions:\nR1\n')));
% bounds with neither one value nor one value per id are rejected by the input parser
assert(verifyCobraFunctionError('addCOBRAVariables', 'inputs', ...
    {baseModel, {'v1', 'v2'}, 'lb', [1, 2, 3]}));

% change the directory
cd(currentDir)
