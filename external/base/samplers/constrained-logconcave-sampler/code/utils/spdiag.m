function D = spdiag(x)
% D = spdiag(x)
% Output the diagonal matrix given by the vector x
    D = diag(sparse(x));
end