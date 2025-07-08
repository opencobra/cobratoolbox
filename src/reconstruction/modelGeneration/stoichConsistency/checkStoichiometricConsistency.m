function [isConsistent, m, model] = checkStoichiometricConsistency(model, printLevel, method)
% Verification of stoichiometric consistency by checking for at least one
% strictly positive basis in the left nullspace of `S`.
% If `S` is not stoichiometrically consistent detect conserved and unconserved
% metabolites, by returning a maximal conservation vector, which is
% a non-negative basis with as many strictly positive entries as possible.
% This omits rows of `S` that are entirely zero, when any exchange reactions
% are removed.
% The strictly positive and zero entries in `m` correspond to the conserved
% and unconserved metabolites respectively.
%
% Verification of stoichiometric consistency is as initially described in:
% `A. Gevorgyan, M. G. Poolman, and D. A. Fell
% Detection of stoichiometric inconsistencies in biomolecular
% models. Bioinformatics, 24(19):2245–2251, 2008`.
%
% Detection of conserved and unconserved metabolites based on a new
% implementation by Nikos Vlassis & Ronan Fleming.
%
% USAGE:
%
%    [isConsistent, m, model] = checkStoichiometricConsistency(model, printLevel, method)
%
% INPUT:
%    model:         structure with fields:
%
%                     * model.S - `m` x `n` stoichiometric matrix
%                     * model.mets - if exists, but `SIntRxnBool does not exist, then
%                       `findSExRxnBool` will attempt to identify exchange
%                       reactions. (optional)
%                     * model.SIntMetBool - `m` x 1 boolean vector indicating the metabolites that
%                       are thought to be exclusively involved in non-exchange
%                       reactions (optional)
%                     * model.SIntRxnBool  `n` x 1 boolean vector indicating the reactions that are
%                       thought to be non-exchange reactions. If this is not present,
%                       then we will attempt to identify such reactions,
%                       `model.rxns` exists, otherwise, we will assume all
%                       reactions are supposed to be non-exchange reactions. (optional)
%
% OPTIONAL INPUTS:
%    printLevel:    {(0), 1}
%    method:        structure with fields:
%
%                     * method.interface - {('SDCCO'),'LP', 'MILP', 'DCCO'} interface called to do the consistency check
%                     * method.solver - {(default solver as specified by CBT_LP_SOLVER), or any other CBT compatible LP solver}
%                     * method.param - solver specific parameter structure
%
% OUTPUTS:
%    isConsistent:        Solver status in standardized form:
%
%                     * 1 - Optimal solution (Stoichiometrically consistent)
%                     * 2 - Unbounded solution (Should never happen)
%                     * 0 - Infeasible (Stoichiometrically INconsistent)
%                     * -1 - No solution reported (timelimit, numerical problem etc)
%
%    m:             `m` x 1 strictly positive vector in left nullspace
%                   (empty if it does not exist)
%    model:         structure with fields:
%
%                     * .SConsistentMetBool - m x 1 boolean vector indicating metabolites involved
%                       in the maximal consistent vector
%                     * .SConsistentRxnBool - `n` x 1 boolean vector non-exchange reaction involving
%                       a stoichiometrically consistent metabolite
%
% .. Author: - Ronan Fleming   2012 initial coding
%                              2013 update with detection of conserved metabolites based on an algorithm by Nikos Vlassis.
%                              2014 update to omit trivial rows corresponding to S row that are all zero
%                              2022 interface with findStoichConsistentSubset

if ~exist('printLevel','var')
    printLevel=0;
end

resetSolver = 0;
if exist('method','var')
    if ~isfield(method,'interface')
        method.interface = 'SDCCO';
    end
    if isfield(method,'solver')
        global CBT_LP_SOLVER
        oldLPSolver = CBT_LP_SOLVER;
        resetSolver = 1;
        %set the solver and solver parameters
        solverOK = changeCobraSolver(method.solver,'LP');
    else
        global CBT_LP_SOLVER
        method.solver=CBT_LP_SOLVER;
    end
else
    method.interface='SDCCO';
    global CBT_LP_SOLVER
    method.solver=CBT_LP_SOLVER;
end



%set parameters according to feastol
feasTol = getCobraSolverParams('LP', 'feasTol');
epsilon = feasTol*10;

[nMet,nRxn]=size(model.S);

if isfield(model,'SConsistentRxnBool')
    model.SIntRxnBool=model.SConsistentRxnBool;
else
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
end

checkConsistency = 0;

if checkConsistency
    % Check the stoichiometric consistency of the network by
    % solving the following linear problem
    %       min sum(m_i)
    %           s.t     S'*m = 0
    %                   m >= 1
    % where l  is is a  mx1 vector of the molecular mass of m molecular species
    N=model.S(:,model.SIntRxnBool);
    LPproblem.A=N';
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
    isConsistent=solution.stat;
else
    isConsistent = 0;
    N=model.S(:,model.SIntRxnBool);
end


% If the network is not stoichiometrically consistent then one maximizes
% the number of  positive component of the molecular masses vector
if isConsistent~=1
    switch method.interface
        case 'none'
            warning(['Stoichiometrically INconsistent ' intR 'stoichiometry.']);
        case 'SDCCO'
            tic
            massBalanceCheck=0;
            fileName=[];
%             [SConsistentMetBool, SConsistentRxnBool, SInConsistentMetBool, SInConsistentRxnBool, unknownSConsistencyMetBool, unknownSConsistencyRxnBool, model, stoichConsistModel] =...
%                 findStoichConsistentSubset(model, massBalanceCheck, printLevel, fileName, epsilon)
             [~, ~, ~, ~, ~, ~, model, ~] = findStoichConsistentSubset(model, massBalanceCheck, printLevel,fileName, epsilon);
            %TODO
            m = 1*model.SConsistentMetBool;
            solution = [];
            timetaken=toc;
        case 'cvx'
            cvx_solver(method.solver)

            [nMet,~]=size(N);
            %maximal conservation vector
            %cvx code from Nikos Vlassis
            tic
            cvx_begin quiet

            variable m(nMet);
            variable z(nMet);

            maximize( ones(1,nMet) * z );

            z>=0; z<=epsilon;

            m>=z; m<=(1/epsilon);

            N'*m==0;

            cvx_end
            timetaken=toc;
            if any(isnan(m))
                error('NaN in maximal conservation vector')
            end
            %boolean indicating metabolites involved in the maximal consistent vector
            model.SConsistentMetBool=m>epsilon & model.SIntMetBool;
        case 'LP'


            [nMet,~]=size(N);

            % Solve the linear problem
            %   max sum(z_i)
            %       s.t S'*m = 0
            %           z <= m
            %           0 <= m <= 1/epsilon
            %           0 <= z <= epsilon
            nInt=nnz(model.SIntRxnBool);
            LPproblem.A=[N'      , sparse(nInt,nMet);
                         speye(nMet),      -speye(nMet)];

            LPproblem.b=zeros(nInt+nMet,1);

            LPproblem.lb=[zeros(nMet,1);zeros(nMet,1)];
            LPproblem.ub=[ones(nMet,1)*(1/epsilon);ones(nMet,1)*epsilon];

            LPproblem.c=zeros(nMet+nMet,1);
            LPproblem.c(nMet+1:2*nMet,1)=1;
            LPproblem.osense=-1;
            LPproblem.csense(1:nInt,1)='E';
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
                if isfield(model,'SIntMetBool') && 0
                    %boolean indicating metabolites involved in the maximal consistent vector
                    model.SConsistentMetBool=m>epsilon & model.SIntMetBool;
                else
                    %boolean indicating metabolites involved in the maximal consistent vector
                    model.SConsistentMetBool=m>epsilon;
                end
            else
                disp(solution)
                error('solve for maximal conservation vector failed')
            end

            %mosek
            algorithm=solution.algorithm;
            %change back the solver
%            solverOK = changeCobraSolver(oldSolver,'LP');
        case 'DCCO'

            tic
            [~, ~, solution] = maxCardinalityConservationVector(N);
            timetaken=toc;
            method.solver='cappedL1';
            if solution.stat==1
                m = solution.l;
                %dummy z
                z = zeros(nMet,1);
                if isfield(model,'SIntMetBool')  && 0
                    %boolean indicating metabolites involved in the maximal consistent vector
                    model.SConsistentMetBool=m>epsilon & model.SIntMetBool;
                else
                    %boolean indicating metabolites involved in the maximal consistent vector
                    model.SConsistentMetBool=m>epsilon;
                end
            else
                disp(solution)
                error('solve for maximal conservation vector failed')
            end
        case 'MILP'
            [nMet,~]=size(N);

            % Solve the MILP problem
            %   max sum(z_i)
            %       s.t S'*m = 0
            %           z <= m
            %           z binary
            nInt=nnz(model.SIntRxnBool);
            MILPproblem.A=[N'      , sparse(nInt,nMet);
                         speye(nMet),      -speye(nMet)];

            MILPproblem.b=zeros(nInt+nMet,1);

            MILPproblem.lb=[zeros(nMet,1);zeros(nMet,1)];
            MILPproblem.ub=[ones(nMet,1)*(1/epsilon);ones(nMet,1)];

            MILPproblem.c=zeros(nMet+nMet,1);
            MILPproblem.c(nMet+1:2*nMet,1)=1;
            MILPproblem.osense=-1;
            MILPproblem.csense(1:nInt,1)='E';
            MILPproblem.csense(nInt+1:nInt+nMet,1)='G';
            MILPproblem.vartype(1:nMet,1)='C';
            MILPproblem.vartype(nMet+1:nMet+nMet,1)='B';
            MILPproblem.x0 = zeros(nMet+nMet,1);

%             solverOK = changeCobraSolver('gurobi','MILP');
            %Requires the COBRA toolbox
            tic
            if isfield(method,'param')
                solution = solveCobraMILP(MILPproblem,'printLevel',printLevel-1,method.param);
            else
                solution = solveCobraMILP(MILPproblem,'printLevel',printLevel-1);
            end
            timetaken=toc;

            if solution.stat==1
                m=solution.full(1:nMet,1);
                z=solution.full(nMet+1:end,1);
                if isfield(model,'SIntMetBool')  && 0
                    %boolean indicating metabolites involved in the maximal consistent vector
                    model.SConsistentMetBool=m>epsilon & model.SIntMetBool;
                else
                    %boolean indicating metabolites involved in the maximal consistent vector
                    model.SConsistentMetBool=m>epsilon;
                end
            else
                disp(solution)
                error('solve for maximal conservation vector failed')
            end
        case 'maxEnt'
            %does not work very well
            tic
            m=maxEntConsVector(N,printLevel);
            timetaken=toc;
            if isfield(model,'SIntMetBool')  && 0
                %boolean indicating metabolites involved in the maximal consistent vector
                model.SConsistentMetBool=m>epsilon & model.SIntMetBool;
            else
                %boolean indicating metabolites involved in the maximal consistent vector
                model.SConsistentMetBool=m>epsilon;
            end
            z=zeros(nMet,1);
        otherwise
            error(['unregognised method.interface = ' method.interface]);
    end
    if any(m < -feasTol)
        error('m should be greater than or equal to zero')
    end
    m(m<0)=0;
    if printLevel>0
        if isfield(method,'param')
            fprintf('%s%s%s%s%s%s%s%g%s\n','Maximal conservation vector, using ', method.interface, ' ', method.solver,' ',algorithm,', in time ',timetaken,' sec.')
        else
            fprintf('%s%s%s%s%s%g%s\n','Maximal conservation vector, using ', method.interface, ' ', method.solver,', in time ',timetaken,' sec.')
        end
        fprintf('%10f%s\n',ones(1,nMet) * m,' = Optimal objective (i.e. 1''*m)')
        fprintf('%10d%s\n', nnz(model.SConsistentMetBool),' = Number of stoichiometrically consistent rows')
        fprintf('%10g%s\n',norm(m'*N),' = || S''*m ||_inf for non-exchange reactions of S')
    end
else
    m=solution.full;
    %The only consistent rows are those corresponding to non-exchange reactions
    model.SConsistentMetBool=model.SIntMetBool;
    if printLevel>0
        fprintf('%s\n','--- Summary of stoichiometric consistency ----')
        fprintf('%6s\t%6s\n','#mets','#rxns')
        fprintf('%6u\t%6u\t%s\n',nMet,nRxn,' totals.')
        fprintf('%6u\t%6u\t%s\n',nnz(~model.SIntMetBool),nnz(~model.SIntRxnBool),' heuristically external.')
        fprintf('%6u\t%6u\t%s\n',nnz(model.SIntMetBool),nnz(model.SIntRxnBool),' heuristically internal:')
        fprintf('%6u\t%6u\t%s\n',nnz(model.SConsistentMetBool),nnz(model.SIntRxnBool),' ... of which are stoichiometrically consistent.')
    end
end

isConsistent = all(model.SConsistentMetBool==1);

if ~isfield(model,'SConsistentRxnBool')
    
    %OLD - incorrect way July 14th 2016 - Ronan.
    % %find every non-exchange reaction involving a stoichiometrically consistent metabolite
    % model.SConsistentRxnBool =(sum(model.S(model.SConsistentMetBool,:)~=0,1)~=0)';
    % model.SConsistentRxnBool(~model.SIntRxnBool)=0;
    
    %corresponding reactions exclusively involving consistent metabolites
    model.SConsistentRxnBool = ~any(model.S(~model.SConsistentMetBool, :), 1)' & model.SIntRxnBool;
    
    model.SConsistentRxnBool = getCorrespondingCols(model.S,model.SConsistentMetBool,model.SIntRxnBool,'inclusive');

end

if resetSolver
    %reset the solver
    solverOK = changeCobraSolver(oldLPSolver,'LP');
end

