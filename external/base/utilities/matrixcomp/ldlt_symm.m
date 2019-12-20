function [L, D, P, rho, ncomp] = ldlt_symm(A, piv)
%LDLT_SYMM  Block LDL^T factorization for a symmetric indefinite matrix.
%           Given a Hermitian matrix A,
%           [L, D, P, RHO, NCOMP] = LDLT_SYMM(A, PIV) computes a permutation P,
%           a unit lower triangular L, and a real block diagonal D
%           with 1x1 and 2x2 diagonal blocks, such that  P*A*P' = L*D*L'.
%           PIV controls the pivoting strategy:
%             PIV = 'p': partial pivoting (Bunch and Kaufman),
%             PIV = 'r': rook pivoting (Ashcraft, Grimes and Lewis).
%           The default is partial pivoting.
%           RHO is the growth factor.
%           For PIV = 'r' only, NCOMP is the total number of comparisons.

%           References:
%           J. R. Bunch and L. Kaufman, Some stable methods for calculating
%              inertia and solving symmetric linear systems, Math. Comp.,
%              31(137):163-179, 1977.
%           C. Ashcraft, R. G. Grimes and J. G. Lewis, Accurate symmetric
%              indefinite linear equation solvers. SIAM J. Matrix Anal. Appl.,
%              20(2):513-561, 1998.
%           N. J. Higham, Accuracy and Stability of Numerical Algorithms,
%              Second edition, Society for Industrial and Applied Mathematics,
%              Philadelphia, PA, 2002; chap. 11.

%           This routine does not exploit symmetry and is not designed to be
%           efficient.

if ~isequal(triu(A,1)',tril(A,-1)), error('Must supply Hermitian matrix.'), end
if nargin < 2, piv = 'p'; end

n = length(A);
k = 1;
D = eye(n); L = eye(n);  if n == 1, D = A; end
pp = 1:n;
if nargout >= 4
   maxA = norm(A(:), inf);
   rho = maxA;
end
ncomp = 0;

alpha = (1 + sqrt(17))/8;

while k < n
      [lambda, r] = max( abs(A(k+1:n,k)) );
      r = r(1) + k;

      if lambda > 0
          swap = 0;
          if abs(A(k,k)) >= alpha*lambda
             s = 1;
          else
             if piv == 'p'
                temp = A(k:n,r); temp(r-k+1) = 0;
                sigma = norm(temp, inf);
                if alpha*lambda^2 <= abs(A(k,k))*sigma
                   s = 1;
                elseif abs(A(r,r)) >= alpha*sigma
                   swap = 1;
                   m1 = k; m2 = r;
                   s = 1;
                else
                   swap = 1;
                   m1 = k+1; m2 = r;
                   s = 2;
                end
                if swap
                   A( [m1, m2], : ) = A( [m2, m1], : );
                   L( [m1, m2], : ) = L( [m2, m1], : );
                   A( :, [m1, m2] ) = A( :, [m2, m1] );
                   L( :, [m1, m2] ) = L( :, [m2, m1] );
                   pp( [m1, m2] ) = pp( [m2, m1] );
                end
             elseif piv == 'r'
                j = k;
                pivot = 0;
                lambda_j = lambda;
                while ~pivot
                      [temp, r] = max( abs(A(k:n,j)) );
                      ncomp = ncomp + n-k;
                      r = r(1) + k - 1;
                      temp = A(k:n,r); temp(r-k+1) = 0;
                      lambda_r = max( abs(temp) );
                      ncomp = ncomp + n-k;
                      if alpha*lambda_r <= abs(A(r,r))
                         pivot = 1;
                         s = 1;
                         A( [k, r], : ) = A( [r, k], : );
                         L( [k, r], : ) = L( [r, k], : );
                         A( :, [k, r] ) = A( :, [r, k] );
                         L( :, [k, r] ) = L( :, [r, k] );
                         pp( [k, r] ) = pp( [r, k] );
                      elseif lambda_j == lambda_r
                         pivot = 1;
                         s = 2;
                         A( [k, j], : ) = A( [j, k], : );
                         L( [k, j], : ) = L( [j, k], : );
                         A( :, [k, j] ) = A( :, [j, k] );
                         L( :, [k, j] ) = L( :, [j, k] );
                         pp( [k, j] ) = pp( [j, k] );
                         k1 = k+1;
                         A( [k1, r], : ) = A( [r, k1], : );
                         L( [k1, r], : ) = L( [r, k1], : );
                         A( :, [k1, r] ) = A( :, [r, k1] );
                         L( :, [k1, r] ) = L( :, [r, k1] );
                         pp( [k1, r] ) = pp( [r, k1] );
                      else
                         j = r;
                         lambda_j = lambda_r;
                      end
                end
             end
          end

          if s == 1

             D(k,k) = A(k,k);
             A(k+1:n,k) = A(k+1:n,k)/A(k,k);
             L(k+1:n,k) = A(k+1:n,k);
             i = k+1:n;
             A(i,i) = A(i,i) - A(i,k) * A(k,i);
             A(i,i) = 0.5 * (A(i,i) + A(i,i)');

          elseif s == 2

             E = A(k:k+1,k:k+1);
             D(k:k+1,k:k+1) = E;
             C = A(k+2:n,k:k+1);
             temp = C/E;
             L(k+2:n,k:k+1) = temp;
             A(k+2:n,k+2:n) = A(k+2:n,k+2:n) - temp*C';
             A(k+2:n,k+2:n) = 0.5 * (A(k+2:n,k+2:n) + A(k+2:n,k+2:n)');

         end

         % Ensure diagonal real (see LINPACK User's Guide, p. 5.17).
         for i=k+s:n
             A(i,i) = real(A(i,i));
         end

         if nargout >= 4 & k+s <= n
            rho = max(rho, max(max(abs(A(k+s:n,k+s:n)))) );
         end

      else  % Nothing to do.

         s = 1;
         D(k,k) = A(k,k);

      end

      k = k + s;

      if k == n
         D(n,n) = A(n,n);
         break
      end

end

if nargout >= 3, P = eye(n); P = P(pp,:); end
if nargout >= 4, rho = rho/maxA; end
