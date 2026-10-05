% The COBRAToolbox: testExtractBondSubgraphs.m
%
% Purpose:
%     - Regression test for extractBondSubgraphs (feature
%       20260921-154310-reacting-moiety-optimisation, spec FR-003, FR-007, FR-013).
%       The expected outputs in data/bondSubgraphReference.mat were captured from the
%       function BEFORE its body was rewritten for speed, so this test fails if the
%       rewritten function's outputs drift in any way.
%     - Covers: the stage-09 inputs (BIG, ATG) of the r0317/ACONTm/r0426 Recon3D
%       fixture; five inputs that break the lookup-array preconditions (duplicated and
%       non-integer AtomIndex, a component label out of range, named BIG nodes, a BIG
%       with no edges), which must give the same outputs or raise the same error as
%       before.
%     - Size-proportional peeling (feature
%       20260928-100409-extract-bond-subgraphs-local-peeling, spec FR-002, FR-011, FR-014):
%       data/bondSubgraphPeelingReference.mat holds pre-change outputs for a hand-built
%       main-path input (parallel edges, repeated BondIndex, bonds inside one component,
%       a component shared by pairs across passes, bonds leaving a pair), 20 randomised
%       inputs (two with a digraph ATG), an input whose Component labels differ from
%       conncomp(ATG), and an input whose atom index exceeds numnodes(BIG), which must
%       raise the same error. The subgraph/rmedge ordering rules the rewrite relies on
%       are asserted directly, so a MATLAB release that changes them fails here.
%
% Authors:
%     - COBRA Toolbox, feature 20260921-154310-reacting-moiety-optimisation
%     - COBRA Toolbox, feature 20260928-100409-extract-bond-subgraphs-local-peeling

% only base MATLAB graph functions are used: no solver or toolbox requirement
prepareTest();

% save the current path and initialize the test
currentDir = cd(fileparts(which(mfilename)));

reference = load(['data' filesep 'bondSubgraphReference.mat']);
ciInputs = reference.ciInputs;
ciExpected = reference.ciExpected;
fallbackCases = reference.fallbackCases;

% --- CI fixture: two-output form ---
[bondSubgraphs, BMG] = extractBondSubgraphs(ciInputs.BIG, ciInputs.ATG);
assert(areGraphCellsEqual(bondSubgraphs, ciExpected.bondSubgraphs), ...
    'extractBondSubgraphs bondSubgraphs differ from the pre-change reference (CI fixture).');
assert(areGraphCellsEqual(BMG, ciExpected.BMG), ...
    'extractBondSubgraphs BMG differ from the pre-change reference (CI fixture).');

% --- inputs outside the lookup-array preconditions: same outputs or same error ---
for k = 1:numel(fallbackCases)
    fallbackCase = fallbackCases(k);
    if strcmp(fallbackCase.outcome, 'ok')
        [caseSubgraphs, caseBMG] = extractBondSubgraphs(fallbackCase.BIG, fallbackCase.ATG);
        assert(areGraphCellsEqual(caseSubgraphs, fallbackCase.bondSubgraphs) && ...
            areGraphCellsEqual(caseBMG, fallbackCase.BMG), ...
            sprintf('extractBondSubgraphs output differs from the pre-change reference (%s).', ...
            fallbackCase.name));
    else
        errorRaised = false;
        try
            extractBondSubgraphs(fallbackCase.BIG, fallbackCase.ATG);
        catch ME
            errorRaised = true;
            assert(strcmp(ME.identifier, fallbackCase.errorIdentifier) && ...
                strcmp(ME.message, fallbackCase.errorMessage), ...
                sprintf(['extractBondSubgraphs raised a different error from the pre-change ' ...
                'function (%s): expected %s: %s; got %s: %s (%s:%d).'], fallbackCase.name, ...
                fallbackCase.errorIdentifier, fallbackCase.errorMessage, ME.identifier, ...
                ME.message, ME.stack(1).file, ME.stack(1).line));
        end
        assert(errorRaised, sprintf(['extractBondSubgraphs returned normally, but the ' ...
            'pre-change function raised %s (%s).'], fallbackCase.errorIdentifier, fallbackCase.name));
    end
