function [bondSubgraphs, BMG, bmgEdgeIndex, stats] = extractBondSubgraphsLocal(BIG, ATG, useLocalATG)
% Research prototype (feature 20260928-100409): main path only, size-proportional peeling.
if nargin < 3
    useLocalATG = true;
end
stats = struct('passes', 0);
atoms2component = conncomp(ATG)';
nComps = max(atoms2component);
if numedges(BIG) == 0
    bondSubgraphs = {}; BMG = {}; bmgEdgeIndex = {}; return
end
atomIndexATG = full(ATG.Nodes.AtomIndex);
componentATG = full(ATG.Nodes.Component);
BIGEdges = BIG.Edges;
BIGNodes = BIG.Nodes;
endNodes = BIGEdges.EndNodes;
isPositiveWholeNumeric = @(v) isnumeric(v) && all(v(:) >= 1) && all(v(:) == fix(v(:)));
lookupOK = isPositiveWholeNumeric(atomIndexATG) && isPositiveWholeNumeric(componentATG) ...
    && isPositiveWholeNumeric(endNodes) ...
    && numel(unique(atomIndexATG)) == numel(atomIndexATG) ...
    && all(componentATG <= nComps) && all(endNodes(:) <= max(atomIndexATG));
if lookupOK
    compOfAtom = zeros(max(atomIndexATG), 1);
    compOfAtom(atomIndexATG) = componentATG;
    lookupOK = all(compOfAtom(endNodes(:)) > 0);
end
if ~lookupOK
    [bondSubgraphs, BMG, bmgEdgeIndex] = extractBondSubgraphsBaseline(BIG, ATG);
    return
end
nodesByComp = accumarray(atoms2component(:), (1:numel(atoms2component))', [nComps, 1], ...
    @(v) {sort(v(:))});

