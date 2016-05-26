% counts the number of self-loops in the graph
% INPUT: adjacency matrix
% OUTPUT: interger, number of self-loops
% Last Updated: GB, October 1, 2009

function sl=selfloops(adj)

sl=sum(diag(adj));