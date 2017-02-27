function [relaxRxnBool,solutionRelax] = minCardinalityConservationRelaxationVector(S,params,printLevel)
% DC programming for solving the cardinality optimization problem
% min    lambda*||x||_0
% s.t.   x + S'*z = 0
%           -inf <= x <= inf
%              1 <= z <= 1/epsilon
%
% INPUT
% S                     m x n stoichiometric matrix
%
% OPTIONAL INPUT
% params.epsilon        (1e-4) 1/epsilon is the largest flux expected
% params.eta            (feasTol*100), cutoff for mass leak/siphon  
% params.nonRelaxBool   (false(n,1)), n x 1 boolean vector for reactions not to relax
% 
% OUTPUT
% relaxRxnBool         n x 1 boolean vector where tru correspond to relaxation
% solutionRelax.stat   solution status
% solutionRelax.x      n x 1 vector where nonzeros>eta correspond to relaxations  
% solutionRelax.z      m x 1 vector where positives correspond to molecular mass

[mlt,nlt]=size(S');

if ~exist('params','var') || isempty(params)
    params.epsilon=1e-4;
    feasTol = getCobraSolverParams('LP', 'feasTol');
    params.eta=feasTol*100;
    params.nonRelaxBool=false(mlt,1);
else
    if ~isfield(params,'epsilon')
        params.epsilon=1e-4;
    end
    if ~isfield(params,'eta')
        feasTol = getCobraSolverParams('LP', 'feasTol');
        params.eta=feasTol*100;
    end
    if ~isfield(params,'nonRelaxBool')
        params.nonRelaxBool=false(mlt,1);
    end
end

cardProblem.p=mlt;
cardProblem.q=0;
cardProblem.r=nlt;
cardProblem.c=zeros(nlt+mlt,1);
cardProblem.A=[speye(mlt,mlt),S'];
cardProblem.b=zeros(mlt,1);
cardProblem.lb=[-inf*ones(mlt,1);ones(nlt,1)];
%cardProblem.lb=[zeros(mlt,1);epsilon*ones(nlt,1)];
cardProblem.ub=[inf*ones(nlt,1);(1/params.epsilon)*ones(mlt,1)];
%omits flux from this reaction - perhaps not a good way to do it.
if any(params.nonRelaxBool)
    %prevent relaxation of specified reactions
    cardProblem.lb([params.nonRelaxBool;false(mlt,1)])=0;
    cardProblem.ub([params.nonRelaxBool;false(mlt,1)])=0;
end
cardProblem.csense(1:mlt,1)='E';
params.lambda=1;
params.delta=0;
solutionRelax = optimizeCardinality(cardProblem,params);
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

%check optimality
if printLevel>2
    fprintf('%g%s\n',norm(solutionRelax.x + S'*solutionRelax.z),' = ||x + S''*z||')
    fprintf('%g%s\n',min(solutionRelax.z),' = min(z_i)')
    fprintf('%g%s\n',max(solutionRelax.z),' = min(z_i)')
    fprintf('%g%s\n',min(solutionRelax.x),' = min(x_i)')
    fprintf('%g%s\n',max(solutionRelax.x),' = max(x_i)')
end

if solutionRelax.stat==1
    %conserved if relaxation is below epsilon
    relaxRxnBool=abs(solutionRelax.x)>=params.eta;
    if printLevel>1
        fprintf('%g%s\n',norm(S(:,~relaxRxnBool)'*solutionRelax.z),' = ||N''*z|| (should be zero)')
    end
else
    disp(solutionRelax)
    error('solve for minimum cardinality of conservation relaxation vector failed')
end