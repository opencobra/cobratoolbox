% The COBRAToolbox: testExtractSubSysModel.m
%
% Purpose:
%     - extractSubSysModel returns the submodel made of the reactions annotated with one or more
%       of the given subsystems, and of the metabolites these reactions use.
%       Characterization test that PINS the current behaviour (feature
%       20261102-142225-tier2-test-pilot, Constitution Principle III characterization mode);
%       it must not change the function under test.
%     - Reference values: the reaction and metabolite counts asserted below were recorded from
%       the first run on 2026-11-02 with ecoli_core_model (no solver). They were not derived
%       independently, so they guard consistency, not independent correctness (Tier 5). The
%       reactions themselves are also derived independently from model.subSystems.
%
% Function under test:
%     src/reconstruction/refinement/extractSubSysModel.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - model manipulation, no solver; ecoli_core_model loaded through getDistributedModel.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: A single subsystem name given as text selects almost every reaction
%       SEVERITY: wrong-result
%       TRIGGER: subSysNames given as a character vector, for example
%         extractSubSysModel(model, 'Exchange')
%       OBSERVED: ismember compares the characters of the name with the characters of each
%         subsystem, so every reaction whose subsystem shares one letter with the name is kept
%         (94 of the 95 reactions of ecoli_core_model instead of the 20 exchange reactions)
%       EXPECTED: the reactions annotated with that subsystem only, as for {'Exchange'}
%       LINES: 20
%
% Authors:
%     - Generated for feature 20261102-142225-tier2-test-pilot, 2026-11-02.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testExtractSubSysModel'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox or
% particular operating system, so none is listed
prepareTest();

% load the model once (95 reactions, 72 metabolites, 137 genes, compartments c and e)
model = getDistributedModel('ecoli_core_model.mat');

% the reaction- and metabolite-sized fields of ecoli_core_model, for the structural checks
rxnFields = {'rxns', 'lb', 'ub', 'c', 'rules', 'grRules', 'rxnNames', 'subSystems'};
metFields = {'mets', 'b', 'csense', 'metNames', 'metFormulas'};

%% one subsystem: its reactions and the metabolites they use are kept

subSysModel = extractSubSysModel(model, {'Citric Acid Cycle'});

% the kept reactions are exactly the reactions annotated with the subsystem, in model order
expectedRxns = model.rxns(strcmp(model.subSystems, 'Citric Acid Cycle'));
assert(isequal(subSysModel.rxns, expectedRxns));
[~, rxnIdx] = ismember(subSysModel.rxns, model.rxns);

% the kept metabolites are exactly those used by the kept reactions, in model order
expectedMets = model.mets(any(model.S(:, rxnIdx) ~= 0, 2));
assert(isequal(subSysModel.mets, expectedMets));
[~, metIdx] = ismember(subSysModel.mets, model.mets);

% Tier-5 reference counts (first run, 2026-11-02); the gene list is not reduced
assert(numel(subSysModel.rxns) == 8);
assert(numel(subSysModel.mets) == 21);
assert(isequal(subSysModel.genes, model.genes));

