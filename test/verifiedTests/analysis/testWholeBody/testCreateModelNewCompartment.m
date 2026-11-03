% The COBRAToolbox: testCreateModelNewCompartment.m
%
% Purpose:
%     - createModelNewCompartment replicates the compartment used by the exchange reactions into
%       a new compartment: for every exchange reaction (identifier containing EX_) with a single
%       metabolite in the old compartment it adds a transport reaction between that metabolite
%       and its copy in the new compartment, with the given bounds; with UB = 0 the transport
%       runs from the new into the old compartment; with RemoveExch = 1 the original exchange
%       reactions are removed.
%       Characterization test that PINS the current behaviour (feature
%       20261103-105830-tier2-safe-batch, Constitution Principle III characterization mode);
%       it must not change the function under test.
%     - The function is part of the whole-body toolbox but works on any model with exchange
%       reactions, so the distributed ecoli_core_model is used.
%     - Reference values: the reaction and metabolite counts asserted below were recorded from
%       the first run on 2026-11-03 with ecoli_core_model (no solver). They were not derived
%       independently, so they guard consistency, not independent correctness (Tier 5). The new
%       reactions, metabolites and stoichiometry are also derived independently from model.rxns
%       and model.S.
%     - The function switches all MATLAB warnings off and does not restore them (defect below);
%       every section restores the warning state saved before the first section, so that the
%       test leaves no global state behind.
%
% Function under test:
%     src/analysis/wholeBody/PSCMToolbox/createModelNewCompartment.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - model manipulation, no solver; ecoli_core_model loaded through getDistributedModel.
%
% Coverage exemptions:
%     Lines 48-49, exchange reactions named with Ex_ instead of EX_: no distributed model has
%     such a reaction identifier (checked: ecoli_core_model, iAF1260, iJO1366, Recon2.v04,
%     Recon3DModel_301, Recon3D_301, Abiotrophia_defectiva_ATCC_49176, modelReg, AntCore,
%     cardiac_mit_glcuptake_atpmax).
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: All MATLAB warnings are switched off and never switched back on
%       SEVERITY: limitation
%       TRIGGER: any call, for example createModelNewCompartment(model, 'e', 'lu', 'lumen')
%       OBSERVED: warning off at the start disables every warning for the rest of the MATLAB
%         session
%       EXPECTED: warnings stay visible, or the previous warning state is restored before return
%       LINES: 29
%     - DEFECT: The names of the new transport reactions lose their blanks
%       SEVERITY: cosmetic
%       TRIGGER: any call that adds a reaction, for example
%         createModelNewCompartment(model, 'e', 'lu', 'lumen') on ecoli_core_model
%       OBSERVED: strcat removes the trailing blanks of ' (from ' and ' to ', so the name is
%         'Acetate exchange (from[e] tolumen)'; with UB = 0 it is
%         'Acetate exchange (fromlumento[e]', also without the closing parenthesis
%       EXPECTED: 'Acetate exchange (from [e] to lumen)' and
%         'Acetate exchange (from lumen to [e])'
%       LINES: 71, 82
%     - DEFECT: rxnGeneMat is dropped when the original exchange reactions are removed
%       SEVERITY: limitation
%       TRIGGER: RemoveExch = 1, for example
%         createModelNewCompartment(model, 'e', 'lu', 'lumen', -1000, 1000, 1)
%       OBSERVED: the result has no rxnGeneMat field although the input model has one
%       EXPECTED: rxnGeneMat kept, with the rows of the removed reactions removed
%       LINES: 97-99
%
% Authors:
%     - Generated for feature 20261103-105830-tier2-safe-batch, 2026-11-03.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testCreateModelNewCompartment'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox or
% particular operating system, so none is listed
prepareTest();

% load the model once (95 reactions, 72 metabolites, 137 genes, compartments c and e; 20
% exchange reactions EX_..., each with one metabolite in [e])
model = getDistributedModel('ecoli_core_model.mat');

% the warning state before the test; createModelNewCompartment switches all warnings off (known
% defect)
warningState = warning;

