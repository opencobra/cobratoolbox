% Checks whether a graph is simple (no self-loops, no multiple edges)
% INPUTs: adj - adjacency matrix
% OUTPUTs: S - a Boolean variable
% Other routines used: selfloops.m, multiedges.m
% GB, Last updated: October 1, 2009

function S = issimple(adj)

S=true;

% check for self-loops or double edges
if selfloops(adj)>0 | multiedges(adj)>0; S=false; end