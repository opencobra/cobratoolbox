function A = makejcf(n, e, m, X)
%MAKEJCF   A matrix with specified Jordan canonical form.
%          MAKEJCF(N, E, M) is a matrix having the Jordan canonical form
%          whose i'th Jordan block is of dimension M(i) with eigenvalue E(i),
%          and where N = SUM(M).
%          Defaults: E = 1:N, M = ONES(SIZE(E)) with M(1) so that SUM(M) = N.
%          The matrix is constructed by applying a random similarity
%          transformation to the Jordan form.
%          Alternatively, the matrix used in the similarity transformation
%          can be specified as a fifth parameter.
%          In particular, MAKEJCF(N, E, M, EYE(N)) returns the Jordan form
%          itself.
%          NB: The JCF is very sensitive to rounding errors.

if nargin < 2, e = 1:n; end
if nargin < 3, m = ones(size(e)); m(1) = m(1) + n - sum(m); end

if length(e) ~= length(m)
   error('Parameters E and M must be of same dimension.')
end

if sum(m) ~= n, error('Block dimensions must add up to N.'), end

A = zeros(n);
j = 1;
for i=1:max(size(m))
    if m(i) > 1
        Jb = gallery('jordbloc',m(i),e(i));
    else
        Jb = e(i);  % JORDBLOC fails in n = 1 case.
    end
    A(j:j+m(i)-1,j:j+m(i)-1) = Jb;
    j = j + m(i);
end

if nargin < 4
   X = randn(n);
end
A = X\A*X;