% the reaction- and metabolite-sized fields of the result, for the structural checks
rxnFields = {'rxns', 'lb', 'ub', 'c', 'rules', 'grRules', 'rxnNames', 'subSystems'};
metFields = {'mets', 'b', 'csense', 'metNames', 'metFormulas'};

% the exchange reactions of the model in model order, and their [e] metabolites
exchangeRxns = model.rxns(contains(model.rxns, 'EX_'));
[~, exchangeIdx] = ismember(exchangeRxns, model.rxns);
[exchangeMetIdx, ~] = find(model.S(:, exchangeIdx));

%% default options: a reversible transport reaction into the new compartment per exchange

newModel = createModelNewCompartment(model, 'e', 'lu', 'lumen');
warning(warningState);

% the original reactions and metabolites are kept in place; one reaction EX_..._[lu] per
% exchange reaction and one metabolite ...[lu] per exchanged metabolite are appended, in the
% order of the exchange reactions in the model
newRxns = strcat(exchangeRxns, '_[lu]');
oldMets = model.mets(exchangeMetIdx);
newMets = regexprep(oldMets, '\[e\]$', '[lu]');
assert(isequal(newModel.rxns, [model.rxns; newRxns]));
assert(isequal(newModel.mets, [model.mets; newMets]));

% Tier-5 reference counts (first run, 2026-11-03): 20 exchange reactions give 20 new reactions
% and 20 new metabolites
assert(numel(newRxns) == 20);
assert(numel(newModel.rxns) == 115);
assert(numel(newModel.mets) == 92);

% the default options are LB = -1000, UB = 1000 and RemoveExch = 0
assert(isequal(createModelNewCompartment(model, 'e', 'lu', 'lumen', -1000, 1000, 0), newModel));
warning(warningState);

% the result is structurally consistent: S matches mets and rxns, every reaction- and
% metabolite-sized field has one entry per reaction or metabolite and rxnGeneMat is reactions x
% genes
nRxns = numel(newModel.rxns);
nMets = numel(newModel.mets);
assert(isequal(size(newModel.S), [nMets, nRxns]));
assert(all(cellfun(@(f) size(newModel.(f), 1) == nRxns, rxnFields)));
assert(all(cellfun(@(f) size(newModel.(f), 1) == nMets, metFields)));
assert(isequal(size(newModel.rxnGeneMat), [nRxns, numel(newModel.genes)]));
assert(isequal(newModel.genes, model.genes));

% the input model is copied unchanged (copies, so equality is exact)
assert(isequal(newModel.S(1:72, 1:95), model.S));
assert(nnz(newModel.S(73:end, 1:95)) == 0);
assert(isequal(newModel.lb(1:95), model.lb) && isequal(newModel.ub(1:95), model.ub));
assert(isequal(newModel.rxnGeneMat(1:95, :), model.rxnGeneMat));

