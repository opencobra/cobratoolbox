function [out] = ratioScore_grad(x, Prob)
% Computes the analytical gradient of the flux-ratio objective evaluated by
% `ratioScore`, with respect to the fluxes `x`
%
% USAGE:
%
%    [out] = ratioScore_grad(x, Prob)
%
% INPUTS:
%    x:       flux vector (in null-space / alpha coordinates)
%    Prob:    problem structure supplied by the solver, with field:
%
%               * .user - structure of user data; `.user.ration` (numerator coefficients) and `.user.ratiod` (denominator coefficients) are read here
%
% OUTPUT:
%    out:     gradient vector of the flux ratio at `x`, same size as `x`

ration = Prob.user.ration;
ratiod = Prob.user.ratiod;
% x should be in alpha coordinates.
% expdata = Prob.user.expdata;
% model = Prob.user.model;
% N = model.N;

%out = (ration'*x)/(ratiod'*x);
out = ((ratiod'*x)*ration - (ration'*x)*ratiod)/(ratiod'*x)^2;

return;
