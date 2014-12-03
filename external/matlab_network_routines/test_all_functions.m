% Test code for "Matlab tools for Network Analysis"

clear all
close all

% Set of test graphs, in various formats =========
one_double_edge = [0 2; 2 0]; 
bowtie=[0 1 1 0 0 0; 1 0 1 0 0 0; 1 1 0 1 0 0; 0 0 1 0 1 1; 0 0 0 1 0 1; 0 0 0 1 1 0];
disconnected_bowtie =[0 1 1 0 0 0; 1 0 1 0 0 0; 1 1 0 0 0 0; 0 0 0 0 1 1; 0 0 0 1 0 1; 0 0 0 1 1 0];
bowtie_edgeL = [1,2,1; 1,3,1; 2,3,1; 3,4,1; 4,5,1; 4,6,1; 5,6,1];
bowtie_edgeL = symmetrize_edgeL(bowtie_edgeL);
bowtie_adjL = {[2,3],[1,3],[1,2,4],[3,5,6],[4,6],[4,5]};
undirected_cherry = [1,2,1; 2,1,1; 1,3,1; 3,1,1];
directed_cherry = [1,2,1; 1,3,1];
undirected_triangle=[0 1 1; 1 0 1; 1 1 0];
undirected_triangle_selfloops = [1 1 1; 1 1 1; 1 1 0];
undirected_triangle_incidence = [1 1 0; 1 0 1; 0 1 1];
directed_triangle=[0 1 0; 0 0 1; 1 0 0];
% ================================================


% Testing getNodes.m =============================
fprintf('testing getNodes.m\n')

if not(getNodes(bowtie,'adj')==[1:6]); fprintf('getNodes.m does not work with bowtie\n'); end
if not(getNodes(random_graph(10),'adj')==[1:10]); fprintf('getNodes.m does not work with random graph with 10 nodes'); end
if not(getNodes(bowtie_adjL,'adjlist')==[1:6]); fprintf('getNodes.m does not work with bowtie_adjL\n'); end
if not(getNodes(directed_cherry,'edgelist')==[1:3]); fprintf('getNodes.m does not work with directed_cherry\n'); end
if not(getNodes(undirected_cherry,'edgelist')==[1:3]); fprintf('getNodes.m does not work with undirected_cherry\n'); end
if not(getNodes(undirected_triangle_incidence,'inc')==[1:3]); fprintf('getNodes.m does not work with undirected_triangle_incidence\n'); end
% ================================================

% Testing getEdges.m =============================
fprintf('testing getEdges.m\n')

if not(getEdges(bowtie,'adj')==bowtie_edgeL); fprintf('getEdges.m does not work with bowtie\n'); end
if not(getEdges(bowtie_adjL,'adjlist')==bowtie_edgeL); fprintf('getEdges.m does not work with bowtie_adjL\n'); end
if not(getEdges(directed_cherry,'edgelist')==directed_cherry); fprintf('getEdges.m does not work with directed_cherry\n'); end
if not(getEdges(undirected_cherry,'edgelist')==undirected_cherry); fprintf('getEdges.m does not work with undirected_cherry\n'); end
if not(getEdges(undirected_triangle_incidence,'inc')==[1,2,1; 2,3,1; 3,1,1; 2,1,1; 3,2,1; 1,3,1]); fprintf('getEdges.m does not work with undirected_triangle_incidence\n'); end
% ================================================

% testing numnodes.m =============================
fprintf('testing numnodes.m\n')
randint = randi(101);
if not(numnodes(random_graph(randint))==randint); fprintf('numnodes.m does not work with random graph with %3i nodes\n',randint); end
if not(numedges(edgeL2adj(directed_cherry))==2); fprintf('numnodes.m does not work with a directed_cherry'); end
% ================================================

% testing numedges.m =============================
fprintf('testing numedges.m\n')
if not(numedges(bowtie)==7); fprintf('numedges.m does not work with bowtie adjacency\n'); end
if not(numedges(undirected_triangle_selfloops)==5); fprintf(['numedges.m does not work with undirected triangle with two selfloops\n']); end
if not(numedges(one_double_edge)==2); fprintf('numedges.m does not work with one_double_edge\n'); end
% ================================================

% testing link_density.m =========================
fprintf('testing link_density.m\n')
randint = randi(101);
if not(link_density(edgeL2adj(canonical_nets(randint,'tree',2)))==2/randint); fprintf('link density does not work with a binary tree with %3i nodes\n',randint); end;
% ================================================

% testing selfloops.m ============================
fprintf('testing selfloops.m\n')
if not(selfloops(undirected_triangle_selfloops)==2); fprintf('selfloops.m does not work with undirected_triangle_selfloops\n'); end
% ================================================

% testing num_conn_comp.m ===================
fprintf('testing num_conn_comp.m\n')
nc=num_conn_comp(disconnected_bowtie);
if not(num_conn_comp(disconnected_bowtie)==2); fprintf('num_conn_comp.m does not work with disconnected_bowtie\n'); end

randint = randi(51);
Adj=zeros(randint*30);
for x=1:randint
  adj=random_graph(30,0.5);
  Adj(30*(x-1)+1:30*x,30*(x-1)+1:30*x)=adj;
end
if not(num_conn_comp(Adj)==randint); fprintf('num_conn_comp.m does not work with Adj\n'); end
% ================================================

% testing find_conn_comp.m ===================
fprintf('testing find_conn_comp.m\n')
clear modules
modules{1}=[0];
randint = randi(21);
Adj = []; adj = [];

for x=1:randint
  randsecint = randi(25)+5;
  lastnode = modules{length(modules)}(length(modules{length(modules)}));
  modules{length(modules)+1} = [lastnode+1:lastnode+randsecint]; 
  while isempty(adj) | not(isconnected(adj)) | not(length(adj)==randsecint); adj=random_graph(randsecint,0.5); end
  %fprintf('last module: %2i, last adj: %2i\n',length(modules{length(modules)}),length(adj))
  Adj(length(Adj)+1:length(Adj)+randsecint,length(Adj)+1:length(Adj)+randsecint)=adj; 
end
%fprintf('size Adj %2i by %2i\n',length(Adj),length(Adj))
modules=modules(2:length(modules));
if not(isequal(find_conn_comp(Adj),modules)); fprintf('find_conn_comp.m does not work with Adj\n'); end
% ================================================

% testing giant_component.m ======================
fprintf('testing giant_component.m\n')
clear modules
modules{1}=[0];
randint = randi(20)+1;
Adj = []; adj = [];

for x=1:randint
  randsecint = randi(25)+5;
  lastnode = modules{length(modules)}(length(modules{length(modules)}));
  modules{length(modules)+1} = [lastnode+1:lastnode+randsecint]; 
  while isempty(adj) | not(isconnected(adj)) | not(length(adj)==randsecint); adj=random_graph(randsecint,0.5); end
  Adj(length(Adj)+1:length(Adj)+randsecint,length(Adj)+1:length(Adj)+randsecint)=adj; 
end
modules=modules(2:length(modules));
L = [];
for m=1:length(modules); L = [L, length(modules{m})]; end;
[maxL,maxind] = max(L);
if not(isequal(giant_component(Adj),subgraph(Adj,modules{maxind}))); fprintf('giant_component.m does not work with Adj\n'); end
% ================================================

% Testing graph_dual.m ===========================
fprintf('testing graph_dual.m\n')

