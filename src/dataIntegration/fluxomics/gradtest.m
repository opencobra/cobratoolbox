function [out] = gradtest(v, model, expdata)
% Diagnostic that checks the finite-difference gradient of the C13 data-fit
% error by evaluating `errorComputation2_grad` over a range of step sizes
% and plotting each gradient component against the step size
%
% USAGE:
%
%    [out] = gradtest(v, model, expdata)
%
% INPUTS:
%    v:          flux vector, converted to null-space (alpha) coordinates via `model.N`
%    model:      model structure, with field:
%
%                  * .N - basis of the null space of `S`, mapping fluxes to alpha coordinates
%    expdata:    experimental data structure passed through to the gradient evaluation
%
% OUTPUT:
%    out:        declared output; the function is a plotting diagnostic and does not assign it

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