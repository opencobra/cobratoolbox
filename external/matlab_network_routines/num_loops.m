% Calculate the number of independent loops (use G=m-n+c)
% where G = num loops, m - num edges, n - num nodes, c - num_connected_components
% This is also known as the "cyclomatic number" or the number of edges that need to be removed so that the graph cannot have cycles.
% INPUTS: adjacency matrix
% OUTPUTs: number of independent loops (or cyclomatic number)
% Other routines used: numnodes.m, numedges.m, find_conn_comp.m

function G = num_loops(adj)

n=numnodes(adj);
m=numedges(adj);
comp_mat = find_conn_comp(adj);

G=m-n+length(comp_mat);