% The COBRAToolbox: testClassifySubgraphIsomorphism.m
%
% Purpose:
%     - Pin the behavior of the shared isomorphism-classification helper
%       `classifySubgraphIsomorphism`, introduced by feature
%       021-prefilter-isomorphism-classification to replace three
%       independent all-pairs `isisomorphic` loops in
%       `findAndExtractMolecularGraphs`, `identifyConservedReactingMoieties`,
%       and `identifyIsomorphicClasses`.
%     - Covers the trivial N=0/N=1 cases, the singleton-invariant-bucket
%       case (a subgraph whose node/edge-count invariant matches no other
%       subgraph's, so no `isisomorphic` call may be made for it), and
%       correct grouping (no false negatives) across the three comparison
%       modes the three call sites use: plain (no label matching),
%       `NodeVariables`, and `EdgeVariables`.
%
% Authors:
%     - COBRA Toolbox, feature 021-prefilter-isomorphism-classification.

% N == 0: all outputs empty, no error, no division by zero or indexing
% out of range.
[classes, firsts, subs] = classifySubgraphIsomorphism({});
assert(isempty(classes));
assert(isempty(firsts));
assert(isempty(subs));

% N == 1: a single trivial class containing just the one subgraph; no
% isisomorphic call is possible or needed to establish this.
gSingle = graph([1 2], [2 3]);
[classes, firsts, subs] = classifySubgraphIsomorphism({gSingle});
assert(isequal(classes, {1}));
assert(isequal(firsts, 1));
assert(isequal(subs, 1));

% Singleton invariant bucket among several subgraphs (plain comparison
% mode, matching findAndExtractMolecularGraphs.m's mode-less isisomorphic
% call): gSmall's node/edge counts match no one else's invariant, so it
% must end up alone in its own class, while the two structurally
% isomorphic 4-node/3-edge subgraphs must be grouped together.
gSmall = graph([1 2], [2 3]);          % 3 nodes, 2 edges (unique invariant)
gBigA = graph([1 2 3], [2 3 4]);       % 4 nodes, 3 edges
gBigB = graph([1 2 3], [2 3 4]);       % 4 nodes, 3 edges, isomorphic to gBigA
[classes, ~, subs] = classifySubgraphIsomorphism({gSmall; gBigA; gBigB});
assert(numel(classes) == 2);
assert(subs(1) ~= subs(2));
assert(subs(2) == subs(3));
assert(isequal(sort(classes{subs(2)}), [2, 3]));

% No false negatives (FR-003) under 'NodeVariables' mode, matching
% identifyConservedReactingMoieties.m:618's `isisomorphic(...,
% 'NodeVariables', 'mets')` call: two subgraphs with identical node/edge
% counts and identical Nodes.mets labels must be classified as isomorphic.
nodeTable = table({'m1'; 'm2'}, 'VariableNames', {'mets'});
edgeTableNV = table([1 2], 'VariableNames', {'EndNodes'});
hNodeA = digraph(edgeTableNV, nodeTable);
hNodeB = digraph(edgeTableNV, nodeTable);
[classes, ~, ~] = classifySubgraphIsomorphism({hNodeA; hNodeB}, 'NodeVariables', 'mets');
assert(numel(classes) == 1);
assert(numel(classes{1}) == 2);

% No false negatives (FR-003) under 'EdgeVariables' mode, matching
% identifyIsomorphicClasses.m:39's `isisomorphic(..., 'EdgeVariables',
% 'mets')` call: two subgraphs with identical node/edge counts and
% identical Edges.mets labels must be classified as isomorphic.
edgeTableEV = table([1 2], {'m1'}, 'VariableNames', {'EndNodes', 'mets'});
nodeTableEV = table((1:2)', 'VariableNames', {'Id'});
hEdgeA = digraph(edgeTableEV, nodeTableEV);
hEdgeB = digraph(edgeTableEV, nodeTableEV);
[classes, ~, ~] = classifySubgraphIsomorphism({hEdgeA; hEdgeB}, 'EdgeVariables', 'mets');
assert(numel(classes) == 1);
assert(numel(classes{1}) == 2);

% The invariant must never prune a pair that the comparison mode would
% have matched: same node/edge counts but different 'mets' labels under
% 'NodeVariables' mode must NOT be classified as isomorphic.
nodeTableDiff = table({'m1'; 'm3'}, 'VariableNames', {'mets'});
hNodeC = digraph(edgeTableNV, nodeTableDiff);
[classes, ~, subs] = classifySubgraphIsomorphism({hNodeA; hNodeC}, 'NodeVariables', 'mets');
assert(numel(classes) == 2);
assert(subs(1) ~= subs(2));
