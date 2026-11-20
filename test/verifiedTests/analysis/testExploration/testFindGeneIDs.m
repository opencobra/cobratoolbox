% The COBRAToolbox: testFindGeneIDs.m
%
% Purpose:
%     - findGeneIDs maps gene identifiers to their positions in model.genes, 0 for a gene that
%       is not in the model. This test checks a cell list (positions in list order, repeated
%       and unknown names, empty list), a single character identifier (found, not found) and a
%       gene listed twice in model.genes (the first position is returned) on a four-reaction
%       model built with createModel, whose three genes come from its gene-reaction rules.
%       Expected values are worked out from the model.
%
% Function under test:
%     src/analysis/exploration/findGeneIDs.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - model look-ups, no solver; a four-reaction createModel model with three genes is
%     the smallest model that reaches every branch.
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
fileDir = fileparts(which('testFindGeneIDs'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

%% fixture: a four-reaction model whose genes g1, g2, g3 come from the rules in that order

model = createModel({'R1'; 'R2'; 'R3'; 'EX_A'}, {'reaction 1'; 'reaction 2'; 'reaction 3'; 'A exchange'}, ...
    {'A[c] -> B[c]'; 'B[c] + C[c] <=> D[c]'; 'D[c] -> E[c]'; 'A[e] <=> '}, ...
    'grRuleList', {'g1 or g2'; 'g2 and g3'; ''; ''}, 'printLevel', 0);
% the genes are registered in the order of their first appearance in the rules
assert(isequal(model.genes, {'g1'; 'g2'; 'g3'}));
% structural consistency of the fixture: S, rxns, mets, genes, rules and rxnGeneMat agree
assert(isequal(size(model.S), [numel(model.mets), numel(model.rxns)]));
assert(numel(model.rules) == numel(model.rxns));
assert(isequal(size(model.rxnGeneMat), [numel(model.rxns), numel(model.genes)]));
% R1 uses g1 and g2, R2 uses g2 and g3, the other reactions have no gene
assert(isequal(full(model.rxnGeneMat), [1 1 0; 0 1 1; 0 0 0; 0 0 0]));

%% cell list: positions in the order of the list, 0 for a gene that is not in the model

assert(isequal(findGeneIDs(model, {'g3'; 'g1'; 'notAGene'}), [3; 1; 0]));
% a row list gives a row; a repeated gene is reported each time
assert(isequal(findGeneIDs(model, {'g2', 'g2'}), [2, 2]));
% an empty list gives an empty result
assert(isempty(findGeneIDs(model, {})));

%% character input: the position of the gene, 0 when it is not in the model

assert(isequal(findGeneIDs(model, 'g2'), 2));
assert(isequal(findGeneIDs(model, 'notAGene'), 0));

%% a gene listed twice in model.genes: only the first position is returned

% a copy of the fixture with a duplicated identifier (only the genes field is consulted)
modelDuplicate = model;
modelDuplicate.genes = {'g1'; 'g2'; 'g1'};
assert(isequal(findGeneIDs(modelDuplicate, 'g1'), 1));
% the cell form also reports the lowest position (ismember)
assert(isequal(findGeneIDs(modelDuplicate, {'g1'}), 1));

% change the directory
cd(currentDir)
