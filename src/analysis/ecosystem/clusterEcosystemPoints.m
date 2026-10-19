function [eco, clusters, k] = clusterEcosystemPoints(eco, varargin)
% Clusters the analyzed points of the abundance-growth grid of an ecosystem
% according to their qualitative flux vectors (see `ecosystemQualitativeFVA`).
% By default, the Jaccard distance between qualitative vectors is computed
% and points are grouped by hierarchical clustering (Ward linkage), cutting
% the dendrogram to obtain at most `k` clusters.
%
% USAGE:
%
%    [eco, clusters, k] = clusterEcosystemPoints(eco, varargin)
%
% INPUT:
%    eco:              (structure) ecosystem structure with qualitative
%                      vectors (`eco.qualVectors`)
%
% OPTIONAL INPUTS:
%    method:           (string) 'hierarchical' or 'dbscan'
%                      (Default = 'hierarchical')
%    k:                (double) maximum number of clusters for hierarchical
%                      clustering (Default = 20)
%    linkageMethod:    (string) linkage method used by `linkage`
%                      (Default = 'ward')
%    linkageImplementation: (string) 'scipy' computes the Ward linkage with
%                      the nearest-neighbor chain algorithm of
%                      `scipy.cluster.hierarchy.linkage` (same tie-breaking,
%                      so that results are identical to the Python
%                      implementation); 'matlab' uses `linkage` of MATLAB.
%                      Other linkage methods always use `linkage`
%                      (Default = 'scipy')
%    distance:         (string) distance metric used by `pdist`
%                      (Default = 'jaccard')
%    epsilon:          (double) neighborhood radius for 'dbscan'
%                      (Default = 0.05)
%    minPoints:        (double) minimum number of neighbors for 'dbscan'
%                      (Default = 5)
%    printLevel:       (double) verbosity level (Default = 1)
%
% OUTPUTS:
%    eco:              (structure) ecosystem structure with fields `.clusters`
%                      (cluster of each analyzed point, aligned with the rows
%                      of `eco.qualVectors`), `.k` (number of clusters) and
%                      `.linkage` (linkage matrix, hierarchical only)
%    clusters:         (double) cluster of each analyzed point
%    k:                (double) number of clusters
%
% EXAMPLE:
%
%    eco = clusterEcosystemPoints(eco, 'method', 'hierarchical', 'k', 8);
%
% NOTE:
%
%    The Jaccard distance is the fraction of coordinates that differ among
%    the coordinates where at least one of the vectors is non-zero (as in
%    `scipy.spatial.distance.pdist`); the distance between two null vectors
%    is set to zero. Cluster labels of the hierarchical method are assigned
%    by a pre-order traversal of the dendrogram, as done by
%    `scipy.cluster.hierarchy.fcluster` with criterion 'maxclust', so that
%    labels follow the same convention as the Python implementation
%    (`Ecosystem.clusterPoints`). For 'dbscan', outliers are grouped in the
%    first cluster. Requires the Statistics and Machine Learning Toolbox.
%
% .. Author: - Sebastián N. Mendoza, 13/10/2026, MATLAB implementation based on the Python code of N.E. Jiménez et al.

parser = inputParser();
parser.addRequired('eco', @(x) isstruct(x) && isfield(x, 'qualVectors'));
parser.addParameter('method', 'hierarchical', @(x) any(strcmpi(x, {'hierarchical', 'dbscan'})));
parser.addParameter('k', 20, @(x) isnumeric(x) && isscalar(x) && x >= 1);
parser.addParameter('linkageMethod', 'ward', @ischar);
parser.addParameter('linkageImplementation', 'scipy', @(x) any(strcmpi(x, {'scipy', 'matlab'})));
parser.addParameter('distance', 'jaccard', @ischar);
parser.addParameter('epsilon', 0.05, @(x) isnumeric(x) && isscalar(x) && x > 0);
parser.addParameter('minPoints', 5, @(x) isnumeric(x) && isscalar(x) && x >= 1);
parser.addParameter('printLevel', 1, @(x) isnumeric(x) || islogical(x));
parser.parse(eco, varargin{:});
eco = parser.Results.eco;
method = lower(parser.Results.method);
kMax = parser.Results.k;
linkageMethod = parser.Results.linkageMethod;
linkageImplementation = parser.Results.linkageImplementation;
distanceMetric = parser.Results.distance;
epsilon = parser.Results.epsilon;
minPoints = parser.Results.minPoints;
printLevel = parser.Results.printLevel;

Z = eco.qualVectors;
if isempty(Z)
    error('No qualitative FVA values stored. Run ecosystemQualitativeFVA first!');
end
n = size(Z, 1);
if printLevel > 0
    fprintf('Calculating %s distances between grid points...\n', distanceMetric);
end
D = pdist(Z, distanceMetric);
D(isnan(D)) = 0;

if printLevel > 0
    fprintf('Clustering grid points ...\n');
