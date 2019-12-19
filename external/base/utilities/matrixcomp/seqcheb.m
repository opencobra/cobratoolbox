function x = seqcheb(n, k)
%SEQCHEB   Sequence of points related to Chebyshev polynomials.
%          X = SEQCHEB(N, K) produces a row vector of length N.
%          There are two choices:
%              K = 1:  zeros of T_N,         (the default)
%              K = 2:  extrema of T_{N-1},
%          where T_k is the Chebsyhev polynomial of degree k.

if nargin == 1, k = 1; end

if k == 1                     %  Zeros of T_n
   i = 1:n; j = .5*ones(1,n);
   x = cos( (i-j) * (pi/n) );
elseif k == 2                 %  Extrema of T_(n-1)
   i = 0:n-1;
   x = cos( i * (pi/(n-1)) );
end
