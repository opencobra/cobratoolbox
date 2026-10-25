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
%     - Pre-change reference (feature 20260930-102230-isomorphism-label-only-copies, spec
%       FR-002, FR-004, FR-005, FR-007): data/classifySubgraphIsomorphismReference.mat holds
%       the classifications and isisomorphic call counts of the helper captured before it began
%       comparing label-only copies, for 30 lists of graph and digraph multigraphs (parallel
%       edges, self-loops, extra node and edge variables, some with many) in five modes
%       (plain, NodeVariables, EdgeVariables, both, and a string-valued option), and the errors
%       it raised for a cell-valued option and a missing variable. Every output, call count
%       and error must be unchanged.
%     - Exact unlabelled classification (feature 20261012-093525-symmetric-iso-zero-bond, spec
%       FR-001, FR-002, SC-001): data/nearSymmetricBondComponentPair.mat holds the label-only
%       copies of two near-identical 318-node bond components on which isisomorphic did not
%       return; they must be one class, decided without the isisomorphic fallback. A random
%       relabelling must join that class and a copy with one edge moved must not; 200 random
%       small graphs and digraphs (simple, multigraphs with self-loops, cycles) and the empty
%       and single-node graphs must be classified as isisomorphic classifies them; and the
%       'getFallbackCount' action must be reset by 'resetCallCount'.
%
% Authors:
%     - COBRA Toolbox, feature 021-prefilter-isomorphism-classification.
%     - COBRA Toolbox, feature 20260930-102230-isomorphism-label-only-copies (reference cases).
%     - COBRA Toolbox, feature 20261012-093525-symmetric-iso-zero-bond (exact unlabelled cases).

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

% Pre-change reference: identical classifications, call counts and errors (feature
% 20260930-102230-isomorphism-label-only-copies)
reference = load([fileparts(which('testClassifySubgraphIsomorphism')) filesep 'data' filesep ...
    'classifySubgraphIsomorphismReference.mat']);
for k = 1:numel(reference.referenceCases)
    referenceCase = reference.referenceCases(k);
    subgraphList = reference.referenceLists{referenceCase.listIndex};
    classifySubgraphIsomorphism('resetCallCount');
    [classes, firsts, subs] = classifySubgraphIsomorphism(subgraphList, referenceCase.options{:});
    callCount = classifySubgraphIsomorphism('getCallCount');
    caseName = sprintf('reference case %d (list %d, %d option arguments)', k, ...
        referenceCase.listIndex, numel(referenceCase.options));
    assert(isequal(classes, referenceCase.isomorphismClasses), ...
        sprintf('isomorphismClasses differ from the pre-change helper (%s).', caseName));
    assert(isequal(firsts, referenceCase.firstSubgraphIndices), ...
        sprintf('firstSubgraphIndices differ from the pre-change helper (%s).', caseName));
    assert(isequal(subs, referenceCase.subsequentSubgraphIndices), ...
        sprintf('subsequentSubgraphIndices differ from the pre-change helper (%s).', caseName));
    assert(callCount == referenceCase.callCount, ...
        sprintf('isisomorphic call count %d differs from the pre-change %d (%s).', callCount, ...
        referenceCase.callCount, caseName));
end
for k = 1:numel(reference.errorCases)
    errorCase = reference.errorCases(k);
    errorRaised = false;
    try
        classifySubgraphIsomorphism(errorCase.subgraphs, errorCase.options{:});
    catch ME
        errorRaised = true;
        assert(strcmp(ME.identifier, errorCase.errorIdentifier) && ...
            strcmp(ME.message, errorCase.errorMessage), ...
            sprintf(['classifySubgraphIsomorphism raised a different error from the pre-change ' ...
            'helper (error case %d): expected %s: %s; got %s: %s (%s:%d).'], k, ...
            errorCase.errorIdentifier, errorCase.errorMessage, ME.identifier, ME.message, ...
            ME.stack(1).file, ME.stack(1).line));
    end
    assert(errorRaised, sprintf(['classifySubgraphIsomorphism returned normally, but the ' ...
        'pre-change helper raised %s (error case %d).'], errorCase.errorIdentifier, k));
end

% Exact unlabelled classification of near-symmetric components (feature
% 20261012-093525-symmetric-iso-zero-bond, spec FR-001, FR-002, SC-001)
pair = load([fileparts(which('testClassifySubgraphIsomorphism')) filesep 'data' filesep ...
    'nearSymmetricBondComponentPair.mat']);
previousRng = rng;
restoreRng = onCleanup(@() rng(previousRng));

% (a) the stored pair of bond components on which isisomorphic did not return within 60 min is
% one class, decided by the exact test without the isisomorphic fallback. The 30 s bound is a
% generous CI guard (the 5 s criterion, SC-001, is measured outside CI)
classifySubgraphIsomorphism('resetCallCount');
assert(classifySubgraphIsomorphism('getFallbackCount') == 0, ...
    'resetCallCount must reset the fallback count.');
tStart = tic;
[classes, firsts, subs] = classifySubgraphIsomorphism({pair.g1; pair.g2});
pairSeconds = toc(tStart);
assert(isequal(classes, {[1, 2]}) && isequal(firsts, 1) && isequal(subs, [1; 1]), ...
    'The stored near-symmetric pair must be one isomorphism class.');
