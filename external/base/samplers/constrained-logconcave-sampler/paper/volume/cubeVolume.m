dim_range = 300;
trials = 10;
steps = 0*dim_range;
times = 0*dim_range;
phases = 0*dim_range;
it = 0;
for dim = dim_range
it = it+1;
P = makeBody('cube',dim);

options  = [];
options.numSamples = 1;
options.warmup = 20;
options.JLdim = 1;

Q.A = [eye(dim); -eye(dim)]; 
Q.b = [P.ub; -P.lb];
[a_sched] = Volume(Q);
% vol = 1;
% fprintf('init: %e\n', vol);
samples = zeros(dim,length(a_sched)-1);
P_prepped = cell(length(a_sched),1);
for t = 1:trials
for i=1:length(a_sched)-1
    options.sigma = 1/sqrt(2*a_sched(i));
    options.warmup = 20;
    options.numSamples = 1;
    [samples(:,i),P_prepped{i}] = sample(P,options);
end
options.warmup = 0;
num_phases = length(a_sched)-1;
converged = 0;
norm_factor = (pi/a_sched(1))^(dim/2/num_phases);
vol = zeros(num_phases,1);
num_steps = 0;
tic;
while converged<50
    num_steps = num_steps + 1;
for i=1:length(a_sched)-1
    options.sigma = 1/sqrt(2*a_sched(i));
    P_prepped{i}.p = samples(:,i);
    options.P_prep = P_prepped{i};
    samples(:,i) = sample(P,options);
    f_i =  exp(-a_sched(i+1)*sum(samples(:,i).^2)+a_sched(i)*sum(samples(:,i).^2));
    if num_steps == 1
        vol(i) = f_i;
    else
        vol(i) = ((num_steps-1)*vol(i) + f_i)/num_steps;
    end
%     fprintf('phase %d/%d: %e\n', i, length(a_sched)-1,vol);
%     vol = vol * (pi / a_sched(1))^5;
end
    vol_est = prod(vol*norm_factor);
    if mod(num_steps,1e3)==0
        fprintf('%e\n', vol_est);
    end
    if abs(vol_est-1) <0.1
        converged = converged + 1;
    else
        converged = 0;
    end
    
end

steps(it) = num_steps;
times(it) = toc;
phases(it) = num_phases;
fprintf('%d dim: %d steps\n', dim, num_steps);
% vol = vol * (pi/a_sched(1))^(dim/2 - 5*(length(a_sched)-1));
e d
end