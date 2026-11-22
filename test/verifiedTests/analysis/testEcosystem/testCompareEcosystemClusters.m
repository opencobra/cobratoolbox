% The COBRAToolbox: testCompareEcosystemClusters.m
%
% Purpose:
%     - compareEcosystemClusters selects the reactions whose representative qualitative states
%       differ between two clusters (NaN differs from any state but equals NaN) and returns them
%       as a table of labels (columns c<i>, rows = reaction IDs), as an nChanging x 2 matrix of
%       codes and as a list of reaction IDs. This test checks a numeric matrix with every NaN
%       combination, cluster IDs given as numbers, 'c<i>' strings, string scalars and plain
%       digits, the table input of getEcosystemClusterReactionValues (labels translated back
%       to codes, 'var' and 'NaN' included), the case where nothing differs, and every input
%       error. Expected values are worked out by hand from the documented rule and the label
%       table of qualitativeStateLabels.
%
% Function under test:
%     src/analysis/ecosystem/compareEcosystemClusters.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver, hand-built matrices and tables.
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
fileDir = fileparts(which('testCompareEcosystemClusters'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% representative codes of five reactions in three clusters
repValues = [1 1 2; -1 0 -1; NaN 3 NaN; 4 2 NaN; 5 5 3];
rxnIds = {'a'; 'b'; 'c'; 'd'; 'e'};

%% numeric input, numeric cluster IDs

% c1 vs c3: a 1/2 differ, b -1/-1 equal, c NaN/NaN equal, d 4/NaN differ, e 5/3 differ
[compTable, compValues, changedIds] = compareEcosystemClusters(repValues, rxnIds, 1, 3);
% codes are integers or NaN, so the comparison is exact
assert(isequaln(compValues, [1 2; 4 NaN; 5 3]));
assert(isequal(changedIds, {'a'; 'd'; 'e'}));
assert(isequal(compTable.Properties.VariableNames, {'c1', 'c3'}));
assert(isequal(compTable.Properties.RowNames, {'a'; 'd'; 'e'}));
% labels: 1 '0+', 2 '++', 4 '-+', NaN 'NaN', 5 'err', 3 '+'
assert(isequal(compTable{:, :}, {'0+', '++'; '-+', 'NaN'; 'err', '+'}));

%% cluster IDs as 'c<i>' text, string scalars and digits give the same result, in order

% c3 vs c1 swaps the columns
[compTable, compValues, changedIds] = compareEcosystemClusters(repValues, rxnIds, 'c3', "c1");
assert(isequaln(compValues, [2 1; NaN 4; 3 5]));
assert(isequal(changedIds, {'a'; 'd'; 'e'}));
assert(isequal(compTable.Properties.VariableNames, {'c3', 'c1'}));
% a digit without the prefix is accepted too; c1 vs c2 differ in a (no), b (-1/0), c (NaN/3),
% d (4/2) and not in e (5/5)
[~, compValues, changedIds] = compareEcosystemClusters(repValues, rxnIds, '1', 2);
assert(isequaln(compValues, [-1 0; NaN 3; 4 2]));
assert(isequal(changedIds, {'b'; 'c'; 'd'}));

%% table input (labels of getEcosystemClusterReactionValues), rxnIds taken from RowNames

labels = {'0+', 'var', '+'; '0', '0', '0'; 'NaN', '--', 'NaN'};
repTable = cell2table(labels, 'VariableNames', {'c1', 'c2', 'c3'}, 'RowNames', {'r1'; 'r2'; 'r3'});
% c1 vs c2: r1 1/100 differ, r2 equal, r3 NaN/-2 differ ('NaN' is not a state label)
[compTable, compValues, changedIds] = compareEcosystemClusters(repTable, {}, 'c1', 'c2');
assert(isequaln(compValues, [1 100; NaN -2]));
assert(isequal(changedIds, {'r1'; 'r3'}));
assert(isequal(compTable{:, :}, {'0+', 'var'; 'NaN', '--'}));

%% nothing differs: empty outputs with the two cluster columns

[compTable, compValues, changedIds] = compareEcosystemClusters([1 1; 2 2], {'x'; 'y'}, 1, 2);
assert(isequal(size(compValues), [0 2]) && isempty(changedIds) && iscell(changedIds));
assert(isequal(size(compTable), [0 2]));
assert(isequal(compTable.Properties.VariableNames, {'c1', 'c2'}));

%% input errors

assert(verifyCobraFunctionError('compareEcosystemClusters', 'inputs', {repValues, rxnIds, 1}, ...
    'testMessage', 'repValues, rxnIds, clusterId1 and clusterId2 must be provided.'));
assert(verifyCobraFunctionError('compareEcosystemClusters', 'inputs', {{1, 2}, rxnIds, 1, 2}, ...
    'testMessage', 'repValues must be a numeric matrix or a table.'));
assert(verifyCobraFunctionError('compareEcosystemClusters', 'inputs', {repValues, rxnIds(1:4), 1, 2}, ...
    'testMessage', 'rxnIds must be a cell array with one ID per row of repValues.'));
assert(verifyCobraFunctionError('compareEcosystemClusters', 'inputs', {repValues, "a", 1, 2}, ...
    'testMessage', 'rxnIds must be a cell array with one ID per row of repValues.'));
% unparsable text, zero, beyond the number of clusters, and a non-numeric ID
assert(verifyCobraFunctionError('compareEcosystemClusters', 'inputs', {repValues, rxnIds, 'cx', 2}, ...
    'testMessage', 'Invalid cluster ID.'));
assert(verifyCobraFunctionError('compareEcosystemClusters', 'inputs', {repValues, rxnIds, 1, 0}, ...
    'testMessage', 'Invalid cluster ID.'));
assert(verifyCobraFunctionError('compareEcosystemClusters', 'inputs', {repValues, rxnIds, 1, 'c4'}, ...
    'testMessage', 'Invalid cluster ID.'));
assert(verifyCobraFunctionError('compareEcosystemClusters', 'inputs', {repValues, rxnIds, {1}, 2}, ...
    'testMessage', 'Invalid cluster ID.'));
assert(verifyCobraFunctionError('compareEcosystemClusters', 'inputs', {repValues, rxnIds, 2, 'c2'}, ...
    'testMessage', 'The two clusters must be different.'));

% change the directory
cd(currentDir)
