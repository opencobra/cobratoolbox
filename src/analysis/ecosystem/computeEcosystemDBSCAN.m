function labels = computeEcosystemDBSCAN(D, epsilon, minPoints)
% Density-based clustering (DBSCAN) from a matrix of pairwise distances,
% without requiring the Statistics and Machine Learning Toolbox. The
% algorithm is that of `sklearn.cluster.DBSCAN` with a precomputed metric
% (used by the Python implementation of Jiménez et al., 2023): a point is
% a core point when at least `minPoints` points (including itself) are at
% a distance lower than or equal to `epsilon`, and clusters are expanded by
% a depth-first search from the core points, in the order of the points,
% so that the labels are identical to those of scikit-learn.
%
% USAGE:
%
%    labels = computeEcosystemDBSCAN(D, epsilon, minPoints)
%
% INPUT:
%    D:                (double) n x n symmetric matrix of distances
%
% OPTIONAL INPUTS:
%    epsilon:          (double) neighborhood radius (Default = 0.05)
%    minPoints:        (double) minimum number of points in the neighborhood
%                      of a core point, including the point itself
%                      (Default = 5)
%
% OUTPUT:
%    labels:           (double) n x 1 vector with the cluster of each point
%                      (0, 1, 2, ... in the order in which clusters are
%                      found) and -1 for the points that are not reachable
%                      from any core point (noise)
%
% EXAMPLE:
%
%    labels = computeEcosystemDBSCAN(computeEcosystemDistances(eco.qualVectors), 0.05, 5);
%
% .. Author: - Sebastián N. Mendoza, 21/10/2026, MATLAB implementation of the DBSCAN algorithm of scikit-learn

if nargin < 1 || ~isnumeric(D) || ~ismatrix(D) || size(D, 1) ~= size(D, 2)
    error('D must be a square matrix of distances.');
end
if nargin < 2 || isempty(epsilon)
    epsilon = 0.05;
end
if nargin < 3 || isempty(minPoints)
    minPoints = 5;
end
if ~isnumeric(epsilon) || ~isscalar(epsilon) || epsilon <= 0
    error('epsilon must be a positive scalar.');
end
if ~isnumeric(minPoints) || ~isscalar(minPoints) || minPoints < 1
    error('minPoints must be a scalar >= 1.');
end
n = size(D, 1);
isNeighbor = D <= epsilon;
isCore = sum(isNeighbor, 2) >= minPoints;
labels = -ones(n, 1);
clusterLabel = 0;
for seed = 1:n
    if labels(seed) ~= -1 || ~isCore(seed)
        continue
    end
    % depth-first search from the core point seed
    stack = zeros(0, 1);
    i = seed;
    while true
        if labels(i) == -1
            labels(i) = clusterLabel;
            if isCore(i)
                neighbors = find(isNeighbor(i, :));
                stack = [stack; neighbors(labels(neighbors) == -1)']; %#ok<AGROW>
            end
        end
        if isempty(stack)
            break
        end
        i = stack(end);
        stack(end) = [];
    end
    clusterLabel = clusterLabel + 1;
end
end
