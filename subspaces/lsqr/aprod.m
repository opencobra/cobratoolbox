function y = aprod( mode, m, n, x, iw, rw )
%        y = aprod( mode, m, n, x, iw, rw )
%
%  if mode = 1, aprod computes y = A*x
%  if mode = 2, aprod computes y = A'*x
%  for some matrix  A.
%
%  This is the simplest example for testing  LSQR.
%  A = rw.

if mode == 1,
   y = rw*x;
else
   y = rw'*x;
end
