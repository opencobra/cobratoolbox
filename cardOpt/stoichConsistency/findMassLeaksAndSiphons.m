function [Vp,Yp,statp,Vn,Yn,statn] = findMassLeaksAndSiphons(model,metBool,rxnBool,modelBoundsFlag,params,printLevel)
% Solve the problem
% max   ||y||_0
% s.t.  Sv - y = 0
% with either
%       l <= v <= u
% or
%      -inf <= v <= inf
% and with either
%       0 <= y <= inf   (semipositive net stoichiometry)
% or 
%       -inf <= y <= 0 (seminegative net stoichiometry)
%
% If there are any zero rows of S, then the corresponding entry in y is 
% then set to zero.
%
% INPUT
% model                 (the following fields are required - others can be supplied)
%   .S                   m x n stoichiometric matrix
%   .lb                  Lower bounds
%   .ub                  Upper bounds
%
% OPTIONAL INPUT
% model
%   .SConsistentMetBool
%   .SConsistentRxnBool
% metBool               m x 1 boolean vector of metabolites to test for
%                       leakage
% modelBoundsFlag       {0,(1)} 
%                       0 = set all reaction bounds to -inf, inf
%                       1 = use reaction bounds provided by model.lb and .ub
% epsilon                1e-4, smallest nonzero reaction flux in leakage mode   
% printLevel             {(0),1}
%
% OUTPUT
%       Vp                  n x 1 vector (positive leakage modes)
%       Yp                  m x 1 vector (positive leakage modes)
%       statp               status (positive leakage modes)
%                           1 =  Solution found
%                           2 =  Unbounded
%                           0 =  Infeasible
%                           -1=  Invalid input
%       Vn                  n x 1 vector (negative leakage modes)
%       Yn                  m x 1 vector (negative leakage modes)
%       statn               status (negative leakage modes)
%                           1 =  Solution found
%                           2 =  Unbounded
%                           0 =  Infeasible
%                           -1=  Invalid input

% Ronan Fleming July 2016

[nMet,nRxn]=size(model.S);

if ~exist('metBool','var')
    metBool=true(nMet,1);
end
if ~exist('rxnBool','var')
    rxnBool=true(nRxn,1);
end
if ~exist('modelBoundsFlag','var')
    modelBoundsFlag=0;
end
if ~exist('params','var') || isempty(params)
    params.theta   = 0.5;    %parameter of capped l1 approximation
    params.epsilon = 1e-4;
    params.method = 'quasiConcave';
else  
    if isfield(params,'epsilon') == 0
        params.epsilon = 1e-4;
    end
    if isfield(params,'theta') == 0
        params.theta   = 0.5;    %parameter of capped l1 approximation
    end
    if isfield(params,'method') == 0
        params.method   = 'quasiConcave';
    end
end
if ~exist('printLevel','var')
    printLevel=0;
end

[theta,epsilon,method]=deal(params.theta,params.epsilon,params.method);

%take the subset of stoichiometry if need be
S=model.S(metBool,rxnBool);

%identify zero rows as they should not be leaking by default
zeroRows=~any(S,2);

[mlt,nlt]=size(S);

if modelBoundsFlag
    lb=model.lb;
    ub=model.ub;
else
    if 1
        lb=-inf*ones(nlt,1);
        ub= inf*ones(nlt,1);
    else
        lb=-(1/epsilon)*ones(nlt,1);
        ub= (1/epsilon)*ones(nlt,1);
    end
end
        
feasTol=getCobraSolverParams('LP','feasTol');

