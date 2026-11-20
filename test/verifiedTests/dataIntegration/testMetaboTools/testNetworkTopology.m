% The COBRAToolbox: testNetworkTopology.m
%
% Purpose:
%     - networkTopology returns, for each metabolite, the number of reactions it takes part in
%       (nonzero entries of its row of S) and, for each reaction, the number of metabolites it
%       involves (nonzero entries of its column of S). The test checks exact counts for a model
%       built by createModel (counted by hand from the reaction formulas) and, on
%       ecoli_core_model, agreement with the row and column sums of S ~= 0.
%
% Function under test:
%     src/dataIntegration/metabotools/networkTopology.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - structural look-up on a small createModel model and ecoli_core_model; no solver.
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
fileDir = fileparts(which('testNetworkTopology'));
cd(fileDir);

% declare the requirements of this test. This test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

%% counts on a hand-built model

% R1 a + b -> 2 c, R2 c -> d, EX_a a <=> (exchange)
model = createModel({'R1', 'R2', 'EX_a'}, {'R1', 'R2', 'EX_a'}, {'a + b -> 2 c', 'c -> d', 'a <=> '});
[metConn, rxnLength] = networkTopology(model);

% counted by hand: a in R1 and EX_a, b in R1, c in R1 and R2, d in R2; R1 has 3 metabolites,
% R2 2 and EX_a 1. The stoichiometric coefficient (2 c) does not count, only participation
expectedConn = [2; 1; 2; 1];
metIdx = findMetIDs(model, {'a[c]'; 'b[c]'; 'c[c]'; 'd[c]'});
assert(isequal(size(metConn), [numel(model.mets), 1]));
assert(isequal(metConn(metIdx), expectedConn));
assert(isequal(rxnLength, [3; 2; 1]));

%% counts on ecoli_core_model agree with the nonzero pattern of S

model = getDistributedModel('ecoli_core_model.mat');
[metConn, rxnLength] = networkTopology(model);
% integer counts: exact comparison; the sum of either vector is the number of nonzeros of S
assert(isequal(metConn, full(sum(model.S ~= 0, 2))));
assert(isequal(rxnLength, full(sum(model.S ~= 0, 1))'));
assert(sum(metConn) == nnz(model.S) && sum(rxnLength) == nnz(model.S));

% change the directory
cd(currentDir)
