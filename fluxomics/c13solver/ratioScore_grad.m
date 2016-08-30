function [out] = ratioScore_grad(x,Prob)
% x should be in alpha coordinates.

%expdata = Prob.user.expdata;

%model = Prob.user.model;
%N = model.N;
ration = Prob.user.ration;
ratiod = Prob.user.ratiod;

%out = (ration'*x)/(ratiod'*x);
out = ((ratiod'*x)*ration - (ration'*x)*ratiod)/(ratiod'*x)^2;

return;