% each new reaction consumes the [e] metabolite of its exchange reaction and produces its copy
% in [lu] (coefficients -1 and 1), is reversible with the default bounds, has no objective
% coefficient and no gene rule, and is in the subsystem Transport
expectedS = sparse([exchangeMetIdx; (73:92)'], [(1:20)'; (1:20)'], [-ones(20, 1); ones(20, 1)], 92, 20);
assert(isequal(newModel.S(:, 96:end), expectedS));
assert(all(newModel.lb(96:end) == -1000) && all(newModel.ub(96:end) == 1000));
assert(all(newModel.c(96:end) == 0));
assert(all(cellfun(@isempty, newModel.rules(96:end))) && all(cellfun(@isempty, newModel.grRules(96:end))));
assert(nnz(newModel.rxnGeneMat(96:end, :)) == 0);
assert(all(cellfun(@(s) isequal(cellstr(s), {'Transport'}), newModel.subSystems(96:end))));

% the name of each new reaction starts with the name of its exchange reaction (the rest of the
% name is a known defect and is not asserted)
assert(all(startsWith(newModel.rxnNames(96:end), model.rxnNames(exchangeIdx))));

%% UB = 0: an irreversible transport from the new compartment into the old one

newModel = createModelNewCompartment(model, 'e', 'lu', 'lumen', -500, 0);
warning(warningState);

% the same reactions and metabolites are appended (Tier-5 counts, first run 2026-11-03)
assert(isequal(newModel.rxns, [model.rxns; strcat(exchangeRxns, '_[lu]')]));
assert(numel(newModel.rxns) == 115 && numel(newModel.mets) == 92);
assert(isequal(size(newModel.S), [numel(newModel.mets), numel(newModel.rxns)]));

% each new reaction consumes the [lu] metabolite and produces the [e] metabolite; the bounds are
% 0 and -LB
expectedS = sparse([exchangeMetIdx; (73:92)'], [(1:20)'; (1:20)'], [ones(20, 1); -ones(20, 1)], 92, 20);
assert(isequal(newModel.S(:, 96:end), expectedS));
assert(all(newModel.lb(96:end) == 0) && all(newModel.ub(96:end) == 500));
assert(isequal(newModel.S(1:72, 1:95), model.S));

%% LB >= 0: an irreversible transport from the old compartment into the new one

newModel = createModelNewCompartment(model, 'e', 'lu', 'lumen', 0, 100);
warning(warningState);

% each new reaction consumes the [e] metabolite and produces the [lu] metabolite with the given
% bounds (Tier-5 counts, first run 2026-11-03)
assert(numel(newModel.rxns) == 115 && numel(newModel.mets) == 92);
expectedS = sparse([exchangeMetIdx; (73:92)'], [(1:20)'; (1:20)'], [-ones(20, 1); ones(20, 1)], 92, 20);
assert(isequal(newModel.S(:, 96:end), expectedS));
assert(all(newModel.lb(96:end) == 0) && all(newModel.ub(96:end) == 100));

%% RemoveExch = 1: the original exchange reactions are removed

newModel = createModelNewCompartment(model, 'e', 'lu', 'lumen', -1000, 1000, 1);
warning(warningState);

% the exchange reactions are replaced by the transport reactions: the other reactions keep their
% order and the transport reactions follow; every metabolite is still used, so all are kept
% (Tier-5 counts, first run 2026-11-03)
otherRxns = model.rxns(~ismember(model.rxns, exchangeRxns));
assert(isequal(newModel.rxns, [otherRxns; strcat(exchangeRxns, '_[lu]')]));
assert(isequal(newModel.mets, [model.mets; regexprep(model.mets(exchangeMetIdx), '\[e\]$', '[lu]')]));
assert(numel(newModel.rxns) == 95 && numel(newModel.mets) == 92);

% the result is structurally consistent (rxnGeneMat is dropped, a known defect, so the gene
% associations are checked through rules: every rule only refers to existing gene indices)
nRxns = numel(newModel.rxns);
nMets = numel(newModel.mets);
assert(isequal(size(newModel.S), [nMets, nRxns]));
assert(all(cellfun(@(f) size(newModel.(f), 1) == nRxns, rxnFields)));
assert(all(cellfun(@(f) size(newModel.(f), 1) == nMets, metFields)));
ruleGeneIdx = str2double(regexp(strjoin(newModel.rules', ' '), '(?<=x\()\d+(?=\))', 'match'));
assert(all(ruleGeneIdx >= 1 & ruleGeneIdx <= numel(newModel.genes)));

% the kept reactions are copied unchanged and the transport reactions are as without removal
[~, rxnIdx] = ismember(otherRxns, model.rxns);
assert(isequal(newModel.S(1:72, 1:75), model.S(:, rxnIdx)));
assert(isequal(newModel.rules(1:75), model.rules(rxnIdx)));
expectedS = sparse([exchangeMetIdx; (73:92)'], [(1:20)'; (1:20)'], [-ones(20, 1); ones(20, 1)], 92, 20);
assert(isequal(newModel.S(:, 76:end), expectedS));

%% a compartment that no exchange reaction uses adds nothing

% every exchange metabolite of ecoli_core_model is in [e], so replicating [c] changes nothing
newModel = createModelNewCompartment(model, 'c', 'lu', 'lumen');
warning(warningState);
assert(isequal(newModel, model));

% change the directory
cd(currentDir)
