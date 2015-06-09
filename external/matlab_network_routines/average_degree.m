% Computes the average degree of a node in a graph, defined as 2*num_edges 
% divided by the num_nodes (every edge is counted in degrees twice).
% Other routines used: numnodes.m, numedges.m
% GB, Last Update: October 1, 2009

function k=average_degree(adj)

k=2*numedges(adj)/numnodes(adj);