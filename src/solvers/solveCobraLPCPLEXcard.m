function [solution,LPProblem]=solveCobraLPCPLEXcard(LPProblem,printLevel,basisReuse,conflictResolve,contFunctName,minNorm,theNorm)
% [solution,LPProblem]=solveCobraLPCPLEX(LPProblem,printLevel,basisReuse,conflictResolve,contFunctName,minNorm)
% call CPLEX to solve an LP problem
% By default, use the matlab interface to cplex written by TOMLAB, in
% preference to the one written by ILOG.
%
%INPUT
% LPproblem Structure containing the following fields describing the LP
% problem to be solved
%  A or S       m x n LHS matrix
%  b            m x 1 RHS vector
%  c            n x 1 Objective coeff vector
%  lb           n x 1 Lower bound vector
%  ub           n x 1 Upper bound vector
%  osense       scalar Objective sense (-1 max, +1 min)
%
%OPTIONAL INPUT
% LPProblem.rxns    cell array of reaction abbreviations (necessary for
%                   making a readable confilict resolution file).
% LPProblem.csense  Constraint senses, a string containting the constraint sense for
%                   each row in A ('E', equality, 'G' greater than, 'L' less than).
%
% LPProblem.LPBasis Basis from previous solution of similar LP problem.
%                   See basisReuse
%
% PrintLevel    Printing level in the CPLEX m-file and CPLEX C-interface.
%               = 0    Silent
%               = 1    Warnings and Errors
%               = 2    Summary information (Default)
%               = 3    More detailed information
%               > 10   Pause statements, and maximal printing (debug mode)
%
% basisReuse = 0   Use this for one of soluion of an LP (Default)
%            = 1   Returns a basis for reuse in the next LP
%                  i.e. outputs LPProblem.LPBasis
%
% conflictResolve  = 0   (Default)
%                  = 1   If LP problem is proven to be infeasible by CPLEX,
%                        it will print out a 'conflict resolution file',
%                        which indicates the irreducible infeasible set of
%                        equaltiy & inequality constraints that together,
%                        combine to make the problem infeasible. This is
%                        useful for debugging an LP problem if you want to
%                        try to resolve a constraint conflict
%
% contFunctName        = [] Use all default CLPEX control parameters, (Default)
%                      = someString e.g. 'someFunctionName'
%                        uses the user specified control parameters defined
%                        in someFunctionName.m
%                       (see template function CPLEXParamSet for details).
%                      = cpxControl structure (output from a file like CPLEXParamSet.m)
%
% minNorm       {(0), 1 , n x 1 vector} If not zero then, minimise the Euclidean length
%               of the solution to the LP problem. Gives the same objective,
%               but minimises the square of flux. minNorm ~1e-6 should be
%               high enough for regularisation yet keep the same objective
%
% theNorm       {'zero','one',('two')} Controls which norm is minimized.
%                'zero' minimizes cardinality for nonzero entries in minNorm
%                'one'  minimizes taxicab norm for nonzero entries in
%                minNorm (not implemented)
%                'two'  minimizes Euclidean norm for nonzero entries in minNorm (default)
%
%OUTPUT
% solution Structure containing the following fields describing a LP
% solution
%  full         Full LP solution vector
%  obj          Objective value
%  rcost        Lagrangian multipliers to the simple inequalties (Reduced costs)
%  dual         Lagrangian multipliers to the equalities
%  nInfeas      Number of infeasible constraints
%  sumInfeas    Sum of constraint violation
%  stat         COBRA Standardized solver status code:
%               1   Optimal solution
%               2   Unbounded solution
%               0   Infeasible
%               -1  No solution reported (timelimit, numerical problem etc)
%  origStat     CPLEX status code. Use cplexStatus(solution.origStat) for
%               more information from the CPLEX solver
%  solver       solver used by cplex
%  time         time taken to solve the optimization problem
%
%OPTIONAL OUTPUT
% LPProblem.LPBasis When input basisReuse=1, we return a basis for reuse in
%                   the next LP
%
% CPLEX consists of 4 different LP solvers which can be used to solve sysbio optimization problems
% you can control which of the solvers, e.g. simplex vs interior point solver using the
% CPLEX control parameter cpxControl.LPMETHOD. At the moment, the solver is
% automatically chosen for you
%

