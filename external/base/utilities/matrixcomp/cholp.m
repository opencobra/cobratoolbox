function [R, P, I] = cholp(A, piv)
%CHOLP  Cholesky factorization with pivoting of a positive semidefinite matrix.
%       [R, P] = CHOLP(A) returns an upper triangular matrix R and a
%       permutation matrix P such that R'*R = P'*A*P.  Only the upper
%       triangular part of A is used. If A is not positive semidefinite,
%       an error message is printed.
%
%       [R, P, I] = CHOLP(A) never produces an error message.
%       If A is positive semidefinite then I = 0 and R is the Cholesky factor.
%       If A is not positive semidefinite then I is positive and
%       R is (I-1)-by-N with P'*A*P - R'*R zero in columns 1:I-1 and
%       rows 1:I-1.
%       [R, I] = CHOLP(A, 0) forces P = EYE(SIZE(A)), and therefore behaves
%       like [R, I] = CHOL(A).

%       This routine is based on the LINPACK routine CCHDC.  It works
%       for both real and complex matrices.
%
%       Reference:
%       N. J. Higham, Accuracy and Stability of Numerical Algorithms,
%       Second edition, Society for Industrial and Applied Mathematics,
%       Philadelphia, PA, 2002; sec. 10.3.

if nargin == 1, piv = 1; end

n = length(A);
pp = 1:n;
I = 0;

for k = 1:n

    if piv
       d = diag(A);
       [big, m] = max( d(k:n) );
       m = m+k-1;
    else
       big = A(k,k);  m = k;
    end
    if big < 0, I = k; break, end

%   Symmetric row/column permutations.
    if m ~= k
       A(:, [k m]) = A(:, [m k]);
       A([k m], :) = A([m k], :);
       pp( [k m] ) = pp( [m k] );
    end

    if big == 0
      if norm(A(k+1:n,k)) ~= 0
         I = k; break
      else
         continue
      end
    end

    A(k,k) = sqrt( A(k,k) );
    if k == n, break, end
    A(k, k+1:n) = A(k, k+1:n) / A(k,k);

%   For simplicity update the whole of the remaining submatrix (rather
%   than just the upper triangle).

    j = k+1:n;
    A(j,j) = A(j,j) - A(k,j)'*A(k,j);

end

R = triu(A);
if I > 0
    if nargout < 3, error('Matrix must be positive semidefinite.'), end
    R = R(1:I-1,:);
end

if piv == 0
   P = I;
else
   P = eye(n); P = P(:,pp);
end
