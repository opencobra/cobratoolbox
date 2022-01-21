%% Demo to sample
initSampler

%% Form the problem P
% Example 1: from a .mat file
% load('Recon2.v04.mat')
% P = Problem;
% P.Aeq = modelR204.S;
% P.beq = modelR204.b;
% P.lb = modelR204.lb;
% P.ub = modelR204.ub;

% Examples 2,3: from the test library, uniform sampling
%P = loadProblem('basic/random_sparse@100')
%P.df=zeros(P.n,1);
%P = loadProblem('basic/birkhoff@100')
%P.df=zeros(P.n,1);

% Example 4: define directly (Gaussian in a cone)
% run scatter(out.samples(1,:),out.samples(2,:)) to see the projection to the first 2 coordinates
P = Problem;
P.lb=zeros(1000,1);
P.Aineq = zeros(1,P.n);
P.Aineq(1)=-1;
P.Aineq(2)=-1;
P.bineq = -1;
P.df=@(x) x;


%% Samples from P
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