assert(pairSeconds < 30, sprintf('The stored pair took %.1f s (bound 30 s).', pairSeconds));
assert(classifySubgraphIsomorphism('getCallCount') == 1, 'One candidate pair, one comparison.');
assert(classifySubgraphIsomorphism('getFallbackCount') == 0, ...
    'The stored pair must be decided without the isisomorphic fallback.');

% (b) a random relabelling of the nodes is the same class; (c) moving one edge endpoint to a
% node of the same degree changes the degree multiset, so that graph is a class of its own
rng(20261012);
numPairNodes = numnodes(pair.g1);
permutedGraph = reordernodes(pair.g1, randperm(numPairNodes));
[sourceNodes, targetNodes] = findedge(pair.g1);
pairDegrees = degree(pair.g1);
movedFrom = targetNodes(1);
candidateTargets = find(pairDegrees == pairDegrees(movedFrom));
candidateTargets = setdiff(candidateTargets, [sourceNodes(1); movedFrom; neighbors(pair.g1, sourceNodes(1))]);
assert(~isempty(candidateTargets), 'No node to move the edge to.');
targetNodes(1) = candidateTargets(1);
movedGraph = graph(sourceNodes, targetNodes, [], numPairNodes);
assert(~isequal(sort(degree(movedGraph)), sort(pairDegrees)), 'The moved edge must change the degree multiset.');
[classes, ~, subs] = classifySubgraphIsomorphism({pair.g1; pair.g2; permutedGraph; movedGraph});
assert(isequal(classes, {[1, 2, 3], 4}) && isequal(subs, [1; 1; 1; 2]), ...
    'Permuted and edge-moved copies of the stored pair are misclassified.');

% (d) randomized equivalence with isisomorphic on small graphs, where isisomorphic is fast:
% simple graphs, multigraphs with self-loops, and highly regular cycles, undirected and
% directed; half of the second graphs are relabellings, half have one edge endpoint moved
rng(1012);
numRandomCases = 200;
for k = 1:numRandomCases
    numNodes = randi([0, 12]);
    isDirected = mod(k, 2) == 0;
    graphKind = mod(floor((k - 1) / 2), 3); % 0 simple, 1 multigraph with self-loops, 2 cycle
    numEdges = randi([0, 2 * numNodes]);
    sourceNodes = randi(max(numNodes, 1), numEdges, 1);
    targetNodes = randi(max(numNodes, 1), numEdges, 1);
    if numNodes == 0
        sourceNodes = zeros(0, 1);
        targetNodes = zeros(0, 1);
    end
    if graphKind == 0
        isKept = sourceNodes ~= targetNodes;
        sourceNodes = sourceNodes(isKept);
        targetNodes = targetNodes(isKept);
    elseif graphKind == 2 && numNodes >= 3
        sourceNodes = (1:numNodes)';
        targetNodes = [2:numNodes, 1]';
    end
    firstGraph = buildTestGraph(sourceNodes, targetNodes, numNodes, isDirected);
    if graphKind == 0
        firstGraph = simplify(firstGraph);
    end
    [sourceNodes, targetNodes] = findedge(firstGraph);
    if rand < 0.5 && ~isempty(sourceNodes)
        movedEdge = randi(numel(sourceNodes));
        targetNodes(movedEdge) = randi(numNodes);
    end
    nodePermutation = randperm(numNodes)';
    secondGraph = buildTestGraph(nodePermutation(sourceNodes), nodePermutation(targetNodes), ...
        numNodes, isDirected);
    isIsomorphicPair = isisomorphic(firstGraph, secondGraph);
    classes = classifySubgraphIsomorphism({firstGraph; secondGraph});
    assert(isequal(classes, {[1, 2]}) == isIsomorphicPair, sprintf(['Random case %d (%d nodes, ' ...
        'directed %d, kind %d): classification differs from isisomorphic.'], k, numNodes, ...
        isDirected, graphKind));
end

% (e) empty and single-node graphs, with and without a self-loop, as isisomorphic classifies them
smallGraphs = {graph(), graph([], [], [], 1), graph(1, 1), graph([1, 1], [1, 1]); ...
    digraph(), digraph([], [], [], 1), digraph(1, 1), digraph([1, 1], [1, 1])};
for row = 1:2
    for first = 1:4
        for second = 1:4
            classes = classifySubgraphIsomorphism({smallGraphs{row, first}; smallGraphs{row, second}});
            assert(isequal(classes, {[1, 2]}) == ...
                isisomorphic(smallGraphs{row, first}, smallGraphs{row, second}), ...
                sprintf('Small graphs %d and %d (row %d) are misclassified.', first, second, row));
        end
    end
end

% (f) the fallback count is a non-negative integer and is reset with the call count
fallbackCount = classifySubgraphIsomorphism('getFallbackCount');
assert(isscalar(fallbackCount) && fallbackCount >= 0 && fallbackCount == round(fallbackCount));
classifySubgraphIsomorphism('resetCallCount');
assert(classifySubgraphIsomorphism('getFallbackCount') == 0 && ...
    classifySubgraphIsomorphism('getCallCount') == 0);

function testGraph = buildTestGraph(sourceNodes, targetNodes, numNodes, isDirected)
% graph or digraph with the given edges and node count
if isDirected
    testGraph = digraph(sourceNodes, targetNodes, [], numNodes);
else
    testGraph = graph(sourceNodes, targetNodes, [], numNodes);
end
end
