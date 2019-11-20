function [Q, R] = gs_c(A)
%GS_C    Classical Gram-Schmidt QR factorization.
%        [Q, R] = GS_C(A) uses the classical Gram-Schmidt method to compute the
%        factorization A = Q*R for m-by-n A of full rank,
%        where Q is m-by-n with orthonormal columns and R is n-by-n.

%        Reference:
%        N. J. Higham, Accuracy and Stability of Numerical Algorithms,
%        Second edition, Society for Industrial and Applied Mathematics,
%        Philadelphia, PA, 2002; sec 19.8.

[m, n] = size(A);
Q = zeros(m,n);
R = zeros(n);

for j=1:n
    R(1:j-1,j) = Q(:,1:j-1)'*A(:,j);
    temp = A(:,j) - Q(:,1:j-1)*R(1:j-1,j);
    R(j,j) = norm(temp);
    Q(:,j) = temp/R(j,j);
end
