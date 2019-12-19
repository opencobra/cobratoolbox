function [L, U, P, Q, rho, ncomp] = gep(A, piv)
%GEP    Gaussian elimination with pivoting: none, complete, partial or rook.
%       [L, U, P, Q, RHO] = GEP(A, piv) computes the factorization P*A*Q = L*U
%       of the m-by-n matrix A, where m >= n,
%       where L is m-by-n unit lower triangular, U is n-by-n upper triangular,
%       and P and Q are permutation matrices.  RHO is the growth factor.
%       PIV controls the pivoting strategy:
%          PIV = 'c': complete pivoting,
%          PIV = 'p': partial pivoting,
%          PIV = 'r': rook pivoting.
%       The default is no pivoting (PIV = '').
%       For PIV = 'r' only, NCOMP is the total number of comparisons.
%
%       By itself, GEP(A) returns the final reduced matrix from the
%       elimination containing both L and U.

%       Reference:
%       N. J. Higham, Accuracy and Stability of Numerical Algorithms,
%       Second edition, Society for Industrial and Applied Mathematics,
%       Philadelphia, PA, 2002; chap. 9.

[m, n] = size(A);
if m < n, error('Matrix must be m-by-n with m >= n.'), end
if nargin < 2, piv = ''; end
pp = 1:m; qq = 1:n;
if nargout >= 5
   maxA = norm(A(:), inf);
   rho = maxA;
end
ncomp = 0;

for k = 1:min(m-1,n)

    if findstr(piv, 'cpr')
       if strcmp(piv, 'c')

          % Find largest element in remaining square submatrix.
          % Note: when tie for max, no guarantee which element is chosen.
          [colmaxima, rowindices] = max( abs(A(k:m, k:n)) );
          [biggest, colindex] = max(colmaxima);
          row = rowindices(colindex)+k-1; col = colindex+k-1;

       elseif strcmp(piv, 'p')

          % Find largest element in k'th column.
          [colmaxima, rowindices] = max( abs(A(k:m, k)) );
          row = rowindices(1)+k-1; col = k;

       elseif strcmp(piv, 'r')

          % Find element that is largest in its row and its column.
          col_last = k;
          for it = 1:inf
            [colmaxima, rowindices] = max( abs(A(k:m, col_last)) );
            ncomp = ncomp + m-k;
            row = rowindices(1)+k-1;
            new_abs = abs(A(row,col_last));
            if it > 1
               if new_abs == last_abs
                  row = row_last;
                  break
               end
            end
            last_abs = new_abs;
            row_last = row;
            [rowmaxima, colindices] = max( abs(A(row, k:n)) );
            ncomp = ncomp + n-k;
            col = colindices(1)+k-1;
            new_abs = abs(A(row,col));
            if new_abs == last_abs
               col = col_last;
               break
            end
            last_abs = new_abs;
            col_last = col;
          end

       end

       % Permute largest element into pivot position.
       A( [k, row], : ) = A( [row, k], : );
       A( :, [k, col] ) = A( :, [col, k] );
       pp( [k, row] ) = pp( [row, k] ); qq( [k, col] ) = qq( [col, k] );
    end

    if A(k,k) == 0
      if findstr(piv, 'c')
         break
      elseif strcmp(piv, '') % Zero pivot is problem only for no pivoting.
         error('Elimination breaks down with zero pivot.  Quitting...')
      end
    end

    i = k+1:m;
    if A(k,k) ~= 0  % Simplest way to handle zero pivot for partial and rook.
       A(i,k) = A(i,k)/A(k,k);          % Multipliers.
    end

    if k+1 <= n
       % Elimination
       j = k+1:n;
       A(i,j) = A(i,j) - A(i,k) * A(k,j);
       if nargout >= 5, rho = max( rho, max(max(abs(A(i,j)))) ); end
    end

end

if nargout <= 1
   L = A;
   return
end

L = tril(A,-1) + eye(m,n);
U = triu(A);
U = U(1:n,:);

if nargout >= 3, P = eye(m); P = P(pp,:); end
if nargout >= 4, Q = eye(n); Q = Q(:,qq); end
if nargout >= 5, rho = rho/maxA; end
