function [inform,m,model]=checkStoichiometricConsistency(model,printLevel,method)
% Verification of stoichiometric consistency by checking for at least one
% strictly positive basis in the left nullspace of S. 
% If S is not stoichiometrically consistent detect conserved and unconserved
% metabolites, by returning a maximal conservation vector, which is 
% a non-negative basis with as many strictly positive entries as possible.
% This omits rows of S that are entirely zero, when any exchange reactions
% are removed.
% The strictly positive and zero entries in m correspond to the conserved 
% and unconserved metabolites respectively.
%
% Verification of stoichiometric consistency is as initially described in:
% A. Gevorgyan, M. G. Poolman, and D. A. Fell. 
% Detection of stoichiometric inconsistencies in biomolecular
% models. Bioinformatics, 24(19):2245–2251, 2008.
%
% Detection of conserved and unconserved metabolites based on a new
% implementation by Nikos Vlassis & Ronan Fleming.
%
% Requires the COBRA toolbox: https://github.com/opencobra/cobratoolbox.git
%
% INPUT
% model.S            m x n Stoichiometric matrix
%
% OPTIONAL INPUT
% model.mets         If exists, but SIntRxnBool does not exist, then 
%                    findSExRxnBool will attempt to identify exchange
%                    reactions.
% model.SIntRxnBool  n x 1 boolean vector indicating the reactions that are
%                    thought to be mass balanced. If this is not present,
%                    then we will attempt to identify such reactions,
%                    model.rxns exists, otherwise, we will assume all
%                    reactions are supposed to be mass balanced.
%
% printLevel         {(0),1}
% method.interface   {('solveCobraLP'),'cvx'} interface called to do the consistency check
% method.solver      {(default solver),'gurobi','mosek'} 
% method.param       solver specific parameter structure
%           
% OUTPUT
% inform                Solver status in standardized form
%                       1   Optimal solution     (Stoichiometrically consistent)
%                       2   Unbounded solution   (Should never happen)
%                       0   Infeasible           (Stoichiometrically INconsistent)
%                       -1   No solution reported (timelimit, numerical problem etc)  
%
% m                     m x 1 strictly positive vector in left nullspace 
%                       (empty if it does not exist)
% 
% model.SConsistentMetBool      m x 1 boolean vector indicating metabolites involved
%                               in the maximal consistent vector
%
% model.SConsistentRxnBool      n x 1 boolean vector non-exchange reaction involving
%                               a stoichiometrically consistent metabolite
%
%
% Ronan Fleming   2012 initial coding
%                 2013 update with detection of conserved metabolites based
%                 on algorithm by Nikos Vlassis.
%                 2014 update to omit trivial rows corresponding to S row
%                 that is all zero

if ~exist('printLevel','var')
    printLevel=0;
end
if ~exist('method','var')
    method.interface='solveCobraLP';
    global CBTLPSOLVER
    method.solver=CBTLPSOLVER;
end

[nMet,nRxn]=size(model.S);
if ~isfield(model,'mets')
    %assume all reactions are internal
    model.SIntRxnBool=true(nRxn,1);
    intR='';
else
    if ~isfield(model,'SIntRxnBool') || ~isfield(model,'SIntMetBool')
        %Requires the openCOBRA toolbox
        model=findSExRxnInd(model);
        intR='internal reaction ';
    else
        intR='';
    end
end

% Check the stoichiometric consistency of the network by
% solving the following linear problem
%       min sum(l_i)
%           s.t     S'*l = 0
%                   l_i >= 1
% where l  is is a  mx1 vector of the molecular mass of m molecular species
SInt=model.S(:,model.SIntRxnBool);
LPproblem.A=SInt';
LPproblem.b=zeros(size(LPproblem.A,1),1);
LPproblem.lb=ones(size(LPproblem.A,2),1);
LPproblem.ub=inf*ones(size(LPproblem.A,2),1);
LPproblem.c=1*ones(size(LPproblem.A,2),1);
LPproblem.osense=1;
LPproblem.csense(1:size(LPproblem.A,1),1)='E';

%Requires the openCOBRA toolbox
solution = solveCobraLP(LPproblem,'printLevel',printLevel-1);

%OUTPUT
% solution Structure containing the following fields describing a LP
% solution
%  full     Full LP solution vector
%  obj      Objective value
%  rcost    Reduced costs
%  dual     Dual solution
%  solver   Solver used to solve LP problem
%
%  stat     Solver status in standardized form
%            1   Optimal solution
%            2   Unbounded solution
%            0   Infeasible
%           -1   No solution reported (timelimit, numerical problem etc)

