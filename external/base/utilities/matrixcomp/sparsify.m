function A = sparsify(A, p)
%SPARSIFY  Randomly set matrix elements to zero.
%          S = SPARSIFY(A, P) is A with elements randomly set to zero
%          (S = S' if A is square and A = A', i.e. symmetry is preserved).
%          Each element has probability P of being zeroed.
%          Thus on average 100*P percent of the elements of A will be zeroed.
%          Default: P = 0.25.

if nargin < 2, p = 0.25; end
if p<0 | p>1, error('Second parameter must be between 0 and 1 inclusive.'), end

[m,n] = size(A);

if ~isequal(A,A')
   A = A .* (rand(m,n) > p);        % Unsymmetric case
else
   A = triu(A,1) .* (rand(m,n) > p);  % Preserve symmetry
   A = A + A';
   A = A + diag( diag(A) .* (rand(size(n,1)) > p) );
end
