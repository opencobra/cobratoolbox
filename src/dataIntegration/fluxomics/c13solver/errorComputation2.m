function [out] = errorComputation2(x, Prob)
% Computes the total C13 data-fit error (objective value) for a set of
% fluxes given the experimental data and model carried in `Prob`
%
% USAGE:
%
%    [out] = errorComputation2(x, Prob)
%
% INPUTS:
%    x:       flux vector (in null-space / alpha coordinates) at which the error is evaluated
%    Prob:    problem structure supplied by the solver, with field:
%
%               * .user - structure of user data; `.user.expdata` (experimental data) and `.user.model` (model structure) are read here
%
% OUTPUT:
%    out:     scalar C13 data-fit error; when `.user.objective` is set, the penalised linear objective is returned instead

expdata = Prob.user.expdata;
model = Prob.user.model;
out = 0;
if iscell(expdata)
    for i = 1:length(expdata)
        t = scoreC13Fit(x,expdata{i},model);
        out = out + t.error;
    end
else
    t = scoreC13Fit(x,expdata,model);
    out = t.error;
end

% if isfield(Prob.user, 'scaled')
%     out = out*Prob.user.scaled;
% end

if isfield(Prob.user, 'objective')
    error = out;
    out = Prob.user.objective'*x;
    if error > Prob.user.max_error
        out = out + Prob.user.multiplier*(Prob.user.max_error-error)^2;
    end
end

if isnan(out)
    save errorFile x Prob
end
return;
