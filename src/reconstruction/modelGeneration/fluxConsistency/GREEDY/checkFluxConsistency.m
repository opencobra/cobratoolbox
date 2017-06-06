function [fluxConsistent, sol]=checkFluxConsistency(model, epsilon)
% Tries to test for flux consistent reactions in one solve
%
% USAGE:
%
%    [fluxConsistent, sol]=checkFluxConsistency(model, epsilon)
%
% INPUTS:
%    model:             cobra model structure
%    epsilon:           flux threshold
%
% OUTPUTS:
%    fluxConsistent:    empty
%    sol:               result of `solveCobraLP` function
%
% .. Author: - Ronan

S=[model.S - model.S]; % assumes all reactions are reversible

[m,n]=size(S);
Om=sparse(zeros(m,m));
On=sparse(zeros(n,n));
Omn=sparse(zeros(m,n));
Onm=sparse(zeros(n,m));
In=sparse(eye(n));

%equality constraints
A1 =[S  -S  Om Omn  Omn Omn Omn;
     On In  S' -In  On  On  On;
     In On -S'  On -In  On  On];

 %inequality constraints
A2 =[-In  On Onm On On In On;
      On -In Onm On On On In];

A=[A1;
   A2];

b=[model.b;zeros(4*n,1)];

csense=char(length(b),1);
csense(1:(m+2*n))='E';
csense((m+2*n+1):(m+4*n))='L';

c=[zeros(4*n+m,1);ones(2*n,1)];

d=1000;
lb=[zeros(2*n,1);ones(m,1)*-d;zeros(4*n,1)];

ub=[ones(2*n,1)*d;ones(m,1)*d;ones(2*n,1)*d;ones(2*n,1)*epsilon];

LPproblem.A=A;
LPproblem.b=b;
LPproblem.c=c;
LPproblem.lb=lb;
LPproblem.ub=ub;
LPproblem.osense=-1;
LPproblem.csense=csense;

sol = solveCobraLP(LPproblem);

fluxConsistent=[];

%pause(eps)
