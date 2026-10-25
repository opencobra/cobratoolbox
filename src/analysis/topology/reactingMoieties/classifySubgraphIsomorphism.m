function [isomorphismClasses, firstSubgraphIndices, subsequentSubgraphIndices] = classifySubgraphIsomorphism(subgraphs, varargin)
% Groups a cell array of subgraphs into isomorphism equivalence classes
%
% USAGE:
%
%    [isomorphismClasses, firstSubgraphIndices, subsequentSubgraphIndices] = classifySubgraphIsomorphism(subgraphs, varargin)
%
% INPUTS:
%    subgraphs:                   cell array where each cell contains a MATLAB `graph`/`digraph` object to classify
%
% OPTIONAL INPUTS:
%    varargin:                    name-value pairs forwarded verbatim to `isisomorphic` for every candidate pair, for example `'NodeVariables', 'mets'` or `'EdgeVariables', 'mets'`; omit for plain structural isomorphism with no label matching
%
% OUTPUTS:
%    isomorphismClasses:          `1 x numClasses` cell array; each cell is an ascending-order row vector of subgraph indices belonging to that class, with the class leader (minimum index) first
%    firstSubgraphIndices:        `numClasses x 1` vector of the leader index of each class, in the same order as `isomorphismClasses`
%    subsequentSubgraphIndices:   `numSubgraphs x 1` vector mapping every subgraph index (leaders included) to its 1-based class number
%
% NOTE:
%    Before calling `isisomorphic` for a candidate pair, a cheap structural
%    invariant (node count, edge count, and, when `NodeVariables`/
%    `EdgeVariables` is present in `varargin`, the sorted multiset of that
%    node/edge label column) is compared for the two subgraphs; the pair is
%    treated as non-isomorphic, without calling `isisomorphic`, whenever the
%    invariants differ. This invariant is a necessary, not sufficient,
%    condition for isomorphism, so no truly isomorphic pair is ever missed
%    (the full `isisomorphic` check still runs for every pair whose
%    invariants match). A bucket with exactly one member never triggers an
%    `isisomorphic` call. This is the single shared classification helper
%    for `findAndExtractMolecularGraphs`, `identifyConservedReactingMoieties`,
%    and `identifyIsomorphicClasses`, replacing three independent all-pairs
%    loops (feature 021-prefilter-isomorphism-classification).
%
%    Since those three functions' public signatures are frozen (Constitution
%    Principle II), the total real `isisomorphic` call count cannot be
%    surfaced through a normal output argument without changing them. A
%    minimal, opt-in diagnostic side channel is provided instead, used only
%    by the feature's non-CI Tyrosine reproducibility check:
%    `classifySubgraphIsomorphism('resetCallCount')` resets a persistent
%    counter to zero, and `n = classifySubgraphIsomorphism('getCallCount')`
%    reads it. This branch never triggers during normal classification
%    calls, which always pass a cell array as `subgraphs`.
%
%    `isisomorphic` compares label-only copies of the subgraphs, built once per
%    subgraph: the same nodes and edges (directions, parallel edges and
%    self-loops) carrying only the `NodeVariables`/`EdgeVariables` compared.
%    Re-reading the label variables out of the full node and edge tables on
%    every comparison dominated the cost of the classification. The
%    invariants, the candidate pairs, the call count and all outputs are
%    unchanged (feature 20260930-102230-isomorphism-label-only-copies).
%
%    Unlabelled candidate pairs (no `varargin`) of the same graph class are
%    decided by an exact test written for this function, because `isisomorphic`
%    can fail to return on large, sparse, near-symmetric subgraphs (KI-001 in
%    KNOWN_ISSUES.md). Two subgraphs with identical edge lists are isomorphic by
%    the identity map. Otherwise both multiplicity adjacency matrices (parallel
%    edges counted, self-loops on the diagonal, direction kept) get an
%    isomorphism-invariant certificate, computed once per subgraph (node hashes
%    after four rounds of colour refinement); different certificates prove the
%    pair non-isomorphic. Otherwise both graphs are coloured jointly by colour
%    refinement from those hashes; different colour counts prove the pair
%    non-isomorphic. A greedy pass then individualises matching nodes of the
%    remaining colour classes, and an exact individualisation-refinement search
%    follows if it fails. A pair is reported isomorphic only for a verified
%    bijection, and non-isomorphic only after the complete search, so the
%    classes are those `isisomorphic` would give. If the search exceeds
%    1e5 search nodes, the pair is decided by `isisomorphic` instead, and a
%    persistent fallback counter is incremented:
%    `n = classifySubgraphIsomorphism('getFallbackCount')` reads it, and
%    `'resetCallCount'` resets it with the call count. Labelled comparisons
%    (`NodeVariables`/`EdgeVariables`) still use `isisomorphic`. The call count
%    still counts one comparison per candidate pair, whichever method decides it
%    (feature 20261012-093525-symmetric-iso-zero-bond).
%
% Author:
%    - COBRA Toolbox, feature 021-prefilter-isomorphism-classification
%    - COBRA Toolbox, feature 20260930-102230-isomorphism-label-only-copies
%    - COBRA Toolbox, feature 20261012-093525-symmetric-iso-zero-bond

    persistent isisomorphicCallCount fallbackCount
    if isempty(isisomorphicCallCount)
        isisomorphicCallCount = 0;
    end
    if isempty(fallbackCount)
        fallbackCount = 0;
    end
    % maximum number of individualisation-refinement search nodes per candidate pair before the
    % exact test hands the pair to isisomorphic
    searchNodeBudget = 1e5;

    if ischar(subgraphs) || (isstring(subgraphs) && isscalar(subgraphs))
        action = lower(char(subgraphs));
        switch action
            case 'resetcallcount'
                isisomorphicCallCount = 0;
                fallbackCount = 0;
                isomorphismClasses = {};
            case 'getcallcount'
                isomorphismClasses = isisomorphicCallCount;
            case 'getfallbackcount'
                isomorphismClasses = fallbackCount;
            otherwise
                error('classifySubgraphIsomorphism:UnknownAction', ...
                    'Unknown action "%s". Valid actions: resetCallCount, getCallCount, getFallbackCount.', subgraphs);
        end
        firstSubgraphIndices = [];
        subsequentSubgraphIndices = [];
        return;
    end

    numSubgraphs = numel(subgraphs);

    isomorphismClasses = {};
    firstSubgraphIndices = [];
    subsequentSubgraphIndices = zeros(numSubgraphs, 1);

    if numSubgraphs == 0
        return;
    end

    % identify which label column, if any, participates in the invariant
    % and in the isisomorphic comparison mode
    nodeVarName = '';
    edgeVarName = '';
    for k = 1:2:numel(varargin)
        if strcmpi(varargin{k}, 'NodeVariables')
            nodeVarName = varargin{k + 1};
        elseif strcmpi(varargin{k}, 'EdgeVariables')
            edgeVarName = varargin{k + 1};
        end
    end

    % precompute the structural invariant once per subgraph
    numNodesVec = zeros(numSubgraphs, 1);
    numEdgesVec = zeros(numSubgraphs, 1);
    nodeLabels = cell(numSubgraphs, 1);
    edgeLabels = cell(numSubgraphs, 1);
    labelOnlySubgraphs = cell(numSubgraphs, 1);
    % unlabelled pairs are decided by the exact refinement test on multiplicity adjacency
    % matrices, built on first use
    isUnlabelled = isempty(varargin);
    multiplicityAdjacencies = cell(numSubgraphs, 1);
    edgeEndNodes = cell(numSubgraphs, 1);
    certificates = cell(numSubgraphs, 1);
    nodeHashes = cell(numSubgraphs, 1);
    for i = 1:numSubgraphs
        numNodesVec(i) = numnodes(subgraphs{i, 1});
        numEdgesVec(i) = numedges(subgraphs{i, 1});
        if ~isempty(nodeVarName)
            nodeLabels{i} = sort(subgraphs{i, 1}.Nodes.(nodeVarName));
        end
        if ~isempty(edgeVarName)
            edgeLabels{i} = sort(subgraphs{i, 1}.Edges.(edgeVarName));
        end
        % copy carrying only the compared label variables, built once per subgraph
        [labelOnlySubgraphs{i}, edgeEndNodes{i}] = labelOnlyCopy(subgraphs{i, 1}, nodeVarName, edgeVarName);
    end

    % single forward-scan exclusion algorithm: for each not-yet-excluded
    % leader i, sweep the remaining not-yet-excluded j > i, skip the
    % isisomorphic call whenever the invariant rules it out, and fall back
    % to the exhaustive check otherwise
    excludedSubgraphs = false(numSubgraphs, 1);
    isomorphismClassNumber = 0;

    for i = 1:numSubgraphs
        if excludedSubgraphs(i)
            continue;
        end

        isomorphismClassNumber = isomorphismClassNumber + 1;
        currentClass = i;
        excludedSubgraphs(i) = true;
        subsequentSubgraphIndices(i) = isomorphismClassNumber;

        for j = (i + 1):numSubgraphs
            if excludedSubgraphs(j)
                continue;
            end

            if numNodesVec(i) ~= numNodesVec(j) || numEdgesVec(i) ~= numEdgesVec(j)
                continue;
            end
            if ~isempty(nodeVarName) && ~isequal(nodeLabels{i}, nodeLabels{j})
                continue;
            end
            if ~isempty(edgeVarName) && ~isequal(edgeLabels{i}, edgeLabels{j})
                continue;
            end

            isisomorphicCallCount = isisomorphicCallCount + 1;
            if isUnlabelled && strcmp(class(labelOnlySubgraphs{i}), class(labelOnlySubgraphs{j})) && ...
                    isequal(edgeEndNodes{i}, edgeEndNodes{j})
                % identical edge lists: the identity map is an isomorphism
                isIsomorphicPair = true;
            elseif isUnlabelled && strcmp(class(labelOnlySubgraphs{i}), class(labelOnlySubgraphs{j}))
                if isempty(multiplicityAdjacencies{i})
                    multiplicityAdjacencies{i} = multiplicityAdjacency(labelOnlySubgraphs{i});
                end
                if isempty(multiplicityAdjacencies{j})
                    multiplicityAdjacencies{j} = multiplicityAdjacency(labelOnlySubgraphs{j});
                end
                if isempty(certificates{i})
                    [certificates{i}, nodeHashes{i}] = refinementCertificate(multiplicityAdjacencies{i}, ...
                        isa(labelOnlySubgraphs{i}, 'digraph'));
                end
                if isempty(certificates{j})
                    [certificates{j}, nodeHashes{j}] = refinementCertificate(multiplicityAdjacencies{j}, ...
                        isa(labelOnlySubgraphs{j}, 'digraph'));
                end
                if isequal(certificates{i}, certificates{j})
                    [isIsomorphicPair, isDecided] = isIsomorphicByRefinement(multiplicityAdjacencies{i}, ...
                        multiplicityAdjacencies{j}, isa(labelOnlySubgraphs{i}, 'digraph'), searchNodeBudget, ...
                        nodeHashes{i}, nodeHashes{j});
                else
                    % different isomorphism-invariant certificates: not isomorphic
                    isIsomorphicPair = false;
                    isDecided = true;
                end
                if ~isDecided
                    fallbackCount = fallbackCount + 1;
                    isIsomorphicPair = isisomorphic(labelOnlySubgraphs{i}, labelOnlySubgraphs{j});
                end
            else
                isIsomorphicPair = isisomorphic(labelOnlySubgraphs{i}, labelOnlySubgraphs{j}, varargin{:});
            end
            if isIsomorphicPair
                currentClass = [currentClass, j]; %#ok<AGROW>
                excludedSubgraphs(j) = true;
                subsequentSubgraphIndices(j) = isomorphismClassNumber;
            end
        end

        isomorphismClasses{1, isomorphismClassNumber} = currentClass; %#ok<AGROW>
        firstSubgraphIndices(isomorphismClassNumber, 1) = i; %#ok<AGROW>
    end
