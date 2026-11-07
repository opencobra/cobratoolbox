% The COBRAToolbox: testFindRxnFromCompartment.m
%
% Purpose:
%     - findRxnFromCompartment returns, as a two-column cell array, the identifiers and the
%       formulas of the reactions that use at least one metabolite whose identifier contains the
%       compartment text (for example '[e]'); a single-letter compartment is put in brackets.
%       Characterization test that PINS the current behaviour (feature
%       20261102-142225-tier2-test-pilot, Constitution Principle III characterization mode);
%       it must not change the function under test.
%     - Reference values: the row counts asserted below were recorded from the first run on
%       2026-11-02 with ecoli_core_model (no solver). They were not derived independently, so
%       they guard consistency, not independent correctness (Tier 5). The reactions themselves
%       are also derived independently from model.S and model.mets.
%
% Function under test:
%     src/analysis/exploration/findRxnFromCompartment.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - model manipulation, no solver; ecoli_core_model loaded through getDistributedModel.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: A compartment with a single metabolite returns the first reaction of the model
%       SEVERITY: wrong-result
%       TRIGGER: a compartment that holds exactly one metabolite, for example ecoli_core_model
%         with o2[e] renamed to o2[p] and findRxnFromCompartment(model, '[p]')
%       OBSERVED: any() of the single selected row of S is one scalar instead of one value per
%         reaction, so only the first reaction of the model (ACALD) is returned
%       EXPECTED: the reactions that use the metabolite (EX_o2(e) and O2t)
%       LINES: 30
%
% Authors:
%     - Generated for feature 20261102-142225-tier2-test-pilot, 2026-11-02.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testFindRxnFromCompartment'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox or
% particular operating system, so none is listed
prepareTest();

% load the model once (95 reactions, 72 metabolites, 137 genes, compartments c and e)
model = getDistributedModel('ecoli_core_model.mat');

%% the reactions of the extracellular compartment [e]

compartmentReactions = findRxnFromCompartment(model, '[e]');

% the reactions are exactly those with a metabolite of [e], in model order, with one formula
% each (Tier-5 count, first run 2026-11-02: 45 reactions, the 20 exchanges and 25 transports)
expectedRxns = model.rxns(any(model.S(endsWith(model.mets, '[e]'), :) ~= 0, 1));
assert(iscell(compartmentReactions) && size(compartmentReactions, 2) == 2);
assert(isequal(compartmentReactions(:, 1), expectedRxns));
assert(size(compartmentReactions, 1) == 45);

% each formula belongs to the reaction in its row: it names every metabolite of that reaction,
% and at least one of them is in [e]
for k = 1:size(compartmentReactions, 1)
    rxnMets = model.mets(model.S(:, strcmp(model.rxns, compartmentReactions{k, 1})) ~= 0);
    assert(all(contains(compartmentReactions{k, 2}, rxnMets)));
    assert(contains(compartmentReactions{k, 2}, '[e]'));
end

%% a single-letter compartment is put in brackets

% 'e' gives the same result as '[e]'
assert(isequal(findRxnFromCompartment(model, 'e'), findRxnFromCompartment(model, '[e]')));

%% the reactions of the cytosol [c]

compartmentReactions = findRxnFromCompartment(model, '[c]');

% the reactions are exactly those with a metabolite of [c], in model order (Tier-5 count, first
% run 2026-11-02: 75 reactions, every reaction except the 20 exchanges)
expectedRxns = model.rxns(any(model.S(endsWith(model.mets, '[c]'), :) ~= 0, 1));
assert(isequal(compartmentReactions(:, 1), expectedRxns));
assert(size(compartmentReactions, 1) == 75);
assert(all(contains(compartmentReactions(:, 2), '[c]')));

%% a compartment that is not in the model gives an empty list

compartmentReactions = findRxnFromCompartment(model, '[x]');
assert(iscell(compartmentReactions) && isequal(size(compartmentReactions), [0, 2]));

% change the directory
cd(currentDir)
