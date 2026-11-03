% The COBRAToolbox: testRemoveCompartments.m
%
% Purpose:
%     - removeCompartments renames the metabolites of the given compartments into one new
%       compartment (default [c]), rebuilds the model reaction by reaction with addReaction, sums
%       the stoichiometry of metabolites that become identical and drops the reactions whose column
%       becomes empty.
%       Characterization test that PINS the current behaviour (feature
%       20261102-142225-tier2-test-pilot, Constitution Principle III characterization mode);
%       it must not change the function under test.
%     - Reference values: the reaction and metabolite counts asserted below were recorded from
%       the first run on 2026-11-02 with ecoli_core_model (no solver). They were not derived
%       independently, so they guard consistency, not independent correctness (Tier 5). The
%       expected stoichiometry and the dropped reactions are also derived independently, by
%       renaming the metabolite identifiers and summing the rows of S that get the same name.
%     - The function switches all MATLAB warnings off and does not restore them (defect below);
%       every section restores the warning state saved before the first section, so that the
%       test leaves no global state behind. The function prints the default compartment and the
%       index of every reaction (defect below); this output is not suppressed.
%     - The result has no rxnGeneMat (defect below), so the structural check of the gene
%       associations uses rules: every rule only refers to existing gene indices.
%
% Function under test:
%     src/reconstruction/modelGeneration/removeCompartments.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - model manipulation, no solver; ecoli_core_model loaded through getDistributedModel.
%
% Coverage exemptions:
%     Line 93, the removal of rxnGeneMat rows: the result is built from an empty structure and
%     addReaction never creates rxnGeneMat, so the field never exists at that point.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: All MATLAB warnings are switched off and never switched back on
%       SEVERITY: limitation
%       TRIGGER: any call, for example removeCompartments(model, {'e'})
%       OBSERVED: warning('OFF') at the start disables every warning for the rest of the MATLAB
%         session; warnings of addReaction (repeated metabolites) and of all later code are hidden
%       EXPECTED: warnings stay visible, or the previous warning state is restored before return
%       LINES: 36
%     - DEFECT: The default compartment and every reaction index are printed
%       SEVERITY: cosmetic
%       TRIGGER: any call; the default compartment is printed when newComp is not given
%       OBSERVED: the assignment of newComp and the loop variable i are not terminated by a
%         semicolon, so newComp = '[c]' and one line per reaction (95 for ecoli_core_model) are
%         printed
%       EXPECTED: no output, or output gated behind a printLevel
%       LINES: 38, 57
%     - DEFECT: Reactions that become duplicates are not removed
%       SEVERITY: wrong-result
%       TRIGGER: removeCompartments(model, {'e'}) on ecoli_core_model
%       OBSERVED: ATPM and GLNabc have the same column of S after the merge (gln[e] and gln[c]
%         cancel in GLNabc) and both are kept; only reactions whose column is empty are removed
%       EXPECTED: duplicate and empty entries removed, as the help text states
%       LINES: 79-89
%     - DEFECT: metNames is a row and holds the metabolite identifiers
%       SEVERITY: wrong-result
%       TRIGGER: any call
%       OBSERVED: metNames is 1 x m while mets is m x 1, and it holds the new metabolite
%         identifiers (for example acald[c]) instead of the metabolite names of the input model
%       EXPECTED: an m x 1 metNames with the names of the input model
%       LINES: 50, 70
%     - DEFECT: An empty rev field is left when no reaction is removed
%       SEVERITY: cosmetic
%       TRIGGER: a call in which no reaction column becomes empty, for example
%         removeCompartments(model, {'e'}, '[x]')
%       OBSERVED: the result has a field rev of size 0 x 0 next to 95 reactions; the field is only
%         removed when a reaction is removed
%       EXPECTED: no rev field, or one entry per reaction
%       LINES: 53, 74, 107
%     - DEFECT: Annotation and constraint fields of the input model are dropped
%       SEVERITY: limitation
%       TRIGGER: any call
%       OBSERVED: the result keeps only genes, rxns, mets, metNames, S, subSystems, lb, ub, c,
%         rules, grRules and b; rxnGeneMat, rxnNames, metFormulas, csense, osenseStr,
%         description and modelID of the input model are lost
%       EXPECTED: the reaction, metabolite and model fields of the input model carried over to
%         the merged entries
%       LINES: 46-55
%
% Authors:
%     - Generated for feature 20261102-142225-tier2-test-pilot, 2026-11-02.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testRemoveCompartments'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox or
% particular operating system, so none is listed
prepareTest();

% load the model once (95 reactions, 72 metabolites, 137 genes, compartments c and e)
model = getDistributedModel('ecoli_core_model.mat');

% the warning state before the test; removeCompartments switches all warnings off (known defect)
warningState = warning;

