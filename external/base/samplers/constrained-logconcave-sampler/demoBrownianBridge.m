%% Demo to sample from a Brownian bridge
% Only diffenerce to demoFlow is that x_i-x_{i-1} is sampled from N(0,1)
% instead of U([-1 1])
% For this problem, the polytope is unbounded.
% This is an example showing that unbounded domain will cause numerical
% issue.

initSampler
%% Form the problem P
n = 1000; e = ones(n,1);
P = Problem;
% the variables are [x, y] where x in R^n, y in R^{n-1}

% y_i = x_i - x_{i-1}
P.Aeq = [spdiags([e -e], 0:1, n-1, n) ...
    spdiags(-e, 0, n-1, n-1)];
P.beq = zeros(n-1,1);

% x_1 = 0
P.Aeq(end+1,1) = 1;
P.beq(end+1) = 0;

% x_n = 0
P.Aeq(end+1,n) = 1;
P.beq(end+1) = 0;

% distribution exp(-y^2/2)
sigma = [zeros(n,1);ones(n-1,1)];
P.df = @(x) sigma .* x;
P.ddf = @(x) sigma;
P.dddf = @(x) zeros(2*n-1,1);

%% Samples from P (this program should fail because unboundedness)
iter = 100;

try
    plan = prepare(P);
    sample(plan, iter);
catch s
    warning(s.identifier, 'k = %i\n%s', k, s.message);
end

%% Provide a crude bound on P and sample again
P.lb = -10*sqrt(n)*ones(2*n-1,1);
P.ub = 10*sqrt(n)*ones(2*n-1,1);

tic;
plan = prepare(P, struct('display', 1));
out = sample(plan, iter);
t = toc;

%% Output the result
fprintf('Total time = %f sec\n', t)

[ess] = effectiveSampleSize(out.samples);
fprintf('Mixing time = %f iter\n', iter / min(ess))

plot(out.samples(1:n,end));
title('Random sample from a flow polytope');