%method='quasiConcave';
%method='dc';
switch method
    case 'quasiConcave' %not really working yet it seems      
        % Solve the linear problem
        %   max sum(z_i)
        %       s.t S*v + p = 0
        %           z <= p
        %          lb <= v <= ub
        %           0 <= p <= inf %inf seems to help keep the problem feasible
        %           0 <= z <= epsilon
        LPproblem.A=[S              , speye(mlt), sparse(mlt,mlt);
                     sparse(mlt,nlt), speye(mlt),-speye(mlt)];
        
        LPproblem.b=zeros(size(LPproblem.A,1),1);
        
        LPproblem.lb=[lb;            zeros(mlt,1); zeros(mlt,1)];
        LPproblem.ub=[ub; inf*ones(mlt,1);  epsilon*ones(mlt,1)];
        
        LPproblem.c=zeros(size(LPproblem.A,2),1);
        LPproblem.c(nlt+mlt+1:nlt+2*mlt,1)=1;%maximise z
        LPproblem.osense=-1;%maximisation
        LPproblem.csense(1:mlt,1)='E';
        LPproblem.csense(mlt+1:mlt+mlt,1)='G';
        
        solp = solveCobraLP(LPproblem,'printLevel',printLevel);
        if printLevel>0
            fprintf('%6u\t%6u\t%s%s%s\n',mlt,nlt,' subset tested for leakage (', method,' method)...');
        end
        if solp.stat == 1
            statp   = 1;
            Vp=sparse(nRxn,1);
            Yp=sparse(nMet,1);
            Vp(rxnBool) = solp.full(1:nlt);
            tmp = solp.full(nlt+1:nlt+mlt);
            tmp(zeroRows)=0;%ignore zero rows
            Yp(metBool) = tmp;
            
            if printLevel>0
                fprintf('%6u\t%6u\t%s\n',nnz(Yp>=epsilon),NaN,' semipositive leaking metabolites.');
            end
        else
            fprintf('%s\n','Infeasibility while detecting semipositive leaking metabolites.');
            Vp=[];
            Yp=[];
            statp=[];
        end
        
        LPproblem_neg=LPproblem;
        LPproblem_neg.A=[S              , -speye(mlt), sparse(mlt,mlt);
                         sparse(mlt,nlt), speye(mlt),-speye(mlt)];
                     
        soln = solveCobraLP(LPproblem_neg,'printLevel',printLevel-1);
        
        if soln.stat == 1
            statn   = 1;
            Vn=sparse(nRxn,1);
            Yn=sparse(nMet,1);
            Vn(rxnBool) = soln.full(1:nlt);
            tmp = soln.full(nlt+1:nlt+mlt);
            tmp(zeroRows)=0;%ignore zero rows
            Yn(metBool) = tmp;
            if printLevel>0
                fprintf('%6u\t%6u\t%s\n',nnz(Yn>=epsilon),NaN,' seminegative leaking metabolites.');
            end
        else
            fprintf('%s\n','Infeasibility while detecting seminegative leaking metabolites.');
            Vn=[];
            Yn=[];
            statn=[];
        end             
    case 'dc'
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
        
        %Define the optimisation problem
        cardPrb.p       = 0;
        cardPrb.q       = mlt;
        cardPrb.r       = nlt;
        cardPrb.c       = zeros(cardPrb.p+cardPrb.q+cardPrb.r,1);
        cardPrb.lambda  = 0;
        cardPrb.delta   = 1;
        cardPrb.A       = [-speye(mlt) S];
        cardPrb.b       = zeros(mlt,1);
        cardPrb.csense  = repmat('E',mlt, 1);
                
        cardPrb.lb      = [zeros(mlt,1)-feasTol;lb];%helps keep the problem feasible
        cardPrb.ub      = [(1/epsilon)*ones(mlt,1);ub];
        if printLevel>0
            fprintf('%6u\t%6u\t%s%s%s\n',mlt,nlt,' subset tested for leakage (', method,' method)...');
        end
        %Call the cardinality optimisation solver for semipositive
        solutionCardp = optimizeCardinality(cardPrb);
        if solutionCardp.stat == 1
            statp   = 1;
            Vp=sparse(nRxn,1);
            Yp=sparse(nMet,1);
            Vp(rxnBool) = solutionCardp.z;
            tmp = solutionCardp.y;
            tmp(zeroRows)=0;%ignore zero rows
            Yp(metBool) = tmp;
            if printLevel>0
                %fprintf('%6u\t%6u\t%s\n',mlt,nlt,' subset tested for leakage...');
                fprintf('%6u\t%6u\t%s\n',nnz(Yp>=epsilon),NaN,' semipositive leaking metabolites.');
            end
        else
            Vp=[];
            Yp=[];
            statp=[];
        end
        
        %seminegative change matrix rather than bounds
        cardPrb.A       = [speye(mlt) S];
        %Call the cardinality optimisation solver
        solutionCardn = optimizeCardinality(cardPrb);
        
        if solutionCardn.stat == 1
            statn   = 1;
            
            Vn=sparse(nRxn,1);
            Yn=sparse(nMet,1);
            Vn(rxnBool) = solutionCardn.z;
            tmp = solutionCardn.y;
            tmp(zeroRows)=0;%ignore zero rows
            Yn(metBool) = tmp;
            if printLevel>0
                fprintf('%6u\t%6u\t%s\n',nnz(Yn>=epsilon),NaN,' seminegative leaking metabolites.');
            end
        else
            Vn=[];
            Yn=[];
            statn=[];
        end
end