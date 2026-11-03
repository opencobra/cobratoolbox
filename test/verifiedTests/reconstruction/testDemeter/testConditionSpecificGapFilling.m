% The COBRAToolbox: testConditionSpecificGapFilling.m
%
% Purpose:
%     - conditionSpecificGapFilling (DEMETER) applies a fixed table of rules to a model. Each
%       rule has a condition on reactions that must be present (one reaction, or several joined
%       by OR or by AND), a reaction that must be absent, a flag that sets the lower bound of
%       the present reaction to 0, and a list of reactions to add. For every rule that applies,
%       each listed reaction that is not in the model is added from the reaction database with
%       the suffix _csGF. Characterization test that PINS the current behaviour (feature
%       20261103-105830-tier2-safe-batch, Constitution Principle III characterization mode);
%       it must not change the function under test.
%     - Input: the AGORA model Acidaminococcus_fermentans_DSM_20731 with the reactions GTHS, AKGS
%       and BTNCL added from the database. In the distributed model these three reactions are
%       absent and the present-condition of their four rules is not met, which triggers the first
%       defect below; with them added, every rule gives the same result under the current and
%       the documented logic, and no OR rule with the bound flag applies (second defect). The
%       database is the VMH database shipped with the toolbox (loadVMHDatabase).
%     - Reference values: the numbers of added reactions and metabolites and the reaction whose
%       bound changes were recorded from the first run on 2026-11-03 with this model (no
%       solver). They were not derived independently, so they guard consistency, not
%       independent correctness (Tier 5). Single rules are also checked independently against
%       the model, and every added reaction against its database formula.
%     - Reactions listed by several rules are added again under the same identifier, and
%       addReaction warns that it updates the reaction; these warnings are not suppressed.
%     - loadVMHDatabase declares two global variables; the test removes the ones it created.
%
% Function under test:
%     src/reconstruction/demeter/src/debugging/conditionSpecificGapFilling.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - model manipulation, no solver; Acidaminococcus_fermentans_DSM_20731 (an AGORA
%     model, the nomenclature of the rules) loaded through getDistributedModel.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: A rule with a present- and an absent-condition applies when only the absent
%       reaction is missing
%       SEVERITY: wrong-result
%       TRIGGER: a rule with both conditions whose absent reaction is not in the model, while
%         its present-condition is not met; for example the distributed
%         Acidaminococcus_fermentans_DSM_20731, which lacks GTHS, AKGS and BTNCL (rules of lines
%         296, 341, 345 and 346)
%       OBSERVED: the absent-condition is evaluated a second time on its own and sets the rule
%         to apply whenever the absent reaction is missing, so for example EX_gthrd(e) and
%         GTHRDt2 are added although GTHP and TSULST are not in the model
%       EXPECTED: the rule applies only when the present-condition is met and the absent
%         reaction is missing
%       LINES: 383-396
%     - DEFECT: The lower bound is not changed for a rule whose present-condition uses OR
%       SEVERITY: wrong-result
%       TRIGGER: a model with EX_dpcoa(e) or EX_coa(e), or with EX_stys(e), EX_raffin(e),
%         EX_melib(e) or EX_lcts(e) (for example Abiotrophia_defectiva_ATCC_49176)
%       OBSERVED: changeRxnBounds receives the whole condition text, for example 'EX_dpcoa(e) OR
%         EX_coa(e)', as one reaction identifier, warns that the reaction is not in the model
%         and changes no bound
%       EXPECTED: the lower bound of each listed reaction that is in the model set to 0
%       LINES: 36, 51, 400-402
%
% Authors:
%     - Generated for feature 20261103-105830-tier2-safe-batch, 2026-11-03.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testConditionSpecificGapFilling'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox or
% particular operating system, so none is listed
prepareTest();

% load the reaction database once; loadVMHDatabase declares the global variables
% additionalSecretionRxns and additionalUptakeRxns, which are removed again if they did not
% exist before
databaseGlobals = {'additionalSecretionRxns', 'additionalUptakeRxns'};
existingGlobals = ismember(databaseGlobals, who('global'));
database = loadVMHDatabase;
for k = find(~existingGlobals)
    clearvars('-global', databaseGlobals{k});
end

% load the model once (1102 reactions, 1013 metabolites) and add GTHS, AKGS and BTNCL from
% the database, so that no rule triggers the first defect in the header
model = getDistributedModel('Acidaminococcus_fermentans_DSM_20731.mat');
for rxn = {'GTHS', 'AKGS', 'BTNCL'}
    model = addReaction(model, rxn{1}, 'reactionFormula', database.reactions{strcmp(database.reactions(:, 1), rxn{1}), 3});
end
nRxns = numel(model.rxns);
nMets = numel(model.mets);

% the reaction- and metabolite-sized fields of this model, for the structural checks
rxnFields = {'rxns', 'lb', 'ub', 'c', 'rules', 'grRules', 'rxnGeneMat', 'rxnConfidenceScores', ...
    'rxnNames', 'rxnECNumbers', 'rxnKEGGID', 'subSystems'};
metFields = {'mets', 'b', 'csense', 'metCharges', 'metFormulas', 'metSmiles', 'metNames', ...
    'metHMDBID', 'metInChIString', 'metKEGGID', 'metChEBIID', 'metPubChemID'};

%% the rules are applied: reactions added, one bound changed, the rest of the model kept

