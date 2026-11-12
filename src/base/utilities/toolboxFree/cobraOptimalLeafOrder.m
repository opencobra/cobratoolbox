function order = cobraOptimalLeafOrder(Z, D)
% Optimal leaf order of a hierarchical cluster tree (the ordering that
% minimizes the sum of distances between adjacent leaves), without the
% Statistics and Machine Learning Toolbox
%
% USAGE:
%
%    order = cobraOptimalLeafOrder(Z, D)
%
% INPUTS:
%    Z:        (n - 1) x 3 linkage matrix in the format of MATLAB's linkage (rows merge
%              clusters Z(k, 1) and Z(k, 2); 1..n are the leaves, n + k the cluster of row k),
%              for example from computeEcosystemLinkage
%    D:        distances between the n leaves: n x n matrix or a pdist row vector
%
% OUTPUT:
%    order:    1 x n permutation of the leaves, consistent with the tree (every cluster is
%              contiguous), minimizing the sum of the distances of adjacent leaves
%
% EXAMPLE:
%
%    X = [0; 10; 1; 11];
%    D = abs(X - X');
%    Z = computeEcosystemLinkage(D, 'average');
%    order = cobraOptimalLeafOrder(Z, D)   % [1 3 2 4] or its reverse
%
% NOTE:
%    Plain-MATLAB replacement for optimalleaforder(Z, D) with its defaults (Criteria
%    'adjacent', Transformation 'linear': maximizing adjacent similarities is minimizing
%    adjacent distances), as clustergram uses it (Statistics and Machine Learning Toolbox);
%    semantics: specs/20261111-152503-toolbox-free-remaining/mathworks-semantics.md, G4
%    section A4. Algorithm: the dynamic programme of Bar-Joseph, Gifford and Jaakkola (2001,
%    Bioinformatics 17 Suppl 1:S22-S29): for every cluster and every pair of its leaves from
%    different subclusters, the best cost of an ordering that starts and ends at them, built
%    from the subclusters by two min-plus products, then reconstructed from the stored
%    choices. O(n^3) time, O(n^2) memory. The optimum is not unique (at least its reverse);
%    ties are broken by the first index.
%
% .. Authors:
%     - Generated for feature 20261111-152503-toolbox-free-remaining, 2026-11-11.

n = size(Z, 1) + 1;
if isvector(D) && n > 1
    full = zeros(n);
    full(tril(true(n), -1)) = D;
    D = full + full';
end
if ~isequal(size(D), [n n])
    error('COBRA:cobraOptimalLeafOrder:invalidInput', 'cobraOptimalLeafOrder: D must hold the distances of the %d leaves of Z.', n);
end
if n == 1
    order = 1;
    return
end

nNodes = 2 * n - 1;
leaves = cell(nNodes, 1);
cost = cell(nNodes, 1);       % cost{v}(p, q): best ordering of v from leaves{v}(p) to leaves{v}(q)
bestK = cell(nNodes, 1);      % choices for the reconstruction (left subcluster end)
bestL = cell(nNodes, 1);      % (right subcluster start)
children = zeros(nNodes, 2);
for leaf = 1:n
    leaves{leaf} = leaf;
    cost{leaf} = 0;
end
for row = 1:n - 1
    v = n + row;
    a = Z(row, 1);
    b = Z(row, 2);
    children(v, :) = [a b];
    La = leaves{a};
    Lb = leaves{b};
    % T(k, j) = min over l of D(k, l) + cost_b(l, j), for k in La, j in Lb
    [T, argL] = minPlus(D(La, Lb), cost{b});
    % cost_v(i, j) = min over k of cost_a(i, k) + T(k, j), for i in La, j in Lb
    [crossCost, argK] = minPlus(cost{a}, T);
    leaves{v} = [La, Lb];
    na = numel(La);
    nb = numel(Lb);
    costV = Inf(na + nb);
    costV(1:na, na + 1:end) = crossCost;
    costV(na + 1:end, 1:na) = crossCost';
    cost{v} = costV;
    bestK{v} = argK;
    bestL{v} = argL;
    cost{a} = [];
    cost{b} = [];
end

% best start and end leaves of the root, then reconstruction with an explicit stack
root = nNodes;
[~, best] = min(cost{root}(:));
[p, q] = ind2sub(size(cost{root}), best);
order = zeros(1, n);
filled = 0;
stack = [root, leaves{root}(p), leaves{root}(q)];
while ~isempty(stack)
    task = stack(end, :);
    stack(end, :) = [];
    [v, first, last] = deal(task(1), task(2), task(3));
    if v <= n
        filled = filled + 1;
        order(filled) = v;
        continue
    end
    a = children(v, 1);
    b = children(v, 2);
    La = leaves{a};
    Lb = leaves{b};
    if any(La == first)
        % from first (in a) to last (in b): a from first to k, then b from l to last
        i = find(La == first);
        j = find(Lb == last);
        k = bestK{v}(i, j);
        l = bestL{v}(k, j);
        stack = [stack; b, Lb(l), last; a, first, La(k)]; %#ok<AGROW>
    else
        % from first (in b) to last (in a): the reverse of the ordering from last to first
        i = find(La == last);
        j = find(Lb == first);
        k = bestK{v}(i, j);
        l = bestL{v}(k, j);
        stack = [stack; a, La(k), last; b, first, Lb(l)]; %#ok<AGROW>
    end
end
end

function [C, arg] = minPlus(A, B)
% Min-plus product: C(i, j) = min over k of A(i, k) + B(k, j), with the first minimizing k
C = Inf(size(A, 1), size(B, 2));
arg = ones(size(A, 1), size(B, 2));
for k = 1:size(A, 2)
    candidate = A(:, k) + B(k, :);
    isBetter = candidate < C;
    C(isBetter) = candidate(isBetter);
    arg(isBetter) = k;
end
end
