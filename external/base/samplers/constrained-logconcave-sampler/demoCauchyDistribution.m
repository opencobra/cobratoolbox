%% Demo to sample from a Cauchy distribution

initSampler
%% Form the problem P
% the distribution is of the form 1/(1+x^2)
% so, f = log(1+x^2)
n = 10000;

P = Problem;
% Need to set some P.ub to tell the sampler the dimension
P.lb = -Inf * ones(n,1);
P.ub = +Inf * ones(n,1);
P.df = @(x) 2 * x ./ (1+x.^2);
P.ddf = @(x) - 2 * (x.^2-1)./((1+x.^2).^2);
P.dddf = @(x) 4 * x .* (x.^2-3)./((1+x.^2).^3);

%% Samples from P (this program should fail because cauchy is not logconcave)
iter = 50;

try
    plan = prepare(P);
    sample(plan, iter);
catch s
    warning(s.identifier, 'k = %i\n%s', k, s.message);
end


%% Chang P and sample again
% We add an extra term to make ddf > 0 always
% the sampler do not assume ddf is the deriative of df.
% But it assume dddf is the deriative of ddf
P.ddf = @(x) - 2 * (x.^2-1)./((1+x.^2).^2) + 0.5 * ones(n,1);
tic;
plan = prepare(P, struct('display', 1));
out = sample(plan, iter);
t = toc;

%% Output the result
fprintf('Total time = %f sec\n', t)

[ess] = effectiveSampleSize(out.samples);
fprintf('Mixing time = %f iter\n', iter / min(ess))

s = thinSamples(out.samples);

histogram(out.samples(1:n,end), 'BinLimits',[-10,10], 'Normalization', 'pdf', 'BinMethod', 'fd');
title('Cauchy distribution');

hold;
x = -10:0.01:10;
plot(x, 1./(pi * (1+x.^2)), '.')