% Checks whether a graph is regular, i.e. every node has the same degree.
% Note: Defined for unweighted graphs only.
% INPUTS: adjacency matrix nxn
% OUTPUTS: Boolean, yes/no
% GB, Last updated: October 1, 2009

function S=isregular(adj)

S=false;

degs=sum(adj>0); % remove weights and sum columns

if degs == degs(1)*ones(size(degs)); S = true; end