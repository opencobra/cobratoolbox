function [ess] = effectiveSampleSize(x)
%ess = effectiveSampleSize(x)
%compute the effective sample sizes of each parameter in the matrix x
%
%Input:
% x - a dim x N vector, where N is the length of the chain.
%
%Output:
% ess - a dim x 1 vector where ess(i) is the effective sample size of x(i,:).

%We use the Geyer's monotone estimator
n = size(x, 2);

ac = autoCorrelation(x);

if mod(size(ac,2),2)~=0, ac = ac(:,1:(end-1)); end %ensure n is even

%sum up pairs of ac
paired_ac = ac(:, 1:2:end) + ac(:, 2:2:end);

%compute cumulative mins for each coordinate
min_ac = cummin(paired_ac,2);

%sum up all correlations, until the first negative paired correlation
corr_sums = sum(min_ac.*(min_ac>0),2);

ess = n./max(1,-1+2*corr_sums);
end