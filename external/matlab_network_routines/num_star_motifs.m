% Calculates the number of star motifs of given (subgraph) size
% Easily extendible to return the actual stars as k-tuples of nodes
% INPUTs: adjacency matrix of original graph, k - size of the star motif
% OUTPUTs: number of stars with k nodes (k-1 spokes)
% Other routines used: degrees.m
% Note: star of size 1 is the trivial case of a single node

function num = num_star_motifs(adj,k)

[deg,~,~]=degrees(adj);

num=0;

for i=1:length(deg)
    if deg(i)>=(k-1); num=num+nchoosek(deg(i),k-1); end
end