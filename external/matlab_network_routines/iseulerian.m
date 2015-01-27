% Check if a graph is Eulerian, i.e. it has an Eulerian circuit
% "A connected undirected graph is Eulerian if and only if every graph vertex has an even degree."
% "A connected directed graph is Eulerian if and only if every graph vertex has equal in- and out- degree."
% Note: Assume that the graph is connected.
% INPUTS: adjacency matrix
% OUTPUTS: Boolean variable
% Other routines used: degrees.m, isdirected.m
% GB, Last Updated: October 2, 2009


function S=iseulerian(adj)

S=false;

[degs,indeg,outdeg]=degrees(adj);
odd=find(mod(degs,2)==1);

if not(isdirected(adj)) & isempty(odd) % if undirected and all degrees are even
  S=true;

elseif isdirected(adj) & indeg==outdeg % directed and in-degrees equal out-degrees
  S=true;

elseif numel(odd)==2
  fprintf('there is an Eulerian trail from node %2i to node %2i\n',odd(1),odd(2));

end