end

function [labelOnlySubgraph, edgeEndNodes] = labelOnlyCopy(subgraph, nodeVarName, edgeVarName)
% Copy of a graph or digraph with the same nodes and edges (directions, parallel edges and
% self-loops, in the same edge row order) that carries only the label variables compared, and
% its edge end nodes as a two-column numeric array
[sourceNodes, targetNodes] = findedge(subgraph);
edgeEndNodes = [sourceNodes, targetNodes];
if isa(subgraph, 'digraph')
    labelOnlySubgraph = digraph(sourceNodes, targetNodes, [], numnodes(subgraph));
else
    labelOnlySubgraph = graph(sourceNodes, targetNodes, [], numnodes(subgraph));
end
if ~isempty(nodeVarName)
    labelOnlySubgraph.Nodes.(nodeVarName) = subgraph.Nodes.(nodeVarName);
end
if ~isempty(edgeVarName)
    labelOnlySubgraph.Edges.(edgeVarName) = subgraph.Edges.(edgeVarName);
end
end

function A = multiplicityAdjacency(subgraph)
% Sparse adjacency matrix counting edge multiplicities, with self-loops on the diagonal
% (undirected graphs: symmetric, each self-loop counted twice; digraphs: A(s, t) per edge s -> t)
[sourceNodes, targetNodes] = findedge(subgraph);
numNodes = numnodes(subgraph);
if isa(subgraph, 'digraph')
    A = sparse(sourceNodes, targetNodes, 1, numNodes, numNodes);
