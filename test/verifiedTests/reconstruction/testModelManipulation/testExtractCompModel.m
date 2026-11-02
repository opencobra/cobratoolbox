% The COBRAToolbox: testExtractCompModel.m
%
% Purpose:
%     - extractCompModel returns the submodel of one compartment: the reactions that use only
%       metabolites of that compartment (default), or every reaction that uses at least one of
%       them (intOnlyFlag false), optionally without the genes that no kept reaction uses
%       (updateGenes true). An unknown compartment symbol gives a warning and an empty result.
%       Characterization test that PINS the current behaviour (feature
%       20261102-142225-tier2-test-pilot, Constitution Principle III characterization mode);
%       it must not change the function under test.
%     - Reference values: the reaction, metabolite and gene counts asserted below were recorded
%       from the first run on 2026-11-02 with ecoli_core_model (no solver). They were not
%       derived independently, so they guard consistency, not independent correctness (Tier 5).
%       The kept reactions and genes are also derived independently from model.S and
%       model.rxnGeneMat.
%
% Function under test:
%     src/reconstruction/refinement/extractCompModel.m
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
fileDir = fileparts(which('testExtractCompModel'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox or
% particular operating system, so none is listed
prepareTest();

% load the model once (95 reactions, 72 metabolites, 137 genes, compartments c and e)
model = getDistributedModel('ecoli_core_model.mat');

% the reaction- and metabolite-sized fields of ecoli_core_model, for the structural checks
rxnFields = {'rxns', 'lb', 'ub', 'c', 'rules', 'grRules', 'rxnNames', 'subSystems'};
metFields = {'mets', 'b', 'csense', 'metNames', 'metFormulas'};

%% compartment c, default options: only reactions entirely inside c are kept

compModel = extractCompModel(model, 'c');

% the kept reactions are exactly those whose metabolites are all in [c], in model order
isCytosolMet = ~cellfun(@isempty, regexp(model.mets, '\[c\]$'));
isInternalRxn = any(model.S(isCytosolMet, :) ~= 0, 1)' & ~any(model.S(~isCytosolMet, :) ~= 0, 1)';
assert(isequal(compModel.rxns, model.rxns(isInternalRxn)));
[~, rxnIdx] = ismember(compModel.rxns, model.rxns);

% the kept metabolites are exactly those used by the kept reactions; all are in [c]
assert(isequal(compModel.mets, model.mets(any(model.S(:, rxnIdx) ~= 0, 2))));
assert(all(~cellfun(@isempty, regexp(compModel.mets, '\[c\]$'))));
[~, metIdx] = ismember(compModel.mets, model.mets);

% Tier-5 reference counts (first run, 2026-11-02); the default keeps every gene
assert(numel(compModel.rxns) == 50);
assert(numel(compModel.mets) == 51);
assert(isequal(compModel.genes, model.genes));

% the description is extended with the compartment symbol
assert(strcmp(compModel.description, [model.description ' Compartment:c']));

% the default intOnlyFlag is true and the default updateGenes is false
assert(isequal(extractCompModel(model, 'c', true), compModel));
assert(isequal(extractCompModel(model, 'c', true, false), compModel));

% the result is structurally consistent: S matches mets and rxns, every reaction- and
% metabolite-sized field has one row per entry, rxnGeneMat is reactions x genes and the rules
% only use existing gene indices
nRxns = numel(compModel.rxns);
nMets = numel(compModel.mets);
assert(isequal(size(compModel.S), [nMets, nRxns]));
assert(all(cellfun(@(f) size(compModel.(f), 1) == nRxns, rxnFields)));
assert(all(cellfun(@(f) size(compModel.(f), 1) == nMets, metFields)));
assert(isequal(size(compModel.rxnGeneMat), [nRxns, numel(compModel.genes)]));
ruleGeneIdx = str2double(regexp(strjoin(compModel.rules', ' '), '(?<=x\()\d+(?=\))', 'match'));
assert(all(ruleGeneIdx >= 1 & ruleGeneIdx <= numel(compModel.genes)));

% the content is copied unchanged from the input model (copies, not computations, so equality
% is exact)
assert(isequal(compModel.S, model.S(metIdx, rxnIdx)));
assert(isequal(compModel.lb, model.lb(rxnIdx)) && isequal(compModel.ub, model.ub(rxnIdx)));
assert(isequal(compModel.c, model.c(rxnIdx)));
assert(isequal(compModel.rules, model.rules(rxnIdx)));
assert(isequal(compModel.rxnGeneMat, model.rxnGeneMat(rxnIdx, :)));
assert(isequal(compModel.metNames, model.metNames(metIdx)));

%% compartment c with transport reactions: every reaction that uses a metabolite of c is kept

compModel = extractCompModel(model, 'c', false);

% the kept reactions are exactly those with at least one [c] metabolite; their other
% metabolites (in [e]) are kept too
isCytosolMet = ~cellfun(@isempty, regexp(model.mets, '\[c\]$'));
assert(isequal(compModel.rxns, model.rxns(any(model.S(isCytosolMet, :) ~= 0, 1)')));
[~, rxnIdx] = ismember(compModel.rxns, model.rxns);
assert(isequal(compModel.mets, model.mets(any(model.S(:, rxnIdx) ~= 0, 2))));
[~, metIdx] = ismember(compModel.mets, model.mets);

% Tier-5 reference counts (first run, 2026-11-02): all 72 metabolites are used by these
% reactions
assert(numel(compModel.rxns) == 75);
assert(numel(compModel.mets) == 72);
assert(isequal(compModel.genes, model.genes));

% the result is structurally consistent and copied unchanged
nRxns = numel(compModel.rxns);
nMets = numel(compModel.mets);
assert(isequal(size(compModel.S), [nMets, nRxns]));
assert(all(cellfun(@(f) size(compModel.(f), 1) == nRxns, rxnFields)));
assert(all(cellfun(@(f) size(compModel.(f), 1) == nMets, metFields)));
assert(isequal(size(compModel.rxnGeneMat), [nRxns, numel(compModel.genes)]));
assert(isequal(compModel.S, model.S(metIdx, rxnIdx)));
assert(isequal(compModel.lb, model.lb(rxnIdx)) && isequal(compModel.ub, model.ub(rxnIdx)));

%% compartment e: the exchange reactions only, or with the transport reactions

isExternalMet = ~cellfun(@isempty, regexp(model.mets, '\[e\]$'));

% intOnlyFlag true: the reactions whose metabolites are all in [e], which are the 20 exchange
% reactions (Tier-5 counts, first run 2026-11-02)
compModel = extractCompModel(model, 'e', true);
isInternalRxn = any(model.S(isExternalMet, :) ~= 0, 1)' & ~any(model.S(~isExternalMet, :) ~= 0, 1)';
assert(isequal(compModel.rxns, model.rxns(isInternalRxn)));
assert(all(strncmp(compModel.rxns, 'EX_', 3)));
assert(numel(compModel.rxns) == 20 && numel(compModel.mets) == 20);
assert(strcmp(compModel.description, [model.description ' Compartment:e']));
assert(isequal(size(compModel.S), [numel(compModel.mets), numel(compModel.rxns)]));

% intOnlyFlag false: every reaction with an [e] metabolite (Tier-5 counts, first run
% 2026-11-02)
compModel = extractCompModel(model, 'e', false);
assert(isequal(compModel.rxns, model.rxns(any(model.S(isExternalMet, :) ~= 0, 1)')));
assert(numel(compModel.rxns) == 45 && numel(compModel.mets) == 49);
assert(isequal(size(compModel.S), [numel(compModel.mets), numel(compModel.rxns)]));

%% updateGenes true: genes that no kept reaction uses are removed and the rules are renumbered

compModel = extractCompModel(model, 'c', true, true);

% the reactions are the same as without updateGenes
[~, rxnIdx] = ismember(compModel.rxns, model.rxns);
isCytosolMet = ~cellfun(@isempty, regexp(model.mets, '\[c\]$'));
isInternalRxn = any(model.S(isCytosolMet, :) ~= 0, 1)' & ~any(model.S(~isCytosolMet, :) ~= 0, 1)';
assert(isequal(compModel.rxns, model.rxns(isInternalRxn)));

% the kept genes are exactly those associated with a kept reaction in the input rxnGeneMat,
% in model order (Tier-5 count, first run 2026-11-02)
assert(isequal(compModel.genes, model.genes(any(model.rxnGeneMat(rxnIdx, :), 1)')));
assert(numel(compModel.genes) == 88);

% rxnGeneMat is reactions x kept genes and equals the input columns of the kept genes
[~, geneIdx] = ismember(compModel.genes, model.genes);
assert(isequal(size(compModel.rxnGeneMat), [numel(compModel.rxns), numel(compModel.genes)]));
assert(isequal(compModel.rxnGeneMat ~= 0, model.rxnGeneMat(rxnIdx, geneIdx) ~= 0));

% the renumbered rules only use existing gene indices and, written with gene names, are the
% rules of the input model: the GPR of every kept reaction is unchanged
ruleGeneIdx = str2double(regexp(strjoin(compModel.rules', ' '), '(?<=x\()\d+(?=\))', 'match'));
assert(all(ruleGeneIdx >= 1 & ruleGeneIdx <= numel(compModel.genes)));
keptGenes = compModel.genes;
allGenes = model.genes;
namedRules = regexprep(compModel.rules, 'x\((\d+)\)', '${keptGenes{str2double($1)}}');
expectedNamedRules = regexprep(model.rules(rxnIdx), 'x\((\d+)\)', '${allGenes{str2double($1)}}');
assert(isequal(namedRules, expectedNamedRules));
assert(isequal(compModel.grRules, model.grRules(rxnIdx)));

%% an unknown compartment symbol gives a warning and an empty result

% the warning stays visible; lastwarn is reset only to read its message afterwards
lastwarn('');
compModel = extractCompModel(model, 'm');
assert(isempty(compModel));
assert(strcmp(lastwarn, 'Compartment symbol not found'));

% change the directory
cd(currentDir)
