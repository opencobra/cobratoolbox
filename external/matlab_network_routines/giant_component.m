% extract giant component from a network
% INPUTS: adjacency matrix
% OUTPUTS: giant comp matrix and node indeces
% Other routines used: find_conn_comp.m, subgraph.m
% GB, Last Updated: October 2, 2009


function [GC,gc_nodes]=giant_component(adj)

comps=find_conn_comp(adj);

L=[];
for k=1:length(comps); L=[L, length(comps{k})]; end
[maxL,ind_max]=max(L);

gc_nodes=comps{ind_max};
GC=subgraph(adj,gc_nodes);