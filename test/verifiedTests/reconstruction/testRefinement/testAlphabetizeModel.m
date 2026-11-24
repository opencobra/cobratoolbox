% The COBRAToolbox: testAlphabetizeModel.m
%
% Purpose:
%     - alphabetizeModel(model) sorts the reactions, metabolites, genes (if present) and
%       compartments (if present) of a model into alphabetical (character code) order and
%       reorders every field associated with them. The test builds a small model by hand in
%       an unsorted order and checks the sorted ids and every reordered field against the
%       permutations derived by hand (including the gene indices in rules), that every
%       reaction keeps its formula, and that a model without genes and compartments is sorted
%       as well.
%
% Function under test:
%     src/reconstruction/refinement/alphabetizeModel.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - a hand-built model of three reactions; no solver.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-23.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testAlphabetizeModel'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% hand-built model, deliberately unsorted:
%   R2:   b[c] -> a[c]               (g2 or g1)
%   R1:   a[c] -> c[e] + d[c]        (g1)
%   EX_b: b[c] <=>
% three reactions, four metabolites, two genes and two compartments, so that reactions
% and metabolites have different sizes
model = struct();
model.rxns = {'R2'; 'R1'; 'EX_b'};
model.mets = {'b[c]'; 'a[c]'; 'c[e]'; 'd[c]'};
model.S = sparse([-1, 0, -1; 1, -1, 0; 0, 1, 0; 0, 1, 0]);
model.lb = [0; -5; -10];
model.ub = [10; 20; 30];
model.c = [0; 1; 0];
model.b = [0; 0; 0; 0];
model.csense = ['E'; 'E'; 'E'; 'E'];
model.osenseStr = 'max';
model.rxnNames = {'reaction 2'; 'reaction 1'; 'exchange b'};
model.metNames = {'B'; 'A'; 'C'; 'D'};
model.metCharges = [-1; 0; 1; 2];
model.genes = {'g2'; 'g1'};
model.rules = {'x(1) | x(2)'; 'x(2)'; ''};
model.grRules = {'g2 or g1'; 'g1'; ''};
model.rxnGeneMat = sparse([1, 1; 0, 1; 0, 0]);
model.comps = {'e'; 'c'};
model.compNames = {'extracellular'; 'cytosol'};

% permutations derived by hand: character codes 'E' < 'R', so EX_b, R1, R2
rxnOrder = [3; 2; 1];
metOrder = [2; 1; 3; 4];
geneOrder = [2; 1];

%% reactions, metabolites, genes and compartments are sorted with their fields

sortedModel = alphabetizeModel(model);
assert(isequal(sortedModel.rxns, {'EX_b'; 'R1'; 'R2'}));
assert(isequal(sortedModel.mets, {'a[c]'; 'b[c]'; 'c[e]'; 'd[c]'}));
assert(isequal(sortedModel.genes, {'g1'; 'g2'}));
assert(isequal(sortedModel.comps, {'c'; 'e'}));
% the stoichiometric matrix is permuted in both dimensions (exact integers)
assert(isequal(sortedModel.S, model.S(metOrder, rxnOrder)));
% reaction fields
assert(isequal(sortedModel.lb, [-10; -5; 0]) && isequal(sortedModel.ub, [30; 20; 10]));
assert(isequal(sortedModel.c, [0; 1; 0]));
assert(isequal(sortedModel.rxnNames, {'exchange b'; 'reaction 1'; 'reaction 2'}));
assert(isequal(sortedModel.grRules, {''; 'g1'; 'g2 or g1'}));
% metabolite fields
assert(isequal(sortedModel.metNames, {'A'; 'B'; 'C'; 'D'}));
assert(isequal(sortedModel.metCharges, [0; -1; 1; 2]));
assert(isequal(sortedModel.csense, model.csense) && isequal(sortedModel.b, model.b));
% gene fields: rxnGeneMat in both dimensions, and the rules refer to the new gene indices
% (g1 is now x(1), g2 is x(2)): R2 'g2 or g1' -> 'x(2) | x(1)', R1 'g1' -> 'x(1)'
assert(isequal(sortedModel.rxnGeneMat, model.rxnGeneMat(rxnOrder, geneOrder)));
assert(isequal(sortedModel.rules, {''; 'x(1)'; 'x(2) | x(1)'}));
% compartment fields
assert(isequal(sortedModel.compNames, {'cytosol'; 'extracellular'}));
% fields of no type are unchanged
assert(isequal(sortedModel.osenseStr, 'max'));

%% every reaction keeps its formula

originalFormulas = printRxnFormula(model, 'rxnAbbrList', model.rxns, 'printFlag', false);
sortedFormulas = printRxnFormula(sortedModel, 'rxnAbbrList', model.rxns, 'printFlag', false);
assert(isequal(sortedFormulas, originalFormulas));

%% a model without genes and compartments: only reactions and metabolites are sorted

plainModel = rmfield(model, {'genes', 'rules', 'grRules', 'rxnGeneMat', 'comps', 'compNames'});
sortedPlainModel = alphabetizeModel(plainModel);
assert(~isfield(sortedPlainModel, 'genes') && ~isfield(sortedPlainModel, 'comps'));
assert(isequal(sortedPlainModel.rxns, {'EX_b'; 'R1'; 'R2'}));
assert(isequal(sortedPlainModel.mets, {'a[c]'; 'b[c]'; 'c[e]'; 'd[c]'}));
assert(isequal(sortedPlainModel.S, model.S(metOrder, rxnOrder)));
assert(isequal(sortedPlainModel.metNames, {'A'; 'B'; 'C'; 'D'}));

%% a sorted model is unchanged

assert(isequal(alphabetizeModel(sortedModel), sortedModel));

% change the directory
cd(currentDir)
