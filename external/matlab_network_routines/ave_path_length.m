% Compute average path length for a network - the average shortest path
% INPUTS: adjL - matrix of weights/distances between nodes
% OUTPUTS: average path length: the average of the shortest paths between every two edges
% Note: works for directed/undirected networks
% GB, December 8, 2005

function l = ave_path_length(adj)

n=size(adj,1);

dij = [];

for i=1:n; dij=[dij; simple_dijkstra(adj,i) ]; end

l = sum(sum(dij))/(n^2-n); % sum and average across everything but the diagonal