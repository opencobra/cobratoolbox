% Computes the link density of a graph, defined as num_edges divided by 
% num_nodes(num_nodes-1)/2 where the latter is the max possible num edges.
% The graph needs to be non-trivial (more than 1 node).
% Other routines used: numnodes.m, numedges.m
% GB, Last Update: October 1, 2009

function d=link_density(adj)

n = numnodes(adj);
d = 2*numedges(adj)/(n*(n-1));