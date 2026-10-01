% Research probe for feature 20260929-111453 on the real n1960 ATG (captured at the
% extractBondSubgraphs call): identity and unprofiled cost of each block, old vs new.
ext = '/home/jackmcgoldrick/repos/reconXmoieties/experiments/moietySizing/results/outputs/extractBondSubgraphsPeeling';
S = load(fullfile(ext, 'n1960-inputs.mat'), 'ATG', 'BIG');
ATG0 = S.ATG; BIG = S.BIG; clear S
fprintf('ATG: %d nodes (%d vars), %d edges (%d vars), class %s\n', numnodes(ATG0), ...
    width(ATG0.Nodes), numedges(ATG0), width(ATG0.Edges), class(ATG0));
fprintf('edge var classes: '); disp(varfun(@class, ATG0.Edges, 'OutputFormat', 'cell'))

%% Target 1: reorientation (mask = edges reoriented relative to dATM)
mask = ATG0.Edges.orientationATG2dATM == -1;
fprintf('reoriented edges: %d of %d\n', nnz(mask), numel(mask));
ATGa = ATG0; nTrans = numedges(ATGa); orientationATG2dATM = ATGa.Edges.orientationATG2dATM;
tic
for i=1:nTrans
    if orientationATG2dATM(i)==-1
        ATGa.Edges.HeadAtomIndex(i) = ATGa.Edges.EndNodes(i,2);
        ATGa.Edges.TailAtomIndex(i) = ATGa.Edges.EndNodes(i,1);
        HeadAtom = ATGa.Edges.TailAtom{i};
        TailAtom = ATGa.Edges.HeadAtom{i};
        ATGa.Edges.HeadAtom{i} = HeadAtom;
        ATGa.Edges.TailAtom{i} = TailAtom;
        ATGa.Edges.Trans{i} = [HeadAtom '#' TailAtom];
    end
end
tOld1 = toc;
ATGb = ATG0;
tic
edges = ATGb.Edges;
endNodes = edges.EndNodes;
headAtom = edges.TailAtom(mask);
tailAtom = edges.HeadAtom(mask);
headAtomIndex = edges.HeadAtomIndex; headAtomIndex(mask) = endNodes(mask, 2);
tailAtomIndex = edges.TailAtomIndex; tailAtomIndex(mask) = endNodes(mask, 1);
headAtoms = edges.HeadAtom; headAtoms(mask) = headAtom;
tailAtoms = edges.TailAtom; tailAtoms(mask) = tailAtom;
trans = edges.Trans; trans(mask) = cellfun(@(h, t) [h '#' t], headAtom, tailAtom, 'UniformOutput', false);
ATGb.Edges.HeadAtomIndex = headAtomIndex;
ATGb.Edges.TailAtomIndex = tailAtomIndex;
ATGb.Edges.HeadAtom = headAtoms;
ATGb.Edges.TailAtom = tailAtoms;
ATGb.Edges.Trans = trans;
tNew1 = toc;
fprintf('T1 reorientation: old %.1f s, new %.2f s, identical %d\n', tOld1, tNew1, ...
    isequaln(ATGa.Edges, ATGb.Edges) && isequaln(ATGa.Nodes, ATGb.Nodes));
clear ATGa ATGb

%% Target 2: per-component subgraphs (sample, then extrapolate)
atoms2component = conncomp(ATG0)';
nComps = max(atoms2component);
rng(1); sample = sort(randperm(nComps, 2000))';
tic
old = cell(numel(sample), 1);
for k = 1:numel(sample)
    old{k} = subgraph(ATG0, atoms2component == sample(k));
