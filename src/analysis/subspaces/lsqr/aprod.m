function y = aprod(mode, m, n, x, iw, rw)
% Simplest example matrix-vector product for testing LSQR, where `A = rw`
%
% If `mode = 1`, `aprod` computes `y = A x`; if `mode = 2`, it computes `y = A^T x`.
%
% USAGE:
%
%    y = aprod(mode, m, n, x, iw, rw)
%
% INPUTS:
%    mode:    1 to compute `y = A x`, 2 to compute `y = A^T x`
%    m:       number of rows of `A`
%    n:       number of columns of `A`
%    x:       vector the product is applied to
%    iw:      integer work array (unused in this example)
%    rw:      real work array holding the matrix `A`
%
% OUTPUTS:
%    y:       the product `A x` (mode 1) or `A^T x` (mode 2)

if mode == 1,
   y = rw*x;
else
   y = rw'*x;
end
