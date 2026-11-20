% The COBRAToolbox: testGetEcosystemClusterReactionValues.m
%
% Purpose:
%     - getEcosystemClusterReactionValues computes the representative qualitative state of
%       each reaction in each cluster: the state (codes rounded) shared by at least a fraction
%       thr of the points of the cluster, the smallest code if several qualify, NaN if none.
%       With 'changing' it keeps only reactions whose representative values differ between
%       clusters (NaN counts as a value). This test checks a hand-built ecosystem structure
%       of six points and four reactions for the default threshold, a lower threshold with a
%       tie, 'changing' on and off, a reaction subset (cell and string array), the number of
%       clusters taken from max(eco.clusters) when eco.k is empty, a cluster without points,
%       and the input errors. Expected values are worked out by hand from the documented rule.
%
% Function under test:
%     src/analysis/ecosystem/getEcosystemClusterReactionValues.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver, a hand-built ecosystem structure.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testGetEcosystemClusterReactionValues'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% six analyzed points (rows) and four reactions (columns); points 1-4 form cluster 1 and
% points 5-6 cluster 2. 4.2 is rounded to 4 before counting
%            r1  r2  r3  r4
qualVectors = [0   1  -1   4; ...
               0   1  -1   4; ...
               0   1   3   4; ...
               1   1   3   4.2; ...
               2   1   3   5; ...
               2   1   3   4];
eco = struct('qualVectors', qualVectors, 'clusters', [1; 1; 1; 1; 2; 2], 'k', 2, ...
    'rxn2cluster', {{'r1'; 'r2'; 'r3'; 'r4'}});

%% default options: thr = 0.75, only changing reactions

% r1: c1 0 (3 of 4), c2 2; r2: 1 in both (dropped); r3: c1 -1 and 3 at 2 of 4 each (none
% reaches 0.75, NaN), c2 3; r4: c1 4 (4 of 4 after rounding), c2 4 and 5 at 1 of 2 (NaN)
[repTable, repValues, rxnIds] = getEcosystemClusterReactionValues(eco);
% codes are integers or NaN, so the comparison is exact
assert(isequaln(repValues, [0 2; NaN 3; 4 NaN]));
assert(isequal(rxnIds, {'r1'; 'r3'; 'r4'}));
assert(isequal(repTable.Properties.VariableNames, {'c1', 'c2'}));
assert(isequal(repTable.Properties.RowNames, {'r1'; 'r3'; 'r4'}));
assert(isequal(repTable{:, :}, {'0', '++'; 'NaN', '+'; '-+', 'NaN'}));

%% all reactions, and a lower threshold where two states tie

[~, repValues, rxnIds] = getEcosystemClusterReactionValues(eco, 'changing', false);
assert(isequaln(repValues, [0 2; 1 1; NaN 3; 4 NaN]));
assert(isequal(rxnIds, {'r1'; 'r2'; 'r3'; 'r4'}));
% thr = 0.5: r3 in c1 has -1 and 3 at 0.5 each and r4 in c2 has 4 and 5 at 0.5 each; the
% smallest code is representative
[~, repValues] = getEcosystemClusterReactionValues(eco, 'thr', 0.5, 'changing', false);
assert(isequal(repValues, [0 2; 1 1; -1 3; 4 4]));
% with changing, r2 (1, 1) and r4 (4, 4) are dropped
[~, repValues, rxnIds] = getEcosystemClusterReactionValues(eco, 'thr', 0.5, 'changing', 1);
assert(isequal(repValues, [0 2; -1 3]) && isequal(rxnIds, {'r1'; 'r3'}));

%% reaction subset, in the order given (cell array and string array)

[repTable, repValues, rxnIds] = getEcosystemClusterReactionValues(eco, 'rxnList', {'r4', 'r1'}, ...
    'changing', false);
assert(isequaln(repValues, [4 NaN; 0 2]) && isequal(rxnIds, {'r4'; 'r1'}));
assert(isequal(repTable.Properties.RowNames, {'r4'; 'r1'}));
[~, repValuesString] = getEcosystemClusterReactionValues(eco, 'rxnList', ["r4", "r1"], 'changing', false);
assert(isequaln(repValuesString, repValues));

%% number of clusters: max(eco.clusters) when eco.k is empty; an empty cluster gives NaN

ecoNoK = eco;
ecoNoK.k = [];
[~, repValues] = getEcosystemClusterReactionValues(ecoNoK, 'changing', false);
assert(isequaln(repValues, [0 2; 1 1; NaN 3; 4 NaN]));
% eco.k = 3 with no point in cluster 3: its column is NaN, and NaN counts as a change, so r2
% (1, 1, NaN) is kept
ecoThree = eco;
ecoThree.k = 3;
[repTable, repValues, rxnIds] = getEcosystemClusterReactionValues(ecoThree);
assert(isequaln(repValues, [0 2 NaN; 1 1 NaN; NaN 3 NaN; 4 NaN NaN]));
assert(isequal(rxnIds, {'r1'; 'r2'; 'r3'; 'r4'}));
assert(isequal(repTable.Properties.VariableNames, {'c1', 'c2', 'c3'}));

%% input errors

assert(verifyCobraFunctionError('getEcosystemClusterReactionValues', 'inputs', {rmfield(eco, 'clusters')}));
assert(verifyCobraFunctionError('getEcosystemClusterReactionValues', 'inputs', {eco, 'thr', 0}));
ecoEmpty = eco;
ecoEmpty.clusters = [];
assert(verifyCobraFunctionError('getEcosystemClusterReactionValues', 'inputs', {ecoEmpty}, ...
    'testMessage', 'Missing clustering/qualitative FVA results!'));
ecoShort = eco;
ecoShort.clusters = [1; 2];
assert(verifyCobraFunctionError('getEcosystemClusterReactionValues', 'inputs', {ecoShort}, ...
    'testMessage', 'The number of clustered points differs from the number of qualitative vectors.'));
assert(verifyCobraFunctionError('getEcosystemClusterReactionValues', 'inputs', {eco, 'rxnList', {'r1', 'rX', 'rY'}}, ...
    'testMessage', 'Reactions not found in eco.rxn2cluster: rX, rY'));

% change the directory
cd(currentDir)
