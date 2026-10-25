% The COBRAToolbox: testExtractPartitionSubgraphs.m
%
% Purpose:
%     - Test extractPartitionSubgraphs (feature 20260929-111453-conserved-moiety-table-hotspots,
%       spec FR-004, FR-005, FR-008; contracts/extractPartitionSubgraphs.md): every part must be
%       identical, in graph class and in its Nodes and Edges tables (variables, row order and
%       values), to the subgraph of that part's nodes, restricted to the eligible edges.
%     - Covers graph and digraph inputs, parallel edges, extra node and edge variables (numeric
%       and cell), single-node parts, parts without edges, edge masks, a graph with no nodes, a
%       graph with no edges and a graph with named nodes.
%
% Authors:
%     - COBRA Toolbox, feature 20260929-111453-conserved-moiety-table-hotspots

% only base MATLAB graph functions are used: no solver or toolbox requirement
prepareTest();

rng(1);
for caseIndex = 1:50
    nNodes = randi([10 40]);
    nLabels = randi([1 8]);
    nodeLabel = randi(nLabels, nNodes, 1) * 10;
    nodeLabel(randperm(nNodes, min(nNodes, 2))) = 1000 + caseIndex * [1; 2];   % single-node parts
    nEdges = randi([0 3 * nNodes]);
    s = randi(nNodes, nEdges, 1);
    t = randi(nNodes, nEdges, 1);
    keep = s ~= t;
    s = s(keep);
    t = t(keep);
    if ~isempty(s)
        repeat = randi(numel(s), randi(3), 1);   % parallel edges
        s = [s; s(repeat)]; %#ok<AGROW>
        t = [t; t(repeat)]; %#ok<AGROW>
    end
    nEdges = numel(s);
    edgeTable = table([s t], rand(nEdges, 1), arrayfun(@num2str, (1:nEdges)', 'UniformOutput', false), ...
        'VariableNames', {'EndNodes', 'Weight', 'Label'});
    nodeTable = table((1:nNodes)' + 100, cellstr(char(64 + randi(26, nNodes, 1))), ...
        'VariableNames', {'AtomIndex', 'Element'});
    if mod(caseIndex, 2) == 0
        G = digraph(edgeTable, nodeTable);
    else
        G = graph(edgeTable, nodeTable);
    end
    if mod(caseIndex, 3) == 0
        keepEdge = rand(numedges(G), 1) > 0.4;
    else
        keepEdge = [];
    end
    parts = extractPartitionSubgraphs(G, nodeLabel, keepEdge);
    assertPartsMatchSubgraph(G, nodeLabel, keepEdge, parts, sprintf('random case %d', caseIndex));
end

% a graph with no nodes
parts = extractPartitionSubgraphs(graph(), zeros(0, 1));
assert(iscell(parts) && isempty(parts), 'A graph with no nodes must give no parts.');

% a graph with nodes but no edges
G = graph(table(zeros(0, 2), zeros(0, 1), 'VariableNames', {'EndNodes', 'Weight'}), ...
    table((1:5)', 'VariableNames', {'AtomIndex'}));
nodeLabel = [2; 1; 2; 3; 1];
parts = extractPartitionSubgraphs(G, nodeLabel);
assertPartsMatchSubgraph(G, nodeLabel, [], parts, 'graph without edges');

% a graph with named nodes
G = graph({'a', 'b', 'c', 'd', 'a'}, {'b', 'c', 'd', 'a', 'c'});
nodeLabel = [1; 1; 2; 2];
parts = extractPartitionSubgraphs(G, nodeLabel);
assertPartsMatchSubgraph(G, nodeLabel, [], parts, 'named graph');

function assertPartsMatchSubgraph(G, nodeLabel, keepEdge, parts, caseName)
% Assert that every part equals the subgraph of its nodes, restricted to the eligible edges
if isempty(keepEdge)
    keepEdge = true(numedges(G), 1);
end
labels = unique(nodeLabel(:));
assert(numel(parts) == numel(labels), ...
    sprintf('%s: expected %d parts, got %d.', caseName, numel(labels), numel(parts)));
% carry the original row of every edge through subgraph, to apply keepEdge afterwards
tracked = G;
tracked.Edges.OriginalRowForTest = (1:numedges(G))';
for k = 1:numel(labels)
    H = subgraph(tracked, find(nodeLabel == labels(k)));
    keptRows = H.Edges.OriginalRowForTest;
    referenceEdges = H.Edges(keepEdge(keptRows), :);
    referenceEdges.OriginalRowForTest = [];
    if isa(G, 'digraph')
        reference = digraph(referenceEdges, H.Nodes);
    else
        reference = graph(referenceEdges, H.Nodes);
    end
    assert(strcmp(class(parts{k}), class(reference)), ...
        sprintf('%s, part %d: class %s, expected %s.', caseName, k, class(parts{k}), class(reference)));
    assert(isequal(parts{k}.Nodes, reference.Nodes), ...
        sprintf('%s, part %d: Nodes differ from the subgraph of the part.', caseName, k));
    assert(isequal(parts{k}.Edges, reference.Edges), ...
        sprintf('%s, part %d: Edges differ from the subgraph of the part.', caseName, k));
end
end
