function [out] = errorComputation2_grad(x, Prob)
% Computes the finite-difference gradient of the C13 data-fit error
% (`errorComputation2`) with respect to the fluxes `x`
%
% USAGE:
%
%    [out] = errorComputation2_grad(x, Prob)
%
% INPUTS:
%    x:       flux vector (in null-space / alpha coordinates) at which the gradient is evaluated
%    Prob:    problem structure supplied by the solver, with field:
%
%               * .user - structure of user data; `.user.model` and, when present, `.user.diff_interval` and `.user.useparfor` are read here
%
% OUTPUT:
%    out:     gradient vector of the C13 data-fit error, same size as `x`

model = Prob.user.model;
f0 = errorComputation2(x,Prob);
if length(x) == length(model.lb)
    method = 1;
else
    method = 2; % in terms of alpha
end

out = zeros(size(x));

if isfield(Prob.user, 'diff_interval')
    diff = Prob.user.diff_interval;
else
    diff = 1e-5;
end
if isfield(Prob.user, 'useparfor')
    useparfor = Prob.user.useparfor;
else
    useparfor = false;
end


if method == 2
    if useparfor
        parfor i = 1:length(x)
            xnew = x;
            tdiff = diff/norm(model.N(:,i));
            xnew(i) = xnew(i) + tdiff;
            f1 = errorComputation2(xnew, Prob);
            out(i) = (f1-f0)/tdiff;
        end
    else
        for i = 1:length(x)
            xnew = x;
            tdiff = diff/norm(model.N(:,i));
            xnew(i) = xnew(i) + tdiff;
            f1 = errorComputation2(xnew, Prob);
            out(i) = (f1-f0)/tdiff;
        end
    end
elseif method == 1
    idxzero = false(size(x));
    for i = 1:length(model.isotopomer)
        if isempty(model.isotopomer{i})
            idxzero(i) = true;
        end
    end

    if length(x) ~= length(model.lb)
        display('shoot');
        pause;
    end

    out = NaN*ones(length(x),1);
    out(idxzero) = 0;
else
    display('whoops');
    return;
end

return;