% the reaction- and metabolite-sized fields of the result, for the structural checks
rxnFields = {'rxns', 'lb', 'ub', 'c', 'rules', 'grRules', 'subSystems'};
metFields = {'mets', 'b'};

% stoichiometric coefficients are summed when two metabolites merge; sums of at most two
% coefficients from the same model, so the only difference allowed is rounding
tol = 1e-12;

%% removing compartment e with the default new compartment [c] merges e into c

decompModel = removeCompartments(model, {'e'});
warning(warningState);

% the expected result, derived independently: each metabolite of e is renamed into c, the rows
% of S with the same new name are summed, and the reactions whose column becomes empty are dropped
renamedMets = regexprep(model.mets, '\[e\]$', '[c]');
[expectedMets, ~, newMetIdx] = unique(renamedMets);
mergeMatrix = sparse(newMetIdx, 1:numel(model.mets), 1, numel(expectedMets), numel(model.mets));
expectedS = mergeMatrix * model.S;
keptRxns = full(any(expectedS, 1))';

% the kept reactions are the reactions with a non-empty merged column, in model order, and the
% metabolites are the merged metabolites; no metabolite of e is left
assert(isequal(decompModel.rxns, model.rxns(keptRxns)));
assert(isequal(sort(decompModel.mets), expectedMets));
assert(all(endsWith(decompModel.mets, '[c]')));

% Tier-5 reference counts (first run, 2026-11-02): 18 transport reactions vanish
assert(numel(decompModel.rxns) == 77);
assert(numel(decompModel.mets) == 54);
assert(nnz(~keptRxns) == 18);

