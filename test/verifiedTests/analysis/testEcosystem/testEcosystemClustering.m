% The COBRAToolbox: testEcosystemClustering.m
%
% Purpose:
%     - tests computeEcosystemDistances, computeEcosystemLinkage,
%       computeEcosystemDBSCAN and the options of clusterEcosystemPoints
%       against reference results of SciPy (scipy.spatial.distance.pdist,
%       scipy.cluster.hierarchy.linkage and fcluster) and scikit-learn
%       (sklearn.cluster.DBSCAN) for a small matrix of qualitative states
%       with a null row and duplicated rows. No solver is needed.
%
% Authors:
%     - Sebastián N. Mendoza, 21/10/2026
%

global CBTDIR

% save the current path and initialize the test
currentDir = cd(fileparts(which(mfilename)));

% set the tolerance
tol = 1e-12;

% qualitative states of 10 points (row 5 is null, rows 1 and 8 are equal)
Z = [2 0 -1 0 3 0; 2 0 -1 0 3 1; 0 4 0 0 0 2; 0 4 0 1 0 2; 0 0 0 0 0 0; -3 -3 2 2 0 0; ...
    -3 -3 2 2 0 1; 2 0 -1 0 3 0; 5 5 5 0 0 0; 0 4 0 1 1 2];

% reference distances (scipy.spatial.distance.pdist)
refD.jaccard = [0 0.25 1 1 1 1 1 0 1 1; 0.25 0 1 1 1 1 5/6 0.25 1 1; 1 1 0 1/3 1 1 1 1 1 0.5; ...
    1 1 1/3 0 1 1 1 1 1 0.25; 1 1 1 1 0 1 1 1 1 1; 1 1 1 1 1 0 0.2 1 1 1; 1 5/6 1 1 1 0.2 0 1 1 1; ...
    0 0.25 1 1 1 1 1 0 1 1; 1 1 1 1 1 1 1 1 0 1; 1 1 0.5 0.25 1 1 1 1 1 0];
refD.hamming = [0 1 5 6 3 5 6 0 4 6; 1 0 5 6 4 6 5 1 5 6; 5 5 0 1 2 5 5 5 4 2; 6 6 1 0 3 5 5 6 5 1; ...
    3 4 2 3 0 4 5 3 3 4; 5 6 5 5 4 0 1 5 4 6; 6 5 5 5 5 1 0 6 5 6; 0 1 5 6 3 5 6 0 4 6; ...
    4 5 4 5 3 4 5 4 0 6; 6 6 2 1 4 6 6 6 6 0] / 6;
refD.cityblock = [0 1 12 13 6 16 17 0 17 12; 1 0 11 12 7 17 16 1 18 11; 12 11 0 1 6 16 15 12 13 2; ...
    13 12 1 0 7 15 14 13 14 1; 6 7 6 7 0 10 11 6 15 8; 16 17 16 15 10 0 1 16 21 16; ...
    17 16 15 14 11 1 0 17 22 15; 0 1 12 13 6 16 17 0 17 12; 17 18 13 14 15 21 22 17 0 15; ...
    12 11 2 1 8 16 15 12 15 0];
refEuclidean15 = [0 1 sqrt(34) sqrt(35) sqrt(14)];
% reference linkage matrices (scipy.cluster.hierarchy.linkage on the Jaccard distances)
refL.ward = [1 8 0; 6 7 0.2; 4 10 0.25; 2 11 0.28867513459481287; 3 13 0.46894286155928144; ...
    5 9 1; 12 16 1.2165525060596438; 15 17 1.4789170927390645; 14 18 1.6073812874282827];
refL.single = [1 8 0; 6 7 0.2; 2 11 0.25; 4 10 0.25; 3 14 1/3; 12 13 5/6; 15 16 1; 5 17 1; 9 18 1];
refL.complete = [1 8 0; 6 7 0.2; 2 11 0.25; 4 10 0.25; 3 14 0.5; 5 12 1; 13 16 1; 9 17 1; 15 18 1];
refL.average = [1 8 0; 6 7 0.2; 2 11 0.25; 4 10 0.25; 3 14 5/12; 12 13 0.97222222222222232; 5 16 1; 9 17 1; 15 18 1];
refL.weighted = [1 8 0; 6 7 0.2; 2 11 0.25; 4 10 0.25; 3 14 5/12; 12 13 0.95833333333333337; 5 16 1; 9 17 1; 15 18 1];
% reference clusters (fcluster with criterion 'maxclust' and k = 3; DBSCAN with eps = 0.5 and min_samples = 2)
refClustersWard = [1 1 2 2 3 3 3 1 3 2]';
refDBSCAN = [0 0 1 1 -1 2 2 0 -1 1]';