end

% --- three-output form: same graphs, plus the per-graph EdgeIndex cache ---
[bondSubgraphs3, BMG3, bmgEdgeIndex] = extractBondSubgraphs(ciInputs.BIG, ciInputs.ATG);
assert(areGraphCellsEqual(bondSubgraphs3, bondSubgraphs) && areGraphCellsEqual(BMG3, BMG), ...
    'extractBondSubgraphs graphs differ between the two- and three-output forms (CI fixture).');
assert(isEdgeIndexCacheConsistent(bmgEdgeIndex, BMG3), ...
    'extractBondSubgraphs bmgEdgeIndex is not the EdgeIndex set of each BMG (CI fixture).');
for k = 1:numel(fallbackCases)
    fallbackCase = fallbackCases(k);
    if strcmp(fallbackCase.outcome, 'ok')
        [~, caseBMG, caseEdgeIndex] = extractBondSubgraphs(fallbackCase.BIG, fallbackCase.ATG);
        assert(isEdgeIndexCacheConsistent(caseEdgeIndex, caseBMG), ...
            sprintf('extractBondSubgraphs bmgEdgeIndex is not the EdgeIndex set of each BMG (%s).', ...
            fallbackCase.name));
    end
end

% --- size-proportional peeling: pre-change outputs on main-path inputs ---
peeling = load(['data' filesep 'bondSubgraphPeelingReference.mat']);
for k = 1:numel(peeling.peelingCases)
    peelingCase = peeling.peelingCases(k);
    if strcmp(peelingCase.outcome, 'ok')
        [caseSubgraphs, caseBMG] = extractBondSubgraphs(peelingCase.BIG, peelingCase.ATG);
        assert(areGraphCellsEqual(caseSubgraphs, peelingCase.bondSubgraphs) && ...
            areGraphCellsEqual(caseBMG, peelingCase.BMG), ...
            sprintf('extractBondSubgraphs output differs from the pre-change reference (%s).', ...
            peelingCase.name));
        [caseSubgraphs3, caseBMG3, caseEdgeIndex] = extractBondSubgraphs(peelingCase.BIG, ...
            peelingCase.ATG);
        assert(areGraphCellsEqual(caseSubgraphs3, peelingCase.bondSubgraphs) && ...
            areGraphCellsEqual(caseBMG3, peelingCase.BMG) && ...
            isequal(caseEdgeIndex, peelingCase.bmgEdgeIndex), ...
            sprintf('extractBondSubgraphs three-output form differs from the reference (%s).', ...
            peelingCase.name));
    else
        errorRaised = false;
        try
            extractBondSubgraphs(peelingCase.BIG, peelingCase.ATG);
        catch ME
            errorRaised = true;
            assert(strcmp(ME.identifier, peelingCase.errorIdentifier) && ...
                strcmp(ME.message, peelingCase.errorMessage), ...
                sprintf(['extractBondSubgraphs raised a different error from the pre-change ' ...
                'function (%s): expected %s: %s; got %s: %s (%s:%d).'], peelingCase.name, ...
                peelingCase.errorIdentifier, peelingCase.errorMessage, ME.identifier, ...
                ME.message, ME.stack(1).file, ME.stack(1).line));
        end
        assert(errorRaised, sprintf(['extractBondSubgraphs returned normally, but the ' ...
            'pre-change function raised %s (%s).'], peelingCase.errorIdentifier, peelingCase.name));
    end
end
if isfield(peeling, 'n332Inputs')
    [bondSubgraphs332, BMG332, edgeIndex332] = extractBondSubgraphs(peeling.n332Inputs.BIG, ...
        peeling.n332Inputs.ATG);
    assert(areGraphCellsEqual(bondSubgraphs332, peeling.n332Expected.bondSubgraphs) && ...
        areGraphCellsEqual(BMG332, peeling.n332Expected.BMG) && ...
        isequal(edgeIndex332, peeling.n332Expected.bmgEdgeIndex), ...
        'extractBondSubgraphs output differs from the pre-change reference (332-reaction subset).');
