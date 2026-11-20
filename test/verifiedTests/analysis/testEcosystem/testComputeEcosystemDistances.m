% The COBRAToolbox: testComputeEcosystemDistances.m
%
% Purpose:
%     - computeEcosystemDistances(Z, distanceMetric) returns the n x n matrix of distances
%       between the rows of Z: Jaccard (fraction of differing coordinates among those where at
%       least one row is non-zero; 0 for two null rows), Hamming (fraction of differing
%       coordinates), Euclidean or city-block. For Jaccard and Hamming it counts equal
%       coordinates with indicator matrices when Z has at most 50 distinct values, and row by
%       row otherwise. This test checks hand-calculated distances for five small rows (two of
%       them null) with every metric and both counting methods, the default metric, the
%       case-insensitive metric name, logical input, the symmetry and zero diagonal of the
%       result, and the documented errors.
%
% Function under test:
%     src/analysis/ecosystem/computeEcosystemDistances.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver, hand-built matrices.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-13.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testComputeEcosystemDistances'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% the distances are ratios of small integers or square roots of integers; 1e-12 allows only
% the rounding of these operations
tol = 1e-12;

% five rows: a, b, c (null), d, e (null)
Z = [1 0 2; 1 0 0; 0 0 0; 1 3 2; 0 0 0];

% Jaccard by hand (coordinates where a row is non-zero; differing ones among them):
% a-b {1,3}, differ at 3: 1/2; a-c {1,3}, both differ: 1; a-d {1,2,3}, differ at 2: 1/3;
% b-c {1}: 1; b-d {1,2,3}, differ at 2 and 3: 2/3; c-d {1,2,3}: 1; c-e: two null rows: 0
refJaccard = [0 1/2 1 1/3 1; 1/2 0 1 2/3 1; 1 1 0 1 0; 1/3 2/3 1 0 1; 1 1 0 1 0];
% Hamming by hand (differing coordinates / 3): a-b 1, a-c 2, a-d 1, b-c 1, b-d 2, c-d 3
refHamming = [0 1 2 1 2; 1 0 1 2 1; 2 1 0 3 0; 1 2 3 0 3; 2 1 0 3 0] / 3;
% Euclidean by hand: a-b 2, a-c sqrt(5), a-d 3, b-c 1, b-d sqrt(13), c-d sqrt(14)
refEuclidean = sqrt([0 4 5 9 5; 4 0 1 13 1; 5 1 0 14 0; 9 13 14 0 14; 5 1 0 14 0]);
% city block by hand: a-b 2, a-c 3, a-d 3, b-c 1, b-d 5, c-d 6
refCityblock = [0 2 3 3 3; 2 0 1 5 1; 3 1 0 6 0; 3 5 6 0 6; 3 1 0 6 0];

%% every metric on few distinct values (indicator-matrix counting for Jaccard and Hamming)

assert(max(max(abs(computeEcosystemDistances(Z, 'jaccard') - refJaccard))) < tol);
assert(max(max(abs(computeEcosystemDistances(Z, 'hamming') - refHamming))) < tol);
assert(max(max(abs(computeEcosystemDistances(Z, 'euclidean') - refEuclidean))) < tol);
assert(max(max(abs(computeEcosystemDistances(Z, 'cityblock') - refCityblock))) < tol);

%% default metric (Jaccard), empty metric, case-insensitive name, logical input

D = computeEcosystemDistances(Z);
assert(isequal(D, computeEcosystemDistances(Z, 'jaccard')));
assert(isequal(computeEcosystemDistances(Z, ''), D));
assert(isequal(computeEcosystemDistances(Z, 'HAMMING'), computeEcosystemDistances(Z, 'hamming')));
% logical rows [1 0] and [1 1]: Jaccard 1/2 (coordinates {1,2}, differ at 2), Hamming 1/2
assert(max(max(abs(computeEcosystemDistances(logical([1 0; 1 1])) - [0 0.5; 0.5 0]))) < tol);

%% the result is exactly symmetric with a zero diagonal

for metric = {'jaccard', 'hamming', 'euclidean', 'cityblock'}
    D = computeEcosystemDistances(Z, metric{1});
    assert(isequal(D, D') && all(diag(D) == 0));
end

%% more than 50 distinct values: row-by-row counting gives the same distances

% 20 extra rows with the 60 values 101 to 160 (none equal to a value of Z) raise the number
% of distinct values to 63; the distances between the first five rows do not depend on the
% other rows, and every extra row differs from every other row in all three coordinates
% (Jaccard and Hamming 1, as all coordinates are non-zero)
Zmany = [Z; reshape(101:160, 20, 3)];
refJaccardMany = ones(25);
refJaccardMany(1:5, 1:5) = refJaccard;
refJaccardMany(logical(eye(25))) = 0;
refHammingMany = ones(25);
refHammingMany(1:5, 1:5) = refHamming;
% null rows c and e differ from an extra row in all three coordinates as well
refHammingMany(logical(eye(25))) = 0;
assert(max(max(abs(computeEcosystemDistances(Zmany, 'jaccard') - refJaccardMany))) < tol);
assert(max(max(abs(computeEcosystemDistances(Zmany, 'hamming') - refHammingMany))) < tol);

%% errors: missing or non-numeric Z, Z with more than two dimensions, NaN, unknown metric

assert(verifyCobraFunctionError('computeEcosystemDistances', 'testMessage', 'Z must be a numeric matrix.'));
assert(verifyCobraFunctionError('computeEcosystemDistances', 'inputs', {{1, 2}}, ...
    'testMessage', 'Z must be a numeric matrix.'));
assert(verifyCobraFunctionError('computeEcosystemDistances', 'inputs', {ones(2, 2, 2)}, ...
    'testMessage', 'Z must be a numeric matrix.'));
assert(verifyCobraFunctionError('computeEcosystemDistances', 'inputs', {[1 NaN; 2 3]}, ...
    'testMessage', 'Z must not contain NaN values.'));
metricMessage = 'distanceMetric must be ''jaccard'', ''hamming'', ''euclidean'' or ''cityblock''.';
assert(verifyCobraFunctionError('computeEcosystemDistances', 'inputs', {Z, 'cosine'}, ...
    'testMessage', metricMessage));
assert(verifyCobraFunctionError('computeEcosystemDistances', 'inputs', {Z, 1}, ...
    'testMessage', metricMessage));

% change the directory
cd(currentDir)
