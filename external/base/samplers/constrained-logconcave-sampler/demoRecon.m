%% Demo to sample from a flow polytope
initSampler

%% Form the problem P
load('Recon2.v05.mat')
P = Problem;
P.Aeq = modelR204.S;
P.beq = modelR204.b;
P.lb = modelR204.lb;
P.ub = modelR204.ub;

%% Generate samples from P
iter = 1000;

tic;
plan = prepare(P, struct('display', 1));
out = sample(plan, iter);
t = toc;

%% Output the result
fprintf('Total time = %f sec\n', t)

[ess] = effectiveSampleSize(out.samples);
fprintf('Mixing time = %f iter\n', iter / min(ess))

p = unifScaleTest(out, plan, struct('toPlot',1));
fprintf('p value = %f\n', p)

