% A LP example which shows all the potentials of GLPKMEX
clear;

disp('LP problem');
s=-1;
c=[10,6,4]';
a=[1,1,1;...
   10,4,5;...
   2,2,6];
b=[100,600,300]';
ctype=['U','U','U']';
lb=[0,0,0]';
ub=[]';
vartype=['C','C','C']';
% Output all GLPK messages on workspace
param.msglev=3;
% Set save options
param.save=1;
param.savefilename='SimpleLP';
param.savefiletype='fixedmps';
[xmin,fmin,status,extra]=glpk(c,a,b,lb,ub,ctype,vartype,s,param)

% OBSOLETE SYNTAX
%lpsolver = param.lpsolver;
%save_pb = param.save;
%[xmin,fmin,status,extra]=glpkmex(s,c,a,b,ctype,lb,ub,vartype,param,lpsolver,save_pb)
