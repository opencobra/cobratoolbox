function [out] = naturallabel(n)
% Returns a natural label `idv` of `n` carbons.
% Assumes 1.1% C13
%
% USAGE:
%
%    [out] = naturallabel(n)
%
% INPUT:
%    n:      size of label
%
% OUTPUT:
%    out:    natural label idv of n carbons

if n <= 0
    out = 1;
    return;
end

out = zeros(2^n,1);
for i = 0:(2^n-1)
    t = dec2bin(i,n);
    c13 = sum(t-48); % subtract 48 for the '0' offset.
    c12 = n-c13;
    out(i+1) = .989^c12*.011^c13;
end
