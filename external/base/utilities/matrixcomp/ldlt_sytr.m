function [L, D] = ldlt_sytr(A)
%LDLT_SYTR  Block LDL^T factorization for a symmetric tridiagonal matrix.
%           [L, D] = LDLT_SYTR(A) factorizes A = L*D*L', where A is
%           Hermitian tridiagonal, L is unit lower triangular, and D is
%           block diagonal with 1x1 and 2x2 diagonal blocks.  It uses
%           Bunch's strategy for choosing the pivots.

%           References:
%           J. R. Bunch, Partial pivoting strategies for symmetric
%              matrices.  SIAM J. Numer. Anal., 11(3):521-528, 1974.
%           N. J. Higham, Accuracy and Stability of Numerical Algorithms,
%              Second edition, Society for Industrial and Applied Mathematics,
%              Philadelphia, PA, 2002; sec. 11.1.4.

n = length(A);
if norm( tril(A,-2), 1) | norm( triu(A,2), 1) | ~isequal(A,A')
   error('Matrix must be Hermitian tridiagonal.')
end

s = norm(A(:), inf);
a = (sqrt(5)-1)/2;
L = eye(n);
D = zeros(n);
k = 1;

while k < n

      if s*abs(A(k,k)) >= a*abs(A(k+1,k))^2

         % 1-by-1 pivot.
         D(k,k) = A(k,k);
         L(k+1,k) = A(k+1,k)/A(k,k);
         A(k+1,k+1) = A(k+1,k+1) - abs(A(k+1,k))^2/A(k,k);
         k = k+1;

      else

         % 2-by-2 pivot.
         E = A(k:k+1,k:k+1);
         D(k:k+1,k:k+1) = E;
         if k+2 <= n
            L(k+2:n,k:k+1) = A(k+2:n,k:k+1)/E;
            A(k+2,k+2) = A(k+2,k+2) - abs(A(k+2,k+1))^2*A(k,k)/det(E);
         end
         k = k+2;

      end

end
if k == n
   D(k,k) = A(k,k);
end
