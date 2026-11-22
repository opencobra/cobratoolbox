% The COBRAToolbox: testCreateEcosystemModel.m
%
% Purpose:
%     - createEcosystemModel merges member models into a community model: member reactions and
%       metabolites are prefixed, every boundary reaction `met <=>` of a member is linked to a
%       pool metabolite `met_pool` exchanged with the environment by `EX_met`, gene rules are
%       renumbered, and the objective is the sum of the member objectives. This test builds two
%       (and three) small createModel members and checks every field of the result against
%       values worked out by hand from the inputs: the stoichiometric links of the pool, bounds,
%       objective, exchange information, metabolite annotation conflicts, gene rules, the
%       defaults for members without annotation fields, the options (name, ID, pool bounds,
%       printed report) and the input errors.
%
% Function under test:
%     src/analysis/ecosystem/createEcosystemModel.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - model manipulation of hand-built createModel members, no solver.
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
fileDir = fileparts(which('testCreateEcosystemModel'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox or
% particular operating system, so none is listed; the call is the standard opening of a COBRA
% test and the place where a requirement would be added later
prepareTest();

% member 1: glucose-like A taken up and turned into biomass, B secreted
org1 = createModel({'EX_A', 'Atr', 'BIO1', 'EX_B'}, ...
    {'A exchange', 'A transport', 'biomass 1', 'B exchange'}, ...
    {'A[e] <=> ', 'A[e] -> A[c]', 'A[c] -> B[c]', 'B[e] <=> '}, ...
    'lowerBoundList', [-10 0 0 0], 'upperBoundList', [1000 1000 1000 5], ...
    'grRuleList', {'', 'g1', 'g2', ''}, 'printLevel', 0);
org1.c = double(strcmp(org1.rxns, 'BIO1'));
% member 2: A taken up directly into biomass, gene rule with two genes
org2 = createModel({'EX_A', 'BIO2'}, {'A exchange', 'biomass 2'}, ...
    {'A[e] <=> ', 'A[e] -> C[c]'}, 'lowerBoundList', [-20 0], 'upperBoundList', [30 1000], ...
    'grRuleList', {'', 'h1 and h2'}, 'printLevel', 0);
org2.c = 2 * double(strcmp(org2.rxns, 'BIO2'));

% annotations: A[e] has the same name and formula in both members but a different charge
org1.metNames = strcat('name_', org1.mets);
org1.metNames{strcmp(org1.mets, 'A[e]')} = 'A';
org1.metFormulas = repmat({'C6H12O6'}, numel(org1.mets), 1);
org1.metCharges = zeros(numel(org1.mets), 1);
org1.rxnNames = strcat('rxnName_', org1.rxns);
org1.subSystems = repmat({'sub1'}, numel(org1.rxns), 1);
org1.modelID = 'member1';
org2.metNames = strcat('name_', org2.mets);
org2.metNames{strcmp(org2.mets, 'A[e]')} = 'A';
org2.metFormulas = repmat({'C6H12O6'}, numel(org2.mets), 1);
org2.metCharges = -ones(numel(org2.mets), 1);
org2.rxnNames = strcat('rxnName_', org2.rxns);
org2.subSystems = repmat({'sub2'}, numel(org2.rxns), 1);

%% two annotated members, default options: structure of the community model

eco = createEcosystemModel({org1, org2}, {'org1', 'org2'}, 'printLevel', 0);
cmodel = eco.model;

% 4 + 2 member reactions and metabolites, plus one pool metabolite and one pool exchange for
% each of the two exchanged metabolites A_e and B_e
expectedRxns = {'org1_EX_A'; 'org1_Atr'; 'org1_BIO1'; 'org1_EX_B'; 'org2_EX_A'; 'org2_BIO2'; ...
    'EX_A_e'; 'EX_B_e'};
expectedMets = [strcat('org1_', org1.mets); strcat('org2_', org2.mets); {'A_e_pool'; 'B_e_pool'}];
assert(isequal(cmodel.rxns, expectedRxns));
assert(isequal(cmodel.mets, expectedMets));
assert(isequal(size(cmodel.S), [8, 8]));
assert(isequal(numel(cmodel.lb), 8) && isequal(numel(cmodel.ub), 8) && isequal(numel(cmodel.c), 8));
assert(isequal(numel(cmodel.b), 8) && isequal(cmodel.csense, repmat('E', 8, 1)));

% the member blocks of S are the member matrices; the pool links are exact integers:
% member exchange prefix_A[e] -> A_e_pool (the member coefficient -1 is mirrored as +1 on the
% pool metabolite) and pool exchange A_e_pool <=> (-1)
assert(isequal(full(cmodel.S(1:4, 1:4)), full(org1.S)));
assert(isequal(full(cmodel.S(5:6, 5:6)), full(org2.S)));
poolA = strcmp(cmodel.mets, 'A_e_pool');
poolB = strcmp(cmodel.mets, 'B_e_pool');
assert(isequal(full(cmodel.S(poolA, :)), [1 0 0 0 1 0 -1 0]));
assert(isequal(full(cmodel.S(poolB, :)), [0 0 0 1 0 0 0 -1]));
% 6 + 3 member entries, 3 member-to-pool links and 2 pool exchange entries
assert(isequal(nnz(cmodel.S), 14));

% bounds: member bounds are kept, pool exchanges get the default [-1000 1000]
assert(isequal(cmodel.lb, [-10; 0; 0; 0; -20; 0; -1000; -1000]));
assert(isequal(cmodel.ub, [1000; 1000; 1000; 5; 30; 1000; 1000; 1000]));
% objective: sum of the member objectives with their coefficients
assert(isequal(cmodel.c, [0; 0; 1; 0; 0; 2; 0; 0]));
assert(strcmp(cmodel.osenseStr, 'max'));
assert(strcmp(cmodel.modelID, 'community') && strcmp(cmodel.modelName, 'My community model'));

% annotations copied from the members; the pool metabolite takes those of the first member
% that exchanges it (charges of A_e: 0 in member 1, -1 in member 2)
assert(isequal(cmodel.metNames(1:6), [org1.metNames; org2.metNames]));
assert(isequal(cmodel.metNames(7:8), {'A'; 'name_B[e]'}));
assert(isequal(cmodel.metFormulas, repmat({'C6H12O6'}, 8, 1)));
assert(isequal(cmodel.metCharges, [0; 0; 0; 0; -1; -1; 0; 0]));
assert(isequal(cmodel.rxnNames, [org1.rxnNames; org2.rxnNames; {'Pool A exchange'; 'Pool name_B[e] exchange'}]));
assert(isequal(cmodel.subSystems, [repmat({'sub1'}, 4, 1); repmat({'sub2'}, 2, 1); {'Exchange'; 'Exchange'}]));

% genes are prefixed and the rules of member 2 are renumbered after the 2 genes of member 1;
% grRules are rebuilt from the rules
assert(isequal(cmodel.genes, {'org1_g1'; 'org1_g2'; 'org2_h1'; 'org2_h2'}));
assert(isequal(cmodel.rules, {''; 'x(1)'; 'x(2)'; ''; ''; 'x(3) & x(4)'; ''; ''}));
assert(isequal(cmodel.grRules, {''; 'org1_g1'; 'org1_g2'; ''; ''; 'org2_h1 and org2_h2'; ''; ''}));

%% two annotated members: the ecosystem structure

assert(strcmp(eco.name, 'My community model') && strcmp(eco.id, 'community'));
assert(isequal(eco.prefixes, {'org1'; 'org2'}) && isequal(eco.size, 2));
assert(isequal(eco.objectives, {'org1_BIO1'; 'org2_BIO2'}));
assert(isequal(eco.memberRxns, {expectedRxns(1:4); expectedRxns(5:6)}));
info = eco.exchangeInfo;
assert(isequal(info.mets, {'A_e'; 'B_e'}));
assert(isequal(info.poolMets, {'A_e_pool'; 'B_e_pool'}));
assert(isequal(info.poolRxns, {'EX_A_e'; 'EX_B_e'}));
% member 2 does not exchange B_e: empty IDs and NaN bounds
assert(isequal(info.memberMets, {'org1_A[e]', 'org2_A[e]'; 'org1_B[e]', ''}));
assert(isequal(info.memberRxns, {'org1_EX_A', 'org2_EX_A'; 'org1_EX_B', ''}));
assert(isequal(size(info.memberBounds), [2, 2, 2]));
assert(isequal(info.memberBounds(:, :, 1), [-10 1000; 0 5]));
assert(isequal(info.memberBounds(1, :, 2), [-20 30]) && all(isnan(info.memberBounds(2, :, 2))));
% A_e has different charges in the two members, so it is the only conflict
assert(isequal(eco.conflicts, {'A_e'}));
% downstream fields are created empty
emptyFields = {'rxn2cluster', 'points', 'pfractions', 'maxCommunityGrowth', 'feasiblePoints', ...
    'qualVectors', 'qualPointIndex', 'fvaResults', 'clusters', 'k'};
for k = 1:numel(emptyFields)
    assert(isempty(eco.(emptyFields{k})));
end

%% options and the printed report (three members, one without exchanges of B_e)

org3 = org2;
org3.rxns = {'EX_A'; 'BIO3'};
% printLevel 1 prints the construction steps, the member objectives, the conflict of A_e and
% the statistics to the console (a short report, left visible)
eco3 = createEcosystemModel({org1, org2, org3}, {'o1', 'o2', 'o3'}, 'communityName', 'toy', ...
    'communityID', 'toy-id', 'poolBounds', [-5 7], 'printLevel', 1);
assert(isequal(eco3.conflicts, {'A_e'}));
assert(strcmp(eco3.name, 'toy') && strcmp(eco3.id, 'toy-id') && isequal(eco3.size, 3));
assert(strcmp(eco3.model.modelName, 'toy') && strcmp(eco3.model.modelID, 'toy-id'));
% 4 + 2 + 2 member reactions plus 2 pool exchanges with the given bounds
assert(isequal(numel(eco3.model.rxns), 10));
assert(isequal(eco3.model.lb(end - 1:end), [-5; -5]) && isequal(eco3.model.ub(end - 1:end), [7; 7]));
% the pool metabolite A_e_pool is linked to the three member exchanges
assert(isequal(nnz(eco3.model.S(strcmp(eco3.model.mets, 'A_e_pool'), :)), 4));
% the rules of member 3 are renumbered after the 4 genes of members 1 and 2
assert(strcmp(eco3.model.rules{strcmp(eco3.model.rxns, 'o3_BIO3')}, 'x(5) & x(6)'));
assert(isequal(eco3.objectives, {'o1_BIO1'; 'o2_BIO2'; 'o3_BIO3'}));

%% members without annotation, gene or subsystem fields: defaults

bareFields = {'S', 'mets', 'rxns', 'lb', 'ub', 'c'};
bare1 = rmfield(org1, setdiff(fieldnames(org1), bareFields));
bare2 = rmfield(org2, setdiff(fieldnames(org2), bareFields));
% prefixes given as a string array are accepted
ecoBare = createEcosystemModel({bare1, bare2}, ["p", "q"], 'printLevel', 0);
bareModel = ecoBare.model;
assert(isequal(ecoBare.prefixes, {'p'; 'q'}));
% names default to the identifiers, formulas to '' and charges to 0; pool names are empty
assert(isequal(bareModel.metNames(1:6), [bare1.mets; bare2.mets]));
assert(isequal(bareModel.metNames(7:8), {''; ''}));
assert(isequal(bareModel.metFormulas, repmat({''}, 8, 1)));
assert(isequal(bareModel.metCharges, zeros(8, 1)));
assert(isequal(bareModel.rxnNames(1:6), [bare1.rxns; bare2.rxns]));
assert(isequal(bareModel.rxnNames(7:8), {'Pool  exchange'; 'Pool  exchange'}));
% genes, rules, grRules and subSystems are kept only when every member has them
assert(~any(isfield(bareModel, {'genes', 'rules', 'grRules', 'subSystems'})));
% without annotations there is nothing to conflict
assert(isempty(ecoBare.conflicts));
% the structure does not depend on the annotation fields
assert(isequal(bareModel.S, cmodel.S) && isequal(bareModel.lb, cmodel.lb) && isequal(bareModel.c, cmodel.c));

%% input errors raised by design

% one prefix for two models
assert(verifyCobraFunctionError('createEcosystemModel', 'inputs', {{org1, org2}, {'org1'}}, ...
    'testMessage', 'The number of prefixes (1) must be equal to the number of models (2).'));
% repeated prefixes
assert(verifyCobraFunctionError('createEcosystemModel', 'inputs', {{org1, org2}, {'o', 'o'}}, ...
    'testMessage', 'Prefixes must be unique.'));
% a member without bounds
assert(verifyCobraFunctionError('createEcosystemModel', 'inputs', ...
    {{rmfield(org1, {'lb', 'ub'}), org2}, {'org1', 'org2'}}, ...
    'testMessage', 'Model 1 (org1) does not have the field(s): lb, ub'));
% a member with two objective reactions
twoObjectives = org2;
twoObjectives.c = [1; 1];
assert(verifyCobraFunctionError('createEcosystemModel', 'inputs', {{org1, twoObjectives}, {'org1', 'org2'}}, ...
    'testMessage', ['More than one (or no) reaction in the objective function of member org2. ' ...
    'Not supported! Set a single objective reaction.']));

% change the directory
cd(currentDir)
