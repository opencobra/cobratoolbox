% The algebraic connectivity of a graph: the second smallest eigenvalue of the Laplacian
% INPUTs: adjacency matrix
% OUTPUTs: algebraic connectivity

function a=algebraic_connectivity(adj)

s=graph_spectrum(adj);
a=s(length(s)-1);