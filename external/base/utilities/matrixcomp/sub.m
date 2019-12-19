function S = sub(A, i, j)
%SUB     Principal submatrix.
%        SUB(A,i,j) is A(i:j,i:j).
%        SUB(A,i)  is the leading principal submatrix of order i,
%        A(1:i,1:i), if i>0, and the trailing principal submatrix
%        of order ABS(i) if i<0.

if nargin == 2
   if i >= 0
      S = A(1:i, 1:i);
   else
      n = min(size(A));
      S = A(n+i+1:n, n+i+1:n);
   end
else
   S = A(i:j, i:j);
end
