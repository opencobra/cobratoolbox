% The vector corresponding to the second smallest eigenvalue of the Laplacian matrix
% INPUTs: adjacency matrix (nxn)
% OUTPUTs: fiedler vector (nx1)

function fv=fiedler_vector(adj)

[V,D]=eig(laplacian_matrix(adj));
[ds,Y]=sort(diag(D));
fv=V(:,Y(2));