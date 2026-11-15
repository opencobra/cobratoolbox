% The COBRAToolbox: testComputeEcosystemLinkage.m
%
% Purpose:
%     - computeEcosystemLinkage(D, linkageMethod) clusters n observations hierarchically from
%       their matrix of distances D and returns the (n - 1) x 3 linkage matrix in the format of
%       MATLAB's linkage: row k merges clusters L(k, 1) < L(k, 2) (1..n: observations, n + k:
%       cluster created at row k) at distance L(k, 3), rows sorted by distance. 'single' uses a
%       minimum spanning tree, the other methods a nearest-neighbour chain with Lance-Williams
%       updates.
%     - This test checks, for four points on a line (positions 0, 1, 3 and 7, Euclidean
%       distances), the linkage matrix of every method calculated by hand from the definitions
%       of the methods (single: closest pair; complete: farthest pair; average: mean of all
%       pairs; weighted: mean of the two merged clusters' distances; Ward: sqrt(2 |A| |B| /
%       (|A| + |B|)) times the distance between centroids), a chain that ends with the lower
%       index on top, equal distances (ties), the default method, the case-insensitive method
%       name, and the documented errors.
%
% Function under test:
%     src/analysis/ecosystem/computeEcosystemLinkage.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver, hand-built distance matrices.
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
fileDir = fileparts(which('testComputeEcosystemLinkage'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% merge distances are small rationals or square roots of rationals; 1e-12 allows only the
% rounding of the Lance-Williams updates
tol = 1e-12;

% four points on a line at 0, 1, 3 and 7
positions = [0 1 3 7];
D = abs(positions' - positions);

%% every method, calculated by hand

% all methods merge 1 and 2 first (distance 1) into cluster 5, then 3 with cluster 5 into
% cluster 6, then 4 with cluster 6; only the distances differ:
% single:   {1,2}-3 = min(3, 2) = 2;          {1,2,3}-4 = min(7, 6, 4) = 4
% complete: {1,2}-3 = max(3, 2) = 3;          {1,2,3}-4 = max(7, 6, 4) = 7
% average:  {1,2}-3 = (3 + 2) / 2 = 2.5;      {1,2,3}-4 = (7 + 6 + 4) / 3 = 17/3
% weighted: {1,2}-3 = (3 + 2) / 2 = 2.5;      {1,2,3}-4 = ((7 + 6) / 2 + 4) / 2 = 5.25
% ward:     {1,2} (centroid 0.5) - 3: sqrt(2 * 2 * 1 / 3) * 2.5 = 2.5 * sqrt(4/3);
%           {1,2,3} (centroid 4/3) - 4: sqrt(2 * 3 * 1 / 4) * (7 - 4/3) = (17/3) * sqrt(3/2)
refL.single = [1 2 1; 3 5 2; 4 6 4];
refL.complete = [1 2 1; 3 5 3; 4 6 7];
refL.average = [1 2 1; 3 5 2.5; 4 6 17/3];
refL.weighted = [1 2 1; 3 5 2.5; 4 6 5.25];
refL.ward = [1 2 1; 3 5 2.5 * sqrt(4/3); 4 6 17/3 * sqrt(3/2)];
for method = {'single', 'complete', 'average', 'weighted', 'ward'}
    L = computeEcosystemLinkage(D, method{1});
    % cluster labels are integers: exact; distances within the rounding tolerance
    assert(isequal(size(L), [3, 3]));
    assert(isequal(L(:, 1:2), refL.(method{1})(:, 1:2)), method{1});
    assert(max(abs(L(:, 3) - refL.(method{1})(:, 3))) < tol, method{1});
end

%% default method (ward), empty method and case-insensitive name

assert(isequal(computeEcosystemLinkage(D), computeEcosystemLinkage(D, 'ward')));
assert(isequal(computeEcosystemLinkage(D, ''), computeEcosystemLinkage(D, 'ward')));
assert(isequal(computeEcosystemLinkage(D, 'Single'), computeEcosystemLinkage(D, 'single')));

%% a nearest-neighbour chain 1 -> 3 -> 2: the mutual neighbours 2 and 3 merge first

% points at 0, 5 and 3.5: the chain starts at 1, whose nearest point is 3 (3.5), whose
% nearest point is 2 (1.5); 2 and 3 are mutual nearest neighbours and merge into cluster 4,
% which then merges with 1 at the complete-linkage distance max(5, 3.5) = 5
positions = [0 5 3.5];
L = computeEcosystemLinkage(abs(positions' - positions), 'complete');
assert(isequal(L(:, 1:2), [2 3; 1 4]) && max(abs(L(:, 3) - [1.5; 5])) < tol);

%% equal distances: the first candidate wins every tie

% three points at distance 1 from each other: 1 and 2 merge first, then 3 joins (cluster 4)
Dtie = ones(3) - eye(3);
for method = {'single', 'complete', 'average', 'weighted'}
    L = computeEcosystemLinkage(Dtie, method{1});
    assert(isequal(L, [1 2 1; 3 4 1]), method{1});
end

%% errors: missing, non-numeric or non-square D, unknown method, fewer than two observations

squareMessage = 'D must be a square matrix of distances.';
assert(verifyCobraFunctionError('computeEcosystemLinkage', 'testMessage', squareMessage));
assert(verifyCobraFunctionError('computeEcosystemLinkage', 'inputs', {{1}}, 'testMessage', squareMessage));
assert(verifyCobraFunctionError('computeEcosystemLinkage', 'inputs', {ones(2, 3)}, 'testMessage', squareMessage));
assert(verifyCobraFunctionError('computeEcosystemLinkage', 'inputs', {ones(2, 2, 2)}, 'testMessage', squareMessage));
methodMessage = 'linkageMethod must be ''ward'', ''single'', ''complete'', ''average'' or ''weighted''.';
assert(verifyCobraFunctionError('computeEcosystemLinkage', 'inputs', {D, 'centroid'}, 'testMessage', methodMessage));
assert(verifyCobraFunctionError('computeEcosystemLinkage', 'inputs', {D, 2}, 'testMessage', methodMessage));
assert(verifyCobraFunctionError('computeEcosystemLinkage', 'inputs', {0}, ...
    'testMessage', 'At least two observations are required.'));

% change the directory
cd(currentDir)
