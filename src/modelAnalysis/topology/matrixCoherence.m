function [mu, Q] = matrixCoherence(A)
% compute the coherence of a matrix A, that is
% the maximum absolute value of the cross correlations
% between the columns of A
%
% INPUT:
%    A:     Matrix
%
% OUTPUT:
%    mu:    coherence

n = size(A, 2);
Q = zeros(n, n);
for j = 1:n
    for k = 1:n
        if j ~= k
            Q(j, k) = abs(A(:, j)' * A(:, k)) / (norm(A(:, j)) * norm(A(:, k)));
        end
    end
end
mu = max(max(Q));
