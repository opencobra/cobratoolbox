function y = seqm(a, b, n)
%SEQM   Multiplicative sequence.
%       Y = SEQM(A, B, N) produces a row vector comprising N
%       logarithmically equally spaced numbers, starting at A ~= 0
%       and finishing at B ~= 0.
%       If A*B < 0 and N > 2 then complex results are produced.
%       If N is omitted then 10 points are generated.

if nargin == 2, n = 10; end

if n <= 1
   y = a;
   return
end
p = [0:n-2]/(n-1);
r = (b/a).^p;
y = [a*r, b];
