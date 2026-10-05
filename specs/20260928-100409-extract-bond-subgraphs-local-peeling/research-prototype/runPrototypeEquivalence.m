% Research: prototype vs baseline equivalence (CI fixture + randomised synthetic inputs)
addpath(fileparts(mfilename('fullpath')));
ref = load('/home/jackmcgoldrick/cobratoolbox/test/verifiedTests/analysis/testReactingMoieties/data/bondSubgraphReference.mat');
BIG = ref.ciInputs.BIG; ATG = ref.ciInputs.ATG;
fprintf('CI fixture: ATG %s %d nodes %d edges; BIG %d nodes %d edges\n', class(ATG), numnodes(ATG), numedges(ATG), numnodes(BIG), numedges(BIG));
fprintf('ATG.Nodes vars: %s\nATG.Edges vars: %s\n', strjoin(ATG.Nodes.Properties.VariableNames, ','), strjoin(ATG.Edges.Properties.VariableNames, ','));
fprintf('BIG.Nodes vars: %s\nBIG.Edges vars: %s\n', strjoin(BIG.Nodes.Properties.VariableNames, ','), strjoin(BIG.Edges.Properties.VariableNames, ','));
fprintf('AtomIndex == 1:n: %d\n', isequal(ATG.Nodes.AtomIndex(:), (1:numnodes(ATG))'));
checkCase('CI', BIG, ATG);

nFail = 0;
for seed = 1:300
    rng(seed);
    [BIGs, ATGs] = makeSynthetic(seed);
    nFail = nFail + ~checkCase(sprintf('synthetic %d', seed), BIGs, ATGs, seed > 5);
end
fprintf('synthetic failures: %d / 300\n', nFail);

function ok = checkCase(name, BIG, ATG, quiet)
if nargin < 4, quiet = false; end
[b0, m0, e0] = extractBondSubgraphsBaseline(BIG, ATG);
try
    extractBondSubgraphsBaselineAssertK(BIG, ATG); kOK = true;
catch ME
    kOK = ~strcmp(ME.identifier, 'FR009:kAdvanced');
end
[b1, m1, e1] = extractBondSubgraphsLocal(BIG, ATG, false);
[b2, m2, e2, st] = extractBondSubgraphsLocal(BIG, ATG, true);
ok1 = cellsEq(b0, b1) && cellsEq(m0, m1) && isequaln(e0, e1);
ok2 = cellsEq(b0, b2) && cellsEq(m0, m2) && isequaln(e0, e2);
ok = ok1 && ok2 && kOK;
if ~quiet || ~ok
    fprintf('%s: outputs %d, story1 %d, story1+2 %d, k-always-first %d, passes %d\n', name, numel(b0), ok1, ok2, kOK, st.passes);
end
end

function eq = cellsEq(A, B)
eq = isequal(size(A), size(B));
for q = 1:numel(A)
    if ~eq, return, end
    eq = strcmp(class(A{q}), class(B{q})) && isequaln(A{q}.Nodes, B{q}.Nodes) && isequaln(A{q}.Edges, B{q}.Edges);
end
end

function [BIG, ATG] = makeSynthetic(seed)
% components are chains/trees of atoms; AtomIndex is a permutation; BIG has parallel
% edges, repeated BondIndex, intra-component and cross-component edges
nComp = randi([2 12]);
sizes = randi([1 6], nComp, 1);
n = sum(sizes);
perm = randperm(n)';
s = zeros(0, 1); t = zeros(0, 1);
offset = 0;
for c = 1:nComp
    ids = offset + (1:sizes(c))';
    for j = 2:sizes(c)
        s(end+1, 1) = ids(randi(j - 1)); t(end+1, 1) = ids(j); %#ok<AGROW>
    end
    if sizes(c) > 2 && rand < 0.3 % extra cycle / parallel ATG edge
        s(end+1, 1) = ids(1); t(end+1, 1) = ids(end); %#ok<AGROW>
    end
    offset = offset + sizes(c);
end
shuffle = randperm(n)'; % ATG node positions are shuffled relative to component
nodeOrder = shuffle;
posOf = zeros(n, 1); posOf(nodeOrder) = 1:n;
Nodes = table(perm(nodeOrder), zeros(n, 1), 'VariableNames', {'AtomIndex', 'Component'});
ET = table([posOf(s) posOf(t)], (1:numel(s))', 'VariableNames', {'EndNodes', 'TransIndex'});
if mod(seed, 7) == 0
    ATG = digraph(ET, Nodes);
else
    ATG = graph(ET, Nodes);
end
ATG.Nodes.Component = conncomp(ATG)';
% BIG over atom indices 1..n (+ possible isolated extra nodes)
nB = randi([1 4 * n]);
bs = randi(n, nB, 1); bt = randi(n, nB, 1);
bad = bs == bt; bt(bad) = mod(bt(bad), n) + 1;
keep = bs ~= bt; bs = bs(keep); bt = bt(keep);
if isempty(bs), bs = 1; bt = min(2, n); end
if n == 1, BIG = digraph(); BIG = addnode(BIG, table(1, 'VariableNames', {'Label'})); ATG = graph(table(zeros(0,2),zeros(0,1),'VariableNames',{'EndNodes','TransIndex'}), table(1,1,'VariableNames',{'AtomIndex','Component'})); return, end
m = numel(bs);
if rand < 0.5 % parallel edges
    dup = randi(m, randi(3), 1); bs = [bs; bs(dup)]; bt = [bt; bt(dup)]; m = numel(bs);
end
EB = table([bs bt], randperm(m)' + 100, randi(max(1, round(m / 3)), m, 1), rand(m, 1), ...
    'VariableNames', {'EndNodes', 'EdgeIndex', 'BondIndex', 'Weight'});
NB = table((1:n + randi([0 2]))' * 10, 'VariableNames', {'Label'});
BIG = digraph(EB, NB);
end
