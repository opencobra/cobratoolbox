function v = checkThermodynamicConsistency(model,q)
%
S=model.S;
[m,n]=size(S);

if ~exist('q','var')
    Q=speye(n,n);
else
    Q=spdiag(q,0,n,n);
end

if isfield(model,'b')
    Sb=model.b;
else
    Sb=sparse(m,1);
end

bool=model.c~=0;
if nnz(bool)>1
    error('biomass reaction assumed to be the non-zero entry of model.c')
end

FBAsolution = optimizeCbModel(model);
fprintf('%s%g\n','Biomass flux, should be non-zero: ',FBAsolution.x(bool))

%require 100th of the FBA optimal biomass flux
model.lb(bool)=FBAsolution.x(bool)*0.001;

% solution = solveCobraLP(LPproblem, parameters)
%
%INPUT
% LPproblem Structure containing the following fields describing the LP
% problem to be solved
%  A      LHS matrix
%  b      RHS vector
%  c      Objective coeff vector
%  lb     Lower bound vector
%  ub     Upper bound vector
%  osense Objective sense (-1 max, +1 min)
%  csense Constraint senses, a string containting the constraint sense for
%         each row in A ('E', equality, 'G' greater than, 'L' less than).

Omn=sparse(m,n);
Onn=sparse(n,n);
Inn=speye(n,n);

A=[S*Q*S'  Omn  Omn;
     Q*S' -Inn  Onn;
     Q*S'  Onn  Inn];
 
b=[Sb;
   model.lb;
   model.ub];

bignum=100000;

lb=[-ones(m,1)*bignum;
    sparse(2*n,1)];

ub=ones(m+2*n,1)*bignum;

LPproblem.A=A;
LPproblem.b=b;
LPproblem.lb=lb;
LPproblem.ub=ub;

LPproblem.csense(1:m+2*n,1)='E';
LPproblem.c=ones(m+2*n,1);
LPproblem.osense=-1;

sol = solveCobraLP(LPproblem);

x=sol.full;
v=S'*x(1:m);

if norm(v)>0
    disp(norm(v))
    fprintf('%s\n','Thermodynamically consistent flux producing biomass exists.')
else
    fprintf('%s\n','For this Q, no thermodynamically consistent production of biomass exists.')
end

