% Two examples to show how to solve an MILP and an LP with interior method

disp('-- Integer problem --');
s=1;
c=[-1,-1]';
a=[-2,5;2,-2];
b=[5;1];
ctype=['U','U']';
lb=[0;0]; ub=[];
vartype=['B';'B'];
param.msglev=3;
[xmin,fmin,status,extra]=glpk(c,a,b,lb,ub,ctype,vartype,s,param)
% --- OBSOLETE ---
% [xmin,fmin,status,extra]=glpkmex(s,c,a,b,ctype,lb,ub,vartype,param)
pause;

disp('3rd problem');
s=1;
c=[0 0 0 -1 -1]';
a=[-2 0 0 1 0;...
    0 1 0 0 2;...
    0 0 1 3 2];
b=[4 12 18]';
ctype=['S','S','S']';
lb=[0,0,0,0,0]'; ub=[];
vartype=['C','C','C','C','C']';
param.lpsolver=2;
[xmin,fmin,status,extra]=glpk(c,a,b,lb,ub,ctype,vartype,s,param)
% --- OBSOLETE ---
% [xmin,fmin,status,extra]=glpkmex(s,c,a,b,ctype,lb,ub,vartype)
