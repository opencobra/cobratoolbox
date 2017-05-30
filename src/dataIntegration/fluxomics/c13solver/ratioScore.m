function [out] = ratioScore(x,Prob)

ration = Prob.user.ration;
ratiod = Prob.user.ratiod;
% x should be in alpha coordinates.
% expdata = Prob.user.expdata;
% model = Prob.user.model;
% N = model.N;

out = (ration'*x)/(ratiod'*x);

return;