end
tOld2 = toc / numel(sample) * nComps;
tic
nodesByComp = accumarray(atoms2component, (1:numel(atoms2component))', [nComps 1], @(v) {sort(v)});
ends = ATG0.Edges.EndNodes;
edgeComp = atoms2component(ends(:, 1));
edgesByComp = accumarray(edgeComp, (1:numel(edgeComp))', [nComps 1], @(v) {sort(v)});
atgNodes = ATG0.Nodes; atgEdges = ATG0.Edges;
localPos = zeros(numel(atoms2component), 1);
tSetup = toc;
tic
new = cell(numel(sample), 1);
for k = 1:numel(sample)
    c = sample(k);
    nodes = nodesByComp{c};
    rows = edgesByComp{c};
    if isempty(rows), rows = zeros(0, 1); end
    localPos(nodes) = 1:numel(nodes);
    e = atgEdges(rows, :);
    localEnds = reshape(localPos(ends(rows, :)), [], 2);
    e.EndNodes = [min(localEnds, [], 2), max(localEnds, [], 2)];
    localPos(nodes) = 0;
    new{k} = graph(e, atgNodes(nodes, :));
end
tNew2 = tSetup + toc / numel(sample) * nComps;
same2 = all(cellfun(@(a, b) isequaln(a.Nodes, b.Nodes) && isequaln(a.Edges, b.Edges), old, new));
fprintf('T2 per-component (one set, %d comps, extrapolated from 2000): old %.1f s, new %.1f s (setup %.2f s), identical %d\n', ...
    nComps, tOld2, tNew2, tSetup, same2);
edgesSorted = all(cellfun(@(r) issorted(r), edgesByComp));
fprintf('   edge rows already in local order without sorting: identical (checked above, no sortrows used)\n');

%% Target 3: per-moiety graphs on an ABG-like graph (MoietyIndex = component, bonds inside)
atomMoiety = atoms2component;
bEnds = BIG.Edges.EndNodes;
moietyBond = zeros(size(bEnds, 1), 1);
inside = atomMoiety(bEnds(:, 1)) == atomMoiety(bEnds(:, 2));
moietyBond(inside) = atomMoiety(bEnds(inside, 1));
nodeTable = ATG0.Nodes; nodeTable.MoietyIndex = atomMoiety;
edgeTable = addvars(BIG.Edges, moietyBond, 'NewVariableNames', 'MoietyBondIndex');
ABG = graph(edgeTable, nodeTable);
uniqueMoietyIndices = unique(ABG.Nodes.MoietyIndex);
sampleM = uniqueMoietyIndices(sort(randperm(numel(uniqueMoietyIndices), 2000)));
tic
oldM = cell(numel(sampleM), 1);
for k = 1:numel(sampleM)
    m = sampleM(k);
    nodeIndices = find(ABG.Nodes.MoietyIndex == m);
    sg = subgraph(ABG, nodeIndices);
    ei = find(sg.Edges.MoietyBondIndex == m);
    oldM{k} = graph(sg.Edges(ei, :), sg.Nodes);
end
tOld3 = toc / numel(sampleM) * numel(uniqueMoietyIndices);
tic
abgNodes = ABG.Nodes; abgEdges = ABG.Edges; abgEnds = abgEdges.EndNodes;
nodeMoiety = abgNodes.MoietyIndex;
[~, ~, nodeGroup] = unique(nodeMoiety);
nodesByMoiety = accumarray(nodeGroup, (1:numel(nodeMoiety))', [], @(v) {sort(v)});
keepEdge = abgEdges.MoietyBondIndex == nodeMoiety(abgEnds(:, 1)) & ...
    abgEdges.MoietyBondIndex == nodeMoiety(abgEnds(:, 2));
edgeGroup = zeros(size(abgEnds, 1), 1);
edgeGroup(keepEdge) = nodeGroup(abgEnds(keepEdge, 1));
edgesByMoiety = accumarray(edgeGroup(keepEdge), find(keepEdge), [numel(nodesByMoiety) 1], @(v) {sort(v)});
localPosM = zeros(numel(nodeMoiety), 1);
tSetup3 = toc;
[~, sampleGroup] = ismember(sampleM, unique(nodeMoiety));
tic
newM = cell(numel(sampleM), 1);
for k = 1:numel(sampleM)
    g = sampleGroup(k);
    nodes = nodesByMoiety{g};
    rows = edgesByMoiety{g};
    if isempty(rows), rows = zeros(0, 1); end
    localPosM(nodes) = 1:numel(nodes);
    e = abgEdges(rows, :);
    localEnds = reshape(localPosM(abgEnds(rows, :)), [], 2);
    e.EndNodes = [min(localEnds, [], 2), max(localEnds, [], 2)];
    localPosM(nodes) = 0;
    newM{k} = graph(e, abgNodes(nodes, :));
end
tNew3 = tSetup3 + toc / numel(sampleM) * numel(uniqueMoietyIndices);
same3 = all(cellfun(@(a, b) isequaln(a.Nodes, b.Nodes) && isequaln(a.Edges, b.Edges), oldM, newM));
fprintf('T3 per-moiety (%d moieties, extrapolated from 2000): old %.1f s, new %.1f s (setup %.2f s), identical %d\n', ...
    numel(uniqueMoietyIndices), tOld3, tNew3, tSetup3, same3);

%% Constructor floor: graph(table, table) alone for component-sized tables
tic
for k = 1:numel(sample)
    g = new{k}; graph(g.Edges, g.Nodes);
end
fprintf('graph(table,table) alone, per component: %.3f ms\n', toc / numel(sample) * 1000);