% --- one-time indices ---
nEdges = size(endNodes, 1);
edgeComp = [compOfAtom(endNodes(:, 1)), compOfAtom(endNodes(:, 2))];
cLo = min(edgeComp, [], 2); cHi = max(edgeComp, [], 2);
[~, ~, bucketOfEdge] = unique([cLo cHi], 'rows');
edgesByBucket = accumarray(bucketOfEdge, (1:nEdges)', [], @(v) {sort(v)});
[pairKeys, firstRow] = unique([cLo cHi], 'rows');
bucketId = sparse(pairKeys(:, 1), pairKeys(:, 2), bucketOfEdge(firstRow), nComps, nComps);
remaining = true(nEdges, 1);
localPos = zeros(max(max(atomIndexATG), size(BIGNodes, 1)), 1);
nBIGNodes = numnodes(BIG);

if useLocalATG
    ATGNodes = ATG.Nodes;
    ATGEdges = ATG.Edges;
    isDirectedATG = isa(ATG, 'digraph');
    atgEnds = ATGEdges.EndNodes;
    if isempty(atgEnds)
        atgBucketId = sparse(nComps, nComps); atgEdgesByBucket = {};
    else
        aC = [atoms2component(atgEnds(:, 1)), atoms2component(atgEnds(:, 2))];
        aLoHi = [min(aC, [], 2), max(aC, [], 2)];
        [aKeys, aFirst, aBucket] = unique(aLoHi, 'rows');
        atgEdgesByBucket = accumarray(aBucket, (1:size(atgEnds, 1))', [], @(v) {sort(v)});
        atgBucketId = sparse(aKeys(:, 1), aKeys(:, 2), aBucket(aFirst), nComps, nComps);
    end
    localPosATG = zeros(numel(atoms2component), 1);
end

bondSubgraphs = {}; BMG = {}; bmgEdgeIndex = {};
subgraphIndex = 1;
first = 1;
while first <= nEdges
    stats.passes = stats.passes + 1;
    component1 = compOfAtom(endNodes(first, 1));
    component2 = compOfAtom(endNodes(first, 2));
    if component1 == component2
        nodesInBothComponents = nodesByComp{component1};
        comps = component1;
    else
        nodesInBothComponents = [nodesByComp{component1}; nodesByComp{component2}];
        comps = [component1; component2];
    end
    if useLocalATG
        localPosATG(nodesInBothComponents) = 1:numel(nodesInBothComponents);
        cLoA = min(component1, component2); cHiA = max(component1, component2);
        ab = full([atgBucketId(cLoA, cLoA); atgBucketId(cHiA, cHiA); atgBucketId(cLoA, cHiA)]);
        ab = unique(ab(ab > 0));
        atgRows = vertcat(atgEdgesByBucket{ab});
        if isempty(atgRows), atgRows = zeros(0, 1); end
        ends = localPosATG(atgEnds(atgRows, :));
        ends = reshape(ends, [], 2);
        if ~isDirectedATG
            ends = [min(ends, [], 2), max(ends, [], 2)];
        end
        [~, order] = sortrows([ends atgRows]);
        cEdges = ATGEdges(atgRows(order), :);
        cEdges.EndNodes = ends(order, :);
        localPosATG(nodesInBothComponents) = 0;
        if isDirectedATG
            combinedSubgraph = digraph(cEdges, ATGNodes(nodesInBothComponents, :));
        else
            combinedSubgraph = graph(cEdges, ATGNodes(nodesInBothComponents, :));
        end
    else
        combinedSubgraph = subgraph(ATG, nodesInBothComponents);
    end

    pairAtoms = atomIndexATG(nodesInBothComponents);
    if any(pairAtoms > nBIGNodes)
        subgraph(BIG, pairAtoms); % raise the error subgraph(BIGCopy, ...) raises
    end
    cLoP = min(component1, component2); cHiP = max(component1, component2);
    buckets = full([bucketId(cLoP, cLoP); bucketId(cHiP, cHiP); bucketId(cLoP, cHiP)]);
    buckets = unique(buckets(buckets > 0));
    rows = vertcat(edgesByBucket{buckets});
    if isempty(rows), rows = zeros(0, 1); end
    rows = rows(remaining(rows));
    localPos(pairAtoms) = 1:numel(pairAtoms);
    ends = reshape(localPos(endNodes(rows, :)), [], 2);
    localPos(pairAtoms) = 0;
    [~, order] = sortrows([ends rows]);
    rows = rows(order);
    GEdges = BIGEdges(rows, :);
    GEdges.EndNodes = ends(order, :);
    GNodes = BIGNodes(pairAtoms, :);

    combinedSubgraphs = {}; BMgraph = {}; BMedgeIdx = {};
    while size(GEdges, 1) > 0
        [~, firstOccurrenceIndices, groupIndices] = unique(GEdges.BondIndex, 'first');
        occurrences = accumarray(groupIndices, 1);
        maxOccurrences = max(occurrences);
        for layer = 1:maxOccurrences
            layerEdgeIdx = GEdges.EdgeIndex(firstOccurrenceIndices);
            layerEndNodes = GEdges.EndNodes(firstOccurrenceIndices, :);
            EdgeTable = GEdges(firstOccurrenceIndices, :);
            BMgraph{layer, 1} = digraph(EdgeTable, GNodes); %#ok<AGROW>
            BMedgeIdx{layer, 1} = layerEdgeIdx; %#ok<AGROW>
            combinedSubgraphs{layer, 1} = addedge(combinedSubgraph, ...
                layerEndNodes(:, 1), layerEndNodes(:, 2)); %#ok<AGROW>
            GEdges(firstOccurrenceIndices, :) = [];
            if size(GEdges, 1) > 0
                [~, firstOccurrenceIndices, ~] = unique(GEdges.BondIndex, 'first');
            else
                break;
            end
        end
    end
    for m = 1:length(combinedSubgraphs)
        bondSubgraphs{subgraphIndex, 1} = combinedSubgraphs{m}; %#ok<AGROW>
        BMG{subgraphIndex, 1} = BMgraph{m}; %#ok<AGROW>
        bmgEdgeIndex{subgraphIndex, 1} = BMedgeIdx{m}; %#ok<AGROW>
        subgraphIndex = subgraphIndex + 1;
    end
    remaining(rows) = false;
    while first <= nEdges && ~remaining(first)
        first = first + 1;
    end
end
end
