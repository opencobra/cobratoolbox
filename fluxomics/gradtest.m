function [out] = gradtest(v, model, expdata)

v = model.N\v;

Prob.user.expdata = expdata;
Prob.user.model = model;

interval = -1:11;
for i = 1:length(interval)
    i
    Prob.user.diff_interval = 10^(-interval(i));
    grad = errorComputation2_grad(v, Prob);
    grads(i,:) = grad;
end

for i = 1:size(grads,2)
    semilogy(interval, abs(grads(:,i)));
    hold on;
end