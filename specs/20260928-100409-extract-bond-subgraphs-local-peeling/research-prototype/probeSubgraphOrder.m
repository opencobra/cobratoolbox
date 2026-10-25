% Probe subgraph node/edge ordering in R2024b (research R1)
rng(1);
fprintf('MATLAB %s\n', version);

% --- digraph multigraph with extra edge vars, unsorted nodeIDs ---
n = 12;
s = randi(n, 60, 1); t = randi(n, 60, 1);
keep = s ~= t; s = s(keep); t = t(keep);
E = table([s t], (1:numel(s))', randi(5, numel(s), 1), 'VariableNames', {'EndNodes','EdgeIndex','BondIndex'});
N = table((1:n)', 'VariableNames', {'AtomIndex'});
D = digraph(E, N);
fprintf('digraph Edges sorted by (s,t) with ties in insertion order: %d\n', ...
    isequal(D.Edges.EdgeIndex, sortrows([s t (1:numel(s))'], [1 2 3])*[0;0;1]));
ids = [7 3 11 1 9]';
H = subgraph(D, ids);
fprintf('digraph subgraph node order == ids order: %d\n', isequal(H.Nodes.AtomIndex, ids));
% predicted: local = position in ids; keep edges with both ends in ids; stable sort by (ls,lt)
[inS, ls] = ismember(D.Edges.EndNodes(:,1), ids);
[inT, lt] = ismember(D.Edges.EndNodes(:,2), ids);
k = find(inS & inT);
P = sortrows([ls(k) lt(k) k], [1 2 3]);
predE = D.Edges(P(:,3), :); predE.EndNodes = P(:,1:2);
fprintf('digraph subgraph edges == stable sort by local (s,t): %d\n', isequal(H.Edges, predE));
predH = digraph(predE, N(ids,:));
fprintf('digraph(predE, nodes) reproduces subgraph exactly: %d\n', ...
    isequal(H.Edges, predH.Edges) && isequal(H.Nodes, predH.Nodes));

% --- undirected graph (ATG-like) ---
Eu = table([s t], (1:numel(s))', 'VariableNames', {'EndNodes','TransIndex'});
Nu = table((1:n)', randi(3, n, 1), 'VariableNames', {'AtomIndex','Component'});
G = graph(Eu, Nu);
Hg = subgraph(G, ids);
fprintf('graph subgraph node order == ids order: %d\n', isequal(Hg.Nodes.AtomIndex, ids));
[inS, ls] = ismember(G.Edges.EndNodes(:,1), ids);
[inT, lt] = ismember(G.Edges.EndNodes(:,2), ids);
k = find(inS & inT);
a = min(ls(k), lt(k)); b = max(ls(k), lt(k));
P = sortrows([a b k], [1 2 3]);
predEu = G.Edges(P(:,3), :); predEu.EndNodes = P(:,1:2);
fprintf('graph subgraph edges == stable sort by local (min,max): %d\n', isequal(Hg.Edges, predEu));
predG = graph(predEu, Nu(ids,:));
fprintf('graph(predEu, nodes) reproduces subgraph exactly: %d\n', ...
    isequal(Hg.Edges, predG.Edges) && isequal(Hg.Nodes, predG.Nodes));

% --- rmedge keeps relative order ---
R = rmedge(D, [2 5 9]);
kk = setdiff(1:numedges(D), [2 5 9]);
fprintf('rmedge preserves relative row order: %d\n', isequal(R.Edges, D.Edges(kk,:)));

% --- timing: subgraph vs direct construction on a pair-sized graph from a large graph ---
nBig = 200000; sB = randi(nBig, 4*nBig, 1); tB = randi(nBig, 4*nBig, 1);
kb = sB ~= tB;
DB = digraph(table([sB(kb) tB(kb)], (1:nnz(kb))', 'VariableNames', {'EndNodes','EdgeIndex'}), ...
    table((1:nBig)', 'VariableNames', {'AtomIndex'}));
idsB = (1:40)';
tic; for r = 1:50, HB = subgraph(DB, idsB); end; fprintf('subgraph on 200k-node digraph: %.2f ms/call\n', toc/50*1000);
tic; for r = 1:50, RB = rmedge(DB, 1:5); end; fprintf('rmedge on 800k-edge digraph: %.2f ms/call\n', toc/50*1000);
smallE = DB.Edges(1:20, :); smallE.EndNodes = randi(40, 20, 2);
tic; for r = 1:500, HS = digraph(smallE, DB.Nodes(idsB,:)); end; fprintf('digraph(table,table) pair-sized: %.3f ms/call\n', toc/500*1000);
Gs = graph(table(randi(40,30,2), (1:30)', 'VariableNames', {'EndNodes','TransIndex'}), table(idsB, ones(40,1), 'VariableNames', {'AtomIndex','Component'}));
tic; for r = 1:500, HS2 = graph(Gs.Edges, Gs.Nodes); end; fprintf('graph(table,table) pair-sized: %.3f ms/call\n', toc/500*1000);
tic; for r = 1:500, HS3 = addedge(Gs, [1 2 3]', [4 5 6]'); end; fprintf('addedge pair-sized: %.3f ms/call\n', toc/500*1000);
