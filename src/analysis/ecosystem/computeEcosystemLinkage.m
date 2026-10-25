function L = computeEcosystemLinkage(D, linkageMethod)
% Agglomerative hierarchical clustering from a matrix of pairwise distances,
% without requiring the Statistics and Machine Learning Toolbox. The
% algorithms, tie-breaking rules and labeling of the merged clusters are
% those of `scipy.cluster.hierarchy.linkage` (used by the Python
% implementation of Jiménez et al., 2023), so that the linkage matrices
% are identical: minimum spanning tree for 'single' and nearest-neighbor
% chain with Lance-Williams updates for 'complete', 'average', 'weighted'
% and 'ward'.
%
% USAGE:
%
%    L = computeEcosystemLinkage(D, linkageMethod)
%
% INPUT:
%    D:                (double) n x n symmetric matrix of distances (n >= 2)
%
% OPTIONAL INPUT:
%    linkageMethod:    (string) 'ward', 'single', 'complete', 'average' or
%                      'weighted' (Default = 'ward')
%
% OUTPUT:
%    L:                (double) (n - 1) x 3 linkage matrix in the format of
%                      MATLAB's `linkage`: row k merges the clusters
%                      `L(k, 1) < L(k, 2)` (indices 1 to n are the
%                      observations and n + k is the cluster created at
%                      row k) at the distance `L(k, 3)`. Rows are sorted by
%                      distance
%
% EXAMPLE:
%
%    L = computeEcosystemLinkage(computeEcosystemDistances(eco.qualVectors), 'ward');
%
% NOTE:
%
%    The Ward method assumes Euclidean distances; as in SciPy and in the
%    Python implementation, it is also applied to other distances (e.g.
%    Jaccard).
%
% .. Author: - Sebastián N. Mendoza, 21/10/2026, MATLAB implementation of the nn_chain and mst_single_linkage algorithms of SciPy

if nargin < 1 || ~isnumeric(D) || ~ismatrix(D) || size(D, 1) ~= size(D, 2)
    error('D must be a square matrix of distances.');
end
if nargin < 2 || isempty(linkageMethod)
    linkageMethod = 'ward';
end
if ~ischar(linkageMethod) || ~any(strcmpi(linkageMethod, {'ward', 'single', 'complete', 'average', 'weighted'}))
    error('linkageMethod must be ''ward'', ''single'', ''complete'', ''average'' or ''weighted''.');
end
linkageMethod = lower(linkageMethod);
n = size(D, 1);
if n < 2
    error('At least two observations are required.');
end
D = double(D);
L = zeros(n - 1, 3);

if strcmp(linkageMethod, 'single')
    % minimum spanning tree (Prim's algorithm, as mst_single_linkage)
    merged = false(n, 1);
    minDist = Inf(n, 1);
    y = 1;
    for step = 1:n - 1
        merged(y) = true;
        currentMin = Inf;
        x = 0;
        for i = 1:n
            if merged(i)
                continue
            end
            if minDist(i) > D(y, i)
                minDist(i) = D(y, i);
            end
            if minDist(i) < currentMin
                x = i;
                currentMin = minDist(i);
            end
        end
        L(step, :) = [y, x, currentMin];
        y = x;
    end
else
    % nearest-neighbor chain with Lance-Williams updates (as nn_chain)
    clusterSize = ones(n, 1);
    chain = zeros(n, 1);
    chainLength = 0;
    for step = 1:n - 1
        if chainLength == 0
            chainLength = 1;
            chain(1) = find(clusterSize > 0, 1);
        end
        while true
            x = chain(chainLength);
            if chainLength > 1
                y = chain(chainLength - 1);
                currentMin = D(x, y);
            else
                y = 0;
                currentMin = Inf;
            end
            % the first closest active cluster replaces y only if it is strictly closer
            candidates = find(clusterSize > 0);
            candidates(candidates == x) = [];
            [minDist, pos] = min(D(x, candidates));
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
        % merge the mutual nearest neighbors x and y into y
        chainLength = chainLength - 2;
        if x > y
            [x, y] = deal(y, x);
        end
        nx = clusterSize(x);
        ny = clusterSize(y);
        L(step, :) = [x, y, currentMin];
        clusterSize(x) = 0;
        clusterSize(y) = nx + ny;
        others = find(clusterSize > 0);
        others(others == y) = [];
        dx = D(others, x);
        dy = D(others, y);
        switch linkageMethod
            case 'complete'
                newDist = max(dx, dy);
            case 'average'
                newDist = (nx * dx + ny * dy) / (nx + ny);
            case 'weighted'
                newDist = 0.5 * (dx + dy);
            case 'ward'
                ni = clusterSize(others);
                t = 1 ./ (nx + ny + ni);
                newDist = sqrt((ni + nx) .* t .* dx .^ 2 + (ni + ny) .* t .* dy .^ 2 - ni .* t .* currentMin ^ 2);
        end
        D(others, y) = newDist;
        D(y, others) = newDist';
    end
end

% stable sort by distance and labeling of the merged clusters (union-find)
[~, order] = sort(L(:, 3));
L = L(order, :);
parent = zeros(2 * n - 1, 1);
for step = 1:n - 1
    xRoot = L(step, 1);
    while parent(xRoot) ~= 0
        xRoot = parent(xRoot);
    end
    yRoot = L(step, 2);
    while parent(yRoot) ~= 0
        yRoot = parent(yRoot);
    end
    L(step, 1:2) = sort([xRoot, yRoot]);
    parent([xRoot, yRoot]) = n + step;
end
end
