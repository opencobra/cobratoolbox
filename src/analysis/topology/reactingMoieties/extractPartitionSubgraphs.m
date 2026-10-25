function parts = extractPartitionSubgraphs(G, nodeLabel, keepEdge)
% Extract the subgraph of every part of a labelling of the nodes of a graph
%
% USAGE:
%
%    parts = extractPartitionSubgraphs(G, nodeLabel)
%    parts = extractPartitionSubgraphs(G, nodeLabel, keepEdge)
%
% INPUTS:
%    G:            graph or digraph
%    nodeLabel:    numnodes(G) x 1 numeric vector, the part of every node
%
% OPTIONAL INPUT:
%    keepEdge:     numedges(G) x 1 logical vector, the edges that may appear in a part
%                  (default: all edges)
%
% OUTPUT:
%    parts:        cell array, one graph or digraph (the class of `G`) per distinct value of
%                  `nodeLabel`, in ascending order of that value, as `unique(nodeLabel)`
%                  gives it; `{}` when `G` has no nodes
%
% NOTE:
%    `parts{k}` is identical, in its `Nodes` and `Edges` tables (variables, row order and
%    values), to `subgraph(G, find(nodeLabel == v))` for the k-th distinct label `v`, restricted
%    to the rows with `keepEdge` true. Because the node positions of a part are ascending, the
%    renumbering from `G` to the part is monotone, so the rows of `G.Edges` that fall inside a
%    part, taken in their `G.Edges` order, are already in the order `subgraph` gives them.
%    The node and edge tables of `G` are therefore read once, the nodes and edges are grouped
%    by part once, and every part is built from its own rows only, instead of calling
%    `subgraph` on the whole graph once per part.
%
% .. Author: - COBRA Toolbox, feature 20260929-111453-conserved-moiety-table-hotspots

if ~exist('keepEdge', 'var') || isempty(keepEdge)
    keepEdge = true(numedges(G), 1);
end

nNodes = numnodes(G);
if nNodes == 0
    parts = {};
    return
end

% Node and edge tables of G, read once, and numeric end nodes of every edge
nodeTable = G.Nodes;
edgeTable = G.Edges;
[sourceNodes, targetNodes] = findedge(G);
endNodes = [sourceNodes(:), targetNodes(:)];
isDirected = isa(G, 'digraph');

% Group the nodes by part, with ascending positions within each part
[labels, ~, nodeGroup] = unique(nodeLabel(:));
nParts = numel(labels);
nodesByPart = accumarray(nodeGroup, (1:nNodes)', [nParts, 1], @(v) {sort(v)});

% Group the eligible edges with both end nodes in the same part, with ascending rows
edgesByPart = cell(nParts, 1);
if ~isempty(endNodes)
    isInPart = keepEdge(:) & nodeGroup(endNodes(:, 1)) == nodeGroup(endNodes(:, 2));
    if any(isInPart)
        edgesByPart = accumarray(nodeGroup(endNodes(isInPart, 1)), find(isInPart), ...
            [nParts, 1], @(v) {sort(v)});
    end
end

% Position of each node within its part (0 outside the current part)
localPos = zeros(nNodes, 1);

parts = cell(nParts, 1);
for k = 1:nParts
    nodes = nodesByPart{k};
    rows = [zeros(0, 1); edgesByPart{k}];
    localPos(nodes) = 1:numel(nodes);
    localEnds = reshape(localPos(endNodes(rows, :)), [], 2);
    localPos(nodes) = 0;
    partEdges = edgeTable(rows, :);
    if isDirected
        partEdges.EndNodes = localEnds;
        parts{k} = digraph(partEdges, nodeTable(nodes, :));
    else
        partEdges.EndNodes = [min(localEnds, [], 2), max(localEnds, [], 2)];
        parts{k} = graph(partEdges, nodeTable(nodes, :));
    end
end
end
