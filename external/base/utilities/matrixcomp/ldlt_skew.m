function [L, D, P, rho] = ldlt_skew(A)
%LDLT_SKEW  Block LDL^T factorization for a skew-symmetric matrix.
%           Given a real, skew-symmetric A,
%           [L, D, P, RHO] = LDLT_SKEW(A) computes a permutation P,
%           a unit lower triangular L, and a block diagonal D
%           with 1x1 and 2x2 diagonal blocks, such that P*A*P' = L*D*L'.
%           A partial pivoting strategy of Bunch is used.
%           RHO is the growth factor.

%           Reference:
%           J. R. Bunch, A note on the stable decomposition of skew-symmetric
%              matrices. Math. Comp., 38(158):475-479, 1982.
%           N. J. Higham, Accuracy and Stability of Numerical Algorithms,
%              Second edition, Society for Industrial and Applied Mathematics,
%              Philadelphia, PA, 2002; chap. 11.

%           This routine does not exploit skew-symmetry and is not designed to
%           be efficient.

if ~isreal(A) | ~isequal(triu(A,1)',-tril(A,-1))
    error('Must supply real, skew-symmetric matrix.')
end

n = length(A);
k = 1;
D = zeros(n);
L = eye(n);
pp = 1:n;
if nargout >= 4
   maxA = norm(A(:), inf);
   rho = maxA;
end

while k < n

      if max( abs(A(k+1:n,k)) ) == 0

         s = 1;
         % Nothing to do.

      else

         s = 2;

         if k < n-1
            [colmaxima, rowindices] = max( abs(A(k+1:n, k:k+1)) );
            [biggest, colindex] = max(colmaxima);
            row = rowindices(colindex)+k; col = colindex+k-1;

            % Permute largest element into (k+1,k) position.
            % NB: k<->col permutation must be done before k+1<->row one.
            A( [k, col], : ) = A( [col, k], : );
            A( :, [k, col] ) = A( :, [col, k] );
            A( [k+1, row], : ) = A( [row, k+1], : );
            A( :, [k+1, row] ) = A( :, [row, k+1] );
            L( [k, col], : ) = L( [col, k], : );
            L( :, [k, col] ) = L( :, [col, k] );
            L( [k+1, row], : ) = L( [row, k+1], : );
            L( :, [k+1, row] ) = L( :, [row, k+1] );
            pp( [k, col] ) = pp( [col, k] );
            pp( [k+1, row] ) = pp( [row, k+1] );
         end

         E = A(k:k+1,k:k+1);
         D(k:k+1,k:k+1) = E;
         C = A(k+2:n,k:k+1);
         temp = C/E;
         L(k+2:n,k:k+1) = temp;
         A(k+2:n,k+2:n) = A(k+2:n,k+2:n) + temp*C';  % Note the plus sign.
         % Restore skew-symmetry.
         A(k+2:n,k+2:n) = 0.5 * (A(k+2:n,k+2:n) - A(k+2:n,k+2:n)');

         if nargout >= 4, rho = max(rho, max(max(abs(A(k+2:n,k+2:n)))) ); end

     end

     k = k + s;
     if k >= n-2, D(k:n,k:n) = A(k:n,k:n); break, end;

end

if nargout >= 3, P = eye(n); P = P(pp,:); end
if nargout >= 4, rho = rho/maxA; end