% Ronan Fleming 10 June 08
%               20 Mar  09  min norm can be specific to each variable
%               12 Jul  09  more description of basis reuse
%               23 Oct  09  ILOG-CPLEX matlab simple interface by default
%                           See solveCobraCPLEX for full control of CPLEX
%                           12.1 via API
% Ronan Fleming 31 Oct  13  Added minimization of cardinality

if ~exist('printLevel','var')
    printLevel=0;
end
if ~exist('basisReuse','var')
    basisReuse=0;
end
if ~exist('conflictResolve','var')
    conflictResolve=0;
end
if ~exist('contFunctName','var')
    cpxControl=[];
else
    if isstruct(contFunctName)
        cpxControl=contFunctName;
    else
        if ~isempty(contFunctName)
            %calls a user specified function to create a CPLEX control structure
            %specific to the users problem. A TEMPLATE for one such function is
            %CPLEXParamSet
            cpxControl=eval(contFunctName);
        else
            cpxControl=[];
        end
    end
end
if ~exist('minNorm','var')
    minNorm=0;
end
if ~exist('theNorm','var')
    theNorm='two';
end

if basisReuse
    if isfield(LPProblem,'LPBasis')
        basis=LPProblem.LPBasis;
        %use advanced starting information when optimization is initiated.
        cpxControl.ADVIND=1;
    else
        basis=[];
    end
else
    basis=[];
    %do not use advanced starting information when optimization is initiated.
    cpxControl.ADVIND=0;
end

if ~isfield(LPProblem,'A')
    if ~isfield(LPProblem,'S')
        error('Equality constraint matrix must either be a field denoted A or S.')
    end
    LPProblem.A=LPProblem.S;
end

if ~isfield(LPProblem,'csense')
    nMet=size(LPProblem.A);
    if printLevel>0
        fprintf('%s\n','Assuming equality constraints, i.e. S*v=b');
    end
    %assuming equality constraints
    LPProblem.csense(1:nMet,1)='E';
end

if ~isfield(LPProblem,'osense')
    %assuming maximisation
    LPProblem.osense=-1;
    if printLevel>0
        fprintf('%s\n','Assuming maximisation of objective');
    end
end

if size(LPProblem.A,2)~=length(LPProblem.c)
    error('dimensions of A & c are inconsistent');
end

if size(LPProblem.A,2)~=length(LPProblem.lb) || size(LPProblem.A,2)~=length(LPProblem.ub)
    error('dimensions of A & bounds are inconsistent');
end

%get data
[c,x_L,x_U,b,csense,osense] = deal(LPProblem.c,LPProblem.lb,LPProblem.ub,LPProblem.b,LPProblem.csense,LPProblem.osense);
%modify objective to correspond to osense
c=full(c*osense);

