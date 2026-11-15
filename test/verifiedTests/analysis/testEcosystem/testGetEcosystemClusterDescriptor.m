% The COBRAToolbox: testGetEcosystemClusterDescriptor.m
%
% Purpose:
%     - getEcosystemClusterDescriptor describes a cluster of grid points: for each reaction with
%       a defined (not NaN) representative state in that cluster it counts the clusters with a
%       different state (NaN counts as different), and returns a table with the label of the
%       state and the count, sorted by count in descending order with NaN counts last. This test
%       checks a hand-built matrix of representative codes for a numeric and a 'c<i>' cluster
%       ID, and every input error. Expected counts and orders are worked out by hand from the
%       documented rule; labels come from the table of qualitativeStateLabels.
%
% Function under test:
%     src/analysis/ecosystem/getEcosystemClusterDescriptor.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver, hand-built matrices.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The status variable is named status_c<id>, not status as documented
%       SEVERITY: cosmetic
%       TRIGGER: getEcosystemClusterDescriptor([1 2; 0 0], {'a'; 'b'}, 1)
%       OBSERVED: VariableNames {'status_c1', 'diff'}, so descriptorTable.status errors
%       EXPECTED: a variable named status, as OUTPUT documents ("variables status ... and diff")
%       LINES: 67
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testGetEcosystemClusterDescriptor'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% representative codes of four reactions in four clusters
repValues = [1 2 1 NaN; 0 0 0 0; NaN 1 1 1; 3 1 2 1];
rxnIds = {'a'; 'b'; 'c'; 'd'};

%% cluster 1 (numeric ID)

% a: 1 vs [2 1 NaN] -> 2; b: 0 everywhere -> 0; c: NaN in cluster 1 -> NaN;
% d: 3 vs [1 2 1] -> 3; descending order with the NaN count last: d, a, b, c
descriptorTable = getEcosystemClusterDescriptor(repValues, rxnIds, 1);
assert(isequal(descriptorTable.Properties.RowNames, {'d'; 'a'; 'b'; 'c'}));
% counts are integers or NaN, so the comparison is exact
assert(isequaln(descriptorTable.diff, [3; 2; 0; NaN]));
assert(strcmp(descriptorTable.Properties.VariableNames{2}, 'diff'));
% the first variable holds the labels: 3 '+', 1 '0+', 0 '0', NaN 'NaN' (its name is the
% cosmetic defect in the header and is not asserted)
assert(isequal(descriptorTable{:, 1}, {'+'; '0+'; '0'; 'NaN'}));

%% cluster 'c2' (text ID)

% a: 2 vs [1 1 NaN] -> 3; b -> 0; c: 1 vs [NaN 1 1] -> 1; d: 1 vs [3 2 1] -> 2
descriptorTable = getEcosystemClusterDescriptor(repValues, rxnIds, 'c2');
assert(isequal(descriptorTable.Properties.RowNames, {'a'; 'd'; 'c'; 'b'}));
assert(isequal(descriptorTable.diff, [3; 2; 1; 0]));
assert(isequal(descriptorTable{:, 1}, {'++'; '0+'; '0+'; '0'}));
% a string scalar is accepted as well
assert(isequaln(getEcosystemClusterDescriptor(repValues, rxnIds, "c2"), descriptorTable));

%% input errors

assert(verifyCobraFunctionError('getEcosystemClusterDescriptor', 'inputs', {repValues, rxnIds}, ...
    'testMessage', 'repValues, rxnIds and clusterId must be provided.'));
assert(verifyCobraFunctionError('getEcosystemClusterDescriptor', 'inputs', {{1}, rxnIds, 1}, ...
    'testMessage', 'repValues must be a numeric matrix.'));
assert(verifyCobraFunctionError('getEcosystemClusterDescriptor', 'inputs', {repValues, rxnIds(1:3), 1}, ...
    'testMessage', 'rxnIds must be a cell array with one ID per row of repValues.'));
assert(verifyCobraFunctionError('getEcosystemClusterDescriptor', 'inputs', {repValues, rxnIds, 'cx'}, ...
    'testMessage', 'Invalid cluster ID.'));
assert(verifyCobraFunctionError('getEcosystemClusterDescriptor', 'inputs', {repValues, rxnIds, 0}, ...
    'testMessage', 'Invalid cluster ID.'));
assert(verifyCobraFunctionError('getEcosystemClusterDescriptor', 'inputs', {repValues, rxnIds, 'c5'}, ...
    'testMessage', 'Invalid cluster ID.'));
assert(verifyCobraFunctionError('getEcosystemClusterDescriptor', 'inputs', {repValues, rxnIds, {1}}, ...
    'testMessage', 'Invalid cluster ID.'));

% change the directory
cd(currentDir)
