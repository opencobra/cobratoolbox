% counts the number of multiple edges in the graph
% INPUT: adjacency matrix
% OUTPUT: interger, number of multiple edges
% Last Updated: GB, October 1, 2009

function mE=multiedges(adj)

mE=length(find(adj>1));