gd=graph_dual(adj2adjL(bowtie));
gdT={};
gdT{1}=[2,3]; gdT{2}=[1,3,4]; gdT{3}=[1,2,4]; gdT{4}=[2,3,5,6]; gdT{5}=[4,6,7]; gdT{6}=[4,5,7]; gdT{7}=[5,6];
if not(isequal(gd,gdT)); 'the graph_dual.m routine does not work with the bowtie graph'; end

gd=graph_dual(adj2adjL(undirected_triangle));
gdT={};
gdT{1}=[2,3]; gdT{2}=[1,3]; gdT{3}=[1,2];
if not(isequal(gd,gdT)); fprintf('the graph_dual.m routine does not work with the undirected_triangle graph\n'); end
L={}; LT={}; L{1}=[2]; L{2}=[1]; LT{1}=[];
if not(isequal(LT,graph_dual(L))); fprintf('graph_dual.m does not work with a single edge\n'); end

% ================================================

% testing graph_complement.m =====================
fprintf('testing graph_complement.m\n')
mat = [1 0 0 1 1 1; 0 1 0 1 1 1; 0 0 1 0 1 1; 1 1 0 1 0 0; 1 1 1 0 1 0; 1 1 1 0 0 1];
if not(graph_complement(bowtie)==mat); fprintf('graph_complement.m does not work with bowtie\n'); end
if not(graph_complement(undirected_triangle)==eye(3)); fprintf('graph_complement.m does not work with undirected_triangle\n'); end
  
% ================================================

% Testing tarjan.m ===============================
fprintf('testing tarjan.m\n')

L = {}; L{1} = 2; L{2} = 1;
GSCC = tarjan(L);
if not(length(GSCC)==1 & GSCC{1}==[1,2]); fprintf('tarjan does not work with an undirected edge\n'); end

L = {}; L{1} = 2; L{2} = [];
GSCC = tarjan(L);
if not(length(GSCC)==2 & GSCC{1}==[2] & GSCC{2}==[1]); fprintf('tarjan does not work with a directed edge\n'); end


L={}; L{1}=[2,3]; L{2}=[1]; L{3}=[1]; L{4}=[1]; % cherry tree (binary) + extra node
GSCC = tarjan(L);
if not(length(GSCC)==2 & GSCC{1}==[1,2,3] & GSCC{2}==[4]); fprintf('tarjan does not work with cherry tree + extra node\n'); end

L={}; L{1}=[2,3]; L{2}=[1,3]; L{3}=[1,2]; L{4}=[1]; % triangle with extra node
GSCC = tarjan(L);
if not(length(GSCC)==2 & GSCC{1}==[1,2,3] & GSCC{2}==[4]); fprintf('tarjan does not work with triangle + extra node\n'); end

L={}; L{1}=[2,3]; L{2}=[1,3]; L{3}=[1,2,4]; L{4}=[5,6]; L{5}=[4,6]; L{6}=[4,5];
GSCC = tarjan(L);
if length(GSCC)==2 & GSCC{1}==[1,2,3] & GSCC{2}==[4,5,6]
  'tarjan works';
elseif length(GSCC)==2 & GSCC{2}==[1,2,3] & GSCC{1}==[4,5,6]
  'tarjan works';
else
  fprintf('tarjan does not work with directed bowtie\n');
end

L={}; L{1}=[2,3]; L{2}=[1,3]; L{3}=[1,2]; L{4}=[5,6]; L{5}=[4,6]; L{6}=[4,5];
GSCC = tarjan(L);
if length(GSCC)==2 & GSCC{1}==[1,2,3] & GSCC{2}==[4,5,6]
  'tarjan works';
elseif length(GSCC)==2 & GSCC{2}==[1,2,3] & GSCC{1}==[4,5,6]
  'tarjan works';
else
  fprintf('tarjan does not work with disconnected bowtie\n');
end


for iter=1:100  % completely random matrix testing ....

  
  % undirected graph testing ========================
  adj = [0 1; 0 0];
  while not(isconnected(adj)); adj = random_graph(randi(50)+1,rand); end

  L=adj2adjL(adj);
  GSCC = tarjan(L);
  if not(length(GSCC)==1 & isequal(GSCC{1},[1:length(adj)])); fprintf('tarjan.m does not work with a random undirected graph\n'); end
  
  % directed graph testing ==========================
  adj=random_directed_graph(randi(50)+1,rand);
  L=adj2adjL(adj);
  GSCC = tarjan(L);
  
  %fprintf('size adj: %3i, num GSCC: %3i\n',length(adj),length(GSCC))
  
  if isconnected(adj) & isconnected(transpose(adj)) & length(adj)>0
    
    %length(GSCC), length(GSCC{1}) - length(adj)
    if not(length(GSCC)==1 & isequal(GSCC{1},[1:length(adj)])); fprintf('tarjan does not work w/ rand directed matrix\n'); end
    
  else
    ll=[];
    for gg=1:length(GSCC); ll=[ll length(GSCC{gg})]; end;
    [ml,maxll]=max(ll);
    if not(isconnected(adj(GSCC{maxll},GSCC{maxll}))) & length(GSCC{maxll})>1
      fprintf('tarjan does not work w/ rand directed matrix\n')
      GSCC{maxll}, adj
      sldfkgjdlfk
      break
    end
    
    for ii=1:length(adj)
      if isempty(find(GSCC{maxll}==ii))
        tryGC = [GSCC{maxll}, ii];
        if isconnected(adj(tryGC,tryGC)) & isconnected(transpose(adj(tryGC,tryGC)))
          fprintf('tarjan does not work w/ rand matrix, there are bigger strongly connected components\n')
          adj
          GSCC
          tryGC
          dlfjgdfj
        end
      end
    end
    
  end
  
end
% ================================================

% testing subgraph.m =============================
fprintf('testing subgraph.m\n')
if not(isequal(undirected_triangle,subgraph(bowtie,[1,2,3]))); fprintf('subgraph.m does not work with bowtie and triangle\n'); end
% ================================================

% testing leaf_nodes.m ===========================
fprintf('testing leaf_nodes.m\n')
if not(leaf_nodes(edgeL2adj(undirected_cherry))==[2,3]); fprintf('leaf_nodes.m does not work with undirected_cherry\n'); end
if not(leaf_nodes(edgeL2adj(directed_cherry))==[2,3]); fprintf('leaf_nodes.m does not work with directed_cherry\n'); end
if not(isempty(leaf_nodes(undirected_triangle))); fprintf('leaf_nodes.m does not work with undirected_triangle\n'); end
% ================================================

% testing leaf_edges.m ===========================
fprintf('testing leaf_edges.m\n')
if not(isequal(leaf_edges(edgeL2adj(undirected_cherry)),[1,2;1,3])); fprintf('leaf_edges.m does not work with undirected_cherry\n'); end
if not(isequal(leaf_edges(edgeL2adj(directed_cherry)),[1,2;1,3])); fprintf('leaf_edges.m does not work with directed_cherry\n'); end
if not(isempty(leaf_edges(undirected_triangle))); fprintf('leaf_edges.m does not work with undirected_triangle\n'); end
hut = [2,1,1;3,1,1];
if not(isempty(leaf_edges(edgeL2adj(hut)))); fprintf('leaf_edges.m does not work with an inverted cherry\n'); end
% ================================================