gapfilledModel = conditionSpecificGapFilling(model, database);

% the reactions and metabolites of the input model are kept in their order, followed by the
% added ones (Tier-5 counts, first run 2026-11-03)
assert(isequal(gapfilledModel.rxns(1:nRxns), model.rxns));
assert(isequal(gapfilledModel.mets(1:nMets), model.mets));
addedRxns = gapfilledModel.rxns(nRxns + 1:end);
assert(numel(addedRxns) == 104);
assert(numel(gapfilledModel.mets) - nMets == 66);

% the result is structurally consistent: S matches mets and rxns, every reaction- and
% metabolite-sized field has one entry per reaction or metabolite, rxnGeneMat is reactions x
% genes and the rules only use existing gene indices; no gene is added
nRxnsOut = numel(gapfilledModel.rxns);
nMetsOut = numel(gapfilledModel.mets);
assert(isequal(size(gapfilledModel.S), [nMetsOut, nRxnsOut]));
assert(all(cellfun(@(f) size(gapfilledModel.(f), 1) == nRxnsOut, rxnFields)));
assert(all(cellfun(@(f) size(gapfilledModel.(f), 1) == nMetsOut, metFields)));
assert(isequal(size(gapfilledModel.rxnGeneMat), [nRxnsOut, numel(gapfilledModel.genes)]));
ruleGeneIdx = str2double(regexp(strjoin(gapfilledModel.rules', ' '), '(?<=x\()\d+(?=\))', 'match'));
assert(all(ruleGeneIdx >= 1 & ruleGeneIdx <= numel(gapfilledModel.genes)));
assert(isequal(gapfilledModel.genes, model.genes));

% the stoichiometry of the input reactions is unchanged and the new metabolites are used by
% added reactions only
assert(isequal(gapfilledModel.S(1:nMets, 1:nRxns), model.S));
assert(nnz(gapfilledModel.S(nMets + 1:end, 1:nRxns)) == 0);

% the only bound that changes is the lower bound of EX_malt(e), set to 0 by the rule
% 'EX_malt(e)' (flag 1) (Tier-5 value, first run 2026-11-03); all other bounds are kept
changedLb = model.rxns(gapfilledModel.lb(1:nRxns) ~= model.lb);
assert(isequal(changedLb, {'EX_malt(e)'}));
assert(gapfilledModel.lb(strcmp(gapfilledModel.rxns, 'EX_malt(e)')) == 0);
assert(isequal(gapfilledModel.ub(1:nRxns), model.ub));

% every added reaction has the suffix _csGF, its database identifier is not in the input model,
% and its metabolites are those of its database formula
assert(all(endsWith(addedRxns, '_csGF')));
databaseIds = erase(addedRxns, '_csGF');
assert(~any(ismember(databaseIds, model.rxns)));
for k = 1:numel(addedRxns)
    formula = database.reactions{strcmp(database.reactions(:, 1), databaseIds{k}), 3};
    expectedMets = unique(regexp(formula, '[^\s]+\[[a-z]\]', 'match'))';
    rxnMets = sort(gapfilledModel.mets(gapfilledModel.S(:, nRxns + k) ~= 0));
    assert(isequal(rxnMets, expectedMets), addedRxns{k});
end

% single rules, checked against the model:
% - absent-only rule [] / 'EX_pnto_R(e)': the reactions of its list that are missing are added,
%   the ones in the model are not
assert(~any(strcmp(model.rxns, 'EX_pnto_R(e)')));
assert(all(ismember({'EX_pnto_R(e)_csGF', 'PNTOabc_csGF'}, addedRxns)));
assert(any(strcmp(model.rxns, 'PTPAT')) && ~any(strcmp(addedRxns, 'PTPAT_csGF')));
% - OR rule 'ACS OR XU5PG3PL OR ...' (ACS is absent, ACKr present): ACtr is added
assert(~any(strcmp(model.rxns, 'ACS')) && any(strcmp(model.rxns, 'ACKr')));
assert(any(strcmp(addedRxns, 'ACtr_csGF')));
% - rule 'TECA5S180' with TECA1S180 absent: TECA1S180 is added
assert(any(strcmp(model.rxns, 'TECA5S180')) && ~any(strcmp(model.rxns, 'TECA1S180')));
assert(any(strcmp(addedRxns, 'TECA1S180_csGF')));
% - rule 'GTHP AND TSULST' with GTHS absent: GTHS is in the model, so EX_gthrd(e) and GTHRDt2
%   (listed by no other applying rule) are not added
assert(~any(ismember({'EX_gthrd(e)_csGF', 'GTHRDt2_csGF'}, addedRxns)));

%% a second application adds nothing new

% the rules still apply to the reactions of the input model, so the same reactions are added
% again under the same identifiers (addReaction updates them) and the model does not change
gapfilledTwice = conditionSpecificGapFilling(conditionSpecificGapFilling(model, database), database);
gapfilledOnce = conditionSpecificGapFilling(model, database);
assert(isequal(gapfilledTwice.rxns, gapfilledOnce.rxns) && isequal(gapfilledTwice.mets, gapfilledOnce.mets));
assert(isequal(gapfilledTwice.S, gapfilledOnce.S));
assert(isequal(gapfilledTwice.lb, gapfilledOnce.lb) && isequal(gapfilledTwice.ub, gapfilledOnce.ub));

% change the directory
cd(currentDir)
