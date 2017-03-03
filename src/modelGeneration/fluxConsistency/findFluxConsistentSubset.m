function [fluxConsistentMetBool,fluxConsistentRxnBool,fluxInConsistentMetBool,fluxInConsistentRxnBool,model] = findFluxConsistentSubset(model,param,printLevel)
%finds the subset of S that is flux consistent using various algorithms,
%but fastcc from fastcore by default
%
%INPUT
% model
%    .S             m x n stoichiometric matrix
%
%OPTIONAL INPUT
% param.epsilon     (1e-4) minimum nonzero mass 
% param.modeFlag    {(0),1} 1 = return flux modes
% param.method      {'fastcc','dc'}          
% printLevel
%
%OUTPUT
% fluxConsistentMetBool            m x 1 boolean vector indicating flux consistent mets
% fluxConsistentRxnBool            n x 1 boolean vector indicating flux consistent rxns
% fluxInConsistentMetBool          m x 1 boolean vector indicating flux inconsistent mets  
% fluxInConsistentRxnBool          n x 1 boolean vector indicating flux inconsistent rxns

if ~exist('param','var')
    param.epsilon=1e-4;
    param.modeFlag=0;
    param.method='fastcc';
end

if ~isfield(param,'epsilon')
    epsilon=1e-4;
else
    epsilon=param.epsilon;
end
if ~isfield(param,'modeFlag')
    modeFlag=0;
else
    modeFlag=param.modeFlag;
end
if ~isfield(param,'method')
    method='fastcc';
else
    method=param.method;
end
if ~exist('printLevel','var')
    printLevel=1;
end

[mlt,nlt]=size(model.S);

fluxConsistentRxnBool=false(nlt,1);
    
switch method
    case 'fastcc'
        %fast consistency check code from Nikos Vlassis et al
        [indFluxConsist,~,V0]=fastcc(model,epsilon,printLevel,modeFlag,'original');
        fluxConsistentRxnBool(indFluxConsist)=1;
    case 'nonconvex'
        [indFluxConsist,V0] = fastcc(model,epsilon,printLevel,modeFlag,'nonconvex');
        fluxConsistentRxnBool(indFluxConsist)=1;
    case 'dc'
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
        
        %bound the fluxes finitely
        if ~isfinite(min(model.lb))
            model.lb(model.lb<-1/epsilon)=-1/epsilon;
        end
        if ~isfinite(min(model.ub))
            model.ub(model.ub>1/epsilon)=1/epsilon;
        end

        cardPrb.p       = 0; %size of vector x
        cardPrb.q       = nlt; %size of vector y
        cardPrb.r       = 0; %size of vector z
        cardPrb.c       = zeros(cardPrb.p+cardPrb.q+cardPrb.r,1);
        cardPrb.lambda  = 0;
        cardPrb.delta   = 1;
        cardPrb.A       = model.S;
        cardPrb.b       = model.b;
        cardPrb.csense  = repmat('E',mlt, 1);
        cardPrb.lb      = model.lb;
        cardPrb.ub      = model.ub;
        
        %Call the cardinality optimisation solver
        solutionCard = optimizeCardinality(cardPrb);
        if solutionCard.stat == 1
            stat   = 1;
            v = solutionCard.y;
            fluxConsistentRxnBool=abs(v)>=epsilon;
        else
            fprintf('%s\n','Infeasibility while testing for flux consistency.');
            stat   = 0;
            v = [];
        end
end

%metabolites exclusively involved in flux inconsistent reactions are deemed flux inconsistent also
fluxConsistentMetBool = getCorrespondingRows(model.S,true(mlt,1),fluxConsistentRxnBool,'exclusive');

fluxInConsistentMetBool=~fluxConsistentMetBool;
fluxInConsistentRxnBool=~fluxConsistentRxnBool;

model.fluxConsistentMetBool=fluxConsistentMetBool;
model.fluxConsistentRxnBool=fluxConsistentRxnBool;
model.fluxInConsistentMetBool=fluxInConsistentMetBool;
model.fluxInConsistentRxnBool=fluxInConsistentRxnBool;
end