end

% --- the subgraph/rmedge ordering rules the rewrite relies on ---
checkSubgraphOrderingContract();

% change the directory
cd(currentDir)

function checkSubgraphOrderingContract()
% Assert the ordering rules 1-5 of contracts/extractBondSubgraphs.md (feature
% 20260928-100409-extract-bond-subgraphs-local-peeling) for a digraph and a graph
% multigraph with parallel edges and an unsorted node list.
rng(1);
nNodes = 12;
s = randi(nNodes, 60, 1);
t = randi(nNodes, 60, 1);
keep = s ~= t;
s = s(keep);
t = t(keep);
ids = [7 3 11 1 9]';
nodeTable = table((1:nNodes)', 'VariableNames', {'AtomIndex'});
edgeTable = table([s t], (1:numel(s))', 'VariableNames', {'EndNodes', 'EdgeIndex'});
graphs = {digraph(edgeTable, nodeTable), graph(edgeTable, nodeTable)};
for g = 1:numel(graphs)
    G = graphs{g};
    H = subgraph(G, ids);
    assert(isequal(H.Nodes, G.Nodes(ids, :)), ...
        sprintf('Ordering rule 1 (%s): subgraph node order does not follow the node list.', class(G)));
    [inS, ls] = ismember(G.Edges.EndNodes(:, 1), ids);
    [inT, lt] = ismember(G.Edges.EndNodes(:, 2), ids);
    kept = find(inS & inT);
    localEnds = [ls(kept) lt(kept)];
    if ~isa(G, 'digraph')
        localEnds = [min(localEnds, [], 2), max(localEnds, [], 2)];
    end
    [~, order] = sortrows([localEnds kept]);
    expectedEdges = G.Edges(kept(order), :);
    expectedEdges.EndNodes = localEnds(order, :);
    assert(numedges(H) == numel(kept), ...
        sprintf('Ordering rule 2 (%s): subgraph keeps a different edge set.', class(G)));
    assert(isequal(H.Edges, expectedEdges), ...
        sprintf('Ordering rule 3 (%s): subgraph edge rows are not in stable local (s, t) order.', ...
        class(G)));
    if isa(G, 'digraph')
        rebuilt = digraph(expectedEdges, G.Nodes(ids, :));
    else
        rebuilt = graph(expectedEdges, G.Nodes(ids, :));
    end
    assert(isequal(rebuilt.Nodes, H.Nodes) && isequal(rebuilt.Edges, H.Edges), ...
        sprintf('Ordering rule 4 (%s): the table constructor does not reproduce subgraph.', ...
        class(G)));
    removed = [2 5 9];
    R = rmedge(G, removed);
    assert(isequal(R.Edges, G.Edges(setdiff(1:numedges(G), removed), :)), ...
        sprintf('Ordering rule 5 (%s): rmedge does not keep the relative order of the other rows.', ...
        class(G)));
end
end

function isConsistent = isEdgeIndexCacheConsistent(bmgEdgeIndex, BMG)
% True when bmgEdgeIndex{m} holds the same EdgeIndex values as BMG{m}, in any order.
isConsistent = iscell(bmgEdgeIndex) && isequal(size(bmgEdgeIndex), size(BMG));
for m = 1:numel(BMG)
    if ~isConsistent
        return
    end
    isConsistent = isequal(sort(bmgEdgeIndex{m}(:)), sort(BMG{m}.Edges.EdgeIndex(:)));
end
end

function isSame = areGraphCellsEqual(A, B)
% True when two cell arrays of graph/digraph objects have the same size and each pair is
% graph-equal.
isSame = iscell(A) && iscell(B) && isequal(size(A), size(B));
for q = 1:numel(A)
    if ~isSame
        return
    end
    isSame = isGraphEqual(A{q}, B{q});
end
end

function isSame = isGraphEqual(A, B)
% True when two graph/digraph objects have the same class and equal Nodes and Edges tables
% (table equality: variable names, types, values and row order all have to match).
isSame = strcmp(class(A), class(B)) && isequal(A.Nodes, B.Nodes) && isequal(A.Edges, B.Edges);
end
