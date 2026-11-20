% The COBRAToolbox: testFindRxnIDs.m
%
% Purpose:
%     - findRxnIDs maps reaction abbreviations to their positions in model.rxns, 0 for a name
%       that is not in the model. This test checks cell, character, character-matrix and string
%       inputs on a four-reaction model built with createModel (positions known by construction),
%       the order and shape of the result, missing and repeated names, the empty list, and the
%       fallback that converts numeric model.rxns to text with a warning. Expected values are
%       worked out from the model.
%
% Function under test:
%     src/analysis/exploration/findRxnIDs.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - model look-ups, no solver; a four-reaction createModel model is the smallest
%     model that reaches every branch.
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
fileDir = fileparts(which('testFindRxnIDs'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

%% fixture: a four-reaction model whose reaction positions are known by construction

model = createModel({'R1'; 'R2'; 'R3'; 'EX_A'}, {'reaction 1'; 'reaction 2'; 'reaction 3'; 'A exchange'}, ...
    {'A[c] -> B[c]'; 'B[c] + C[c] <=> D[c]'; 'D[c] -> E[c]'; 'A[e] <=> '}, ...
    'grRuleList', {'g1 or g2'; 'g2 and g3'; ''; ''}, 'printLevel', 0);
% the reactions keep the order they were given in, so the expected positions are 1 to 4
assert(isequal(model.rxns, {'R1'; 'R2'; 'R3'; 'EX_A'}));
% structural consistency of the fixture: S, rxns, mets, genes, rules and rxnGeneMat agree
assert(isequal(size(model.S), [numel(model.mets), numel(model.rxns)]));
assert(numel(model.rules) == numel(model.rxns) && numel(model.lb) == numel(model.rxns));
assert(isequal(size(model.rxnGeneMat), [numel(model.rxns), numel(model.genes)]));

%% cell array of abbreviations: positions in the order of the list, 0 for an unknown name

% a column list gives a column of positions
assert(isequal(findRxnIDs(model, {'R3'; 'R1'}), [3; 1]));
% a row list gives a row (ismember keeps the shape of the list); an unknown name gives 0
assert(isequal(findRxnIDs(model, {'EX_A', 'notARxn', 'R2'}), [4, 0, 2]));
% a repeated name is reported each time it appears
assert(isequal(findRxnIDs(model, {'R2'; 'R2'}), [2; 2]));
% an empty list gives an empty result
assert(isempty(findRxnIDs(model, {})));

%% character and string inputs are wrapped with cellstr

assert(isequal(findRxnIDs(model, 'R2'), 2));
assert(isequal(findRxnIDs(model, 'notARxn'), 0));
% a character matrix gives one position per row, as a column
assert(isequal(findRxnIDs(model, ['R1'; 'R3']), [1; 3]));
% a string scalar behaves like a character vector
assert(isequal(findRxnIDs(model, "EX_A"), 4));

%% numeric reaction identifiers: ismember fails, so model.rxns is converted to text with a warning

modelNumeric = model;
modelNumeric.rxns = {1; 2; 3; 4};
lastwarn('');
rxnID = findRxnIDs(modelNumeric, {'2'; '5'});
% the text form of the numbers is matched: '2' is the second reaction, '5' does not exist
assert(isequal(rxnID, [2; 0]));
% the conversion is announced by a warning (shown, not suppressed)
assert(strcmp(lastwarn, ['Some model.rxns are double rather than char. Had to convert model.rxns ' ...
    'to a cell array of character vectors.']));

% change the directory
cd(currentDir)
