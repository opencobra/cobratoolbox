function C = strassen(A, B, nmin)
%STRASSEN  Strassen's fast matrix multiplication algorithm.
%          C = STRASSEN(A, B, NMIN), where A and B are matrices of dimension
%          a power of 2, computes the product C = A*B.
%          Strassen's algorithm is used recursively until dimension <= NMIN
%          is reached, at which point standard multiplication is used.
%          The default is NMIN = 8 (which minimizes the total number of
%          operations).

%          Reference:
%          V. Strassen, Gaussian elimination is not optimal,
%          Numer. Math., 13 (1969), pp. 354-356.

if nargin < 3, nmin = 8; end

n = length(A);
if n ~= 2^( log2(n) )
   error('The matrix dimension must be a power of 2.')
end

if n <= nmin
   C = A*B;
else
   m = n/2; i = 1:m; j = m+1:n;
   P1 = strassen( A(i,i)+A(j,j), B(i,i)+B(j,j), nmin);
   P2 = strassen( A(j,i)+A(j,j), B(i,i), nmin);
   P3 = strassen( A(i,i), B(i,j)-B(j,j), nmin);
   P4 = strassen( A(j,j), B(j,i)-B(i,i), nmin);
   P5 = strassen( A(i,i)+A(i,j), B(j,j), nmin);
   P6 = strassen( A(j,i)-A(i,i), B(i,i)+B(i,j), nmin);
   P7 = strassen( A(i,j)-A(j,j), B(j,i)+B(j,j), nmin);
   C = [ P1+P4-P5+P7  P3+P5;  P2+P4  P1+P3-P2+P6 ];
end
