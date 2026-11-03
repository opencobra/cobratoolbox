% The COBRAToolbox: testAddReactionGEM.m
%
% Purpose:
%     - addReactionGEM writes reactions given as formula strings into the reaction slots of a
%       model that start at index nRxn: it sets lb, ub, c (0), rxnNames, subSystems, grRules
%       and rules of each slot, parses the formula ('<==>' or '-->', a coefficient before each
%       metabolite) into the slot's column of S, adds the metabolites that are new to the model
%       (with b = 0 and the default values of the other metabolite fields) and sets the gene
%       list to the genes input. The coefficients are added to those already in the column (the
%       help: S is used to determine whether a metabolite already participates in the reactions
%       being replaced). With more than two reactions, or with a hash table input, metabolites
%       are looked up in a java.util.Hashtable, which is returned. The callers in the toolbox
%       (createUniversalReactionModel, createXMatrix) declare the reactions in the model and let
%       this function fill them; the tests below use that pattern: reaction slots of
%       ecoli_core_model whose column of S is emptied (placeholders) are filled again.
%       Characterization test that PINS the current behaviour (feature
%       20261103-105830-tier2-safe-batch, Constitution Principle III characterization mode);
%       it must not change the function under test.
%     - Reference values: the expected models are the input model itself (a placeholder filled
%       with the formula written from its own column of S must give back the original reaction)
%       and the metabolite count and coefficients of hand-written formulas, so they are derived
%       independently. The default values of the metabolite fields of a new metabolite were
%       recorded from the first run on 2026-11-03 with ecoli_core_model (no solver); they guard
%       consistency, not independent correctness (Tier 5).
%     - Every call stores the subsystem of a filled reaction as a cell inside a cell (defect
%       below); no input avoids it, so the subSystems entries of the filled reactions are never
%       compared, and every other field is.
%
% Function under test:
%     src/reconstruction/refinement/addReactionGEM.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - model manipulation, no solver; ecoli_core_model loaded through getDistributedModel.
%
% Coverage exemptions:
%     Line 105, the default nRxn: it appends after the last reaction, which leaves rxns shorter
%     than the other reaction fields (defect below), so the input is skipped.
%     Line 161: strtok never returns a token that is a single space, so the branch for ' '
%     cannot be reached.
%     Lines 169-170: the arrow '=>' is not a documented formula syntax (the help names '-->'
%     and '<==>'), so it is not tested.
%     Lines 256-258: a proteins field of another size than the new gene list discards the whole
%     result (defect below), so the input is skipped.
%     Line 268: a gene field of another size than the new gene list only arises when the gene
%     list is changed, which leaves rxnGeneMat inconsistent (defect below); the input is skipped.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The subsystem of every filled reaction is stored as a cell inside a cell
%       SEVERITY: wrong-result
%       TRIGGER: any call, with or without the subSystems input
%       OBSERVED: subSystems(i,1) (a 1 x 1 cell holding the cell {'name'}) is assigned with
%         braces, so model.subSystems{nRxn} becomes {{'name'}} instead of {'name'} or 'name'
%       EXPECTED: the entry holds the subsystem name (a character array or a cell of character
%         arrays), like every other entry of the field
%       LINES: 64-73, 139
%     - DEFECT: Appended reactions get no identifier, so rxns is shorter than the other fields
%       SEVERITY: wrong-result
%       TRIGGER: nRxn after the last reaction, including the default length(model.lb) + 1, for
%         example addReactionGEM(model, {'NEW'}, {'new'}, {'1 newmet[c] + 1 atp[c] --> 1 adp[c]'},
%         1, 0, 1000) on ecoli_core_model
%       OBSERVED: the rxns input is never stored (the assignment is commented out) and the
%         reaction fields are extended with the original size taken after the call, so lb, ub,
%         c, rxnNames, rules, grRules, subSystems and S have 96 entries while rxns keeps 95 and
%         rxnGeneMat keeps 95 rows
%       EXPECTED: rxns extended with the given identifiers and every reaction field extended
%       LINES: 105, 136, 273
%     - DEFECT: Appending a reaction whose first metabolite is already in the model stops with
%       an error
%       SEVERITY: error
%       TRIGGER: nRxn after the last reaction and a formula whose first metabolite exists, for
%         example '1 atp[c] --> 1 adp[c]'
%       OBSERVED: the existing coefficient is read from a column of S that does not exist yet:
%         "Index exceeds array bounds."
%       EXPECTED: the new column starts empty
%       LINES: 211-212
%     - DEFECT: A formula whose first metabolite has no coefficient stops with an error
%       SEVERITY: error
%       TRIGGER: a formula such as 'atp[c] --> 1 adp[c]'
%       OBSERVED: the coefficient is read from the token before the metabolite, which does not
%         exist for the first token: "Array indices must be positive integers or logical
%         values."; a later metabolite without coefficient gets the coefficient 1
%       EXPECTED: coefficient 1, as for the other metabolites without coefficient
%       LINES: 205
%     - DEFECT: The default gene list removes all genes of the model
%       SEVERITY: wrong-result
%       TRIGGER: a model with genes and no genes input (or a genes input other than model.genes)
%       OBSERVED: model.genes is replaced by the genes input (default cell(0,1)), while rules
%         still refer to x(i) of the old genes and rxnGeneMat keeps its columns; gene fields of
%         the old size (genes*) are removed
%       EXPECTED: the genes of the model kept when no genes are given, and the rules and
%         rxnGeneMat consistent with the new gene list
%       LINES: 100-101, 245-253, 262-271
%     - DEFECT: A new metabolite used twice in one call is added twice or loses a coefficient
%       SEVERITY: wrong-result
%       TRIGGER: a metabolite that is not in the model and appears twice in the formulas of one
%         call
%       OBSERVED: with more than two reactions and no hash table input, new metabolites are not
%         put into the internal hash table, so the second use adds a second row with the same
%         identifier; without a hash table, the existing coefficient of a metabolite that is new
%         is taken as 0, so the second use in one formula overwrites the first
%       EXPECTED: one row per metabolite and the coefficients summed, as for metabolites already
%         in the model
%       LINES: 117-126, 199-201, 210-218
%     - DEFECT: A proteins field of another size than the gene list discards the result
%       SEVERITY: wrong-result
%       TRIGGER: a model with a proteins field whose size differs from the genes input
%       OBSERVED: rmfield is applied to the input model instead of the result, so the filled
%         reactions are lost and the input model (without proteins or proteinNames) is returned
%       EXPECTED: rmfield applied to the result
%       LINES: 256-258
%
% Authors:
%     - Generated for feature 20261103-105830-tier2-safe-batch, 2026-11-03.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testAddReactionGEM'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox or
% particular operating system, so none is listed
prepareTest();

