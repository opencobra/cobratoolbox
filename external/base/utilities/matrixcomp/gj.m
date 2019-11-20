function x = gj(A, b, piv)
%GJ        Gauss-Jordan elimination to solve Ax = b.
%          x = GJ(A, b, PIV) solves Ax = b by Gauss-Jordan elimination,
%          where A is a square, nonsingular matrix.
%          PIV determines the form of pivoting:
%              PIV = 0:           no pivoting,
%              PIV = 1 (default): partial pivoting.

%          Reference:
%          N. J. Higham, Accuracy and Stability of Numerical Algorithms,
%          Second edition, Society for Industrial and Applied Mathematics,
%          Philadelphia, PA, 2002; sec. 14.4.

n = length(A);
if nargin < 3, piv = 1; end

for k=1:n
    if piv
       % Partial pivoting (below the diagonal).
       [colmax, i] = max( abs(A(k:n, k)) );
       i = k+i-1;
       if i ~= k
          A( [k, i], : ) = A( [i, k], : );
          b( [k, i] ) = b( [i, k] );
       end
    end

    irange = [1:k-1 k+1:n];
    jrange = k:n;
    mult = A(irange,k)/A(k,k); % Multipliers.
    A(irange, jrange) =  A(irange, jrange) - mult*A(k, jrange);
    b(irange) =  b(irange) - mult*b(k);

end

x = diag(diag(A))\b;
