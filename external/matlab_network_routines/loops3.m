% Calculates number of loops of length 3
% INPUTs: adj - adjacency matrix
% OUTPUTs: L3 - number of triangles (loops of length 3)
% Valid for an undirected network
% GB, April 6, 2006

function L3 = loops3(adj)

L3 = trace(adj^3)/6;   % trace(adj^3)/3!