% the result is structurally consistent: S matches mets and rxns, every reaction- and
% metabolite-sized field has one row per entry, rxnGeneMat is reactions x genes and the rules
% only use existing gene indices
nRxns = numel(subSysModel.rxns);
nMets = numel(subSysModel.mets);
assert(isequal(size(subSysModel.S), [nMets, nRxns]));
assert(all(cellfun(@(f) size(subSysModel.(f), 1) == nRxns, rxnFields)));
assert(all(cellfun(@(f) size(subSysModel.(f), 1) == nMets, metFields)));
assert(isequal(size(subSysModel.rxnGeneMat), [nRxns, numel(subSysModel.genes)]));
ruleGeneIdx = str2double(regexp(strjoin(subSysModel.rules', ' '), '(?<=x\()\d+(?=\))', 'match'));
assert(all(ruleGeneIdx >= 1 & ruleGeneIdx <= numel(subSysModel.genes)));

% the content is copied unchanged from the input model (copies, not computations, so equality
% is exact): stoichiometry, bounds, objective, rules and metabolite data
assert(isequal(subSysModel.S, model.S(metIdx, rxnIdx)));
assert(isequal(subSysModel.lb, model.lb(rxnIdx)) && isequal(subSysModel.ub, model.ub(rxnIdx)));
assert(isequal(subSysModel.c, model.c(rxnIdx)));
assert(isequal(subSysModel.rules, model.rules(rxnIdx)));
assert(isequal(subSysModel.grRules, model.grRules(rxnIdx)));
assert(isequal(subSysModel.rxnGeneMat, model.rxnGeneMat(rxnIdx, :)));
assert(isequal(subSysModel.metNames, model.metNames(metIdx)));
assert(isequal(subSysModel.b, model.b(metIdx)) && isequal(subSysModel.csense, model.csense(metIdx)));
assert(isequal(subSysModel.description, model.description));

%% several subsystems: the reactions of all of them are kept

subSysNames = {'Citric Acid Cycle', 'Glycolysis/Gluconeogenesis'};
subSysModel = extractSubSysModel(model, subSysNames);

% the kept reactions are exactly the reactions annotated with any of the subsystems
expectedRxns = model.rxns(ismember(model.subSystems, subSysNames));
assert(isequal(subSysModel.rxns, expectedRxns));
[~, rxnIdx] = ismember(subSysModel.rxns, model.rxns);
expectedMets = model.mets(any(model.S(:, rxnIdx) ~= 0, 2));
assert(isequal(subSysModel.mets, expectedMets));
[~, metIdx] = ismember(subSysModel.mets, model.mets);

% Tier-5 reference counts (first run, 2026-11-02): 8 + 12 reactions
assert(numel(subSysModel.rxns) == 20);
assert(numel(subSysModel.mets) == 32);

% the order of the names does not change the result
assert(isequal(extractSubSysModel(model, fliplr(subSysNames)), subSysModel));

% the result is structurally consistent
nRxns = numel(subSysModel.rxns);
nMets = numel(subSysModel.mets);
assert(isequal(size(subSysModel.S), [nMets, nRxns]));
assert(all(cellfun(@(f) size(subSysModel.(f), 1) == nRxns, rxnFields)));
assert(all(cellfun(@(f) size(subSysModel.(f), 1) == nMets, metFields)));
assert(isequal(size(subSysModel.rxnGeneMat), [nRxns, numel(subSysModel.genes)]));
ruleGeneIdx = str2double(regexp(strjoin(subSysModel.rules', ' '), '(?<=x\()\d+(?=\))', 'match'));
assert(all(ruleGeneIdx >= 1 & ruleGeneIdx <= numel(subSysModel.genes)));

% the stoichiometry and bounds are copied unchanged
assert(isequal(subSysModel.S, model.S(metIdx, rxnIdx)));
assert(isequal(subSysModel.lb, model.lb(rxnIdx)) && isequal(subSysModel.ub, model.ub(rxnIdx)));
assert(isequal(subSysModel.subSystems, model.subSystems(rxnIdx)));

%% a subsystem name that is not in the model gives an empty model

subSysModel = extractSubSysModel(model, {'Not a subsystem'});

% no reaction and no metabolite is kept; every reaction- and metabolite-sized field is empty,
% while the gene list and the model-level fields are kept
assert(isempty(subSysModel.rxns) && isempty(subSysModel.mets));
assert(isequal(size(subSysModel.S), [0, 0]));
assert(all(cellfun(@(f) size(subSysModel.(f), 1) == 0, rxnFields)));
assert(all(cellfun(@(f) size(subSysModel.(f), 1) == 0, metFields)));
assert(isequal(subSysModel.genes, model.genes));
assert(isequal(size(subSysModel.rxnGeneMat), [0, numel(model.genes)]));
assert(isequal(subSysModel.description, model.description));

% change the directory
cd(currentDir)
