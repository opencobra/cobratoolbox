% Finds the dual of a graph; a dual is the inverted nodes-edges graph
% This is also called the line graph, adjoint graph or the edges adjacency
% INPUTs: adjacency (neighbor) list representation of the graph (see adj2adjL.m)
% OUTPUTs: adj (neighbor) list of the corresponding dual graph and cell array of edges
% Note: this routine only works for undirected, simple graphs
% GB, March 26, 2011

function [dL,edge_array] = graph_dual(L)

dL={}; % initialize
for i=1:length(L)
  for j=1:length(L{i})
  
    if i<=L{i}(j); dL{length(dL)+1}=[]; end

  end
end

edge_array={};

for i=1:length(L)
  
  for j=1:length(L{i})  % add i,L{i}j to list of nodes
    if i<=L{i}(j); edge_array{length(edge_array)+1}= strcat(num2str(i),'-',num2str(L{i}(j))); end
  end
  
  for j=1:length(L{i})  % add i - L{i}j to list of edges
    for k=j+1:length(L{i})
      edge1=strcat(num2str(min([i,L{i}(j)])),'-',num2str(max([i,L{i}(j)])));
      edge2=strcat(num2str(min([i,L{i}(k)])),'-',num2str(max([i,L{i}(k)])));

      ind_edge1=find(ismember(edge_array, edge1)==1);
      ind_edge2=find(ismember(edge_array, edge2)==1);
      
      dL{ind_edge1}=unique([dL{ind_edge1},ind_edge2]);
      dL{ind_edge2}=unique([dL{ind_edge2},ind_edge1]);
    end
  end
end