else
    A = sparse([sourceNodes; targetNodes], [targetNodes; sourceNodes], 1, numNodes, numNodes);
end
end

function [isIsomorphic, isDecided, numSearchNodes] = isIsomorphicByRefinement(A1, A2, isDirected, searchNodeBudget, initial1, initial2)
% Exact isomorphism test of two multiplicity adjacency matrices by joint colour refinement and
% individualisation-refinement: some permutation p with A2(p, p) == A1 exists exactly when a
% bijection induced by a discrete colouring is found and verified. The colouring is the same
% function of both graphs, so every isomorphism preserves it, and the depth-first search over
% individualisations is complete. When the budget of search nodes is exhausted first, isDecided
% is false and isIsomorphic must not be used. initial1 and initial2 are an isomorphism-invariant
% initial colouring of the nodes of each graph (the per-node hashes of refinementCertificate)
isIsomorphic = false;
isDecided = true;
numSearchNodes = 1;
numNodes = size(A1, 1);
if numNodes ~= size(A2, 1) || nnz(A1) ~= nnz(A2)
    return;
end
if numNodes == 0
    isIsomorphic = true;
    return;
end
graphs.A1 = A1;
graphs.A2 = A2;
graphs.isDirected = isDirected;
if isDirected
    graphs.At1 = A1';
    graphs.At2 = A2';