inform=solution.stat;
epsilon = 1e-4;
smallestM =epsilon;
largestM  =1e4;
% If the network is not stoichiometrically consistent then one maximizes
% the number of  positive component of the molecular masses vector
if inform~=1
    switch method.interface
        case 'none'
            warning(['Stoichiometrically INconsistent ' intR 'stoichiometry.']);
        case 'cvx'
            cvx_solver(method.solver) 
            
            [nMet,~]=size(SInt);
            %maximal conservation vector
            %cvx code from Nikos Vlassis
            tic
            cvx_begin quiet
            
            variable m(nMet);
            variable z(nMet);
            
            maximize( ones(1,nMet) * z );
            
            z>=0; z<=epsilon;
            
            m>=z; m<=largestM;
            
            SInt'*m==0;
            
            cvx_end
            timetaken=toc;
            if any(isnan(m))
                error('NaN in maximal conservation vector')
            end
            %boolean indicating metabolites involved in the maximal consistent vector
            model.SConsistentMetBool=m>smallestM & model.SIntMetBool;
        case 'solveCobraLP'
            %set the solver and solver parameters
            global CBTLPSOLVER
            oldSolver=CBTLPSOLVER;
            solverOK = changeCobraSolver(method.solver,'LP');
            
            
            [nMet,~]=size(SInt);
            
            % Solve the linear problem
            %   max sum(z_i)
            %       s.t S'*l = 0
            %           z <= l
            %           0 <= l <= 1e+4            
            %           0 <= z <= 1e-4
            nInt=nnz(model.SIntRxnBool);
            LPproblem.A=[SInt'      , sparse(nInt,nMet); 
                         speye(nMet),      -speye(nMet)];
            
            LPproblem.b=zeros(nInt+nMet,1);
            
            LPproblem.lb=[zeros(nMet,1);zeros(nMet,1)];
            LPproblem.ub=[ones(nMet,1)*largestM;ones(nMet,1)*epsilon];
            
            LPproblem.c=zeros(nMet+nMet,1);
            LPproblem.c(nMet+1:2*nMet,1)=1;
            LPproblem.osense=-1;
            LPproblem.csense(nInt,1)='E';
            LPproblem.csense(nInt+1:nInt+nMet,1)='G';
            
            %Requires the COBRA toolbox
            tic
            if isfield(method,'param')
                solution = solveCobraLP(LPproblem,'printLevel',printLevel-1,method.param);
            else
                solution = solveCobraLP(LPproblem,'printLevel',printLevel-1);
            end
            timetaken=toc;
            
            if solution.stat==1
                m=solution.full(1:nMet,1);
                z=solution.full(nMet+1:end,1);
                if isfield(model,'SIntMetBool')
                    %boolean indicating metabolites involved in the maximal consistent vector
                    model.SConsistentMetBool=m>smallestM & model.SIntMetBool;
                else
                    %boolean indicating metabolites involved in the maximal consistent vector
                    model.SConsistentMetBool=m>smallestM;
                end
                inform=1;
            else
                disp(solution)
                error('solve for maximal conservation vector failed')
            end
            
            %mosek
            algorithm=solution.algorithm;
            %change back the solver
            solverOK = changeCobraSolver(oldSolver,'LP');
        case 'maxEnt'
            %does not work very well
            tic
            m=maxEntConsVector(SInt,printLevel);
            timetaken=toc;
            if isfield(model,'SIntMetBool')
                %boolean indicating metabolites involved in the maximal consistent vector
                model.SConsistentMetBool=m>smallestM & model.SIntMetBool;
            else
                %boolean indicating metabolites involved in the maximal consistent vector
                model.SConsistentMetBool=m>smallestM;
            end
            z=zeros(nMet,1);
    end
    m(m<0)=0;
    if printLevel>0
        if isfield(method,'param')
            fprintf('%s%s%s%s%s%s%s%g%s\n','Maximal conservation vector, using ', method.interface, ' ', method.solver,' ',algorithm,', in time ',timetaken,' sec.')
        else
            fprintf('%s%s%s%s%s%g%s\n','Maximal conservation vector, using ', method.interface, ' ', method.solver,', in time ',timetaken,' sec.')
        end
        fprintf('%10f%s\n',ones(1,nMet) * z,' = Optimal objective (i.e. 1''*z)')
        fprintf('%10d%s\n', nnz(model.SConsistentMetBool),' = Number of stoichiometrically consistent rows')
        fprintf('%10g%s\n',norm(m'*SInt),' = || S''*m ||_inf for non-exchange reactions of S')
    end
else
    m=solution.full;
    %The only consistent rows are those corresponding to non-exchange
    %reactions
    model.SConsistentMetBool=model.SIntMetBool;
    if printLevel>0
        fprintf('%s\n',['Stoichiometrically consistent ' intR 'with respect to non-exchange reactions.']);
    end
end

%find every non-exchange reaction involving a stoichiometrically consistent metabolite
model.SConsistentRxnBool =(sum(model.S(model.SConsistentMetBool,:)~=0,1)~=0)';
model.SConsistentRxnBool(~model.SIntRxnBool)=0;