% load the model once (95 reactions, 72 metabolites, 137 genes)
model = getDistributedModel('ecoli_core_model.mat');

% the reactions refilled below: PGK (reversible, one gene), PGL (irreversible, one gene) and
% PGM (reversible, three genes joined by or); they are consecutive (75, 76, 77) because the
% function fills the slots nRxn, nRxn + 1, ...
fillRxns = {'PGK'; 'PGL'; 'PGM'};
fillIdx = findRxnIDs(model, fillRxns);
assert(isequal(fillIdx(:)', fillIdx(1):fillIdx(1) + 2));

% the formula of each of these reactions written from its column of S in the documented
% syntax: a coefficient before every metabolite, '<==>' for reversible and '-->' for
% irreversible reactions
fillFormulas = cell(numel(fillIdx), 1);
for k = 1:numel(fillIdx)
    column = full(model.S(:, fillIdx(k)));
    substrates = find(column < 0);
    products = find(column > 0);
    lhs = strjoin(arrayfun(@(m) sprintf('%.15g %s', -column(m), model.mets{m}), substrates, 'UniformOutput', false)', ' + ');
    rhs = strjoin(arrayfun(@(m) sprintf('%.15g %s', column(m), model.mets{m}), products, 'UniformOutput', false)', ' + ');
    if model.lb(fillIdx(k)) < 0
        fillFormulas{k} = [lhs ' <==> ' rhs];
    else
        fillFormulas{k} = [lhs ' --> ' rhs];
    end
end
isReversible = double(model.lb(fillIdx) < 0);

% the placeholder model: the same model with the columns of S of these reactions emptied
placeholder = model;
placeholder.S(:, fillIdx) = 0;

% the reaction- and metabolite-sized fields of ecoli_core_model, for the structural checks
rxnFields = {'rxns', 'lb', 'ub', 'c', 'rules', 'grRules', 'rxnNames', 'subSystems', 'rxnGeneMat'};
metFields = {'mets', 'b', 'csense', 'metNames', 'metFormulas'};
modelFields = fieldnames(model);

%% two placeholders, all optional inputs given: the original reactions are restored

% two reactions use the direct search of the metabolites (no hash table); the subsystems are
% given as character arrays, which the function wraps into cells
newModel = addReactionGEM(placeholder, fillRxns(1:2), model.rxnNames(fillIdx(1:2)), fillFormulas(1:2), ...
    isReversible(1:2), model.lb(fillIdx(1:2)), model.ub(fillIdx(1:2)), fillIdx(1), ...
    model.subSystems(fillIdx(1:2)), model.grRules(fillIdx(1:2)), model.rules(fillIdx(1:2)), model.genes);

% the expected model: the original model with the third placeholder, not part of the call,
% still empty
expectedModel = model;
expectedModel.S(:, fillIdx(3)) = 0;

% the result has the fields of the input model and, apart from the subsystems of the filled
% reactions (defect in the header), every field equals the expected model: the columns of S
% are restored exactly (integer coefficients) and the other slots and fields are untouched
assert(isequal(sort(fieldnames(newModel)), sort(modelFields)));
for k = 1:numel(modelFields)
    if ~strcmp(modelFields{k}, 'subSystems')
        assert(isequal(newModel.(modelFields{k}), expectedModel.(modelFields{k})), ['field ' modelFields{k} ' changed']);
    end
end
otherRxns = setdiff(1:numel(model.rxns), fillIdx(1:2));
assert(isequal(newModel.subSystems(otherRxns), model.subSystems(otherRxns)));

%% three placeholders: the metabolites are looked up in a hash table, which is returned

[newModel, metTable] = addReactionGEM(placeholder, fillRxns, model.rxnNames(fillIdx), fillFormulas, ...
    isReversible, model.lb(fillIdx), model.ub(fillIdx), fillIdx(1), model.subSystems(fillIdx), ...
    model.grRules(fillIdx), model.rules(fillIdx), model.genes);

% every field except the subsystems of the filled reactions equals the original model, so
% reversible and irreversible formulas and the GPR of PGM (three genes) are all restored
for k = 1:numel(modelFields)
    if ~strcmp(modelFields{k}, 'subSystems')
        assert(isequal(newModel.(modelFields{k}), model.(modelFields{k})), ['field ' modelFields{k} ' changed']);
    end
end
otherRxns = setdiff(1:numel(model.rxns), fillIdx);
assert(isequal(newModel.subSystems(otherRxns), model.subSystems(otherRxns)));

% the returned hash table maps every metabolite of the model to its index
assert(isa(metTable, 'java.util.Hashtable'));
assert(metTable.size() == numel(model.mets));
assert(metTable.get('atp[c]') == findMetIDs(model, 'atp[c]'));
assert(metTable.get(model.mets{end}) == numel(model.mets));

%% a hash table input and a new metabolite: the metabolite is added and put into the table

% the hash table of the caller maps the metabolites of the model to their indices
metTable = java.util.Hashtable;
for k = 1:numel(model.mets)
    metTable.put(model.mets{k}, k);
end

% PGK is refilled with a formula that also uses the new metabolite newmet[c]
newFormula = '1 3pg[c] + 1 atp[c] + 2 newmet[c] <==> 1 13dpg[c] + 1 adp[c]';
[newModel, metTableOut] = addReactionGEM(placeholder, fillRxns(1), {'PGK with newmet'}, {newFormula}, ...
    1, -1000, 1000, fillIdx(1), {'Test subsystem'}, model.grRules(fillIdx(1)), model.rules(fillIdx(1)), model.genes, metTable);

% the new metabolite is appended, and the returned table (the same Java object) maps it to
% its index
nMets = numel(model.mets) + 1;
assert(isequal(newModel.mets, [model.mets; {'newmet[c]'}]));
assert(metTableOut.get('newmet[c]') == nMets);
assert(metTableOut.size() == nMets);

% the result is structurally consistent: S matches mets and rxns, every reaction- and
% metabolite-sized field has one entry per reaction or metabolite, rxnGeneMat is reactions x
% genes and the rules only use existing gene indices
nRxns = numel(newModel.rxns);
assert(isequal(size(newModel.S), [nMets, nRxns]));
assert(all(cellfun(@(f) size(newModel.(f), 1) == nRxns, rxnFields)));
assert(all(cellfun(@(f) size(newModel.(f), 1) == nMets, metFields)));
assert(isequal(size(newModel.rxnGeneMat), [nRxns, numel(newModel.genes)]));
ruleGeneIdx = str2double(regexp(strjoin(newModel.rules', ' '), '(?<=x\()\d+(?=\))', 'match'));
assert(all(ruleGeneIdx >= 1 & ruleGeneIdx <= numel(newModel.genes)));

% the column of PGK holds the hand-written formula; the other columns are unchanged and the
% new metabolite is used by PGK only
expectedColumn = zeros(nMets, 1);
expectedColumn(findMetIDs(newModel, {'3pg[c]', 'atp[c]', 'newmet[c]', '13dpg[c]', 'adp[c]'})) = [-1; -1; -2; 1; 1];
assert(isequal(full(newModel.S(:, fillIdx(1))), expectedColumn));
otherRxns = setdiff(1:nRxns, fillIdx(1));
assert(isequal(newModel.S(1:end - 1, otherRxns), placeholder.S(:, otherRxns)));
assert(nnz(newModel.S(end, otherRxns)) == 0);
assert(strcmp(newModel.rxnNames{fillIdx(1)}, 'PGK with newmet'));
assert(newModel.lb(fillIdx(1)) == -1000 && newModel.ub(fillIdx(1)) == 1000);

% the new metabolite gets b = 0 and the default values of the other metabolite fields: csense
% 'E', its identifier as name and an empty formula (Tier-5 values, first run 2026-11-03); the
% existing metabolites keep theirs
assert(newModel.b(end) == 0 && isequal(newModel.b(1:end - 1), model.b));
assert(newModel.csense(end) == 'E' && isequal(newModel.csense(1:end - 1), model.csense));
assert(strcmp(newModel.metNames{end}, 'newmet[c]') && isequal(newModel.metNames(1:end - 1), model.metNames));
assert(isequal(newModel.metFormulas{end}, '') && isequal(newModel.metFormulas(1:end - 1), model.metFormulas));

%% a metabolite listed twice in one formula

% Filling a slot whose column is not empty is not tested: the coefficients are added to the old
% ones, and whether that is intended is an open question for the maintainer (feature summary).
% in a formula, a metabolite without coefficient (after the first) gets the coefficient 1, and
% a metabolite that is listed twice gets the sum of its coefficients: h2o[c] is -1 + -1
newModel = addReactionGEM(placeholder, fillRxns(2), {'PGL variant'}, {'1 6pgl[c] + h2o[c] + 1 h2o[c] --> 1 6pgc[c] + 1 h[c]'}, ...
    0, 0, 1000, fillIdx(2), model.subSystems(fillIdx(2)), model.grRules(fillIdx(2)), model.rules(fillIdx(2)), model.genes);
expectedColumn = zeros(numel(model.mets), 1);
expectedColumn(findMetIDs(model, {'6pgl[c]', 'h2o[c]', '6pgc[c]', 'h[c]'})) = [-1; -2; 1; 1];
assert(isequal(full(newModel.S(:, fillIdx(2))), expectedColumn));

%% defaults: subSystems, grRules and rules default to empty, and missing fields are created

% a placeholder without GPR (empty rules and grRules, no rxnGeneMat entries) in a model
% without the subSystems and grRules fields
noGprModel = placeholder;
noGprModel.rules(fillIdx) = {''};
noGprModel.rxnGeneMat(fillIdx, :) = 0;
noGprModel = rmfield(noGprModel, {'subSystems', 'grRules'});
newModel = addReactionGEM(noGprModel, fillRxns, model.rxnNames(fillIdx), fillFormulas, ...
    isReversible, model.lb(fillIdx), model.ub(fillIdx), fillIdx(1), [], [], [], model.genes);

% the missing fields are created with an empty entry for every reaction, and the filled
% reactions get empty rules and grRules
nRxns = numel(model.rxns);
assert(isequal(newModel.grRules, repmat({''}, nRxns, 1)));
assert(isequal(size(newModel.subSystems), [nRxns, 1]));
otherRxns = setdiff(1:nRxns, fillIdx);
assert(isequal(newModel.subSystems(otherRxns), repmat({''}, numel(otherRxns), 1)));
assert(isequal(newModel.rules, noGprModel.rules));

% the stoichiometry and bounds are restored as with all inputs given
assert(isequal(newModel.S, model.S));
assert(isequal(newModel.lb, model.lb) && isequal(newModel.ub, model.ub) && isequal(newModel.c, model.c));
assert(isequal(newModel.rxnNames, model.rxnNames));
assert(isequal(newModel.rxnGeneMat, noGprModel.rxnGeneMat) && isequal(newModel.genes, model.genes));

%% a model without genes: the default gene list is empty

% the model without the gene fields and with empty GPRs (a reconstruction without genes)
noGeneModel = rmfield(placeholder, {'genes', 'rxnGeneMat'});
noGeneModel.rules(:) = {''};
noGeneModel.grRules(:) = {''};
newModel = addReactionGEM(noGeneModel, fillRxns(1:2), model.rxnNames(fillIdx(1:2)), fillFormulas(1:2), ...
    isReversible(1:2), model.lb(fillIdx(1:2)), model.ub(fillIdx(1:2)), fillIdx(1), ...
    model.subSystems(fillIdx(1:2)), noGeneModel.grRules(fillIdx(1:2)), noGeneModel.rules(fillIdx(1:2)));

% the model gets an empty gene list; the two reactions are restored (the third placeholder
% stays empty) and the GPRs stay empty
assert(isequal(size(newModel.genes), [0, 1]));
assert(isequal(newModel.S(:, [1:fillIdx(2), fillIdx(3) + 1:end]), model.S(:, [1:fillIdx(2), fillIdx(3) + 1:end])));
assert(nnz(newModel.S(:, fillIdx(3))) == 0);
assert(isequal(newModel.rules, noGeneModel.rules) && isequal(newModel.grRules, noGeneModel.grRules));
assert(isequal(newModel.lb, model.lb) && isequal(newModel.ub, model.ub));

%% a proteins field of the size of the gene list is kept

% a gene-sized proteins field built from the gene identifiers
proteinModel = placeholder;
proteinModel.proteins = strcat(model.genes, '_protein');
newModel = addReactionGEM(proteinModel, fillRxns(1:2), model.rxnNames(fillIdx(1:2)), fillFormulas(1:2), ...
    isReversible(1:2), model.lb(fillIdx(1:2)), model.ub(fillIdx(1:2)), fillIdx(1), ...
    model.subSystems(fillIdx(1:2)), model.grRules(fillIdx(1:2)), model.rules(fillIdx(1:2)), model.genes);
assert(isequal(newModel.proteins, proteinModel.proteins));
assert(isequal(newModel.genes, model.genes));
assert(isequal(newModel.S(:, fillIdx(1:2)), model.S(:, fillIdx(1:2))));

% change the directory
cd(currentDir)