% the result is structurally consistent: S matches mets and rxns, every reaction- and
% metabolite-sized field has one entry per reaction or metabolite, the gene list is kept and the
% rules only use existing gene indices
nRxns = numel(decompModel.rxns);
nMets = numel(decompModel.mets);
assert(isequal(size(decompModel.S), [nMets, nRxns]));
assert(all(cellfun(@(f) isequal(size(decompModel.(f)), [nRxns, 1]), rxnFields)));
assert(all(cellfun(@(f) isequal(size(decompModel.(f)), [nMets, 1]), metFields)));
assert(numel(decompModel.metNames) == nMets);
assert(isequal(decompModel.genes, model.genes));
ruleGeneIdx = str2double(regexp(strjoin(decompModel.rules', ' '), '(?<=x\()\d+(?=\))', 'match'));
assert(all(ruleGeneIdx >= 1 & ruleGeneIdx <= numel(decompModel.genes)));
assert(~isfield(decompModel, 'rev'));

% the stoichiometry is the merged stoichiometry of the input model (tolerance: see tol above)
[~, rxnIdx] = ismember(decompModel.rxns, model.rxns);
[~, metIdx] = ismember(decompModel.mets, expectedMets);
assert(max(max(abs(decompModel.S - expectedS(metIdx, keptRxns)))) < tol);

% merged metabolites have summed stoichiometry: ATPS4r uses 4 h[e] and makes 3 h[c], so the
% merged h[c] has the sum of both coefficients (integers, so equality is exact)
atpsCol = strcmp(decompModel.rxns, 'ATPS4r');
hRow = strcmp(decompModel.mets, 'h[c]');
summedCoef = model.S(strcmp(model.mets, 'h[e]'), strcmp(model.rxns, 'ATPS4r')) ...
    + model.S(strcmp(model.mets, 'h[c]'), strcmp(model.rxns, 'ATPS4r'));
assert(full(decompModel.S(hRow, atpsCol)) == full(summedCoef));
assert(full(decompModel.S(hRow, atpsCol)) == -1);

% bounds, objective, subsystems and gene rules are carried over (copies, so equality is exact;
% addReaction stores each subsystem in a cell and normalises the blanks of the rules)
assert(isequal(decompModel.lb, model.lb(rxnIdx)) && isequal(decompModel.ub, model.ub(rxnIdx)));
assert(isequal(decompModel.c, model.c(rxnIdx)));
assert(isequal(cellfun(@(s) s{1}, decompModel.subSystems, 'UniformOutput', false), ...
    model.subSystems(rxnIdx)));
assert(isequal(regexprep(decompModel.grRules, '\s', ''), regexprep(model.grRules(rxnIdx), '\s', '')));
assert(isequal(regexprep(decompModel.rules, '\s', ''), regexprep(model.rules(rxnIdx), '\s', '')));
assert(isequal(decompModel.b, zeros(nMets, 1)));

%% an explicit new compartment renames the metabolites without merging

decompModel = removeCompartments(model, {'e'}, '[x]');
warning(warningState);

% e is renamed to x, no two metabolites get the same name, so every reaction is kept in model
% order (Tier-5 counts, first run 2026-11-02: 95 reactions, 72 metabolites)
renamedMets = regexprep(model.mets, '\[e\]$', '[x]');
assert(isequal(decompModel.rxns, model.rxns));
assert(isequal(sort(decompModel.mets), sort(renamedMets)));
assert(nnz(endsWith(decompModel.mets, '[x]')) == nnz(endsWith(model.mets, '[e]')));
assert(numel(decompModel.rxns) == 95);
assert(numel(decompModel.mets) == 72);

% the result is structurally consistent
nRxns = numel(decompModel.rxns);
nMets = numel(decompModel.mets);
assert(isequal(size(decompModel.S), [nMets, nRxns]));
assert(all(cellfun(@(f) isequal(size(decompModel.(f)), [nRxns, 1]), rxnFields)));
assert(all(cellfun(@(f) isequal(size(decompModel.(f)), [nMets, 1]), metFields)));
assert(numel(decompModel.metNames) == nMets);
assert(isequal(decompModel.genes, model.genes));
ruleGeneIdx = str2double(regexp(strjoin(decompModel.rules', ' '), '(?<=x\()\d+(?=\))', 'match'));
assert(all(ruleGeneIdx >= 1 & ruleGeneIdx <= numel(decompModel.genes)));

% the stoichiometry and bounds are copied unchanged (nothing is summed, so equality is exact)
[~, metIdx] = ismember(decompModel.mets, renamedMets);
assert(isequal(decompModel.S, model.S(metIdx, :)));
assert(isequal(decompModel.lb, model.lb) && isequal(decompModel.ub, model.ub));
assert(isequal(decompModel.c, model.c));

%% removing both compartments into one new compartment

decompModel = removeCompartments(model, {'c', 'e'}, '[x]');
warning(warningState);

% the expected result, derived independently as in the first section
renamedMets = regexprep(model.mets, '\[[ce]\]$', '[x]');
[expectedMets, ~, newMetIdx] = unique(renamedMets);
mergeMatrix = sparse(newMetIdx, 1:numel(model.mets), 1, numel(expectedMets), numel(model.mets));
expectedS = mergeMatrix * model.S;
keptRxns = full(any(expectedS, 1))';

% every metabolite is in x; the same reactions as with the default vanish (Tier-5 counts, first
% run 2026-11-02: 77 reactions, 54 metabolites)
assert(isequal(decompModel.rxns, model.rxns(keptRxns)));
assert(isequal(sort(decompModel.mets), expectedMets));
assert(all(endsWith(decompModel.mets, '[x]')));
assert(numel(decompModel.rxns) == 77);
assert(numel(decompModel.mets) == 54);

% the result is structurally consistent and holds the merged stoichiometry (tolerance: see tol)
nRxns = numel(decompModel.rxns);
nMets = numel(decompModel.mets);
assert(isequal(size(decompModel.S), [nMets, nRxns]));
assert(all(cellfun(@(f) isequal(size(decompModel.(f)), [nRxns, 1]), rxnFields)));
assert(all(cellfun(@(f) isequal(size(decompModel.(f)), [nMets, 1]), metFields)));
assert(isequal(decompModel.genes, model.genes));
[~, metIdx] = ismember(decompModel.mets, expectedMets);
assert(max(max(abs(decompModel.S - expectedS(metIdx, keptRxns)))) < tol);

%% compartments written in parentheses are removed as well

% the input is derived from the loaded model: every [c] and [e] suffix is written as (c) and (e)
parenModel = model;
parenModel.mets = regexprep(model.mets, '\[([ce])\]$', '($1)');
decompModel = removeCompartments(parenModel, {'e'}, '(c)');
warning(warningState);

% the result equals the bracket case of the first section, with (c) suffixes (Tier-5 counts,
% first run 2026-11-02: 77 reactions, 54 metabolites)
renamedMets = regexprep(parenModel.mets, '\(e\)$', '(c)');
[expectedMets, ~, newMetIdx] = unique(renamedMets);
mergeMatrix = sparse(newMetIdx, 1:numel(model.mets), 1, numel(expectedMets), numel(model.mets));
expectedS = mergeMatrix * model.S;
keptRxns = full(any(expectedS, 1))';
assert(isequal(decompModel.rxns, model.rxns(keptRxns)));
assert(isequal(sort(decompModel.mets), expectedMets));
assert(all(endsWith(decompModel.mets, '(c)')));
assert(numel(decompModel.rxns) == 77);
assert(numel(decompModel.mets) == 54);
nRxns = numel(decompModel.rxns);
nMets = numel(decompModel.mets);
assert(isequal(size(decompModel.S), [nMets, nRxns]));
[~, metIdx] = ismember(decompModel.mets, expectedMets);
assert(max(max(abs(decompModel.S - expectedS(metIdx, keptRxns)))) < tol);
clear parenModel

% change the directory
cd(currentDir)