% distances
for metric = {'jaccard', 'hamming', 'cityblock'}
    D = computeEcosystemDistances(Z, metric{1});
    assert(max(max(abs(D - refD.(metric{1})))) < tol);
end
D = computeEcosystemDistances(Z, 'euclidean');
assert(max(abs(D(1, 1:5) - refEuclidean15)) < tol && isequal(D, D'));
assert(isequal(computeEcosystemDistances(Z), computeEcosystemDistances(Z, 'jaccard')));
% matrices with many distinct values use the row-by-row computation
Zmany = reshape(1:60, 10, 6);
Zmany(5, :) = 0;
Zmany(2, 1:3) = 0;
nonZero = Zmany ~= 0;
for metric = {'jaccard', 'hamming'}
    D = computeEcosystemDistances(Zmany, metric{1});
    for i = 1:10
        for j = 1:10
            unequal = Zmany(i, :) ~= Zmany(j, :);
            if strcmp(metric{1}, 'jaccard')
                union = nonZero(i, :) | nonZero(j, :);
                expected = sum(unequal & union) / max(sum(union), 1);
            else
                expected = mean(unequal);
            end
            assert(abs(D(i, j) - expected) < tol);
        end
    end
end

% linkage
for method = {'ward', 'single', 'complete', 'average', 'weighted'}
    L = computeEcosystemLinkage(refD.jaccard, method{1});
    assert(isequal(L(:, 1:2), refL.(method{1})(:, 1:2)));
    assert(max(abs(L(:, 3) - refL.(method{1})(:, 3))) < tol);
end
assert(isequal(computeEcosystemLinkage(refD.jaccard), computeEcosystemLinkage(refD.jaccard, 'ward')));

% DBSCAN
assert(isequal(computeEcosystemDBSCAN(refD.jaccard, 0.5, 2), refDBSCAN));
assert(isequal(computeEcosystemDBSCAN(refD.jaccard), -ones(10, 1)));

% clusterEcosystemPoints
eco = struct('qualVectors', Z);
[eco, clusters, k] = clusterEcosystemPoints(eco, 'k', 3, 'printLevel', 1);
assert(isequal(clusters, refClustersWard) && isequal(eco.clusters, refClustersWard) && k == 3);
assert(isequal(eco.linkage, computeEcosystemLinkage(refD.jaccard, 'ward')));
[~, clusters] = clusterEcosystemPoints(eco, 'k', 20, 'printLevel', 0);
assert(isequal(sort(clusters), (1:10)'));
[~, clusters] = clusterEcosystemPoints(eco, 'k', 2, 'linkageMethod', 'average', 'distance', 'hamming', 'printLevel', 0);
assert(numel(unique(clusters)) <= 2);
[~, clusters, k] = clusterEcosystemPoints(eco, 'method', 'dbscan', 'epsilon', 0.5, 'minPoints', 2, 'printLevel', 1);
% DBSCAN labels: outliers (-1) in cluster 1, then clusters 0, 1, 2 in clusters 2, 3, 4
assert(k == 4 && isequal(clusters, refDBSCAN + 2));
[~, clusters, k] = clusterEcosystemPoints(struct('qualVectors', Z(1, :)), 'printLevel', 0);
assert(clusters == 1 && k == 1);

% wrong inputs
assert(verifyCobraFunctionError('computeEcosystemDistances', 'inputs', {{1}}));
assert(verifyCobraFunctionError('computeEcosystemDistances', 'inputs', {Z, 'cosine'}));
assert(verifyCobraFunctionError('computeEcosystemDistances', 'inputs', {[1 NaN; 2 3]}));
assert(verifyCobraFunctionError('computeEcosystemLinkage', 'inputs', {ones(2, 3)}));
assert(verifyCobraFunctionError('computeEcosystemLinkage', 'inputs', {refD.jaccard, 'centroid'}));
assert(verifyCobraFunctionError('computeEcosystemLinkage', 'inputs', {0}));
assert(verifyCobraFunctionError('computeEcosystemDBSCAN', 'inputs', {ones(2, 3)}));
assert(verifyCobraFunctionError('computeEcosystemDBSCAN', 'inputs', {refD.jaccard, -1}));
assert(verifyCobraFunctionError('computeEcosystemDBSCAN', 'inputs', {refD.jaccard, 0.5, 0}));
assert(verifyCobraFunctionError('clusterEcosystemPoints', 'inputs', {struct('qualVectors', [])}, ...
    'testMessage', 'No qualitative FVA values stored. Run ecosystemQualitativeFVA first!'));
assert(verifyCobraFunctionError('clusterEcosystemPoints', 'inputs', {eco, 'linkageMethod', 'centroid'}));
fprintf('Done.\n');

% change the directory
cd(currentDir)
