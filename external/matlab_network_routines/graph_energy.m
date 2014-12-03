% Graph energy defined as: the sum of the absolute values of the real components of the eigenvalues
% Source: Gutman, The energy of a graph, Ber. Math. Statist. Sekt. Forsch-ungszentram Graz. 103 (1978) 1?22.
% INPUTs: adjacency matrix (nxn)
% OUTPUTs: graph energy

function G=graph_energy(adj)

[~,e]=eig(adj);  % e are the eigenvalues
G=sum(abs(real(diag(e))));