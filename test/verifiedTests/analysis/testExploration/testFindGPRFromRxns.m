% The COBRAToolbox: testFindGPRFromRxns.m
%
% Purpose:
%     - findGPRFromRxns returns the textual gene-reaction rules of the given reactions without
%       printing them; it is printGPRForRxns(model, rxnIDs, 0). This test checks reaction
%       abbreviations (cell and character) and numeric positions against the model's grRules,
%       the text built from rules and genes when grRules is absent, the empty rules of a model
%       without gene associations, and the errors for an unknown abbreviation and a position
%       beyond the model, on a four-reaction model built with createModel. Expected values are
%       worked out from the model.
%
% Function under test:
%     src/analysis/exploration/findGPRFromRxns.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - model look-ups, no solver; a four-reaction createModel model with three genes is
%     the smallest model that reaches the single line of the function.
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
fileDir = fileparts(which('testFindGPRFromRxns'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

%% fixture: R1 uses g1 or g2, R2 uses g2 and g3, R3 and EX_A have no gene

model = createModel({'R1'; 'R2'; 'R3'; 'EX_A'}, {'reaction 1'; 'reaction 2'; 'reaction 3'; 'A exchange'}, ...
    {'A[c] -> B[c]'; 'B[c] + C[c] <=> D[c]'; 'D[c] -> E[c]'; 'A[e] <=> '}, ...
    'grRuleList', {'g1 or g2'; 'g2 and g3'; ''; ''}, 'printLevel', 0);
% structural consistency of the fixture: S, rxns, mets, genes, rules and rxnGeneMat agree
assert(isequal(size(model.S), [numel(model.mets), numel(model.rxns)]));
assert(numel(model.rules) == numel(model.rxns) && numel(model.grRules) == numel(model.rxns));
assert(isequal(size(model.rxnGeneMat), [numel(model.rxns), numel(model.genes)]));
assert(isequal(model.genes, {'g1'; 'g2'; 'g3'}));
assert(isequal(model.grRules, {'g1 or g2'; 'g2 and g3'; ''; ''}));

%% abbreviations: the grRules entries of the reactions, in the order of the list

gprs = findGPRFromRxns(model, {'R2'; 'R1'});
assert(isequal(gprs, {'g2 and g3'; 'g1 or g2'}));
% a reaction without gene association gives an empty rule
assert(isequal(findGPRFromRxns(model, {'R3'; 'EX_A'}), {''; ''}));
% a single abbreviation as a character vector
assert(isequal(findGPRFromRxns(model, 'R1'), {'g1 or g2'}));

%% numeric positions are accepted as well

assert(isequal(findGPRFromRxns(model, [2; 1]), {'g2 and g3'; 'g1 or g2'}));

%% without grRules the text is built from rules and genes; without both the rules are empty

modelRulesOnly = rmfield(model, 'grRules');
% the rules of the fixture use the gene positions of model.genes: these are set by hand so
% that the expected text is known exactly
modelRulesOnly.rules = {'x(1) | x(2)'; 'x(2) & x(3)'; ''; ''};
assert(isequal(findGPRFromRxns(modelRulesOnly, {'R1'; 'R2'; 'R3'}), {'g1 or g2'; 'g2 and g3'; ''}));
modelNoGenes = rmfield(modelRulesOnly, 'rules');
assert(isequal(findGPRFromRxns(modelNoGenes, {'R1'; 'R2'}), {''; ''}));

%% errors of the callee surface: an unknown abbreviation and a position beyond the model

assert(verifyCobraFunctionError('findGPRFromRxns', 'inputs', {model, {'notARxn'}}));
assert(verifyCobraFunctionError('findGPRFromRxns', 'inputs', {model, 9}, ...
    'testMessage', 'Some indices provided are larger than the number of reactions.'));

% change the directory
cd(currentDir)
