function solution = minCardinalityConservationRelaxationVector(S,epsilon)
% DC programming for solving the cardinality optimization problem
% min    lambda*||x||_0
% s.t.   x + S'*z = 0
%           -inf <= x <= inf
%              1 <= z <= 1/epsilon
%
%INPUT
% S         m x n stoichiometric matrix
% epsilon   smallest molecular mass considered nonzero, 1/epsilon is the
%           largest molecular mass expected
%
%OUTPUT
% solution.stat   solution status
% solution.x      n x 1 vector where nonzeros correspond to relaxations  
% solution.z      m x 1 vector where positives correspond to molecular mass


[mlt,nlt]=size(S');
cardProblem.p=mlt;
cardProblem.q=0;
cardProblem.r=nlt;
cardProblem.c=zeros(nlt+mlt,1);
cardProblem.A=[speye(mlt,mlt),S'];
cardProblem.b=zeros(mlt,1);
cardProblem.lb=[-inf*ones(mlt,1);ones(nlt,1)];
%cardProblem.lb=[zeros(mlt,1);epsilon*ones(nlt,1)];
cardProblem.ub=[inf*ones(nlt,1);(1/epsilon)*ones(mlt,1)];
cardProblem.csense(1:mlt,1)='E';
params.lambda=1;
params.delta=0;
solution = optimizeCardinality(cardProblem,params);
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