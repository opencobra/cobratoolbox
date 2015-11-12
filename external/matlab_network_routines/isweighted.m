% Check whether a graph is weighted, i.e not all edges are 0,1.
% INPUTS: edge list, m x 3, m: number of edges, [node 1, node 2, edge weight]
% OUTPUTS: Boolean variable, yes/no
% GB, Last updated: October 1, 2009

function S=isweighted(el)

S=true;

if numel( find(el(:,3)==1) ) == size(el,1); S=false; end