dim_range = [20];
trials = 1;
steps = 0*dim_range;
times = 0*dim_range;
phases = 0*dim_range;
it = 0;
K = 10;
vol_ests = cell(length(dim_range),1);
for dim = dim_range
    fprintf('dim=%d/%d\n', dim, max(dim_range));
it = it+1;
P = makeBody('cube',dim);

Q.A = [eye(dim); -eye(dim)]; 
Q.b = [P.ub; -P.lb];
[a_sched] = Volume(Q);
% vol = 1;
% fprintf('init: %e\n', vol);
samples = zeros(dim,length(a_sched)-1,K);
P_prepped = cell(length(a_sched),1);
num_steps = 10*ceil(sqrt(num_phases));
vol_ests{it} = zeros(num_steps,trials);
for t = 1:trials
    fprintf('Trial %d/%d\n', t, trials);
    options = [];
    options.JL_dim = 1;
for i=1:length(a_sched)-1
    sigma = 1/sqrt(2*a_sched(i));
    options.warmup = 20;
    options.numSamples = 1;
    
    grad = @(x) x/sigma^2;
    hess = @(x) ones(n,1)/sigma^2;
    tensor = @(x) zeros(n,1);
    [samples(:,i,K),P_prepped{i}] = sample(P,options,grad,hess,tensor);
end
options.warmup = 0;
options.numSamples = K;
num_phases = length(a_sched)-1;
converged = 0;
norm_factor = (pi/a_sched(1))^(dim/2/num_phases);
vol = zeros(num_phases,1);
% num_steps = 0;
tic;
for step_i = 1:num_steps
% while converged<10
%     num_steps = num_steps + 1;
for i=1:length(a_sched)-1
    sigma = 1/sqrt(2*a_sched(i));
    P_prepped{i}.p = samples(:,i,K);
    options.P_prep = P_prepped{i};
    grad = @(x) x/sigma^2;
    hess = @(x) ones(n,1)/sigma^2;
    tensor = @(x) zeros(n,1);
    samples(:,i,:) = sample(P,options,grad,hess,tensor);
    f_i =  mean(exp(-a_sched(i+1)*sum(samples(:,i,:).^2,1)+a_sched(i)*sum(samples(:,i,:).^2,1)),3);
    if num_steps == 1
        vol(i) = f_i;
    else
        vol(i) = ((step_i-1)*vol(i) + f_i)/step_i;
    end
%     fprintf('phase %d/%d: %e\n', i, length(a_sched)-1,vol);
%     vol = vol * (pi / a_sched(1))^5;
end
    vol_ests{it}(step_i,t) = prod(vol*norm_factor);
    if mod(num_steps,1e3)==0
        fprintf('%e\n', vol_est{i}(step_i,t));
    end
%     if abs(vol_est-1) <0.1
%         converged = converged + 1;
%     else
%         converged = 0;
%     end
    
end

% steps(it) = num_steps;
times(it) = toc;
% phases(it) = num_phases;
% fprintf('%d dim: %d steps\n', dim, num_steps);
% vol = vol * (pi/a_sched(1))^(dim/2 - 5*(length(a_sched)-1));
end
figure;
hold on;
title(strcat('Cube volumes, dim=',num2str(dim),' phases=',num2str(num_phases)));
xlabel('Number of steps/phase');
ylabel('Volume estimate');
for i=1:trials
   plot(K*(1:num_steps)',vol_ests{it}(:,i)); 
end
plot(K*(1:num_steps)',mean(vol_ests{it}(:,:),2),'k','LineWidth',3);
drawnow;
end