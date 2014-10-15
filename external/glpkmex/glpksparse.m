% A LP example which defines A as a sparse matrix

disp('Solve problem with sparse matrix');
s=1;
c=[0 0 0 -1 -1]';
a=sparse([-2 0 0 1 0;...
    0 1 0 0 2;...
    0 0 1 3 2]);
b=[4 12 18]';
ctype=['S','S','S']';
lb=[0,0,0,0,0]'; ub=[];
vartype=['C','C','C','C','C']';
param.msglev=3;
param.lpsolver=2;

[xmin,fmin,status,extra]=glpk(c,a,b,lb,ub,ctype,vartype,s,param)

%[xmin,fmin,status,extra]=glpkmex(s,c,a,b,ctype,lb,ub,vartype,param,lpsolver)
