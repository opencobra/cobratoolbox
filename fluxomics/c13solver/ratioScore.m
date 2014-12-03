function [out] = ratioScore(x,Prob)
% x should be in alpha coordinates.

%expdata = Prob.user.expdata;

%model = Prob.user.model;
%N = model.N;
ration = Prob.user.ration;
ratiod = Prob.user.ratiod;

out = (ration'*x)/(ratiod'*x);

return;