% The COBRAToolbox: testBuildTmodel.m
%
% Purpose:
%     - buildTmodel turns a model checked by verifyModelBorg into a modelBorgifier template
%       model (Tmodel): the non-empty entries of rxnID, metID, subSystems, rxnReferences,
%       rxnECNumbers and grRules get the prefix '<description>:', Models.<description> holds
%       true membership vectors for all reactions and metabolites and the genes, lb, ub and
%       c become structures with one field <description>, S becomes sparse, and the fields
%       description, genes, rxnGeneMat and rules are removed when present.
%     - Expected values are written down from these rules for a hand-built three-reaction
%       model; all other fields must pass through unchanged.
%
% Function under test:
%     src/reconstruction/comparison/modelBorgifier/buildTmodel.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - model manipulation on a hand-built three-reaction model, no solver.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testBuildTmodel'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% a model as verifyModelBorg leaves it: full S, flat cell arrays, some empty entries
model = struct();
model.rxns = {'r1'; 'r2'; 'ex_a'};
model.mets = {'a[c]'; 'b[c]'};
model.S = [-1 0 -1; 1 -1 0];
model.lb = [0; -10; -10];
model.ub = [10; 10; 10];
model.c = [0; 1; 0];
model.rxnID = {'r1'; 'r2'; ''};
model.rxnNames = {'one'; 'two'; 'ex a'};
model.subSystems = {'Sub1'; ''; 'Exchange'};
model.rxnReferences = {''; 'PMID:1'; ''};
model.rxnECNumbers = {'1.1.1.1'; ''; ''};
model.grRules = {'g1 or g2'; ''; 'g3'};
model.metID = {'a[c]'; ''};
model.metNames = {'a'; 'b'};
model.genes = {'g1'; 'g2'; 'g3'};
model.rules = {'x(1) | x(2)'; ''; 'x(3)'};
model.rxnGeneMat = sparse([1 1 0; 0 0 0; 0 0 1]);
model.description = 'modelA';

%% the template model of a model with all four removable fields

tmodel = buildTmodel(model);

% non-empty entries get the 'modelA:' prefix, empty entries stay empty
assert(isequal(tmodel.rxnID, {'modelA:r1'; 'modelA:r2'; ''}));
assert(isequal(tmodel.metID, {'modelA:a[c]'; ''}));
assert(isequal(tmodel.subSystems, {'modelA:Sub1'; ''; 'modelA:Exchange'}));
assert(isequal(tmodel.rxnReferences, {''; 'modelA:PMID:1'; ''}));
assert(isequal(tmodel.rxnECNumbers, {'modelA:1.1.1.1'; ''; ''}));
assert(isequal(tmodel.grRules, {'modelA:g1 or g2'; ''; 'modelA:g3'}));

% membership of every reaction and metabolite, and the genes, under Models.modelA
assert(isequal(fieldnames(tmodel.Models), {'modelA'}));
assert(isequal(tmodel.Models.modelA.rxns, true(3, 1)));
assert(isequal(tmodel.Models.modelA.mets, true(2, 1)));
assert(isequal(tmodel.Models.modelA.genes, model.genes));

% bounds and objective moved into structures keyed by the model name (exact copies)
assert(isequal(tmodel.lb, struct('modelA', model.lb)));
assert(isequal(tmodel.ub, struct('modelA', model.ub)));
assert(isequal(tmodel.c, struct('modelA', model.c)));

% S becomes sparse with the same entries
assert(issparse(tmodel.S));
assert(isequal(full(tmodel.S), model.S));

% the four fields are removed; names, reactions and metabolites are unchanged
assert(~any(isfield(tmodel, {'description', 'genes', 'rxnGeneMat', 'rules'})));
assert(isequal(tmodel.rxns, model.rxns));
assert(isequal(tmodel.mets, model.mets));
assert(isequal(tmodel.rxnNames, model.rxnNames));
assert(isequal(tmodel.metNames, model.metNames));
expectedFields = [setdiff(fieldnames(model), {'description', 'genes', 'rxnGeneMat', ...
    'rules'}, 'stable'); {'Models'}];
assert(isequal(fieldnames(tmodel), expectedFields));

%% removable fields that are absent are skipped

% without rxnGeneMat and rules, rmfield fails for them and the catch branch goes on
modelNoRules = rmfield(model, {'rxnGeneMat', 'rules'});
modelNoRules.description = 'modelB';
tmodelB = buildTmodel(modelNoRules);
assert(~any(isfield(tmodelB, {'description', 'genes', 'rxnGeneMat', 'rules'})));
assert(isequal(fieldnames(tmodelB.Models), {'modelB'}));
assert(isequal(tmodelB.rxnID, {'modelB:r1'; 'modelB:r2'; ''}));
assert(isequal(tmodelB.lb, struct('modelB', model.lb)));

% change the directory
cd(currentDir)
