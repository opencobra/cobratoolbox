% The COBRAToolbox: testInitFBAFields.m
%
% Purpose:
%     - initFBAFields adds to a model every field that the toolbox field definitions mark as
%       needed for flux balance analysis (S, mets, rxns, lb, ub, c, genes, rules) and that the
%       model lacks, with its default value sized from S; fields already present are kept
%       unchanged. A model without S is rejected with an error.
%       Characterization test that PINS the current behaviour (feature
%       20261103-105830-tier2-safe-batch, Constitution Principle III characterization mode);
%       it must not change the function under test.
%     - Reference values: the list and order of the created fields asserted below were recorded
%       from the first run on 2026-11-03 with ecoli_core_model (no solver). They were not derived
%       independently, so they guard consistency, not independent correctness (Tier 5). The
%       default values themselves (R1.., M1.., -1000, 1000, 0, no genes, empty rules) are the
%       ones stated in the help text and are checked exactly.
%     - The models with missing fields are built from the loaded model by keeping only some of
%       its fields.
%
% Function under test:
%     src/base/io/utilities/initFBAFields.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - model manipulation, no solver; ecoli_core_model loaded through getDistributedModel.
%
% Coverage exemptions:
%     Line 54, the evaluation of a second dimension given as text: every field marked for flux
%     balance analysis except S (which must be present) has the numeric second dimension 1.
%     Line 62, the evaluation of a text default for a cell field: the strfind call on line 61
%     searches the field validator inside the word iscell (the arguments are swapped), so it
%     never matches and line 64 runs instead; the result is the same because the value set on
%     either line is only used by the ischar(x) branch.
%     Lines 77-78, the character-field branch: no field marked for flux balance analysis has the
%     validator ischar(x).
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The documented osense and csense fields are not created
%       SEVERITY: limitation
%       TRIGGER: initFBAFields(model) on a model without osense or csense, for example a model
%         with only S
%       OBSERVED: only S, mets, rxns, lb, ub, c, genes and rules are created; csense and osense
%         are not added because the field definitions do not mark them for flux balance analysis
%       EXPECTED: osense (-1) and csense (one E per metabolite) added, as the help text states
%       LINES: 41-42
%
% Authors:
%     - Generated for feature 20261103-105830-tier2-safe-batch, 2026-11-03.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testInitFBAFields'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox or
% particular operating system, so none is listed
prepareTest();

% load the model once (95 reactions, 72 metabolites, 137 genes)
model = getDistributedModel('ecoli_core_model.mat');

%% a model with only S gets every flux balance field with its default value

nMets = size(model.S, 1);
nRxns = size(model.S, 2);
initModel = initFBAFields(struct('S', model.S));

% Tier-5 reference (first run, 2026-11-03): the created fields, in the order of the field
% definitions
assert(isequal(fieldnames(initModel), {'S'; 'mets'; 'rxns'; 'lb'; 'ub'; 'c'; 'genes'; 'rules'}));

% S is unchanged and the defaults are those of the help text, sized from S
assert(isequal(initModel.S, model.S));
assert(isequal(initModel.mets, strcat('M', arrayfun(@num2str, (1:nMets)', 'UniformOutput', false))));
assert(isequal(initModel.rxns, strcat('R', arrayfun(@num2str, (1:nRxns)', 'UniformOutput', false))));
assert(isequal(initModel.lb, -1000 * ones(nRxns, 1)));
assert(isequal(initModel.ub, 1000 * ones(nRxns, 1)));
assert(isequal(initModel.c, zeros(nRxns, 1)));
assert(iscell(initModel.genes) && isequal(size(initModel.genes), [0, 1]));
assert(isequal(initModel.rules, repmat({''}, nRxns, 1)));

% the result is structurally consistent: S matches mets and rxns and every reaction-sized field
% has one row per reaction
rxnFields = {'rxns', 'lb', 'ub', 'c', 'rules'};
assert(isequal(size(initModel.S), [numel(initModel.mets), numel(initModel.rxns)]));
assert(all(cellfun(@(f) isequal(size(initModel.(f)), [nRxns, 1]), rxnFields)));

% the optional printLevel does not change the result
assert(isequal(initFBAFields(struct('S', model.S), 0), initModel));

%% a complete model is returned unchanged

assert(isequal(initFBAFields(model), model));
assert(isequal(initFBAFields(model, 1), model));

%% fields already present are kept and only the missing ones are added

% keep S, rxns, lb, genes and metNames of the loaded model
partialModel = struct('S', model.S, 'rxns', {model.rxns}, 'lb', model.lb, ...
    'genes', {model.genes}, 'metNames', {model.metNames});
initModel = initFBAFields(partialModel);

% the present fields, including one that is not a flux balance field, are unchanged
assert(isequal(initModel.S, model.S));
assert(isequal(initModel.rxns, model.rxns));
assert(isequal(initModel.lb, model.lb));
assert(isequal(initModel.genes, model.genes));
assert(isequal(initModel.metNames, model.metNames));

% the missing fields get their defaults (rules are empty although genes are present)
nRxns = numel(model.rxns);
assert(isequal(initModel.mets, strcat('M', arrayfun(@num2str, (1:numel(model.mets))', 'UniformOutput', false))));
assert(isequal(initModel.ub, 1000 * ones(nRxns, 1)));
assert(isequal(initModel.c, zeros(nRxns, 1)));
assert(isequal(initModel.rules, repmat({''}, nRxns, 1)));

% Tier-5 reference (first run, 2026-11-03): the present fields come first, then the added ones
assert(isequal(fieldnames(initModel), ...
    {'S'; 'rxns'; 'lb'; 'genes'; 'metNames'; 'mets'; 'ub'; 'c'; 'rules'}));

%% a model without S is rejected

assert(verifyCobraFunctionError('initFBAFields', 'inputs', {rmfield(model, 'S')}, ...
    'testMessage', 'Cannot create FBA fields without stoichiometric matrix'));

% change the directory
cd(currentDir)
