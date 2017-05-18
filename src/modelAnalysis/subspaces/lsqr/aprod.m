function y = aprod( mode, m, n, x, iw, rw )
% This is the simplest example for testing  LSQR.
% `A = rw`.
% If `mode = 1`, aprod computes `y = A*x`.
% Ff `mode = 2`, aprod computes `y = A'*x`.
% for some matrix  `A`.

if mode == 1,
   y = rw*x;
else
   y = rw'*x;
end
