% Convert an adjacency matrix of a general graph to the adjacency matrix of
% a simple graph (no loops, no double edges) - great for quick data clean up
% INPUTS: adjacency matrix
% OUTPUTs: adjacency matrix of the corresponding simple graph
% GB, Last updated: October 4, 2009

function adj=adj2simple(adj)

adj=adj>0; % make all edges weight 1
adj = adj - diag(diag(adj)); % clear the diagonal (selfloops)