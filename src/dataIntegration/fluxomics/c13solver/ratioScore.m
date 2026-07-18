function [out] = ratioScore(x, Prob)
% Computes a flux-ratio objective `(ration'*x)/(ratiod'*x)` used when
% computing confidence intervals on flux ratios
%
% USAGE:
%
%    [out] = ratioScore(x, Prob)
%
% INPUTS:
%    x:       flux vector (in null-space / alpha coordinates)
%    Prob:    problem structure supplied by the solver, with field:
%
%               * .user - structure of user data; `.user.ration` (numerator coefficients) and `.user.ratiod` (denominator coefficients) are read here
%
% OUTPUT:
%    out:     scalar value of the flux ratio at `x`

ration = Prob.user.ration;
ratiod = Prob.user.ratiod;
% x should be in alpha coordinates.
% expdata = Prob.user.expdata;
% model = Prob.user.model;
% N = model.N;

out = (ration'*x)/(ratiod'*x);

return;
