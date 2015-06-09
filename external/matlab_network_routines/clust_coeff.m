% Computes clustering coefficient, based on triangle motifs count and local clustering
% C1 = num triangle loops / num connected triples
% C2 = the average local clustering, where Ci = (num triangles connected to i) / (num triples centered on i)
% Ref: M. E. J. Newman, "The structure and function of complex networks"
% Valid for directed and undirected graphs
% INPUT: adjacency matrix representation of a graph
% OUTPUT: graph average clustering coefficient and clustering coefficient
% Other routines used: degrees.m, isdirected.m, kneighbors.m, numedges.m, subgraph.m, loops3.m, num_conn_triples.m
% GB, October 9, 2009

function [C1,C2,C] = clust_coeff(adj)

n = length(adj);
adj = adj>0;  % no multiple edges
[deg,~,~] = degrees(adj);
C=zeros(n,1); % initialize clustering coefficient

% multiplication change in the clust coeff formula
coeff = 2;
if isdirected(adj); coeff=1; end

for i=1:n
  
  if deg(i)==1 | deg(i)==0; C(i)=0; continue; end

  neigh=kneighbors(adj,i,1);
  edges_s=numedges(subgraph(adj,neigh));
    
  C(i)=coeff*edges_s/deg(i)/(deg(i)-1);

end

C1=loops3(adj)/num_conn_triples(adj);
C2=sum(C)/n;