end
switch method
    case 'hierarchical'
        if n == 1
            clusters = 1;
            k = 1;
            Zl = zeros(0, 3);
        else
            if strcmpi(linkageMethod, 'ward') && strcmpi(linkageImplementation, 'scipy')
                % Ward linkage by the nearest-neighbor chain algorithm with the
                % tie-breaking rules and labeling of scipy.cluster.hierarchy.linkage
                Dm = squareform(D);
                clusterSize = ones(n, 1);
                chain = zeros(n, 1);
                chainLength = 0;
                Zl = zeros(n - 1, 3);
                for step = 1:n - 1
                    if chainLength == 0
                        chainLength = 1;
                        chain(1) = find(clusterSize > 0, 1);
                    end
                    while true
                        x = chain(chainLength);
                        if chainLength > 1
                            y = chain(chainLength - 1);
                            currentMin = Dm(x, y);
                        else
                            y = 0;
                            currentMin = Inf;
                        end
                        candidates = find(clusterSize > 0);
                        candidates(candidates == x) = [];
                        [minDist, pos] = min(Dm(x, candidates));
                        if minDist < currentMin
                            currentMin = minDist;
                            y = candidates(pos);
                        end
                        if chainLength > 1 && y == chain(chainLength - 1)
                            break
                        end
                        chainLength = chainLength + 1;
                        chain(chainLength) = y;
                    end
                    chainLength = chainLength - 2;
                    if x > y
                        [x, y] = deal(y, x);
                    end
                    nx = clusterSize(x);
                    ny = clusterSize(y);
                    Zl(step, :) = [x, y, currentMin];
                    clusterSize(x) = 0;
                    clusterSize(y) = nx + ny;
                    others = find(clusterSize > 0);
                    others(others == y) = [];
                    ni = clusterSize(others);
                    t = 1 ./ (nx + ny + ni);
                    newDist = sqrt((ni + nx) .* t .* Dm(others, x) .^ 2 + (ni + ny) .* t .* Dm(others, y) .^ 2 ...
                        - ni .* t .* currentMin ^ 2);
                    Dm(others, y) = newDist;
                    Dm(y, others) = newDist';
                end
                % stable sort by height and relabeling of the merged clusters
                [~, order] = sort(Zl(:, 3));
                Zl = Zl(order, :);
                parent = zeros(2 * n - 1, 1);
                nextLabel = n + 1;
                for step = 1:n - 1
                    xRoot = Zl(step, 1);
                    while parent(xRoot) ~= 0
                        xRoot = parent(xRoot);
                    end
                    yRoot = Zl(step, 2);
                    while parent(yRoot) ~= 0
                        yRoot = parent(yRoot);
                    end
                    Zl(step, 1:2) = sort([xRoot, yRoot]);
                    parent([xRoot, yRoot]) = nextLabel;
                    nextLabel = nextLabel + 1;
                end
            else
                warningState = warning('off', 'stats:linkage:NotEuclideanMatrix');
                Zl = linkage(D, linkageMethod);
                warning(warningState);
                Zl(:, 1:2) = sort(Zl(:, 1:2), 2);
            end
            % maximum distance within the subtree of each internal node
            nInternal = n - 1;
            MC = Zl(:, 3);
            for i = 1:nInternal
                for c = 1:2
                    child = Zl(i, c);
                    if child > n
                        MC(i) = max(MC(i), MC(child - n));
                    end
                end
            end
            % smallest cutoff leaving at most kMax clusters
            if kMax >= n
                cutoff = -Inf;
            else
                sortedMC = sort(MC);
                cutoff = sortedMC(end);
                for m = 1:nInternal
                    if n - sum(MC <= sortedMC(m)) <= kMax
                        cutoff = sortedMC(m);
                        break
                    end
                end
            end
            % pre-order traversal assigning cluster labels (scipy convention)
            clusters = zeros(n, 1);
            visited = false(2 * n - 1, 1);
            stack = zeros(n, 1);
            top = 1;
            stack(1) = 2 * n - 1;
            nClusters = 0;
            leader = 0;
            while top >= 1
                root = stack(top) - n;
                lc = Zl(root, 1);
                rc = Zl(root, 2);
                if leader == 0 && MC(root) <= cutoff
                    leader = root;
                    nClusters = nClusters + 1;
                end
                if lc > n && ~visited(lc)
                    visited(lc) = true;
                    top = top + 1;
                    stack(top) = lc;
                    continue
                end
                if rc > n && ~visited(rc)
                    visited(rc) = true;
                    top = top + 1;
                    stack(top) = rc;
                    continue
                end
                if lc <= n
                    if leader == 0
                        nClusters = nClusters + 1;
                    end
                    clusters(lc) = nClusters;
                end
                if rc <= n
                    if leader == 0
                        nClusters = nClusters + 1;
                    end
                    clusters(rc) = nClusters;
                end
                if leader == root
                    leader = 0;
                end
                top = top - 1;
            end
            k = kMax;
        end
        eco.linkage = Zl;
    case 'dbscan'
        labels = dbscan(squareform(D), epsilon, minPoints, 'Distance', 'precomputed');
        [uniqueLabels, ~, clusters] = unique(labels);
        k = numel(uniqueLabels);
        if printLevel > 0 && any(uniqueLabels == -1)
            fprintf('outliers: cluster %d\n', find(uniqueLabels == -1));
        end
end
eco.clusters = clusters(:);
eco.k = k;
if printLevel > 0
    fprintf('Done!\n');
end
end
