% Vertex eccentricity - the maximum distance to any other vertex
% Input: adjacency matrix
% Output: vector of eccentricities
% Other routines used: simple_dijkstra.m

function ec=vertex_eccentricity(adj)

n=size(adj,1);
ec=zeros(1,n);

for s=1:n; ec(s)=max( simple_dijkstra(adj,s) ); end