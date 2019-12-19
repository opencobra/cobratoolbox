function [y] = thinSamples(x)
%y = thinSamples(x)
%extract independent samples by taking one sample every N/ess(x) many samples
% where ess(x) is the min(effectiveSampleSize(x))
%
%Input:
% x - a dim x N vector, where N is the length of the chain.
%
%Output:
% y - a dim x ess(x) vector.

ess = effectiveSampleSize(x);

mt = size(x,2)/min(ess);

y = x(:,ceil(mt):ceil(mt):end);
end

