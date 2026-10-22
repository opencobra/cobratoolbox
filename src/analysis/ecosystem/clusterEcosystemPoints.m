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
%    linkageMethod:    (string) 'ward', 'single', 'complete', 'average' or
%                      'weighted' (see `computeEcosystemLinkage`)
%                      (Default = 'ward')
%    distance:         (string) 'jaccard', 'hamming', 'euclidean' or
%                      'cityblock' (see `computeEcosystemDistances`)
%                      (Default = 'jaccard')
%    epsilon:          (double) neighborhood radius for 'dbscan'
%                      (Default = 0.05)
%    minPoints:        (double) minimum number of points in the neighborhood
%                      of a core point, including the point itself, for
%                      'dbscan' (Default = 5)
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
%    is zero. Distances, linkage and DBSCAN are computed with
%    `computeEcosystemDistances`, `computeEcosystemLinkage` and
%    `computeEcosystemDBSCAN`, which reproduce SciPy and scikit-learn (no
%    MATLAB toolbox is required). Cluster labels of the hierarchical method
%    are assigned by a pre-order traversal of the dendrogram, as done by
%    `scipy.cluster.hierarchy.fcluster` with criterion 'maxclust', so that
%    labels follow the same convention as the Python implementation
%    (`Ecosystem.clusterPoints`). For 'dbscan', outliers are grouped in the
%    first cluster.
%
% .. Author: - Sebastián N. Mendoza, 13/10/2026, MATLAB implementation based on the Python code of N.E. Jiménez et al.

parser = inputParser();
parser.addRequired('eco', @(x) isstruct(x) && isfield(x, 'qualVectors'));
parser.addParameter('method', 'hierarchical', @(x) any(strcmpi(x, {'hierarchical', 'dbscan'})));
parser.addParameter('k', 20, @(x) isnumeric(x) && isscalar(x) && x >= 1);
parser.addParameter('linkageMethod', 'ward', @(x) any(strcmpi(x, {'ward', 'single', 'complete', 'average', 'weighted'})));
parser.addParameter('distance', 'jaccard', @(x) any(strcmpi(x, {'jaccard', 'hamming', 'euclidean', 'cityblock'})));
parser.addParameter('epsilon', 0.05, @(x) isnumeric(x) && isscalar(x) && x > 0);
parser.addParameter('minPoints', 5, @(x) isnumeric(x) && isscalar(x) && x >= 1);
parser.addParameter('printLevel', 1, @(x) isnumeric(x) || islogical(x));
parser.parse(eco, varargin{:});
eco = parser.Results.eco;
method = lower(parser.Results.method);
kMax = parser.Results.k;
linkageMethod = parser.Results.linkageMethod;
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
D = computeEcosystemDistances(Z, distanceMetric);

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
            % linkage with the algorithms and labeling of scipy.cluster.hierarchy.linkage
            Zl = computeEcosystemLinkage(D, linkageMethod);
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
        labels = computeEcosystemDBSCAN(D, epsilon, minPoints);
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
