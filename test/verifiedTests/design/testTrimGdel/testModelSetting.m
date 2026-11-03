% The COBRAToolbox: testModelSetting.m
%
% Purpose:
%     - modelSetting finds the exchange reaction of a target metabolite: EX_<met> if the model
%       has it (type 1), else DM_<met> (type 2); the model is then returned unchanged. Otherwise
%       it appends a reaction named Transport that consumes the metabolite, with bounds 0 and
%       999999 and rev 0 (type 3), and returns its index.
%       Characterization test that PINS the current behaviour (feature
%       20261103-105830-tier2-safe-batch, Constitution Principle III characterization mode);
%       it must not change the function under test.
%     - Reference values: the reaction indices asserted below were recorded from the first run on
%       2026-11-03 with iAF1260 (no solver). They were not derived independently, so they guard
%       consistency, not independent correctness (Tier 5). They are also checked against the
%       reaction identifiers.
%     - iAF1260 is used because its exchange and demand reactions are named EX_<met> and
%       DM_<met> after the metabolite identifiers, which the function requires; ecoli_core_model
%       and the AGORA models use EX_<met>(e), so only the type-3 branch could be reached with them.
%     - For the type-3 branch the model is given a rev field built in the test from the loaded
%       model (rev = lb < 0, one row per reaction), because without it the function creates rev
%       as a row (defect below).
%
% Function under test:
%     src/design/TrimGdel/modelSetting.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - model manipulation, no solver; iAF1260 loaded through getDistributedModel.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: A model without rev gets rev as a row vector
%       SEVERITY: wrong-result
%       TRIGGER: modelSetting(model, targetMet) on a model without the field rev and a target
%         metabolite without EX_ or DM_ reaction, for example iAF1260 with btn_c
%       OBSERVED: model2.rev(n) = 0 creates rev as a 1 x n row of zeros, while every other
%         reaction field has one row per reaction
%       EXPECTED: rev, if created at all, as an n x 1 column (or the deprecated field not
%         created)
%       LINES: 56
%
% Authors:
%     - Generated for feature 20261103-105830-tier2-safe-batch, 2026-11-03.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testModelSetting'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox or
% particular operating system, so none is listed
prepareTest();

% load the model once (2382 reactions, 1668 metabolites, 1261 genes)
model = getDistributedModel('iAF1260.mat');

%% a metabolite with an exchange reaction EX_<met> (type 1)

[model2, targetRID, extype] = modelSetting(model, 'succ_e');

% the model is unchanged and the index is that of EX_succ_e (Tier-5 index, first run 2026-11-03)
assert(isequal(model2, model));
assert(extype == 1);
assert(strcmp(model.rxns{targetRID}, 'EX_succ_e') && targetRID == 933);

%% a metabolite with a demand reaction DM_<met> and no exchange reaction (type 2)

[model2, targetRID, extype] = modelSetting(model, '5drib_c');

% the model is unchanged and the index is that of DM_5drib_c (Tier-5 index, first run 2026-11-03)
assert(~any(strcmp(model.rxns, 'EX_5drib_c')));
assert(isequal(model2, model));
assert(extype == 2);
assert(strcmp(model.rxns{targetRID}, 'DM_5drib_c') && targetRID == 593);

%% a metabolite without exchange or demand reaction gets an auxiliary reaction (type 3)

% rev built from the loaded model, one row per reaction (see the header)
modelWithRev = model;
modelWithRev.rev = double(model.lb < 0);
assert(~any(strcmp(model.rxns, 'EX_btn_c')) && ~any(strcmp(model.rxns, 'DM_btn_c')));
[model2, targetRID, extype] = modelSetting(modelWithRev, 'btn_c');

% one reaction named Transport is appended and its index is returned
nRxns = numel(model.rxns);
assert(extype == 3);
assert(targetRID == nRxns + 1);
assert(isequal(model2.rxns, [model.rxns; {'Transport'}]));
assert(isequal(model2.mets, model.mets));

% the new reaction only consumes the target metabolite, with bounds 0 and 999999 and rev 0
targetIdx = find(strcmp(model.mets, 'btn_c'));
expectedColumn = zeros(numel(model.mets), 1);
expectedColumn(targetIdx) = -1;
assert(isequal(full(model2.S(:, end)), expectedColumn));
assert(model2.lb(end) == 0 && model2.ub(end) == 999999 && model2.rev(end) == 0);

% the existing reactions are unchanged (copies, so equality is exact)
assert(isequal(model2.S(:, 1:nRxns), model.S));
assert(isequal(model2.lb(1:nRxns), model.lb) && isequal(model2.ub(1:nRxns), model.ub));
assert(isequal(model2.rev(1:nRxns), modelWithRev.rev));
assert(isequal(model2.rules(1:nRxns), model.rules));

% the result is structurally consistent: S matches mets and rxns, every reaction-sized field of
% the input has one more row, rxnGeneMat is reactions x genes and the rules only use existing
% gene indices
assert(isequal(size(model2.S), [numel(model2.mets), numel(model2.rxns)]));
rxnFields = fieldnames(modelWithRev);
rxnFields = rxnFields(cellfun(@(f) size(modelWithRev.(f), 1) == nRxns && ~strcmp(f, 'S'), rxnFields));
assert(all(cellfun(@(f) size(model2.(f), 1) == nRxns + 1, rxnFields)));
assert(isequal(size(model2.rxnGeneMat), [nRxns + 1, numel(model2.genes)]));
ruleGeneIdx = str2double(regexp(strjoin(model2.rules', ' '), '(?<=x\()\d+(?=\))', 'match'));
assert(all(ruleGeneIdx >= 1 & ruleGeneIdx <= numel(model2.genes)));

% change the directory
cd(currentDir)
