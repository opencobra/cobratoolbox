% Calculate the number of connected components using the Laplacian
% eigenvalues - counting the number of zeros
% INPUTS: adjacency matrix
% OUTPUTs: positive integer - number of connected components
% Other routines used: graph_spectrum.m
% GB, Last updated: October 22, 2009

function nc=num_conn_comp(adj)

s=graph_spectrum(adj);
nc=numel(find(s<10^(-5)));   % zero eigenvalues are sometimes close to zeros numerically in matlab