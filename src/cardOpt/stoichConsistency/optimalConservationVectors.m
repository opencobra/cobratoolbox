function solution = optimalConservationVectors(S,lambda,delta)
% DC programming for solving the cardinality optimization problem
% min    lambda*||x||_0  - delta*||y||_0
% s.t.   x + S'*y = 0
%        0 <= y <= 1e4

if ~exist('lambda','var')
    lambda=1;
end
if ~exist('delta','var')
    delta=1;
end

[mlt,nlt]=size(S');
prob.p=mlt;
prob.q=nlt;
prob.r=0;
prob.c=zeros(nlt+mlt,1);
prob.A=[speye(mlt,mlt),S'];
prob.b=zeros(mlt,1);
prob.lb=[-inf*ones(mlt,1);zeros(nlt,1)];
prob.ub=[inf*ones(nlt,1);1e4*ones(mlt,1)];
prob.csense(1:mlt,1)='E';
params.lamda=lambda;
params.delta=delta;
solution = optimizeCardinality(prob,params);
% DC programming for solving the cardinality optimization problem
% The l0 norm is approximated by capped-l1 function.
% min       c'(x,y,z) + lambda*||x||_0 - delta*||y||_0
% s.t.      A*(x,y,z) <= b
%           l <= (x,y,z) <=u
%           x in R^p, y in R^q, z in R^r
% 
% solution = optimizeCardinality(problem,params)
%
%  problem                  Structure containing the following fields describing the problem
%       p                   size of vector x
%       q                   size of vector y
%       r                   size of vector z
%       c                   (p+q+r) x 1 linear objective function vector
%       lambda              trade-off parameter of ||x||_0
%       delta               trade-off parameter of ||y||_0
%       A                   s x (p+q+r) LHS matrix
%       b                   s x 1 RHS vector
%       csense              s x 1 Constraint senses, a string containting the constraint sense for
%                           each row in A ('E', equality, 'G' greater than, 'L' less than).
%       lb                  (p+q+r) x 1 Lower bound vector
%       ub                  (p+q+r) x 1 Upper bound vector
%
% OPTIONAL INPUTS
% params                    parameters structure
%       nbMaxIteration      stopping criteria - number maximal of iteration (Defaut value = 1000)
%       epsilon             stopping criteria - (Defaut value = 10e-6)
%       theta               parameter of the approximation (Defaut value = 2)
% 
% OUTPUT
% solution                  Structure containing the following fields
%       x                   p x 1 solution vector
%       y                   q x 1 solution vector
%       z                   r x 1 solution vector
%       stat                status
%                           1 =  Solution found
%                           2 =  Unbounded
%                           0 =  Infeasible
%                           -1=  Invalid input