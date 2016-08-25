function y = lsqraprod( mode, m, n, x, iw, rw )
%  y = lsqraprod( mode, m, n, x, iw, rw );
%
%  if mode = 1, lsqraprod computes y = A*x
%  if mode = 2, lsqraprod computes y = A'*x
%  for some matrix  A.
%
%  This is a simple example for testing  LSQR.
%  It uses the leading m*n submatrix from
%  A = [ 1
%        1 2
%          2 3
%            3 4
%              ...
%                n ]
%  suitably padded by zeros.

%  11 Apr 1996: First version for distribution with lsqr.m.
%               Michael Saunders, Dept of EESOR, Stanford University.

if mode == 1,
   d  = (1:n)';  % Column vector
   y1 = [d.*x; 0] + [0;d.*x];
   if m <= n+1, y = y1(1:m);
   else         y = [y1; zeros(m-n-1,1)]; end
else
   d  = (1:m)';  % Column vector
   y1 = [d.*x] + [d(1:m-1).*x(2:m); 0];
   if m >= n,   y = y1(1:n);
   else         y = [y1; zeros(n-m,1)];   end
end
%===================
% End of lsqraprod.m
%===================
