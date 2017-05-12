function mix = mixFraction(sample1, sample2, fixed)
% Compares two sets of sampled points and determines how mixed
% they are.
%
% USAGE:
%
%    mix = mixFraction(sample1, sample2, fixed)
%
% INPUTS:
%    sample1, sample2:      Ordered set of points. The points must be in
%                          the same order otherwise it does not make sense.
%
% OPTIONAL INPUT:
%    fixed:                The directions which are fixed and are not expected
%                          to mix. They are ignored.
%
% OUTPUT:
%    mix:                  The mix fraction. Goes from 0 to 1 with 1 being
%                          completely unmixed and .5 being essentially
%                          perfectly mixed.

if nargin <3
    fixed = [];
end

sample1 = full(sample1);
sample2 = full(sample2);

sample1(fixed, :) = zeros(length(fixed), size(sample1,2));
sample2(fixed, :) = zeros(length(fixed), size(sample2,2));

m1 = median(sample1, 2);
LPproblem = median(sample2, 2);

l1 = sample1 > m1*ones(1, size(sample1,2));
eq1 = sample1 == m1*ones(1, size(sample1,2));
l2 = sample2 > LPproblem*ones(1, size(sample1,2));
eq2 = sample2 == LPproblem*ones(1, size(sample1,2));

eqtotal = eq1 | eq2;

mix = sum(sum((l1 == l2) & ~eqtotal))/(numel(l1)-sum(sum(eqtotal)));
