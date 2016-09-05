% The eigenvalues of the Laplacian of the graph
% INPUTs: adjacency matrix
% OUTPUTs: laplacian eigenvalues, sorted

function s=graph_spectrum(adj)

[v,D]=eig(laplacian_matrix(adj));
s=-sort(-diag(D)); % sort in decreasing order