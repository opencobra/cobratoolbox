% The COBRAToolbox: testAddReactionsHH.m
%
% Purpose:
%     - addReactionsHH adds reactions to a whole-body model, each with its name, subsystem,
%       optional gene rule, notes and references, and couples every added reaction whose
%       identifier does not start with an exchange, diet, excretion or blood-brain-barrier
%       prefix to the biomass maintenance reaction of its organ (the identifier part before the
%       first underscore): one coupling constraint for an irreversible reaction and two for a
%       reversible one, with the coupling factor 20000. A reaction that already exists gives a
%       warning and is not added.
%       Characterization test that PINS the current behaviour (feature
%       20261103-105830-tier2-safe-batch, Constitution Principle III characterization mode);
%       it must not change the function under test.
%     - Whole-body models are not distributed. Reactions with an exempt prefix (EX_, Diet_, BBB_,
%       ...) are added to the distributed ecoli_core_model as is. For the coupled reactions the
%       test builds a fixture from ecoli_core_model: three copies of its biomass reaction under
%       the whole-body names of an organ biomass maintenance reaction
%       (Liver_biomass_maintenance, sIEC_biomass_reactionIEC01b and
%       Brain_biomass_maintenance_noTrTr), so that each lookup of the organ biomass reaction is
%       reached. The notes and references fields, which ecoli_core_model lacks, are built as
%       empty per-reaction fields in the section that uses them.
%     - Reference values: the reaction and metabolite counts and the coupling coefficients
%       asserted below were recorded from the first run on 2026-11-03 with ecoli_core_model (no
%       solver). They were not derived independently, so they guard consistency, not independent
%       correctness (Tier 5). The stoichiometry of the added reactions and the coupling
%       constraints are also derived independently from the reaction formulas and the
%       documented coupling rule.
%
% Function under test:
%     src/analysis/wholeBody/PSCMToolbox/io/addReactionsHH.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - model manipulation, no solver; ecoli_core_model loaded through getDistributedModel.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The coupling factor given by the caller is ignored
%       SEVERITY: unusable-option
%       TRIGGER: a couplingFactor other than 20000, for example
%         addReactionsHH(model, {'Liver_NEWRXN'}, {'new'}, {'glc-D[c] -> g6p[c]'}, {''},
%         {'Glycolysis'}, 500) on a model with Liver_biomass_maintenance, or an empty
%         couplingFactor []
%       OBSERVED: a non-empty value is replaced by 20000 (the coupling coefficient is -20000);
%         an empty value is passed on as empty and coupleRxnList2Rxn then uses its own default
%         1000 (the coefficient is -1000)
%       EXPECTED: the given coupling factor is used, and 20000 when it is empty or not given
%       LINES: 36-38
%     - DEFECT: rxnGeneMat is not updated for the gene rules of the added reactions
%       SEVERITY: wrong-result
%       TRIGGER: a non-empty gene rule on a model with rxnGeneMat, for example the rule
%         'b0008 or b9999' on ecoli_core_model
%       OBSERVED: changeGeneAssociation is called with addRxnGeneMat = 0, so the row of the new
%         reaction stays empty and the new gene b9999 gets no column: rxnGeneMat is 96 x 137
%         while genes has 138 entries
%       EXPECTED: rxnGeneMat with one column per gene and the associations of the new rule
%       LINES: 60
%
% Authors:
%     - Generated for feature 20261103-105830-tier2-safe-batch, 2026-11-03.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testAddReactionsHH'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox or
% particular operating system, so none is listed
prepareTest();

% load the model once (95 reactions, 72 metabolites, 137 genes, compartments c and e; it has no
% glycerol metabolite)
model = getDistributedModel('ecoli_core_model.mat');

% the fixture for the coupled reactions: the model with three copies of its biomass reaction
% under whole-body organ biomass names (reactions 96 to 98)
biomassFormula = printRxnFormula(model, 'rxnAbbrList', 'Biomass_Ecoli_core_w_GAM', 'printFlag', 0);
organModel = addReaction(model, 'Liver_biomass_maintenance', 'reactionFormula', biomassFormula{1});
organModel = addReaction(organModel, 'sIEC_biomass_reactionIEC01b', 'reactionFormula', biomassFormula{1});
organModel = addReaction(organModel, 'Brain_biomass_maintenance_noTrTr', 'reactionFormula', biomassFormula{1});

% the reaction- and metabolite-sized fields of ecoli_core_model, for the structural checks
rxnFields = {'rxns', 'lb', 'ub', 'c', 'rules', 'grRules', 'rxnNames', 'subSystems'};
metFields = {'mets', 'b', 'csense', 'metNames', 'metFormulas'};

