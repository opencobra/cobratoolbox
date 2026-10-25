% The COBRAToolbox: testAssignRxnWeights.m
%
% Purpose:
%     - assignRxnWeights gives every reaction of the fastGapFill matrix a weight: one for metabolic
%     reactions, one for exchange reactions (names starting with EX_) and one for transport
%     reactions, optionally overridden per reaction.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch3, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/reconstruction/fastGapFill/AuxillaryFiles/assignRxnWeights.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The NoWeight argument never has an effect
%       SEVERITY: unusable-option
%       TRIGGER: the optional argument NoWeight (or its default 1000) for reactions that are neither
%         metabolic, exchange nor transport
%       OBSERVED: the weight vector is filled with NoWeight and then replaced by zeros a few lines
%         later, so such reactions get 0
%       EXPECTED: NoWeight for those reactions
%       LINES: 45, 54
%
% Authors:
%     - Generated for feature tier1-test-batch3, 2026-10-12.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testAssignRxnWeights'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% matrix parts: 2 = metabolic reactions, 3 = exchange and transport reactions
% (reactions of other parts are not used here, see the header)
model.rxns = {'a'; 'EX_b'; 't1'; 'm1'};
model.MatrixPart = [2; 3; 3; 2];

%% default weights: 10 for metabolic, exchange and transport reactions

result = assignRxnWeights(model);
assert(isequal(result.weights, [10; 10; 10; 10]));

%% weights per reaction type

weights = struct('MetabolicRxns', 1, 'ExchangeRxns', 2, 'TransportRxns', 3);
result = assignRxnWeights(model, weights);
% a = metabolic, EX_b = exchange (name starts with EX_), t1 = transport, m1 = metabolic
assert(isequal(result.weights, [1; 2; 3; 1]));

%% weights for single reactions override the type weights; unknown reactions are ignored

perReaction = struct('rxns', {{'m1', 'unknown'}}, 'weights', {{7, 8}});
result = assignRxnWeights(model, [], perReaction);
assert(isequal(result.weights, [10; 10; 10; 7]));

%% an empty list, or a structure without the field rxns, changes nothing

result = assignRxnWeights(model, [], struct('rxns', {{}}, 'weights', {{}}));
assert(isequal(result.weights, [10; 10; 10; 10]));
result = assignRxnWeights(model, [], struct('other', 1));
assert(isequal(result.weights, [10; 10; 10; 10]));

% change the directory
cd(currentDir)
