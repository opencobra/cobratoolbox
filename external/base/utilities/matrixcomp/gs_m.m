function [Q, R] = gs_m(A)
%GS_M    Modified Gram-Schmidt QR factorization.
%        [Q, R] = GS_M(A) uses the modified Gram-Schmidt method to compute the
%        factorization A = Q*R for m-by-n A of full rank,
%        where Q is m-by-n with orthonormal columns and R is n-by-n.

%        Reference:
%        N. J. Higham, Accuracy and Stability of Numerical Algorithms,
%        Second edition, Society for Industrial and Applied Mathematics,
%        Philadelphia, PA, 2002; sec 19.8.

[m, n] = size(A);
Q = zeros(m,n);
R = zeros(n);

for k=1:n
    R(k,k) = norm(A(:,k));
    Q(:,k) = A(:,k)/R(k,k);
    R(k,k+1:n) = Q(:,k)'*A(:,k+1:n);
    A(:,k+1:n) = A(:,k+1:n) - Q(:,k)*R(k,k+1:n);
end
