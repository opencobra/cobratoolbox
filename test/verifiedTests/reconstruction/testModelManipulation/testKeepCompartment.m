% The COBRAToolbox: testKeepCompartment.m
%
% Purpose:
%     - keepCompartment removes every reaction that uses a metabolite outside the given
%       compartments (written as in the metabolite identifiers, for example {'[c]'}), prints the
%       formula of each removed reaction, and removes the metabolites used only by removed
%       reactions. When nothing is removed it displays 'No Compartments Removed' and returns the
%       model unchanged.
%       Characterization test that PINS the current behaviour (feature
%       20261102-142225-tier2-test-pilot, Constitution Principle III characterization mode);
%       it must not change the function under test.
%     - Reference values: the reaction and metabolite counts asserted below were recorded from
%       the first run on 2026-11-02 with ecoli_core_model (no solver). They were not derived
%       independently, so they guard consistency, not independent correctness (Tier 5). The
%       removed reactions are also derived independently from model.S.
%     - The function prints the formula of every removed reaction once per metabolite it has
%       outside the kept compartments; this output is not suppressed and not asserted.
%
% Function under test:
%     src/reconstruction/refinement/keepCompartment.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - model manipulation, no solver; ecoli_core_model loaded through getDistributedModel.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261102-142225-tier2-test-pilot, 2026-11-02.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testKeepCompartment'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox or
% particular operating system, so none is listed
prepareTest();

% load the model once (95 reactions, 72 metabolites, 137 genes, compartments c and e)
model = getDistributedModel('ecoli_core_model.mat');

% the reaction- and metabolite-sized fields of ecoli_core_model, for the structural checks
rxnFields = {'rxns', 'lb', 'ub', 'c', 'rules', 'grRules', 'rxnNames', 'subSystems'};
metFields = {'mets', 'b', 'csense', 'metNames', 'metFormulas'};

%% keep c: the reactions that use a metabolite of e are removed

keptModel = keepCompartment(model, {'[c]'});

% the removed reactions are exactly those with a metabolite outside [c]; the others are kept in
% model order
isCytosolMet = ~cellfun(@isempty, regexp(model.mets, '\[c\]$'));
usesOtherComp = any(model.S(~isCytosolMet, :) ~= 0, 1)';
assert(isequal(keptModel.rxns, model.rxns(~usesOtherComp)));
[~, rxnIdx] = ismember(keptModel.rxns, model.rxns);

% the kept metabolites are exactly those used by a kept reaction: no metabolite of e is left
assert(isequal(keptModel.mets, model.mets(any(model.S(:, rxnIdx) ~= 0, 2))));
assert(all(~cellfun(@isempty, regexp(keptModel.mets, '\[c\]$'))));
[~, metIdx] = ismember(keptModel.mets, model.mets);

% Tier-5 reference counts (first run, 2026-11-02): 45 reactions removed, and with them the
% 20 metabolites of e and o2[c], every reaction of which uses a metabolite of e; the genes
% are kept
assert(numel(keptModel.rxns) == 50);
assert(numel(keptModel.mets) == 51);
assert(isequal(setdiff(model.mets(isCytosolMet), keptModel.mets), {'o2[c]'}));
assert(isequal(keptModel.genes, model.genes));

% the result is structurally consistent: S matches mets and rxns, every reaction- and
% metabolite-sized field has one row per entry, rxnGeneMat is reactions x genes and the rules
% only use existing gene indices
nRxns = numel(keptModel.rxns);
nMets = numel(keptModel.mets);
assert(isequal(size(keptModel.S), [nMets, nRxns]));
assert(all(cellfun(@(f) size(keptModel.(f), 1) == nRxns, rxnFields)));
assert(all(cellfun(@(f) size(keptModel.(f), 1) == nMets, metFields)));
assert(isequal(size(keptModel.rxnGeneMat), [nRxns, numel(keptModel.genes)]));
ruleGeneIdx = str2double(regexp(strjoin(keptModel.rules', ' '), '(?<=x\()\d+(?=\))', 'match'));
assert(all(ruleGeneIdx >= 1 & ruleGeneIdx <= numel(keptModel.genes)));

% the content is copied unchanged from the input model (copies, not computations, so equality
% is exact): stoichiometry, bounds, objective, rules and metabolite data
assert(isequal(keptModel.S, model.S(metIdx, rxnIdx)));
assert(isequal(keptModel.lb, model.lb(rxnIdx)) && isequal(keptModel.ub, model.ub(rxnIdx)));
assert(isequal(keptModel.c, model.c(rxnIdx)));
assert(isequal(keptModel.rules, model.rules(rxnIdx)));
assert(isequal(keptModel.rxnGeneMat, model.rxnGeneMat(rxnIdx, :)));
assert(isequal(keptModel.metNames, model.metNames(metIdx)));
assert(isequal(keptModel.b, model.b(metIdx)) && isequal(keptModel.csense, model.csense(metIdx)));

%% keep e: the reactions that use a metabolite of c are removed

keptModel = keepCompartment(model, {'[e]'});

% the kept reactions are exactly those without a metabolite outside [e], which are the
% exchange reactions (Tier-5 counts, first run 2026-11-02)
isExternalMet = ~cellfun(@isempty, regexp(model.mets, '\[e\]$'));
assert(isequal(keptModel.rxns, model.rxns(~any(model.S(~isExternalMet, :) ~= 0, 1)')));
assert(all(strncmp(keptModel.rxns, 'EX_', 3)));
assert(numel(keptModel.rxns) == 20 && numel(keptModel.mets) == 20);
assert(all(~cellfun(@isempty, regexp(keptModel.mets, '\[e\]$'))));

% the result is structurally consistent and the stoichiometry is copied unchanged
[~, rxnIdx] = ismember(keptModel.rxns, model.rxns);
[~, metIdx] = ismember(keptModel.mets, model.mets);
assert(isequal(size(keptModel.S), [numel(keptModel.mets), numel(keptModel.rxns)]));
assert(all(cellfun(@(f) size(keptModel.(f), 1) == numel(keptModel.rxns), rxnFields)));
assert(all(cellfun(@(f) size(keptModel.(f), 1) == numel(keptModel.mets), metFields)));
assert(isequal(keptModel.S, model.S(metIdx, rxnIdx)));

%% keep c and e: no reaction is removed and the model is returned unchanged

% the function displays 'No Compartments Removed' (not suppressed)
keptModel = keepCompartment(model, {'[c]', '[e]'});
assert(isequal(keptModel, model));

% change the directory
cd(currentDir)
