function [relaxRxnBool, solutionRelax] = minCardinalityConservationRelaxationVector(S, param, printLevel)
% DC programming for solving the cardinality optimization problem
%
% .. math::
%
%    min  ~& \lambda ||x||_0 \\
%    s.t. ~& x + S^T z = 0 \\
%         ~& -\infty \leq x \leq \infty, \\
%         ~& 1 \leq z \leq 1 / \epsilon
%
% USAGE:
%
%    [relaxRxnBool, solutionRelax] = minCardinalityConservationRelaxationVector(S, param, printLevel)
%
% INPUT:
%    S:                `m` x `n` stoichiometric matrix
%
% OPTIONAL INPUTS:
%    param:           structure with:
%
%                        * param.epsilon - (getCobraSolverParams('LP', 'feasTol')*100) 1/epsilon is the largest flux expected
%                        * param.eta - (`feasTol` * 100), cutoff for mass leak/siphon
%                        * param.nonRelaxBool - (false(n, 1)), `n` x 1 boolean vector for reactions not to relax
%    printLevel:       verbose level
%
% OUTPUTS:
%    relaxRxnBool:     `n` x 1 boolean vector where true correspond to relaxation
%    solutionRelax:    structure with:
%
%                        * solutionRelax.stat - solution status
%                        * solutionRelax.x - `n` x 1 vector where nonzeros>eta correspond to relaxations
%                        * solutionRelax.z - `m` x 1 vector where positives correspond to molecular mass

[mlt,nlt]=size(S');

if ~exist('param','var') || isempty(param)
    param.epsilon=getCobraSolverParams('LP', 'feasTol')*100;
    feasTol = getCobraSolverParams('LP', 'feasTol');
    param.eta=feasTol*100;
    param.nonRelaxBool=false(mlt,1);
    param.checkConsistency=0;
else
    if ~isfield(param,'epsilon')
        param.epsilon=getCobraSolverParams('LP', 'feasTol')*100;
    end
    if ~isfield(param,'eta')
        feasTol = getCobraSolverParams('LP', 'feasTol');
        param.eta=feasTol*100;
    end
    if ~isfield(param,'nonRelaxBool')
        param.nonRelaxBool=false(mlt,1);
    end
    if ~isfield(param,'checkConsistency')
        param.checkConsistency=1;
    end
end

if ~exist('printLevel','var') 
    printLevel =0;
end

if param.checkConsistency
    % Check the stoichiometric consistency of the network without relaxation by
    % solving the following linear problem
    %       min sum(m_i)
    %           s.t     S'*m = 0
    %                   m >= 1
    % where l  is is a  mx1 vector of the molecular mass of m molecular species
    cardProblem.A=S';
    cardProblem.b=zeros(size(cardProblem.A,1),1);
    cardProblem.lb=ones(size(cardProblem.A,2),1);
    cardProblem.ub=inf*ones(size(cardProblem.A,2),1);
    cardProblem.c=1*ones(size(cardProblem.A,2),1);
    cardProblem.osense=1;
    cardProblem.csense(1:size(cardProblem.A,1),1)='E';
    
    solutionRelax = solveCobraLP(cardProblem,'printLevel',printLevel);
    if solutionRelax.stat==1
        solutionRelax.z = solutionRelax.full;
        solutionRelax.x = S'*solutionRelax.z;
    end
    done=1;
else
    done=0;
end

%relaxation problem
if done==0
    cardProblem.p=mlt;
    cardProblem.q=0;
    cardProblem.r=nlt;
    cardProblem.c=zeros(nlt+mlt,1);
    if 1
        cardProblem.A=[speye(mlt,mlt),S'];
    else
        cardProblem.A=[sparse(mlt,mlt),S'];
    end
    cardProblem.b=zeros(mlt,1);
    cardProblem.lb=[-inf*ones(mlt,1);ones(nlt,1)];
    %cardProblem.lb=[zeros(mlt,1);epsilon*ones(nlt,1)];
    cardProblem.ub=[inf*ones(nlt,1);(1/param.epsilon)*ones(mlt,1)];
    %omits flux from this reaction - perhaps not a good way to do it.
    if any(param.nonRelaxBool)
        %prevent relaxation of specified reactions
        cardProblem.lb([param.nonRelaxBool;false(mlt,1)])=0;
        cardProblem.ub([param.nonRelaxBool;false(mlt,1)])=0;
    end
    cardProblem.csense(1:mlt,1)='E';
    cardProblem.lambda0=1;
    cardProblem.lambda1=getCobraSolverParams('LP', 'feasTol')*100;% sensitive to this value, 1e-4 works for Recon3Model.
    cardProblem.delta=0;
    solutionRelax = optimizeCardinality(cardProblem,param);
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
    % param                    parameters structure
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
end

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
    relaxRxnBool=abs(solutionRelax.x)>=param.eta;
    if printLevel>1
        fprintf('%g%s\n',norm(S(:,~relaxRxnBool)'*solutionRelax.z),' = ||N''*z|| (should be zero)')
    end
    if printLevel>1
        fprintf('%s\n',[int2str(nnz(relaxRxnBool)) '/' int2str(length(relaxRxnBool)) ' reactions relaxed.'])
    end
else
    disp(solutionRelax)
    error('solve for minimum cardinality of conservation relaxation vector failed')
end
