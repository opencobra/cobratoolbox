% The COBRAToolbox: testFindMetIDs.m
%
% Purpose:
%     - findMetIDs maps metabolite identifiers to their positions in model.mets, 0 for a
%       metabolite that is not in the model. This test checks a cell list (positions in list
%       order, repeated and unknown names, empty list), a single character identifier (found,
%       not found) and a metabolite listed twice in model.mets (the first position is returned)
%       on a four-reaction model built with createModel, whose six metabolites are sorted by
%       identifier. Expected values are worked out from the model.
%
% Function under test:
%     src/analysis/exploration/findMetIDs.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - model look-ups, no solver; a four-reaction createModel model with six metabolites
%     is the smallest model that reaches every branch.
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
fileDir = fileparts(which('testFindMetIDs'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

%% fixture: a four-reaction model whose six metabolites are stored in sorted order

model = createModel({'R1'; 'R2'; 'R3'; 'EX_A'}, {'reaction 1'; 'reaction 2'; 'reaction 3'; 'A exchange'}, ...
    {'A[c] -> B[c]'; 'B[c] + C[c] <=> D[c]'; 'D[c] -> E[c]'; 'A[e] <=> '}, ...
    'grRuleList', {'g1 or g2'; 'g2 and g3'; ''; ''}, 'printLevel', 0);
% createModel collects the metabolites with unique, so they are sorted: positions 1 to 6
assert(isequal(model.mets, {'A[c]'; 'A[e]'; 'B[c]'; 'C[c]'; 'D[c]'; 'E[c]'}));
% structural consistency of the fixture: S, rxns, mets, genes, rules and rxnGeneMat agree
assert(isequal(size(model.S), [numel(model.mets), numel(model.rxns)]));
assert(numel(model.b) == numel(model.mets) && numel(model.rules) == numel(model.rxns));
assert(isequal(size(model.rxnGeneMat), [numel(model.rxns), numel(model.genes)]));
% R1: A[c] -> B[c]; R2: B[c] + C[c] <=> D[c]; R3: D[c] -> E[c]; EX_A: A[e] <=>
assert(isequal(full(model.S), [-1 0 0 0; 0 0 0 -1; 1 -1 0 0; 0 -1 0 0; 0 1 -1 0; 0 0 1 0]));

%% cell list: positions in the order of the list, 0 for a metabolite that is not in the model

assert(isequal(findMetIDs(model, {'E[c]'; 'A[e]'; 'notAMet'}), [6; 2; 0]));
% a row list gives a row; a repeated metabolite is reported each time
assert(isequal(findMetIDs(model, {'B[c]', 'B[c]'}), [3, 3]));
% an empty list gives an empty result
assert(isempty(findMetIDs(model, {})));

%% character input: the position of the metabolite, 0 when it is not in the model

assert(isequal(findMetIDs(model, 'C[c]'), 4));
assert(isequal(findMetIDs(model, 'notAMet'), 0));
% the comparison is exact: the identifier without its compartment is not found
assert(isequal(findMetIDs(model, 'C'), 0));

%% a metabolite listed twice in model.mets: only the first position is returned

% a copy of the fixture with a duplicated identifier (only the mets field is consulted)
modelDuplicate = model;
modelDuplicate.mets = {'A[c]'; 'B[c]'; 'A[c]'};
assert(isequal(findMetIDs(modelDuplicate, 'A[c]'), 1));
% the cell form also reports the lowest position (ismember)
assert(isequal(findMetIDs(modelDuplicate, {'A[c]'}), 1));

% change the directory
cd(currentDir)