%% reactions with an exempt prefix are added without coupling constraints

rxnAbbrs = {'EX_glyc[e]', 'Diet_EX_glyc[d]', 'BBB_GLYCt'};
rxnNames = {'Glycerol exchange', 'Glycerol diet uptake', 'Glycerol transport'};
formulas = {'glyc[e] <=> ', 'glyc[d] <=> glyc[e]', 'glyc[e] -> glyc[c]'};
subSystems = {'Exchange', 'Diet', 'Transport'};
newModel = addReactionsHH(model, rxnAbbrs, rxnNames, formulas, {'', '', ''}, subSystems);

% the reactions are appended in the given order with their names and subsystems; the three
% glycerol metabolites are new (Tier-5 counts, first run 2026-11-03)
assert(isequal(newModel.rxns, [model.rxns; rxnAbbrs']));
assert(isequal(newModel.mets, [model.mets; {'glyc[e]'; 'glyc[d]'; 'glyc[c]'}]));
assert(numel(newModel.rxns) == 98 && numel(newModel.mets) == 75);
assert(isequal(newModel.rxnNames(96:98), rxnNames'));
assert(isequal(newModel.subSystems(96:98), subSystems'));

% the stoichiometry follows the formulas and the bounds their direction
expectedS = sparse([73, 74, 73, 73, 75], [1, 2, 2, 3, 3], [-1, -1, 1, -1, 1], 75, 3);
assert(isequal(newModel.S(:, 96:98), expectedS));
assert(isequal(newModel.lb(96:98), [-1000; -1000; 0]) && isequal(newModel.ub(96:98), [1000; 1000; 1000]));

% no coupling constraint is added and no helper field is left
assert(~any(isfield(newModel, {'C', 'd', 'dsense', 'ctrs', 'A'})));

% the result is structurally consistent and the input model is copied unchanged (copies, so
% equality is exact)
nRxns = numel(newModel.rxns);
nMets = numel(newModel.mets);
assert(isequal(size(newModel.S), [nMets, nRxns]));
assert(all(cellfun(@(f) size(newModel.(f), 1) == nRxns, rxnFields)));
assert(all(cellfun(@(f) size(newModel.(f), 1) == nMets, metFields)));
assert(isequal(size(newModel.rxnGeneMat), [nRxns, numel(newModel.genes)]));
assert(isequal(newModel.genes, model.genes));
assert(isequal(newModel.S(1:72, 1:95), model.S));
assert(isequal(newModel.lb(1:95), model.lb) && isequal(newModel.ub(1:95), model.ub));
assert(isequal(newModel.rules(1:95), model.rules));

%% organ reactions are coupled to the biomass maintenance reaction of their organ

rxnAbbrs = {'Liver_GLYCt', 'Liver_GLYK'};
formulas = {'glyc[e] <=> glyc[c]', 'glyc[c] + atp[c] -> glyc3p[c] + adp[c] + h[c]'};
newModel = addReactionsHH(organModel, rxnAbbrs, {'Glycerol transport', 'Glycerol kinase'}, ...
    formulas, {'', ''}, {'Transport', 'Glycerol metabolism'});

% both reactions are appended after the fixture reactions (Tier-5 counts, first run 2026-11-03)
assert(isequal(newModel.rxns, [organModel.rxns; rxnAbbrs']));
assert(numel(newModel.rxns) == 100 && numel(newModel.mets) == 75);
assert(isequal(size(newModel.S), [numel(newModel.mets), numel(newModel.rxns)]));
assert(isequal(newModel.S(1:72, 1:98), organModel.S));

% the reversible transport gets two constraints and the irreversible kinase one: each added
% flux minus (or, for the reverse direction, plus) 20000 times the flux of
% Liver_biomass_maintenance (reaction 96) is at most (at least) 0
assert(isequal(newModel.ctrs, {'slack_Liver_GLYCt'; 'slack_Liver_GLYCt_R'; 'slack_Liver_GLYK'}));
expectedC = sparse([1, 2, 3, 1, 2, 3], [96, 96, 96, 99, 99, 100], [-20000, 20000, -20000, 1, 1, 1], 3, 100);
assert(isequal(newModel.C, expectedC));
assert(isequal(newModel.d, zeros(3, 1)));
assert(isequal(newModel.dsense, ['L'; 'G'; 'L']));

% the helper field A is removed again
assert(~isfield(newModel, 'A'));

%% an organ without biomass maintenance falls back to its noTrTr biomass reaction

newModel = addReactionsHH(organModel, {'Brain_GLYCt'}, {'Glycerol transport'}, ...
    {'glyc[e] -> glyc[c]'}, {''}, {'Transport'});

% the reaction is coupled to Brain_biomass_maintenance_noTrTr (reaction 98)
assert(isequal(newModel.ctrs, {'slack_Brain_GLYCt'}));
assert(isequal(newModel.C, sparse([1, 1], [98, 99], [-20000, 1], 1, 99)));
assert(isequal(newModel.d, 0) && isequal(newModel.dsense, 'L'));
assert(isequal(size(newModel.S), [numel(newModel.mets), numel(newModel.rxns)]));

%% a small intestine reaction falls back to the sIEC IEC01b biomass reaction

newModel = addReactionsHH(organModel, {'sIEC_GLYCt'}, {'Glycerol transport'}, ...
    {'glyc[e] -> glyc[c]'}, {''}, {'Transport'});

% the fixture has no sIEC_biomass_maintenance, so the reaction is coupled to
% sIEC_biomass_reactionIEC01b (reaction 97)
assert(isequal(newModel.ctrs, {'slack_sIEC_GLYCt'}));
assert(isequal(newModel.C, sparse([1, 1], [97, 99], [-20000, 1], 1, 99)));
assert(isequal(size(newModel.S), [numel(newModel.mets), numel(newModel.rxns)]));

%% notes and references are stored when the model has these fields

% ecoli_core_model has no rxnNotes or rxnReferences, so empty per-reaction fields are built; the
% coupling factor 20000 is passed explicitly to reach the later arguments (a different value is
% a known defect)
annotatedModel = model;
annotatedModel.rxnNotes = repmat({''}, numel(model.rxns), 1);
annotatedModel.rxnReferences = repmat({''}, numel(model.rxns), 1);
newModel = addReactionsHH(annotatedModel, {'EX_glyc[e]'}, {'Glycerol exchange'}, {'glyc[e] <=> '}, ...
    {''}, {'Exchange'}, 20000, {'added by the test'}, {'PMID:1'});
assert(isequal(newModel.rxnNotes, [annotatedModel.rxnNotes; {'added by the test'}]));
assert(isequal(newModel.rxnReferences, [annotatedModel.rxnReferences; {'PMID:1'}]));
assert(numel(newModel.rxns) == 96);

% empty notes and references leave the new entries empty
newModel = addReactionsHH(annotatedModel, {'EX_glyc[e]'}, {'Glycerol exchange'}, {'glyc[e] <=> '}, ...
    {''}, {'Exchange'}, 20000, {}, {});
assert(isempty(newModel.rxnNotes{96}) && isempty(newModel.rxnReferences{96}));
assert(numel(newModel.rxnNotes) == 96 && numel(newModel.rxnReferences) == 96);

%% a gene rule is added, with new genes appended to the gene list

% the model without rxnGeneMat (an optional field), because rxnGeneMat is not updated for the
% rule (known defect)
geneModel = rmfield(model, 'rxnGeneMat');
rule = [model.genes{1} ' or b9999'];
newModel = addReactionsHH(geneModel, {'EX_glyc[e]'}, {'Glycerol exchange'}, {'glyc[e] <=> '}, ...
    {rule}, {'Exchange'});

% the existing gene keeps its index, the new gene b9999 is appended as gene 138, and the rule of
% the new reaction refers to both
assert(isequal(newModel.genes, [model.genes; {'b9999'}]));
assert(strcmp(newModel.grRules{96}, rule));
assert(strcmp(newModel.rules{96}, 'x(1) | x(138)'));

% the rules of all other reactions are unchanged and every rule only refers to existing genes
assert(isequal(newModel.rules(1:95), model.rules));
ruleGeneIdx = str2double(regexp(strjoin(newModel.rules', ' '), '(?<=x\()\d+(?=\))', 'match'));
assert(all(ruleGeneIdx >= 1 & ruleGeneIdx <= numel(newModel.genes)));
assert(isequal(size(newModel.S), [numel(newModel.mets), numel(newModel.rxns)]));

%% a reaction that already exists gives a warning and is not added

% the warning stays visible; lastwarn is reset only to read its message afterwards
lastwarn('');
newModel = addReactionsHH(model, {'PGI'}, {'Glucose-6-phosphate isomerase'}, ...
    {'g6p[c] <=> f6p[c]'}, {''}, {'Glycolysis'});
assert(strcmp(lastwarn, 'Reaction with the same name already exists in the model'));
assert(isequal(newModel, model));

% change the directory
cd(currentDir)
