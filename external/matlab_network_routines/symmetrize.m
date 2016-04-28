% Symmetrize a non-symmetric matrix
% For matrices in which mat(i,j)~=mat(j,i), the larger (nonzero) value is chosen
% INPUTS: a matrix - nxn
% OUTPUT: corresponding symmetric matrix - nxn
% Last Updated: October 1, 2009

function adj_sym = symmetrize(adj)

adj_sym = max(adj,transpose(adj));