% testing issimple.m =============================
fprintf('testing issimple.m\n')
if not(issimple(random_graph(randi(5)+20,rand))); fprintf('issimple.m does not work with a simple random matrix\n'); end
if issimple(edgeL2adj([1,2,2])); fprintf('issimple.m does not work with a double edge.m'); end
if issimple( [1 0 0; 0 0 1; 0 1 0]); fprintf('issimple.m does not work with a single-loop, single-edge matrix\n'); end
% ================================================

% testing isdirected.m ===========================
fprintf('testing isdirected.m\n')
if not(isdirected(random_directed_graph(randi(5)+20,rand))); fprintf('isdirected.m does not work with with a random directed graph\n'); end
if isdirected(random_graph(randi(5)+20,rand)); fprintf('isdirected.m does not work with with a random undirected graph\n'); end
% ================================================

% testing issymmetric.m ==========================
fprintf('testing issymmetric.m\n')
for i=1:100
  if not(issymmetric(random_graph(randi(5)+20,rand))); fprintf('issymmetric.m does not work with with a random undirected graph\n'); end
  adj = random_directed_graph(randi(5)+20,rand);
  if issymmetric(adj) & not(adj==zeros(size(adj))); fprintf('issymmetric.m does not work with with a random directed graph\n'); end
end
% ================================================

% testing isconnected.m ==========================
fprintf('testing isconnected.m\n')
if not(isconnected(bowtie)); fprintf('isconnected.m does not work with bowtie\n'); end
if isconnected(disconnected_bowtie); fprintf('isconnected.m does not work with disconnected_bowtie\n'); end

% ================================================

% testing isweighted.m ===========================
fprintf('testing isweighted.m\n')
if not(isweighted([1,2,2])); fprintf('isweighted.m does not work with a double edge\n'); end
if isweighted(adj2edgeL(random_graph(randi(5)+20,rand))); fprintf('isweighted.m does not work with a random_graph\n'); end
if isweighted(adj2edgeL(random_directed_graph(randi(5)+20,rand))); fprintf('isweighted.m does not work with a random_directed_graph\n'); end
if not(isweighted([1,2,0.5; 1,3,1.5; 1,4,1])); fprintf('isweighted.m does not work with some weighted graph\n'); end
if not(isweighted([1,2,0.5; 1,3,1; 1,4,1])); fprintf('isweighted.m does not work with some [0,1] weighted graph\n'); end
% ================================================

% testing isregular.m ============================
fprintf('testing isregular.m\n')
adj = edgeL2adj(canonical_nets(20,'circle'));
if not(isregular(adj)); fprintf('isregular.m does not work a circle\n'); end
adj = edgeL2adj(canonical_nets(20,'tree',3));
if isregular(adj); fprintf('isregular.m does not work a tree\n'); end
if not(isregular([0 1; 1 0])); fprintf('isregular.m does not work an edge\n'); end
if isregular([0 0; 1 0]); fprintf('isregular.m does not work a directed edge\n'); end
% ================================================

% testing iscomplete.m ============================
fprintf('testing iscomplete.m\n')
if not(iscomplete([0 1; 1 0])); fprintf('iscomplete.m does not work with an edge\n'); end
if iscomplete(edgeL2adj(directed_cherry)); fprintf('iscomplete.m does not work with a directed_cherry\n'); end
if iscomplete(edgeL2adj(undirected_cherry)); fprintf('iscomplete.m does not work with a undirected_cherry\n'); end
randint = randi(10)+10;
adj = ones(randint)-eye(randint);
if not(iscomplete(adj)); fprintf('iscomplete.m does not work with a complete graph with %2i nodes\n',randint); end
% ================================================

% testing iseulerian.m ===========================
fprintf('testing iseulerian.m\n')
adj = edgeL2adj(canonical_nets(10,'circle'));
if not(iseulerian(adj)); fprintf('iseulerian.m does not work with a circle\n'); end
adj = edgeL2adj(canonical_nets(10,'tree',3));
if iseulerian(adj); fprintf('iseulerian.m does not work with a tree\n'); end
% ================================================

% testing istree.m ===============================
fprintf('testing istree.m\n')
adj = edgeL2adj(canonical_nets(randi(10)+10,'tree',2));
if not(istree(adj)); fprintf('istree.m does not work with a random tree\n'); end
adj = edgeL2adj(canonical_nets(randi(10)+10,'circle'));
if istree(adj); fprintf('istree.m does not work with a circle\n'); end
% ================================================

% testing isgraphic.m ==========================
fprintf('testing isgraphic.m\n')
for i=1:100
  adj = giant_component(random_graph(randi(20)+1,0.5));
  [deg,indeg,outdeg] = degrees(adj);
  if not(isgraphic(deg)) & not(adj==0); fprintf('isgraphic.m does not work with a random graph\n'); end
end
% ================================================

% testing isbipartite.m ==========================
fprintf('testing isbipartite.m\n')
if isbipartite(adj2adjL(bowtie)); fprintf('isbipartite does not work with bowtie\n'); end
if not(isbipartite(edgeL2adjL(undirected_cherry))); fprintf('isbipartite does not work with undirected_cherry\n'); end
even_circle = canonical_nets(2*randi(10),'circle');
if not(isbipartite(edgeL2adjL(even_circle))); fprintf('isbipartite does not work with even_circle\n'); end
odd_circle = canonical_nets(2*randi(10)+1,'circle');
if isbipartite(edgeL2adjL(odd_circle)); fprintf('isbipartite does not work with odd_circle\n'); end
% ================================================

