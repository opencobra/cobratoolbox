% Converts an edgelist to an adjacency list
% INPUTS: edgelist, (mx3)
% OUTPUTS: adjacency list
% GB, Last updated: October 13, 2006

function adjL = edgeL2adjL(el)

nodes = unique([el(:,1)' el(:,2)']);
adjL=cell(numel(nodes),1);

for e=1:size(el,1); adjL{el(e,1)}=[adjL{el(e,1)},el(e,2)]; end