end
[~, ~, initialColours] = unique([initial1; initial2]);
colours1 = initialColours(1:numNodes);
colours2 = initialColours(numNodes + 1:end);
numCells = max(initialColours);
[colours1, colours2, numCells, isCompatible] = refineColours(graphs, colours1, colours2, numCells, (1:numCells)');
if ~isCompatible
    return;
end
if numCells == numNodes
    isIsomorphic = isMappedByColours(A1, A2, colours1, colours2);
    return;
end

% verified greedy pass: individualise the t-th node of every non-singleton colour class of
% graph 1 against the t-th node of the same class of graph 2, as many at once as stay
% compatible, and refine, until the colouring is discrete; a verified bijection proves
% isomorphism, otherwise the exact search below decides
greedyColours1 = colours1;
greedyColours2 = colours2;
greedyNumCells = numCells;
isGreedyCompatible = true;
while isGreedyCompatible && greedyNumCells < numNodes
    % pair the t-th node of each non-singleton colour class of graph 1 with the t-th node of
    % the same class of graph 2 (all but the last node of each class), ordered by t
    [sortedColours1, order1] = sort(greedyColours1);
    [~, order2] = sort(greedyColours2);
    isClassStart = [true; diff(sortedColours1) ~= 0];
    classStart = find(isClassStart);
    classSizes = diff([classStart; numNodes + 1]);
    % (repelem of a scalar returns a row, so both are reshaped to columns)
    startOfNode = reshape(repelem(classStart, classSizes), [], 1);
    sizeOfNode = reshape(repelem(classSizes, classSizes), [], 1);
    rankInClass = (1:numNodes)' - startOfNode + 1;
    isLastInClass = rankInClass == sizeOfNode;
    isCandidate = ~isLastInClass;
    candidateRanks = rankInClass(isCandidate);
    candidateColours = sortedColours1(isCandidate);
    candidateNodes1 = order1(isCandidate);
    candidateNodes2 = order2(isCandidate);
    [~, candidateOrder] = sortrows([candidateRanks, candidateColours]);
    candidateNodes1 = candidateNodes1(candidateOrder);
    candidateNodes2 = candidateNodes2(candidateOrder);
    candidateColours = candidateColours(candidateOrder);
    % individualise as many pairs at once as stay compatible, halving the batch on failure
    batchSize = numel(candidateNodes1);
    while true
        batch = (1:batchSize)';
        newColours = max(max(greedyColours1), max(greedyColours2)) + batch;
        trialColours1 = greedyColours1;
        trialColours2 = greedyColours2;
        trialColours1(candidateNodes1(batch)) = newColours;
        trialColours2(candidateNodes2(batch)) = newColours;
        [trialColours1, trialColours2, trialNumCells, isGreedyCompatible] = refineColours(graphs, ...
            trialColours1, trialColours2, greedyNumCells + batchSize, [unique(candidateColours(batch)); newColours]);
        if isGreedyCompatible || batchSize == 1
            break;
        end
        batchSize = ceil(batchSize / 2);
    end
    greedyColours1 = trialColours1;
    greedyColours2 = trialColours2;
    greedyNumCells = trialNumCells;
end
if isGreedyCompatible && isMappedByColours(A1, A2, greedyColours1, greedyColours2)
    isIsomorphic = true;
    return;
end

% depth-first individualisation-refinement search with an explicit stack: each level holds the
% refined colours, the node of graph 1 individualised and its candidate images in graph 2
stack = struct('colours1', {}, 'colours2', {}, 'numCells', {}, 'node1', {}, 'candidates2', {}, 'next', {});
stack(1) = individualisationLevel(colours1, colours2, numCells);
while ~isempty(stack)
    level = stack(end);
    if level.next > numel(level.candidates2)
        stack(end) = [];
        continue;
    end
    stack(end).next = level.next + 1;
    if numSearchNodes >= searchNodeBudget
        isDecided = false;
        return;
    end
    numSearchNodes = numSearchNodes + 1;
    colours1 = double(level.colours1);
    colours2 = double(level.colours2);
    targetColour = colours1(level.node1);
    newColour = max(max(colours1), max(colours2)) + 1;
    colours1(level.node1) = newColour;
    colours2(level.candidates2(level.next)) = newColour;
    [colours1, colours2, numCells, isCompatible] = refineColours(graphs, colours1, colours2, ...
        level.numCells + 1, [targetColour; newColour]);
    if ~isCompatible
        continue;
    end
    if numCells == numNodes
        if isMappedByColours(A1, A2, colours1, colours2)
            isIsomorphic = true;
            return;
        end
    else
        stack(end + 1) = individualisationLevel(colours1, colours2, numCells); %#ok<AGROW>
    end
end
end

function level = individualisationLevel(colours1, colours2, numCells)
% Search level that individualises the first node of graph 1 in the smallest non-singleton
% colour class against every node of that class in graph 2
[cellColours, ~, cellIndex] = unique(colours1);
classSizes = accumarray(cellIndex, 1);
classSizes(classSizes < 2) = Inf;
[~, smallest] = min(classSizes);
targetColour = cellColours(smallest);
level.colours1 = int32(colours1);
level.colours2 = int32(colours2);
level.numCells = numCells;
level.node1 = find(colours1 == targetColour, 1);
level.candidates2 = find(colours2 == targetColour);
level.next = 1;
end

function isIsomorphic = isMappedByColours(A1, A2, colours1, colours2)
% For a discrete colouring (every class one node in each graph), true when the bijection that
% maps each node of graph 1 to the node of graph 2 of the same colour is an isomorphism
numNodes = numel(colours1);
[~, order1] = sort(colours1);
[~, order2] = sort(colours2);
nodeMap = zeros(numNodes, 1);
nodeMap(order1) = order2;
isIsomorphic = isequal(A1, A2(nodeMap, nodeMap));
end

function [colours1, colours2, numCells, isCompatible] = refineColours(graphs, colours1, colours2, numCells, changedColours)
% Joint colour refinement (1-dimensional Weisfeiler-Leman) of two graphs, from a worklist: each
% node next to a recoloured node gets a signature made of its colour and the multiset of its
% neighbours' colours, counted with edge multiplicity (out- and in-neighbours separately for
% digraphs), and every colour class whose nodes' signatures differ is split, until no class
% splits. The multiset is represented by two integer-weighted sums, which are exact in double
% precision; a weight collision only makes the colouring coarser. New colours are numbered in
% sorted signature order over both graphs together, so the colouring is the same function of
% both. The graphs are incompatible (not isomorphic) as soon as a split gives the two graphs
% different numbers of nodes of some colour.
numNodes = numel(colours1);
isCompatible = true;
maxColour = max(max(colours1), max(colours2));
% per-node colour weights, updated only for recoloured nodes
[weightsA1, weightsB1] = colourWeights(colours1);
[weightsA2, weightsB2] = colourWeights(colours2);
% nodes whose colour changed: the nodes of the given colours, then the recoloured nodes
colourMask = false(maxColour, 1);
colourMask(changedColours) = true;
changedNodes1 = find(colourMask(colours1));
changedNodes2 = find(colourMask(colours2));
while ~isempty(changedNodes1)
    isAffected1 = any(graphs.A1(:, changedNodes1), 2);
    isAffected2 = any(graphs.A2(:, changedNodes2), 2);
    if graphs.isDirected
        isAffected1 = isAffected1 | any(graphs.At1(:, changedNodes1), 2);
        isAffected2 = isAffected2 | any(graphs.At2(:, changedNodes2), 2);
    end
    colourMask = false(maxColour, 1);
    colourMask(colours1(isAffected1)) = true;
    colourMask(colours2(isAffected2)) = true;
    if ~any(colourMask)
        break;
    end
    nodes1 = find(colourMask(colours1));
    nodes2 = find(colourMask(colours2));
    if graphs.isDirected
        % out-neighbour sums from A', in-neighbour sums from A
        signatures = [colours1(nodes1), graphs.At1(:, nodes1)' * weightsA1, graphs.At1(:, nodes1)' * weightsB1, ...
            graphs.A1(:, nodes1)' * weightsA1, graphs.A1(:, nodes1)' * weightsB1; ...
            colours2(nodes2), graphs.At2(:, nodes2)' * weightsA2, graphs.At2(:, nodes2)' * weightsB2, ...
            graphs.A2(:, nodes2)' * weightsA2, graphs.A2(:, nodes2)' * weightsB2];
    else
        signatures = [colours1(nodes1), graphs.A1(:, nodes1)' * weightsA1, graphs.A1(:, nodes1)' * weightsB1; ...
            colours2(nodes2), graphs.A2(:, nodes2)' * weightsA2, graphs.A2(:, nodes2)' * weightsB2];
    end
    [groupSignatures, ~, groupIndex] = unique(signatures, 'rows');
    numGroups = size(groupSignatures, 1);
    numNodes1 = numel(nodes1);
    if ~isequal(accumarray(groupIndex(1:numNodes1), 1, [numGroups, 1]), ...
            accumarray(groupIndex(numNodes1 + 1:end), 1, [numGroups, 1]))
        isCompatible = false;
        return;
    end
    % groups are sorted by old colour first; a colour splits when it has more than one group
    [~, ~, colourOfGroup] = unique(groupSignatures(:, 1));
    numGroupsOfColour = accumarray(colourOfGroup, 1);
    isSplitGroup = numGroupsOfColour(colourOfGroup) > 1;
    if ~any(isSplitGroup)
        break;
    end
    newColourOfGroup = zeros(numGroups, 1);
    newColourOfGroup(isSplitGroup) = maxColour + (1:nnz(isSplitGroup))';
    maxColour = maxColour + nnz(isSplitGroup);
    numCells = numCells + nnz(isSplitGroup) - nnz(numGroupsOfColour > 1);
    isRecoloured = isSplitGroup(groupIndex);
    newColours = newColourOfGroup(groupIndex);
    recoloured1 = isRecoloured(1:numNodes1);
    recoloured2 = isRecoloured(numNodes1 + 1:end);
    recolouredNodes1 = nodes1(recoloured1);
    recolouredNodes2 = nodes2(recoloured2);
    colours1(recolouredNodes1) = newColours([recoloured1; false(numel(nodes2), 1)]);
    colours2(recolouredNodes2) = newColours([false(numNodes1, 1); recoloured2]);
    [weightsA1(recolouredNodes1), weightsB1(recolouredNodes1)] = colourWeights(colours1(recolouredNodes1));
    [weightsA2(recolouredNodes2), weightsB2(recolouredNodes2)] = colourWeights(colours2(recolouredNodes2));
    changedNodes1 = recolouredNodes1;
    changedNodes2 = recolouredNodes2;
    if numCells == numNodes
        break;
    end
