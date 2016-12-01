% Checks whether a (sub)graph is complete, i.e. whether every node is
% linked to every other node. Only defined for unweighted graphs.
% INPUTS: adjacency matrix, adj, nxn
% OUTPUTS: Boolean variable, true/false
% GB, Last Updated: October 1, 2009

function S=iscomplete(adj)

S=false; % default

adj=adj>0;  % remove weights
n=length(adj);

% all degrees "n-1" or "n" or w/ n selfloops
if sum(adj)==ones(1,n)*(n-1) | sum(adj)==ones(1,n)*n; S=true; end