%cplex expects it dense
b=full(b);
%Conflict groups descriptor (cpxBuildConflict can be used to generate the input). Set this if
%conflict refinement is desired in the case that infeasibility is detected
%by CPLEX.
if conflictResolve
    [m_lin,n]=size(LPProblem.A);
    m_quad=0;
    m_sos=0;
    m_log=0;
    %determines how elaborate the output is
    mode='full';%'minimal';
    fprintf('%s\n%s\n','Building Structure for Conflict Resolution...','...this slows CPLEX down so should not be used for repeated LP');
    confgrps = cpxBuildConflict(n,m_lin,m_quad,m_sos,m_log,mode);
    prefix=pwd;
    suffix='LP_CPLEX_conflict_file.txt';
    conflictFile=[prefix '\' suffix];
else
    confgrps=[]; conflictFile=[];
end

%Name of file to write the CPLEX log information to. If empty, no log is
%written.
logfile=[];

%Name of a file to save the CPLEX problem object (Used for submitting
%possible bugs in CPLEX to ILOG)
savefile=[]; savemode=[];
% savefile='C:\CPLEX_possible_bug.txt';

% vector defining which callbacks to use in CPLEX. If the ith entry of the logical vector
% callback is set, the corresponding callback is defined. The callback calls the m-file specified
% in Table 7 below. The user may edit this file, or make a new copy, which is put in a directory
% that is searched before the cplex directory in the Matlab path.
callback=[]; %I'm not really sure what this option means as yet

%this is not a tomlab problem so this is not needed
Prob=[];

% variables not used in LP problems
IntVars=[]; PI=[]; SC=[]; SI=[]; sos1=[]; sos2=[];

%quadratic constraint matrix, size n x n
switch theNorm
    case 'zero'
        %cardinality optimized only over nonzero entries
        if length(minNorm)==1
            if minNorm>=0
                % same weighting of min norm for all variables
                cardVector = ones(length(c),1);
            else
                % same weighting of min norm for all variables
                cardVector = -ones(length(c),1);
            end
        else
            if length(minNorm)~=length(c)
                error('Either minNorm is a scalar, or is an n x 1 vector')
            else
                if 0
                    %same weighting
                    cardVector = (minNorm~=0)+0;
                else
                    %TODO
                    %individual weighting of cardinality for all variables
                    %perhaps it is not a simple as this.
                    cardVector = minNorm;
                end
                if sign(max(cardVector(cardVector~=0)))~=sign(min(cardVector(cardVector~=0)))
                    error('mixing maximization and minimization of cardinality not implemented')
                end
            end
        end
        F=[];
    case 'one'
        error('not yet implemented')
    case 'two'
        if sum(minNorm)~=0
            if length(minNorm)==1
                % same weighting of min norm for all variables
                F=speye(length(c))*minNorm;
            else
                if length(minNorm)~=length(c)
                    error('Either minNorm is a scalar, or is an n x 1 vector')
                else
                    % individual weighting of min norm for all variables
                    F=spdiags(minNorm,0,length(c),length(c));
                end
            end
            cardVector=[];
        else
            cardVector=[];
            F=[];
        end
end

%Structure array defining quadratic constraints
qc=[];

%Structure telling whether and how you want CPLEX to perform a sensitivity analysis (SA).
%This may be useful in future but probably will have more meaning with an
%additional term in the objective
saRequest =[];

%Vector with MIP starting solution, if known
xIP=[];

%Logical constraints, i.e. an additional set of single-sided linear constraints that are controlled
%by a binary variable (switch) in the problem
logcon=[];

%call cplex
tic;
%by default use the complex ILOG-CPLEX interface as it seems to be faster
%IBM(R) ILOG(R) CPLEX(R) Interactive Optimizer 12.5.1.0
ILOGcomplex=1;

tomlab_cplex=0; %by default use the complex ilog interface instead of the tomlab_cplex interface

if ~isempty(which('cplexlp')) && tomlab_cplex==0
    if ILOGcomplex
        if isempty(cardVector)
            %complex ibm ilog cplex interface
            if ~isempty(csense)
                %set up constant vectors for CPLEX
                b_L(csense == 'E',1) = b(csense == 'E');
                b_U(csense == 'E',1) = b(csense == 'E');
                b_L(csense == 'G',1) = b(csense == 'G');
                b_U(csense == 'G',1) = Inf;
                b_L(csense == 'L',1) = -Inf;
                b_U(csense == 'L',1) = b(csense == 'L');
            else
                b_L = b;
                b_U = b;
            end
            
            % Initialize the CPLEX object
            try
                ILOGcplex = Cplex('fba');
            catch ME
                error('CPLEX not installed or licence server not up')
            end
            
            if osense==1
                ILOGcplex.Model.sense = 'minimize';
            else
                ILOGcplex.Model.sense = 'maximize';
            end
            
            % Now populate the problem with the data
            ILOGcplex.Model.obj   = -c;
            ILOGcplex.Model.lb    = x_L;
            ILOGcplex.Model.ub    = x_U;
            ILOGcplex.Model.A     = LPProblem.A;
            ILOGcplex.Model.lhs   = b_L;
            ILOGcplex.Model.rhs   = b_U;
            
            if ~isempty(F)
                %quadratic constraint matrix, size n x n
                ILOGcplex.Model.Q=F;
            end
            
            if ~isempty(cpxControl)
                if isfield(cpxControl,'LPMETHOD')
                    %set the solver
                    ILOGcplex.Param.lpmethod.Cur=cpxControl.LPMETHOD;
                end
            end
            
            if printLevel==0
                ILOGcplex.DisplayFunc=[];
            else
                %print level
                ILOGcplex.Param.barrier.display.Cur = printLevel;
                ILOGcplex.Param.simplex.display.Cur = printLevel;
                ILOGcplex.Param.sifting.display.Cur = printLevel;
            end
            
            % Optimize the problem
            ILOGcplex.solve();
            
            solution.obj        = osense*ILOGcplex.Solution.objval;
            solution.full       = ILOGcplex.Solution.x;
            solution.rcost      = ILOGcplex.Solution.reducedcost;
            solution.dual       = ILOGcplex.Solution.dual;
            solution.nInfeas    = NaN;
            solution.sumInfeas  = NaN;
            %solution.stat       = ILOGcplex.Solution.
            solution.origStat   = ILOGcplex.Solution.status;
            solution.solver     = ILOGcplex.Solution.method;
            solution.time       = ILOGcplex.Solution.time;
        else
            %approximation of cardinality optimization -Ronan
            %complex ibm ilog cplex interface
            if ~isempty(csense)
                %set up constant vectors for CPLEX
                b_L(csense == 'E',1) = b(csense == 'E');
                b_U(csense == 'E',1) = b(csense == 'E');
                b_L(csense == 'G',1) = b(csense == 'G');
                b_U(csense == 'G',1) = Inf;
                b_L(csense == 'L',1) = -Inf;
                b_U(csense == 'L',1) = b(csense == 'L');
            else
                b_L = b;
                b_U = b;
            end
            
            % Initialize the CPLEX object
            try
                ILOGcplex = Cplex('fba');
            catch ME
                error('CPLEX not installed or licence server not up')
            end
                        if osense==1
                ILOGcplex.Model.sense = 'minimize';
            else
                ILOGcplex.Model.sense = 'maximize';
            end
       %     ILOGcplex.Model.sense = 'minimize';
            
            % Now populate the problem with the data
            ILOGcplex.Model.obj   = c;
            ILOGcplex.Model.lb    = x_L;
            ILOGcplex.Model.ub    = x_U;
            ILOGcplex.Model.A     = LPProblem.A;
            ILOGcplex.Model.lhs   = b_L;
            ILOGcplex.Model.rhs   = b_U;
            
            if ~isempty(F)
                %quadratic constraint matrix, size n x n
                ILOGcplex.Model.Q=F;
            end
            
            if ~isempty(cpxControl)
                if isfield(cpxControl,'LPMETHOD')
                    %set the solver
                    ILOGcplex.Param.lpmethod.Cur=cpxControl.LPMETHOD;
                end
            end
            
            if printLevel==0
                ILOGcplex.DisplayFunc=[];
            else
                %print level
                ILOGcplex.Param.barrier.display.Cur = printLevel;
                ILOGcplex.Param.simplex.display.Cur = printLevel;
                ILOGcplex.Param.sifting.display.Cur = printLevel;
            end
            
            % Optimize the problem
            ILOGcplex.solve();
            
            solution.obj        = osense*ILOGcplex.Solution.objval
            solution.full       = ILOGcplex.Solution.x;
            solution.rcost      = ILOGcplex.Solution.reducedcost;
            solution.dual       = ILOGcplex.Solution.dual;
            solution.nInfeas    = NaN;
            solution.sumInfeas  = NaN;
            %solution.stat       = ILOGcplex.Solution.
            solution.origStat   = ILOGcplex.Solution.status;
            solution.solver     = ILOGcplex.Solution.method;
            solution.time       = ILOGcplex.Solution.time;
            
            %maximise cardinality
            if sum(cardVector)<0
                %second solve, with optimal value of first objective
                epsilon    = 1e-3; 
                zeroCutoff = 1e-6;
                %largestV = 1e2;
                beta=1-1e-8; % how close to previous optima is required
                
                A=LPProblem.A;
                [mlt,nlt]=size(A);
                
                %pad out constraint matrix with the dummy vector
                A2 = [         A,   sparse(mlt,nlt);
                    speye(nlt),      -speye(nlt)];
                
                %pad out the rhs
                b_L2 = [b_L;zeros(nlt,1)];
                b_U2 = [b_U;inf*ones(nlt,1)];
                %b_L2 = [b_L;-inf*ones(nlt,1)];
                %b_U2 = [b_U;    zeros(nlt,1)];
                
                %expecting v_i for all |v_i| to be non-negative
                %e.g. exchanges supposed to be non-negative, when maximising
                %cardinality over all exchange reactions
                x_L2 = [x_L; zeros(nlt,1)];
                x_U2 = [x_U; ones(nlt,1)*epsilon];
                %replace the original objective with a lower bound created from
                %FBA, then add the cardinality minimization
                originalObjectiveIndex=find(c~=0);
                x_L2(originalObjectiveIndex)= solution.obj*beta;
                c2   = [zeros(nlt,1);cardVector];
                
                % Initialize the CPLEX object
                try
                    ILOGcplex2 = Cplex('fba');
                catch ME
                    error('CPLEX not installed or licence server not up')
                end
                
                ILOGcplex2.Model.sense = 'minimize';
                
                % Now populate the problem with the data
                ILOGcplex2.Model.obj   = c2;
                ILOGcplex2.Model.lb    = x_L2;
                ILOGcplex2.Model.ub    = x_U2;
                ILOGcplex2.Model.A     = A2;
                ILOGcplex2.Model.lhs   = b_L2;
                ILOGcplex2.Model.rhs   = b_U2;
                
                if ~isempty(cpxControl)
                    if isfield(cpxControl,'LPMETHOD')
                        %set the solver
                        ILOGcplex2.Param.lpmethod.Cur=cpxControl.LPMETHOD;
                    end
                end
                
                if printLevel==0
                    ILOGcplex2.DisplayFunc=[];
                else
                    %print level
                    ILOGcplex2.Param.barrier.display.Cur = printLevel;
                    ILOGcplex2.Param.simplex.display.Cur = printLevel;
                    ILOGcplex2.Param.sifting.display.Cur = printLevel;
                end
                
                % Optimize the problem
                ILOGcplex2.solve();
                
                %Relative difference between objectives
                %disp((solution.obj-ILOGcplex2.Solution.x(originalObjectiveIndex))/solution.obj)
                
                solution.obj        = ILOGcplex.Solution.x'*c;
                solution.cardObj    = ILOGcplex2.Solution.x'*c2;
                solution.full       = ILOGcplex2.Solution.x(1:nlt,1);
                solution.rcost      = ILOGcplex2.Solution.reducedcost(1:nlt,1);
                solution.dual       = ILOGcplex2.Solution.dual(1:mlt,1);
                solution.nInfeas    = NaN;
                solution.sumInfeas  = NaN;
                %solution.stat       = ILOGcplex.Solution.
                solution.origStat   = ILOGcplex2.Solution.status;
                solution.solver     = ILOGcplex2.Solution.method;
                solution.time       = ILOGcplex2.Solution.time;
                solution.cardinality = nnz(ILOGcplex2.Solution.x(1:nlt,1)>zeroCutoff);
            else
                %L1 approximation to cardinality minimisation
                %second solve, with optimal value of first objective
                zeroCutoff = 1e-6;
                beta=1-1e-8; % how close to previous optima is required
                
                %replace the original objective with a lower bound created from FBA
                originalObjectiveIndex=find(c~=0);
                x_L2=x_L;
                x_L2(originalObjectiveIndex)= solution.obj*beta;
                %add the approximation to cardinality minimization
                c2=c;
                c2(originalObjectiveIndex)=0;
                c2(cardVector~=0)=1;
                
                % Initialize the CPLEX object
                try
                    ILOGcplex2 = Cplex('fba');
                catch ME
                    error('CPLEX not installed or licence server not up')
                end
                
                ILOGcplex2.Model.sense = 'minimize';
                
                % Now populate the problem with the modified data
                % If irreversible model
                if isfield(LPProblem,'reversibleModel') && LPProblem.reversibleModel == 0
                    ILOGcplex2.Model.obj   = c2;
                else
                    % reversible model
                    ILOGcplex2.Model.obj   = -c2;
                end
                ILOGcplex2.Model.lb    = x_L2;
                ILOGcplex2.Model.ub    = x_U;
                ILOGcplex2.Model.A     = LPProblem.A;
                ILOGcplex2.Model.lhs   = b_L;
                ILOGcplex2.Model.rhs   = b_U;
                
                if ~isempty(cpxControl)
                    if isfield(cpxControl,'LPMETHOD')
                        %set the solver
                        ILOGcplex2.Param.lpmethod.Cur=cpxControl.LPMETHOD;
                    end
                end
                
                if printLevel==0
                    ILOGcplex2.DisplayFunc=[];
                else
                    %print level
                    ILOGcplex2.Param.barrier.display.Cur = printLevel;
                    ILOGcplex2.Param.simplex.display.Cur = printLevel;
                    ILOGcplex2.Param.sifting.display.Cur = printLevel;
                end
                
                % Optimize the problem
                ILOGcplex2.solve();
                
                %Relative difference between objectives
                %disp((solution.obj-ILOGcplex2.Solution.x(originalObjectiveIndex))/solution.obj)
                
                solution.obj        = -ILOGcplex.Solution.x'*c;
                solution.cardObj    = ILOGcplex2.Solution.x'*c2;
                solution.full       = ILOGcplex2.Solution.x;
                solution.rcost      = ILOGcplex2.Solution.reducedcost;
                solution.dual       = ILOGcplex2.Solution.dual;
                solution.nInfeas    = NaN;
                solution.sumInfeas  = NaN;
                %solution.stat       = ILOGcplex.Solution.
                solution.origStat   = ILOGcplex2.Solution.status;
                solution.solver     = ILOGcplex2.Solution.method;
                solution.time       = ILOGcplex2.Solution.time;
                solution.cardinality = nnz(ILOGcplex2.Solution.x(cardVector~=0)>zeroCutoff);
            end
        end
    else
        try
            ILOGcplex = Cplex('fba');
        catch ME
            error('CPLEX not installed or licence server not up')
        end
        %simple ibm ilog cplex interface
        options = cplexoptimset;
        switch printLevel
            case 0
                options = cplexoptimset(options,'Display','off');
            case 1
                options = cplexoptimset(options,'Display','off');
            case 1
                options = cplexoptimset(options,'Display','off');
            case 1
                options = cplexoptimset(options,'Display','off');
        end
        
        if ~isempty(csense)
            if sum(minNorm)~=0
                Aineq = [LPProblem.A(csense == 'L',:); - LPProblem.A(csense == 'G',:)];
                bineq = [b(csense == 'L',:); - b(csense == 'G',:)];
                %             min      0.5*x'*H*x+f*x or f*x
                %             st.      Aineq*x     <= bineq
                %             Aeq*x    = beq
                %             lb <= x <= ub
                [x,fval,exitflag,output,lambda] = cplexqp(F,c,Aineq,bineq,LPProblem.A(csense == 'E',:),b(csense == 'E',1),x_L,x_U,[],options);
            else
                Aineq = [LPProblem.A(csense == 'L',:); - LPProblem.A(csense == 'G',:)];
                bineq = [b(csense == 'L',:); - b(csense == 'G',:)];
                %        min      c*x
                %        st.      Aineq*x <= bineq
                %                 Aeq*x    = beq
                %                 lb <= x <= ub
                [x,fval,exitflag,output,lambda] = cplexlp(c,Aineq,bineq,LPProblem.A(csense == 'E',:),b(csense == 'E',1),x_L,x_U,[],options);
            end
            %primal
            solution.obj=osense*fval;
            solution.full=x;
            %this is the dual to the equality constraints but it's not the chemical potential
            solution.dual=lambda.eqlin;
        else
            Aineq=[];
            bineq=[];
            if sum(minNorm)~=0
                [x,fval,exitflag,output,lambda] = cplexqp(F,c,Aineq,bineq,LPProblem.A,b,x_L,x_U,[],options);
            else
                [x,fval,exitflag,output,lambda] = cplexlp(c,Aineq,bineq,LPProblem.A,b,x_L,x_U,[],options);
            end
            solution.obj=osense*fval;
            solution.full=x;
            %this is the dual to the equality constraints but it's not the chemical potential
            solution.dual=sparse(size(LPProblem.A,1),1);
            solution.dual(csense == 'E')=lambda.eqlin;
            %this is the dual to the inequality constraints but it's not the chemical potential
            solution.dual(csense == 'L')=lambda.ineqlin(1:nnz(csense == 'L'),1);
            solution.dual(csense == 'G')=lambda.ineqlin(nnz(csense == 'L')+1:end,1);
        end
        %this is the dual to the simple ineequality constraints : reduced costs
        solution.rcost=lambda.lower-lambda.upper;
        solution.nInfeas = [];
        solution.sumInfeas = [];
        solution.origStat = output.cplexstatus;
    end
    %1 = (Simplex or Barrier) Optimal solution is available.
    Inform = solution.origStat;
    
else
    %tomlab cplex interface
    if ~isempty(csense)
        %set up constant vectors for CPLEX
        b_L(csense == 'E',1) = b(csense == 'E');
        b_U(csense == 'E',1) = b(csense == 'E');
        b_L(csense == 'G',1) = b(csense == 'G');
        b_U(csense == 'G',1) = Inf;
        b_L(csense == 'L',1) = -Inf;
        b_U(csense == 'L',1) = b(csense == 'L');
    else
        b_L = b;
        b_U = b;
    end
    
    %tomlab cplex interface
    %   minimize   0.5 * x'*F*x + c'x     subject to:
    %      x             x_L <=    x   <= x_U
    %                    b_L <=   Ax   <= b_U
    [x, slack, v, rc, f_k, ninf, sinf, Inform, basis] = cplex(c, LPProblem.A, x_L, x_U, b_L, b_U, ...
        cpxControl, callback, printLevel, Prob, IntVars, PI, SC, SI, ...
        sos1, sos2, F, logfile, savefile, savemode, qc, ...
        confgrps, conflictFile, saRequest, basis, xIP, logcon);
    
    solution.full=x;
    %this is the dual to the equality constraints but it's not the chemical potential
    solution.dual=v*osense;%negative sign Jan 25th
    %this is the dual to the simple ineequality constraints : reduced costs
    solution.rcost=rc*osense;%negative sign Jan 25th
    if Inform~=1
        solution.obj = NaN;
    else
        if minNorm==0
            solution.obj=f_k*osense;
        else
            solution.obj=c'*x*osense;
        end
        %     solution.obj
        %     norm(x)
    end
    solution.nInfeas = ninf;
    solution.sumInfeas = sinf;
    solution.origStat = Inform;
end
solution.time=toc;

if Inform~=1 && ~isempty(which('cplex'))
    if conflictResolve ==1
        if isfield(LPProblem,'mets') && isfield(LPProblem,'rxns')
            %this code reads the conflict resolution file and replaces the
            %arbitrary names with the abbreviations of metabolites and reactions
            [nMet,nRxn]=size(LPProblem.A);
            totAbbr=nMet+nRxn;
            conStrFind=cell(nMet+nRxn,1);
            conStrReplace=cell(nMet+nRxn,1);
            %only equality constraint rows
            for m=1:nMet
                conStrFind{m,1}=['c' int2str(m) ':'];
                conStrReplace{m,1}=[LPProblem.mets{m} ':  '];
            end
            %reactions
            for n=1:nRxn
                conStrFind{nMet+n,1}=['x' int2str(n) ' '];
                conStrReplace{nMet+n,1}=[LPProblem.rxns{n} ' '];
            end
            fid1 = fopen(suffix);
            fid2 = fopen(['COBRA_' suffix], 'w');
            while ~feof(fid1)
                tline{1}=fgetl(fid1);
                %replaces all occurrences of the string str2 within string str1
                %with the string str3.
                %str= strrep(str1, str2, str3)
                for t=1:totAbbr
                    tline= strrep(tline, conStrFind{t}, conStrReplace{t});
                end
                fprintf(fid2,'%s\n', tline{1});
            end
            fclose(fid1);
            fclose(fid2);
            %delete other file without replacements
            %         delete(suffix)
        else
            warning('Need reaction and metabolite abbreviations in order to make a readable conflict resolution file');
        end
        fprintf('%s\n',['Conflict resolution file written to: ' prefix '\COBRA_' suffix]);
        fprintf('%s\n%s\n','The Conflict resolution file gives an irreducible infeasible subset ','of constraints which are making this LP Problem infeasible');
    else
        if printLevel>0
            fprintf('%s\n','No conflict resolution file. Perhaps set conflictResolve = 1 next time.');
        end
    end
    solution.solver = 'cplex_direct';
end


% Try to give back COBRA Standardized solver status:
%           1   Optimal solution
%           2   Unbounded solution
%           0   Infeasible
%           -1  No solution reported (timelimit, numerical problem etc)
if Inform==1
    solution.stat = 1;
    if printLevel>0
        %use tomlab code to print out exit meassage
        [ExitText,ExitFlag] = cplexStatus(Inform);
        solution.ExitText=ExitText;
        solution.ExitFlag=ExitFlag;
        fprintf('\n%s%g\n',[ExitText ', Objective '],  c'*solution.full*osense);
    end
else
    if Inform==2
        solution.stat = 2;
        %use tomlab code to print out exit meassage
        [ExitText,ExitFlag] = cplexStatus(Inform);
        solution.ExitText=ExitText;
        solution.ExitFlag=ExitFlag;
        fprintf('\n%s%g\n',[ExitText ', Objective '],  c'*solution.full*osense);
    else
        if Inform==3
            solution.stat = 0;
        else
            %this is a conservative view
            solution.stat = -1;
            %use tomlab code to print out exit meassage
            [ExitText,ExitFlag] = cplexStatus(Inform);
            solution.ExitText=ExitText;
            solution.ExitFlag=ExitFlag;
            fprintf('\n%s%g\n',[ExitText ', Objective '],  c'*solution.full*osense);
        end
    end
end

%return basis
if basisReuse
    LPProblem.LPBasis=basis;
end

if sum(minNorm)~=0
    fprintf('%s\n','This objective corresponds to a flux with minimum Euclidean norm.');
    fprintf('%s%d%s\n','The largest weighting for minimising the norm was ',max(abs(minNorm)),'.');
    fprintf('%s\n','Check that the objective is the same without minimising the norm.');
end