% testing adj2adjL.m =============================
fprintf('testing adj2adjL.m\n')
if not(isequal(adj2adjL(bowtie),bowtie_adjL')); fprintf('adj2adjL.m does not work with bowtie\n'); end
% ================================================

% testing adjL2adj.m =============================
fprintf('testing adjL2adj.m\n')
if not(isequal(adjL2adj(bowtie_adjL),bowtie)); fprintf('adjL2adj.m does not work with bowtie\n'); end
L = {}; L{1}=[2,3]; L{2}=[]; L{3}=[];
if not(isequal(adjL2adj(L),edgeL2adj(directed_cherry))); fprintf('adjL2adj.m does not work with directed_cherry\n'); end
% ================================================

% testing adj2edgeL.m =============================
fprintf('testing adj2edgeL.m\n')
if not(adj2edgeL(bowtie)==bowtie_edgeL); fprintf('adj2edgeL.m does not work with bowtie\n'); end
if not(adj2edgeL([0 1 1; 0 0 0; 0 0 0])==directed_cherry); fprintf('adj2edgeL.m does not work with directed_cherry\n'); end
% ================================================

% testing edgeL2adj.m =============================
fprintf('testing edgeL2adj.m\n')
if not(edgeL2adj(bowtie_edgeL)==bowtie); fprintf('edgeL2adj.m does not work with bowtie\n'); end
if not(edgeL2adj(directed_cherry)==[0 1 1; 0 0 0; 0 0 0]); fprintf('edgeL2adj.m does not work with directed_cherry\n'); end
% ================================================

% testing adj2inc.m =============================
fprintf('testing adj2inc.m\n')
randint = randi(10)+1;
if not(adj2inc(eye(randint))==eye(randint)); fprintf('adj2inc.m does not work with an eye matrix\n'); end
adj = [0 1 0; 0 1 0; 1 0 0 ];
if not(adj2inc(adj)==[-1 0 1; 1 1 0; 0 0 -1]); fprintf('adj2inc.m does not work with this particular non-simple graph matrix\n'); end
% ================================================

% testing inc2adj.m =============================
fprintf('testing inc2adj.m\n')
randint = randi(10)+1;
if not(inc2adj(eye(randint))==eye(randint)); fprintf('inc2adj.m does not work with eye\n'); end
adj = ones(3) - eye(3);
if not(inc2adj(adj)==adj); fprintf('inc2adj.m does not work with a triangle\n'); end
inc = [-1 1; 1 0; 0 -1];
if not(inc2adj(inc)==[0 1 0; 0 0 0; 1 0 0]); fprintf('inc2adj.m does not work with this matrix\n'); end
% ================================================

% testing adj2str.m =============================
fprintf('testing adj2str.m\n')
if not(strcmp(adj2str(ones(3)-eye(3)),'.2.3,.1.3,.1.2,')); fprintf('adj2str.m does not work with a triangle\n'); end
if not(strcmp(adj2str(eye(3)),'.1,.2,.3,')); fprintf('adj2str.m does not work with an eye\n'); end
% ================================================

% testing str2adj.m =============================
fprintf('testing str2adj.m\n')
if not(isequal(ones(3)-eye(3),str2adj('.2.3,.1.3,.1.2,'))); fprintf('str2adj.m does not work with a triangle\n'); end
if not(isequal(eye(3),str2adj('.1,.2,.3,'))); fprintf('str2adj.m does not work with an eye\n'); end
if not(isequal([0 1 0; 0 0 0; 1 0 0 ],str2adj('.2,,.1,'))); fprintf('str2adj.m does not work with this matrix\n'); end
% ================================================

% testing adjL2edgeL.m ===========================
fprintf('testing adjL2edgeL.m\n')
if not(isequal(adjL2edgeL({[2,3],[],[]}),directed_cherry)); fprintf('adjL2edgeL.m does not work with a directed_cherry\n'); end
% ================================================

% testing edgeL2adjL.m ===========================
fprintf('testing edgeL2adjL.m\n')
if not(isequal(edgeL2adjL(directed_cherry),{[2,3],[],[]}')); fprintf('edgeL2adjL.m does not work with a directed_cherry\n'); end
% ================================================

% testing inc2edgeL.m ============================
fprintf('testing inc2edgeL.m\n')
if not(inc2edgeL([1 0 0; 0 1 0; 0 0 1])==[1 1 1; 2 2 1; 3 3 1]); fprintf('inc2edgeL.m does not work with eye\n'); end
if not(inc2edgeL([-1 -1; 1 0; 0 1])==[1 2 1; 1 3 1]); fprintf('inc2edgeL.m does not work with directed_cherry\n'); end
% ================================================

% testing adj2simple.m ===========================
fprintf('testing adj2simple.m\n')
if not(adj2simple(rand(6))==ones(6)-eye(6)); fprintf('adj2simple.m does not work with a random matrix\n'); end
% ================================================

% testing edgeL2simple.m =========================
fprintf('testing edgeL2simple.m\n')
if not(isempty(edgeL2simple([1 1 1; 2 2 1; 3 3 1]))); fprintf('edgeL2simple.m does not work with eye\n'); end
% ================================================

% testing add_edge_weights.m =====================
fprintf('testing add_edge_weights.m\n')
if not([1 2 2; 1 3 1; 3 4 3]==add_edge_weights([1 2 1; 1 2 1; 1 3 1; 3 4 2; 3 4 1])); fprintf('add_edge_weights.m does not work with this edgelist\n'); end
% ================================================

% testing degrees.m ==============================
fprintf('testing degrees.m\n')
if not([2 2 3 3 2 2]==degrees(bowtie)); fprintf('degrees.m does not work with this bowtie\n'); end
if not([2 1 1]==degrees(edgeL2adj(directed_cherry))); fprintf('degrees.m does not work with this directed_cherry\n'); end
if not([2 1 1]==degrees(edgeL2adj(undirected_cherry))); fprintf('degrees.m does not work with this undirected_cherry\n'); end
[deg,indeg,outdeg]=degrees(edgeL2adj(directed_cherry));
if not(indeg==[0 1 1]); fprintf('degrees.m does not work with this directed_cherry\n'); end
% ================================================

% testing laplacian_matrix.m =====================
fprintf('testing laplacian_matrix.m\n')
if not(laplacian_matrix(bowtie)==[2 -1 -1 0 0 0; -1 2 -1 0 0 0; -1 -1 3 -1 0 0; 0 0 -1 3 -1 -1; 0 0 0 -1 2 -1; 0 0 0 -1 -1 2]); fprintf('laplacian_matrix.m does not work with bowtie\n'); end
% ================================================

% testing rewire.m ===============================
fprintf('testing rewire.m\n')
for x=1:100
  
  el = adj2edgeL(random_graph(randi(10)+10,0.4));
  eln = rewire(el,randi(5));
  degn = degrees(edgeL2adj(eln));
  deg = degrees(edgeL2adj(el));
  if not(sort(deg)==sort(degn)); fprintf('rewire.m does not work with this random_graph.m\n'); end

end
% ================================================

% testing rewire_assort.m ========================
fprintf('testing rewire_assort.m\n')
for x=1:100
  adj = [0 0; 0 0];
  while not(isconnected(adj)); adj = random_graph(randi(10)+10,0.4); end
  el = adj2edgeL(adj);
  eln = rewire_assort(el,randi(5));
  if pearson(edgeL2adj(eln))<pearson(edgeL2adj(el))-10^(-7)
    fprintf('rewire_assort.m does not work with this random graph\n');
    pearson(edgeL2adj(eln))-pearson(edgeL2adj(el))
  end
end
% ================================================

% testing rewire_disassort.m =====================
fprintf('testing rewire_disassort.m\n')
for x=1:100
  adj = [0 0; 0 0];
  while not(isconnected(adj)); adj = random_graph(randi(10)+10,0.4); end
  el = adj2edgeL(adj);
  eln = rewire_disassort(el,randi(5));
  if pearson(edgeL2adj(eln))>pearson(edgeL2adj(el))+10^(-7)
    fprintf('rewire_disassort.m does not work with this random graph\n');
    pearson(edgeL2adj(eln))-pearson(edgeL2adj(el))
  end
end
% ================================================

% testing ave_neighbor_deg.m =====================
fprintf('testing ave_neighbor_deg.m\n')
if not(ave_neighbor_deg(undirected_triangle)==[2 2 2]); fprintf('ave_neighbor_deg.m does not work with an undirected_triangle\n'); end
if not(ave_neighbor_deg(bowtie)==[2.5 2.5 7/3 7/3 2.5 2.5]); fprintf('ave_neighbor_deg.m does not work with a bowtie\n'); end
% ================================================


% testing edge_betweenness.m =====================
fprintf('testing edge_betweenness.m\n')
eb_bowtie = adj2edgeL(bowtie);
eb_bowtie(:,3) = [1/30; 4/30; 1/30; 4/30; 4/30; 4/30; 9/30; 9/30; 4/30; 4/30; 4/30; 1/30; 4/30; 1/30];
if not(isequal(edge_betweenness(bowtie),eb_bowtie)); fprintf('edge_betweenness.m does not work with bowtie\n'); end
if not(isequal(edge_betweenness(undirected_triangle),[2 1 1/6; 3 1 1/6; 1 2 1/6; 3 2 1/6; 1 3 1/6; 2 3 1/6])); fprintf('edge_betweenness.m does not with an undirected_triangle\n'); end
if not(isequal(edge_betweenness([0 1 1 0; 1 0 1 0; 1 1 0 1; 0 0 1 0]),[2 1 1/12; 3 1 1/6; 1 2 1/12; 3 2 1/6; 1 3 1/6; 2 3 1/6; 4 3 3/12; 3 4 3/12])); fprintf('edge_betweenness.m does not work with triangle+edge\n'); end
% ================================================

% testing clust_coeff.m ==========================
fprintf('testing clust_coeff.m\n')
if not(clust_coeff(undirected_triangle)==1); fprintf('clust_coeff.m does not work with undirected_triangle\n'); end
if not(clust_coeff(edgeL2adj(undirected_cherry))==0); fprintf('clust_coeff.m does not work with undirected_cherry\n'); end
if not(clust_coeff(edgeL2adj(canonical_nets(randi(10)+5,'tree',2)))==0); fprintf('clust_coeff.m does not work a random tree\n'); end
% ================================================

% testing s_metric.m =============================
fprintf('testing s_metric.m\n')
if not(s_metric(undirected_triangle)==2*12); fprintf('s_metric.m does not work with undirected_triangle.m\n'); end
if not(s_metric(bowtie)==2*41); fprintf('s_metric.m does not work with bowtie.m\n'); end
if not(s_metric(edgeL2adj(directed_cherry))==4); fprintf('s_metric.m does not work with directed_cherry.m\n'); end
% ================================================

% testing rich_club_metric.m =====================
fprintf('testing rich_club_metric.m\n')
if not(rich_club_metric(random_graph(randi(5)+5,rand),12)==0); fprintf('rich_club_metric.m does not work with a random_graph\n'); end
if not(rich_club_metric(bowtie,2)==link_density(bowtie)); fprintf('rich_club_metric.m does not work with bowtie\n'); end
mat = [0 1 1 0; 1 0 1 0; 1 1 0 1; 0 0 1 0];
if not(rich_club_metric(mat,2)==1); fprintf('rich_club_metric.m does not work with a triangle+edge\n'); end
% ================================================

% testing simple_dijkstra.m ======================
fprintf('testing simple_dijkstra.m\n')
if not(simple_dijkstra(bowtie,1)==[0, 1, 1, 2, 3, 3]); fprintf('simple_dijkstra.m does not work with bowtie\n'); end
if not(simple_dijkstra(bowtie,3)==[1, 1, 0, 1, 2, 2]); fprintf('simple_dijkstra.m does not work with bowtie\n'); end
mat = [0 3.5 0 1; 3.5 0 1 0; 0 1 0 1.4; 1 0 1.4 0];
if not(simple_dijkstra(mat,1)==[0, 3.4, 2.4, 1]); fprintf('simple_dijkstra.m does not work with this matrix\n'); end
if not(simple_dijkstra(edgeL2adj(directed_cherry),1)==[0, 1, 1]); fprintf('simple_dijkstra.m does not work with directed_cherry\n'); end
if not(simple_dijkstra(edgeL2adj(directed_cherry),2)==[inf, 0, inf]); fprintf('simple_dijkstra.m does not work with directed_cherry\n'); end
% ================================================

% testing closeness.m ============================
fprintf('testing closeness.m\n')
if not(closeness(bowtie)'==[1/(1+1+2+3+3), 1/(1+1+2+3+3), 1/(1+1+1+2+2), 1/(1+1+1+2+2), 1/(1+1+2+3+3), 1/(1+1+2+3+3)]); fprintf('closeness.m does not work with bowtie\n'); end
% ================================================

% testing dijkstra.m ============================
fprintf('testing dijkstra.m\n')
[d,p]=dijkstra(bowtie,1,5);
if not(d==3 & p==[1,3,4,5]); fprintf('dijkstra.m does not work with bowtie\n'); end
[d,p]=dijkstra(undirected_triangle,3,[]);
if not(d==[0,1,1]) | not(isequal(p,{[3,1],[3,2],[3]})); fprintf('dijkstra.m does not work with undirected_triangle\n'); end
% ================================================

% testing diameter.m =============================
fprintf('testing diameter.m\n')
el=canonical_nets(randi(10)+10,'tree',2);
adj = edgeL2adj(el);
if not(diameter(adj))==length(adj)-1; fprintf('diameter.m does not work with a tree.\n'); end
if not(diameter(bowtie)==3); fprintf('diameter.m does not work with bowtie\n'); end
% ================================================

% testing ave_path_length.m ======================
fprintf('testing ave_path_length.m\n')
if not(ave_path_length(bowtie)==(0+1+1+2+3+3 +0+1+2+3+3+ 0+1+2+2 +0+1+1 +0+1 +0)/15); fprintf('ave_path_length.m does not work with bowtie\n'); end
% ================================================

% testing vertex_eccentricity.m ==================
fprintf('testing vertex_eccentricity.m\n')
if not(vertex_eccentricity(bowtie)==[3 3 2 2 3 3]); fprintf('vertex_eccentricity.m does not work with bowtie\n'); end
% ================================================

% testing graph_radius.m =========================
fprintf('testing graph_radius.m\n')
if not(graph_radius(bowtie)==2); fprintf('graph_radius.m does not work with bowtie\n'); end
el = canonical_nets(randi(10)+10,'line');
adj = edgeL2adj(el);
if not(graph_radius(adj)==(size(adj,1)-mod(size(adj,1),2))/2); fprintf('graph_radius.m does not work with a line\n'); end
% ================================================

% testing shortest_pathDP.m ======================
fprintf('testing shortest_pathDP.m\n')
[Jb,rb,J,r]=shortest_pathDP(bowtie,1,3,size(bowtie,1));
if not(Jb==1 & rb==[1 3]); fprintf('shortest_pathDP.m does not work with bowtie\n'); end
[Jb,rb,J,r]=shortest_pathDP(bowtie,1,4,size(bowtie,1));
if not(Jb==2 & rb==[1 3 4]); fprintf('shortest_pathDP.m does not work with bowtie\n'); end
[Jb,rb,J,r]=shortest_pathDP(bowtie,1,5,size(bowtie,1));
if not(Jb==3 & rb==[1 3 4 5]); fprintf('shortest_pathDP.m does not work with bowtie\n'); end
% ================================================

% testing kneighbors.m ===========================
fprintf('testing kneighbors.m\n')
if not(kneighbors(bowtie,1,3)==[1 2 3 4 5 6]); fprintf('kneighbors.m does not work with bowtie\n'); end
if not(kneighbors(bowtie,3,1)==[1 2 4]); fprintf('kneighbors.m does not work with bowtie\n'); end
% ================================================

% testing kmin_neighbors.m =======================
fprintf('testing kmin_neighbors.m\n')
if not(kmin_neighbors(bowtie,1,3)==[5 6]); fprintf('kmin_neighbors.m does not work with bowtie\n'); end
if not(kmin_neighbors(bowtie,3,1)==[1 2 4]); fprintf('kmin_neighbors.m does not work with bowtie\n'); end
if not(kmin_neighbors(bowtie,3,2)==[5 6]); fprintf('kmin_neighbors.m does not work with bowtie\n'); end
% ================================================

% testing distance_distribution.m ================
fprintf('testing distance_distribution.m\n')
if not(distance_distribution(bowtie)==[7/15 4/15 4/15 0 0]); fprintf('distance_distribution.m does not work with bowtie\n'); end
if not(distance_distribution(undirected_triangle)==[1 0]); fprintf('distance_distribution.m does not work with undirected_triangle\n'); end
% ================================================

% testing smooth_diameter.m ======================
fprintf('testing smooth_diameter.m\n')
adj = random_graph(randi(10)+10,rand);
if not(diameter(adj)==smooth_diameter(adj,1)); fprintf('smooth_diameter.m does not work with a random graph\n'); end
% ================================================

% testing num_loops.m ============================
fprintf('testing num_loops.m\n')
if not(num_loops(undirected_triangle)==1); fprintf('num_loops.m does not work with an undirected triangle.m\n'); end
% ================================================

% testing newmangirvan.m =========================
fprintf('testing newmangirvan.m\n')
modules = newmangirvan(bowtie,2);
if not(modules{1}==[1,2,3] & modules{2}==[4,5,6]); fprintf('newmangirvan.m does not work with bowtie\n'); end
% ================================================


% testing simple_spectral_partitioning.m =========
fprintf('testing simple_spectral_partitioning.m\n')

for xx=1:100  % do the randomized test 100 times
  n = randi(99)+11;   % number of nodes
  adj = random_modular_graph(n,4,0.1,0.9);  % random graph with n nodes
  num_groups = randi(10)+1;  % number of groups to split the nodes in
  groups = [];
  for x=1:length(num_groups)-1; groups = [groups ceil(rand*n/num_groups)+1]; end
  groups = [groups n-sum(groups)];
  %fprintf('total num nodes %2i; num nodes in groups %2i\n', n, sum(groups));

  modules = simple_spectral_partitioning(adj,groups);
  for m=1:length(modules)
    if not(length(modules{m})==groups(m)); ...
          fprintf('simple_spectral_partitioning.m does not work with a random modular graph\n')
    end
  end
  
end % end of 100 iterations
% ================================================


% testing newman_eigenvector_method.m =========
fprintf('testing newman_eigenvector_method.m\n')

modules = newman_eigenvector_method(bowtie);
if not(length(modules)==2 & modules{1}==[4,5,6] & modules{2}==[1,2,3]); fprintf('newman_eigenvector_method.m does not work with bowtie\n'); end

for x=1:100
  adj = random_graph(randi(10)+5,1);
  Adj = zeros(4*length(adj));
  Adj(1:length(adj),1:length(adj))=adj;
  Adj(length(adj)+1:2*length(adj),length(adj)+1:2*length(adj))=adj;
  Adj(2*length(adj)+1:3*length(adj),2*length(adj)+1:3*length(adj))=adj;
  Adj(3*length(adj)+1:4*length(adj),3*length(adj)+1:4*length(adj))=adj;

  Adj(5,length(adj)+5)=1; Adj(length(adj)+5,5)=1; 
  Adj(length(adj)+6,2*length(adj)+6)=1; Adj(2*length(adj)+6,length(adj)+6)=1; 
  Adj(2*length(adj)+7,3*length(adj)+7)=1; Adj(3*length(adj)+7,2*length(adj)+7)=1; 
  Adj(3*length(adj)+1,1)=1; Adj(1,3*length(adj)+1)=1; 

  modules = newman_eigenvector_method(Adj);
  if not(length(modules)==4); 
    fprintf('newman_eigenvector_method.m does not work with a constructed 4-module random graph\n');
  end


  prescribed = randi(6)+2;
  
  n = randi(50)+50;
  adj = [];
  while not(isconnected(adj)); adj = random_modular_graph(n,prescribed,0.9*log(n)/n,1-0.3*rand); end
  modules = newman_eigenvector_method(adj);
  %fprintf('num modules found %3i; prescribed: %3i\n',length(modules),prescribed);
  
  sumnodes = 0;
  for m=1:length(modules); sumnodes = sumnodes + length(modules{m}); end
  
  if not(n==sumnodes); 
    fprintf('newman_eigenvector_method does not work with a random graph\n')
    dgdff
  end
  
  for m1=1:length(modules)
    for m2=m1+1:length(modules)
      if length(intersect(modules{m1},modules{m2}))>0
        fprintf('newman_eigenvector_method does not work with a random graph\n')
        fgdfgd
      end
    end
  end
    
end
% ================================================

% testing nested_hierarchies_model.m =============
% This test is not well-developped .... WORK ZONE
fprintf('testing nested_hierarchies_model.m\n')
N = 40*randi(3);
el = nested_hierarchies_model(N,3,[10, 20, 40],10);
adj = edgeL2adj(el);
if length(adj)~=N; fprintf('nested_hierarchies_model.m does not work one particular example\n'); end

% ================================================

% testing num_star_motifs.m ======================
fprintf('testing num_star_motifs.m\n')
if num_star_motifs(bowtie,3)~=4+6; fprintf('num_star_motifs.m does not work with bowtie\n'); end
if num_star_motifs(bowtie,4)~=2; fprintf('num_star_motifs.m does not work with bowtie\n'); end
if num_star_motifs(undirected_triangle,3)~=3; fprintf('num_star_motifs.m does not work with undirected_triangle\n'); end
if num_star_motifs(undirected_triangle,2)~=6; fprintf('num_star_motifs.m does not work with undirected_triangle\n'); end
% ================================================

% testing loops4.m ===============================
fprintf('testing loops4.m\n')
if length(loops4(bowtie))~=0; fprintf('loops4.m does not work with bowtie\n'); end
c4 = ones(4)-eye(4); % clique of size 4
if length(loops4(c4))~=1; fprintf('loops4.m does not work with a 4-clique\n'); end
c6 = ones(6)-eye(6); % clique of size 6
if length(loops4(c6))~=nchoosek(6,4); fprintf('loops4.m does not work with a 6-clique\n'); end
% ================================================

% testing symmetrize.m ===========================
fprintf('testing symmetrize.m\n')
randint = randi(10);
adj = rand(randint);
adjsym = symmetrize(adj);
for i=1:length(adjsym)
  for j=i:length(adjsym)
  
    if adjsym(i,j)~=adjsym(j,i); fprintf('symmetrize.m does not work with a random matrix\n'); end
  
  end
end
% ================================================


% testing symmetrize_edgeL.m =====================
fprintf('testing symmetrize_edgeL.m\n')

for x=1:50
  randint = randi(20)+2;  % some number of nodes
  adj = random_directed_graph(randint,0.4); % create a random adjacency
  el = adj2edgeL(adj);
  if isempty(el); continue; end
  elsym = symmetrize_edgeL(el);
  adjsym = edgeL2adj(elsym);
  if not(issymmetric(adj)) & not(issymmetric(adjsym)); fprintf('symmetrize_edgeL.m does not work with a random edgelist\n'); end
end
% ================================================

% testing purge.m ================================
fprintf('testing purge.m\n')
randint = randi(10)+1; % random integer
A = rand(1,randint);     % random vector of randint numbers
ind = randi(randint); % select a random index
Anew = purge(A,A(ind));     % remove A(ind) from A

% check if element has been removed
if sum(find(Anew==A(ind)))>0; fprintf('purge.m does not work with removing one element from a vector of random numbers\n'); end
% check order of elements
for xx=1:10 % try 10 times
  
  % pick two random numbers in Anew
  ind1 = randi(length(Anew));
  ind2 = randi(length(Anew));
  
  indA1 = find(A==Anew(ind1));
  indA2 = find(A==Anew(ind2));
  
  if ind1 <= ind2 & indA1 > indA2; fprintf('purge.m does not work with removing one element from a vector of random numbers\n'); end
  if ind2 <= ind1 & indA2 > indA1; fprintf('purge.m does not work with removing one element from a vector of random numbers\n'); end
  
  
end
% ================================================

% testing random_directed_graph.m ================
fprintf('testing random_directed_graph.m\n')

issym = 0;

for x = 1:100
  adj = random_directed_graph(randi(20)+2,rand);
  if issymmetric(adj); issym = issym + 1; end
end
  
if issym/100 > 0.3; fprintf('random_directed_graph.m does not work, %3i out of 100 matrices turn out to be symmetric\n',issym); end
% ================================================


% testing num_conn_triples.m =====================
fprintf('testing num_conn_triples.m\n')
if num_conn_triples(bowtie)~=6; fprintf('num_conn_triples.m does not work with bowtie\n'); end
if num_conn_triples(undirected_triangle)~=1; fprintf('num_conn_triples.m does not work with undirected_triangle\n'); end
% ================================================

% testing sort_nodes_by_max_neighbor_degree.m ====
fprintf('testing sort_nodes_by_max_neighbor_degree.m\n')
if sort_nodes_by_max_neighbor_degree(bowtie)~=[1,2,5,6,3,4]'; fprintf('sort_nodes_by_max_neighbor_degree.m does not work with bowtie\n'); end
if sort_nodes_by_max_neighbor_degree(edgeL2adj(undirected_cherry))~=[1,3,2]'; fprintf('sort_nodes_by_max_neighbor_degree.m does not work with undirected_cherry\n'); end
% ================================================

% testing sort_nodes_by_sum_neighbor_degrees.m ===
fprintf('testing sort_nodes_by_sum_neighbor_degrees.m\n')
if not(sort_nodes_by_sum_neighbor_degrees(bowtie)==[4,3,6,5,2,1]'); fprintf('sort_nodes_by_sum_neighbor_degrees.m does not work with bowtie\n'); end
% ================================================

% test min_span_tree.m ===========================
fprintf('testing min_span_tree.m\n')
for x=1:100
  adj = random_graph(50,0.2);
  if not(isconnected(adj)); continue; end
  for y=1:10; adj(randi(50),randi(50))=randi(10); end
  tr = min_span_tree(adj);
  if not(istree(tr)) | length(find(tr>1))>0; fprintf('min_span_tree.m does not work with a random_graph\n'); end
end
% ================================================

% test bfs.m =====================================
fprintf('testing BFS.m\n')
for x=1:100
  adj = random_graph(50,0.2);
  if not(isconnected(adj)); continue; end
  tr = BFS(adj2adjL(adj),randi(50));
  if not(istree(symmetrize(adjL2adj(tr)))); fprintf('BFS.m does not work with a random_graph\n'); end
end
% ================================================

% test kregular.m ================================
fprintf('testing kregular.m\n');
for x=1:100
  n = randi(20)+5; % random integer between 6 and 25
  k = randi(n-2)+1;  % randon integer between 2 and n-1
  if mod(k,2)==1 & mod(n,2)==1; continue; end % no solution for this case
  el = kregular(n,k);
  adj = edgeL2adj(el);
  deg = degrees(adj);
  if deg~=k*ones(1,length(adj)); fprintf('kregular.m does not work with %3i nodes and k=%3i\n',n,k); end
end
% ================================================


% test random_modular_graph.m ====================
fprintf('testing random_modular_graph.m\n');
for x=1:20
  dens = rand*0.5;
  mods = randi(5);
  [adj,modules] = random_modular_graph(randi(100)+20,mods,dens,0.9);
  if length(modules)~=mods; fprintf('random_modular_graph does not split the number of modules correctly\n'); end
end
% ================================================


% test graph_from_degree_sequence.m ==============
fprintf('testing graph_from_degree_sequence.m\n')
for x=1:100
  adj = zeros(2);
  while not(isconnected(adj)); adj = random_graph(randi(200),rand); end
  adjr=graph_from_degree_sequence(degrees(adj));
  if degrees(adj)~=degrees(adjr); fprintf('graph_from_degree_sequence.m does not work with a random graph degree sequence\n'); end
  if not(issimple(adjr)); fprintf('graph_from_degree_sequence.m does not work with a random graph degree sequence\n'); end
end
% ================================================

% test newmangastner.m ===========================
% make sure it generates a tree
fprintf('testing newmangastner.m\n');
for x=1:100
  randint = randi(150)+5;
  el = newmangastner(randint,rand);
  adj = edgeL2adj(el);
  if numnodes(adj)~=randint & numedges(adj)~=randint-1; fprintf('newmangastner does not work with a random number nodes\n'); end
end
% ================================================


% test el2geom.m =================================
fprintf('testing el2geom.m\n')
[el,p] = newmangastner(1000,0.5);
elnew = [];
for e=1:size(el,1); elnew = [elnew; el(e,1), el(e,2), randi(9), p(el(e,1),1), p(el(e,1),2), p(el(e,2),1), p(el(e,2),2)]; end
figure
el2geom(elnew)
% ================================================


% testing canonical_nets.m =======================
fprintf('testing canonical_nets.m\n')
for x=1:50
  randint = randi(50)+5;
  el = canonical_nets(randint,'line');
  if not(istree(edgeL2adj(el))); fprintf('canonical_nets.m does not work with line\n'); end
  
  el = canonical_nets(randint,'circle');
  if istree(edgeL2adj(el)); fprintf('canonical_nets.m does not work with circle\n'); end
  if not(degrees(edgeL2adj(el)))==2*ones(1,size(edgeL2adj(el),1)); fprintf('canonical_nets.m does not work with circle\n'); end
  
  el = canonical_nets(randint,'btree');
  if not(istree(edgeL2adj(el))); fprintf('canonical_nets.m does not work with btree\n'); end
  el = canonical_nets(randint,'tree',randi(4)+1);
  if not(istree(edgeL2adj(el))); fprintf('canonical_nets.m does not work with tree\n'); end
  el = canonical_nets(randint,'star');
  if not(istree(edgeL2adj(el))); fprintf('canonical_nets.m does not work with star\n'); end
  el = canonical_nets(randint,'clique');
  if not(iscomplete(edgeL2adj(el))); fprintf('canonical_nets.m does not work with clique\n'); end

  % test the lattices
  el = canonical_nets(randint,'htree',randi(3)+1);
  if not(isconnected(edgeL2adj(el)));  fprintf('canonical_nets.m does not work with htree\n'); end
  adj = giant_component(edgeL2adj(el));
  if size(adj,1)~=randint; fprintf('canonical_nets.m does not work with htree\n'); end

  el = canonical_nets(randint,'trilattice');
  if not(isconnected(edgeL2adj(el)));
    fprintf('canonical_nets.m does not work with trilattice with %3i nodes\n',randint); end
  adj = giant_component(edgeL2adj(el));
  if size(adj,1)~=randint; fprintf('canonical_nets.m does not work with trilattice\n'); end

  el = canonical_nets(randint,'sqlattice');
  if not(isconnected(edgeL2adj(el)));  fprintf('canonical_nets.m does not work with sqlattice\n'); end
  adj = giant_component(edgeL2adj(el));
  if size(adj,1)~=randint; fprintf('canonical_nets.m does not work with sqlattice\n'); end

  el = canonical_nets(randint,'hexlattice');
  if not(isconnected(edgeL2adj(el)));  fprintf('canonical_nets.m does not work with hexlattice\n'); end
  adj = giant_component(edgeL2adj(el));
  if size(adj,1)~=randint; fprintf('canonical_nets.m does not work with hexlattice\n'); end

  
end
% ================================================


% testing fabrikant_model.m ======================
fprintf('testing fabrikant_model.m\n')
for x=1:50
  adj = fabrikant_model(randi(30)+10,rand*10);
  if not(isconnected(adj)) | not(istree(adj)); fprintf('fabrikant_model.m does not work with a random number of nodes\n'); end
end
figure
fabrikant_model(randi(30)+40,rand*10,'on');
% ================================================

% testing DoddsWattsSabel.m ======================
fprintf('testing DoddsWattsSabel.m\n')
for x=1:40
  randint = randi(50)+2;
  m = randi(round(randint/4));
  adj = DoddsWattsSabel(randint,2,m,10*rand,10*rand);
  if numedges(adj)~=m+randint-1; fprintf('DoddsWattsSabel.m does not work with random parameters\n'); end
  
end
% ================================================

% testing preferential_attachment.m ==============
fprintf('testing preferential_attachment.m\n')
for x=1:10
  el = preferential_attachment(randi(10)+10,1);
  adj = edgeL2adj(el);
  if not(istree(adj)); fprintf('preferential_attachment.m with m=1 does not work\n'); end

  randint = randi(30)+5;
  el = preferential_attachment(randint,2);
  adj = edgeL2adj(el);
  if numedges(adj)~=1+2*(length(adj)-2); fprintf('preferential_attachment.m does not produce the right density\n'); end
    
end
% ================================================

% testing exponential_growth_model.m =============
fprintf('testing exponential_growth_model.m\n')
for x=1:10
  el = exponential_growth_model(randi(100));
  adj=edgeL2adj(el);
  if not(isconnected(adj)) & not(istree(adj)); fprintf('exponential_growth_model.m does not work with random number of nodes\n'); end

end
% ================================================

% testing master_equation.m ======================
fprintf('testing master_equation.m\n')
for x=1:30
  randint = randi(100)+3;
  adj = master_equation_growth_model(randint,1,0);
  if not(istree(adj)); fprintf('master_equation_growth_model.m does not work with a=0,m=1\n'); end
  
end
% ================================================


% testing PriceModel.m ===========================
fprintf('testing PriceModel.m\n')
for x=1:20
  randint = randi(10)+10;
  adj = PriceModel(randint);
  if not(isdirected(adj)); fprintf('PriceModel.m does not produce a directed matrix\n'); end
  %adj = symmetrize(adj);
  %if not(isconnected(adj)); fprintf('PriceModel.m produces a disconnected network\n'); end
    
end
% ================================================

% testing forestFireModel.m ======================
% fprintf('still have to test the forestFireModel ==============\n');
% $$$ 
% $$$ for x=1:20
% $$$   randint = randi(50)+5;
% $$$ 
% $$$   p=1;
% $$$   L = forestFireModel(randint,p,1.5);
% $$$   adj = adjL2adj(L);
% $$$   if not(iscomplete(adj)); fprintf('forestFireModel does not work with a forward burning ratio of 1\n'); end
% $$$ 
% $$$ end
% ================================================

% testing build_smax_graph.m =====================
fprintf('testing build_smax_graph.m\n');
for x=1:50
  adj  = [];
  while not(isconnected(adj)); adj = random_graph(30,0.1); end
  sm = s_metric(adj);
  adjmax = build_smax_graph(degrees(adj));
  smax = s_metric(adj);
  if sm>smax; fprintf('build_smax_graph produces a graph with a higher smax than the original random graph\n'); end
end

for x=1:50
  adj  = [];
  while not(isconnected(adj)); adj = giant_component(edgeL2adj(preferential_attachment(30,1))); end
  sm = s_metric(adj);
  adjmax = build_smax_graph(degrees(adj));
  smax = s_metric(adj);
  if sm>smax; fprintf('build_smax_graph produces a graph with a higher smax than the original pref attach graph\n'); end
end
% ================================================


% testing graph_from_degree_sequence.m ===========
fprintf('testing graph_from_degree_sequence.m\n');
for x=1:100
  adj = [];
  while not(isconnected(adj)); adj = random_graph(randi(100)+3,rand); end
  mat = graph_from_degree_sequence(degrees(adj));
  if degrees(adj)~=degrees(mat); fprintf('graph_from_degree_sequence.m does not work with a random degree sequence\n'); end
  mat1 = graph_from_degree_sequence(degrees(adj));
  if mat~=mat; fprintf('graph_from_degree_sequence.m is not deterministic\n'); end
  
end
% ================================================


% testing random_graph.m =========================
fprintf('testing random_graph.m\n');
vars = 0;
for x=1:1000
  adj = random_graph(randi(500)+3);
  if link_density(adj)<0.4 | link_density(adj)>0.6;
    vars = vars + 1;
    fprintf('link_density.m varies below 0.4 or above 0.6, %3f\n',link_density(adj)); end
end
fprintf('link_density is outside of 0.4-0.6 range in %3.3f fraction of cases\n',vars/1000)

vars = 0;
for x=1:1000
  p = rand;
  adj = random_graph(randi(500)+3,p);
  if link_density(adj)<p-0.1 | link_density(adj)>p+1;
    vars = vars + 1;
    fprintf('link_density.m varies below p-0.1 %3.3f or above p+0.1 %3.3f > , %3f\n',p-0.1,p+0.1,link_density(adj)); end
end
fprintf('link_density is outside of p-0.1,p+0.1 range in %3.3f fraction of cases\n',vars/1000)

for x=1:100
  E = randi(100);
  adj = random_graph(101,[],E);
  if numedges(adj)~=E; fprintf('random_graph.m does not produce the right number of edges\n'); end
end

for x=1:10

  adj = [];
  while not(isconnected(adj)); adj = random_graph(randi(70)+3,rand); end
  adj1 = random_graph(length(adj),[],[],'sequence',degrees(adj));
  if not(issimple(adj1)); fprintf('random_graph.m produces a non-simple graph\n'); end
  if length(adj1)~=length(adj); fprintf('random_graph.m does not produce the right size graph\n'); end
  if degrees(adj1)~=degrees(adj); 
    fprintf('random_graph.m does not produce the right degree sequence\n'); 
    degrees(adj1)-degrees(adj)
  end

end

for x=1:10
  
  adj = [];
  while not(isconnected(adj)); adj = edgeL2adj(preferential_attachment(randi(50)+50,1)); end
  adj1 = random_graph(length(adj),[],[],'sequence',degrees(adj));
  if not(issimple(adj1)); fprintf('random_graph.m produces a non-simple graph\n'); end
  if length(adj1)~=length(adj); fprintf('random_graph.m does not produce the right size graph\n'); end
  if degrees(adj1)~=degrees(adj); 
    fprintf('random_graph.m does not produce the right degree sequence\n'); 
    degrees(adj1)-degrees(adj)
  end
  
end
% ================================================
