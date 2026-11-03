% The COBRAToolbox: testFindCyclicRxns.m
%
% Purpose:
%     - findCyclicRxns computes a basis of the right null space of model.S with getNullSpace and
%       returns the rank of S and, as first output, a summary of the null-space basis. Only the
%       rank is asserted: the first output is affected by the defect below.
%       Characterization test that PINS the current behaviour (feature
%       20261103-105830-tier2-safe-batch, Constitution Principle III characterization mode);
%       it must not change the function under test.
%     - Reference values: the rank asserted below was recorded from the first run on 2026-11-03
%       with ecoli_core_model (no solver). It was not derived independently, so it guards
%       consistency, not independent correctness (Tier 5); it is also compared with the rank that
%       MATLAB computes from the full matrix.
%
% Function under test:
%     src/analysis/topology/findCyclicRxns.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - model manipulation, no solver; ecoli_core_model loaded through getDistributedModel.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The first output is not a per-reaction boolean
%       SEVERITY: wrong-result
%       TRIGGER: any call, for example findCyclicRxns(model, 0) with ecoli_core_model
%       OBSERVED: cyclicRxnBool = Z' * ones(n, 1) sums the entries of each null-space basis
%         vector, giving a (n - rank(S)) x 1 vector of real numbers (28 x 1 for
%         ecoli_core_model), not one value per reaction
%       EXPECTED: an n x 1 logical vector, true for the reactions in the support of the null
%         space (part of a stoichiometrically balanced cycle), as the help text states
%       LINES: 24
%
% Authors:
%     - Generated for feature 20261103-105830-tier2-safe-batch, 2026-11-03.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testFindCyclicRxns'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox or
% particular operating system, so none is listed
prepareTest();

% load the model once (95 reactions, 72 metabolites)
model = getDistributedModel('ecoli_core_model.mat');

%% the rank of S, without output

[~, rankS] = findCyclicRxns(model, 0);

% the rank equals the rank MATLAB computes from the full matrix (an integer, so equality is
% exact); Tier-5 value, first run 2026-11-03: 67
assert(rankS == rank(full(model.S)));
assert(rankS == 67);

%% the rank of S, with the output of getNullSpace

% printLevel 1 makes getNullSpace print the sizes of S and of the null-space basis and the
% residual norm(S*Z, inf); the rank is the same
[~, rankS] = findCyclicRxns(model, 1);
assert(rankS == 67);

% change the directory
cd(currentDir)