end
end

function [weightsA, weightsB] = colourWeights(colours)
% Two deterministic integer weights per colour, below 2^20, so that weighted neighbour sums are
% exact integers in double precision for any realistic degree and multiplicity
weightsA = mod(colours * 40503, 1048573) + 1;
weightsB = mod(colours * 69069 + 12345, 999983) + 1;
end

function [certificate, hashes] = refinementCertificate(A, isDirected)
% Isomorphism-invariant certificate of one graph: node hashes after four rounds of colour
% refinement, where each round hashes a node's hash with the weighted sum of its neighbours'
% hashes (out- and in-neighbours separately for digraphs), and their sorted list. The hashes are
% a fixed function of the graph, independent of node order, so isomorphic graphs have equal
% certificates and the per-node hashes are a valid initial colouring for the joint refinement.
% All arithmetic stays below 2^53, so it is exact in double precision
numRounds = 4;
hashes = full(diag(A)) + 1;
for r = 1:numRounds
    weights = mod(hashes * 40503, 1048573) + 1;
    if isDirected
        hashes = mod(hashes * 7919 + mod(A * weights, 999983) * 31 + mod(A' * weights, 999979), 1048573);
    else
        hashes = mod(hashes * 7919 + mod(A * weights, 999983) * 31, 1048573);
    end
end
certificate = sort(hashes);
end
