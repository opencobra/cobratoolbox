function [solution,model]=solveCobraCPLEX(model,printLevel,basisReuse,conflictResolve,contFunctName,minNorm)
% [solution,LPProblem]=solveCobraCPLEX(model,printLevel,basisReuse,conflictResolve,contFunctName,minNorm)
% call CPLEX to solve an LP or QP problem using the matlab API to cplex written by ILOG
%
%INPUT
% Model Structure containing the following fields describing the LP
% problem to be solved
%  A or S       m x n LHS matrix
%  b            m x 1 RHS vector
%  c            n x 1 Objective coeff vector
%  lb           n x 1 Lower bound vector
%  ub           n x 1 Upper bound vector
%  osense       scalar Objective sense (-1 max, +1 min)
%
%OPTIONAL INPUT
% model.rxns    cell array of reaction abbreviations (necessary for
%                   making a readable confilict resolution file).
% model.csense  Constraint senses, a string containting the constraint sense for
%                   each row in A ('E', equality, 'G' greater than, 'L' less than).
%
% model.LPBasis Basis from previous solution of similar LP problem.
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
%                  i.e. outputs model.LPBasis
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
% model.LPBasis When input basisReuse=1, we return a basis for reuse in
%                   the next LP
%
% CPLEX consists of 4 different LP solvers which can be used to solve sysbio optimization problems
% you can control which of the solvers, e.g. simplex vs interior point solver using the
% CPLEX control parameter cpxControl.LPMETHOD. At the moment, the solver is
% automatically chosen for you
%
% Ronan Fleming 23 Oct  09  ILOG-CPLEX 12.1 via  matlab API

if ~exist('printLevel','var')
    printLevel=0;
end
if ~exist('basisReuse','var')
    basisReuse=0;
end
if ~exist('conflictResolve','var')
    conflictResolve=0;
end

if ~exist('minNorm','var')
    minNorm=0;
end

if basisReuse
    if isfield(model,'LPBasis')
        basis=model.LPBasis;
        %use advanced starting information when optimization is initiated.
        %cpxControl.ADVIND=1;
    else
        basis=[];
    end
else
    basis=[];
    %do not use advanced starting information when optimization is initiated.
    cplex.Param.ADVIND=0;
end

if ~isfield(model,'A')
    if ~isfield(model,'S')
        error('Equality constraint matrix must either be a field denoted A or S.')
    end
    model.A=model.S;
end

if ~isfield(model,'csense')
    nMet=size(model.A);
    if printLevel>0
        fprintf('%s\n','Assuming equality constraints, i.e. S*v=b');
    end
    %assuming equality constraints
    model.csense(1:nMet,1)='E';
end

if ~isfield(model,'osense')
    %assuming maximisation
    model.osense=-1;
    if printLevel>0
        fprintf('%s\n','Assuming maximisation of objective');
    end
end

if size(model.A,2)~=length(model.c)
    error('dimensions of A & c are inconsistent');
end

if size(model.A,2)~=length(model.lb) || size(model.A,2)~=length(model.ub)
    error('dimensions of A & bounds are inconsistent');
end

%Conflict groups descriptor (cpxBuildConflict can be used to generate the input). Set this if
%conflict refinement is desired in the case that infeasibility is detected
%by CPLEX.
if conflictResolve
    [m_lin,n]=size(model.A);
    m_quad=0;
    m_sos=0;
    m_log=0;
    %determines how elaborate the output is
    mode='full';%'minimal';
    fprintf('%s\n%s\n','Building Structure for Conflict Resolution...','...this slows CPLEX down so should not be used for repeated LP');
    confgrps = cpxBuildConflict(n,m_lin,m_quad,m_sos,m_log,mode);
    prefix=pwd;
    suffix='CPLEX_conflict_file.txt';
    conflictFile=[prefix '\' suffix];
else
    confgrps=[]; conflictFile=[];
end

% Initialize the CPLEX object
try
	cplex = Cplex('fba');
catch ME
	error('CPLEX not installed or licence server not up')
end

% Now populate the problem with the data
cplex.Model.sense = 'minimize';
if model.osense==1
    %minimise linear objective
    cplex.Model.obj   = model.c;
else
    %maximise linear objective by reversing sign
    cplex.Model.obj   = - model.c;
end

cplex.Model.lb    = model.lb;
cplex.Model.ub    = model.ub;
cplex.Model.A     = model.A;

%cplex interface
if isfield(model,'csense')
    %set up constant vectors for CPLEX
    b_L(model.csense == 'E',1) = model.b(model.csense == 'E');
    b_U(model.csense == 'E',1) = model.b(model.csense == 'E');
    b_L(model.csense == 'G',1) = model.b(model.csense == 'G');
    b_U(model.csense == 'G',1) =  Inf;
    b_L(model.csense == 'L',1) = -Inf;
    b_U(model.csense == 'L',1) = model.b(model.csense == 'L');
    cplex.Model.lhs   = b_L;
    cplex.Model.rhs   = b_U;
else
    cplex.Model.lhs   = model.b;
    cplex.Model.rhs   = model.b;
end

%quadratic constraint matrix, size n x n
if sum(minNorm)~=0
    if length(minNorm)==1
        % same weighting of min norm for all variables
        cplex.Model.Q=model.osense*speye(length(model.c))*minNorm;
    else
        if length(minNorm)~=length(model.c)
            error('Either minNorm is a scalar, or is an n x 1 vector')
        else
            % individual weighting of min norm for all variables
            cplex.Model.Q=model.osense*spdiags(minNorm,0,length(model.c),length(model.c));
        end
    end
end

%set the solver parameters
if exist('contFunctName','var')
    if isstruct(contFunctName)
        cplex.Param=contFunctName;
    else
        if ~isempty(contFunctName)
            %calls a user specified function to create a CPLEX control structure
            %specific to the users problem. A TEMPLATE for one such function is
            %CPLEXParamSet
            %e.g. Param.lpmethod.Cur=0;
            cplex.Param=Param;
        end
    end
end

if printLevel==0
    cplex.DisplayFunc=[];
else
    %print level
    cplex.Param.barrier.display.Cur = printLevel;
    cplex.Param.simplex.display.Cur = printLevel;
    cplex.Param.sifting.display.Cur = printLevel;
end

%limit the processing to 3 threads
cplex.Param.threads.Cur = 3;

% Optimize the problem
cplex.solve();
solution.origStat   = cplex.Solution.status;

if printLevel>0 && solution.origStat~=1
    %use tomlab code to print out exit meassage
    [ExitText,ExitFlag] = cplexStatus(solution.origStat);
    solution.ExitText=ExitText;
    solution.ExitFlag=ExitFlag;
    if any(model.c~=0)
        fprintf('\n%s%g\n',[ExitText ', Objective '],  model.c'*cplex.Solution.x);
    end
end

if solution.origStat==1
    %extract the solution
    solution.obj        = model.osense*cplex.Solution.objval;
    solution.full       = cplex.Solution.x;
    solution.rcost      = cplex.Solution.reducedcost;
    solution.dual       = cplex.Solution.dual;
    solution.nInfeas    = NaN;
    solution.sumInfeas  = NaN;
    solution.solver     = cplex.Solution.method;
    solution.time       = cplex.Solution.time;
else
    solution.time=NaN;
    %conflict resolution
    if conflictResolve ==1
        Cplex.refineConflict
        Cplex.writeConflict(suffix)
        if isfield(model,'mets') && isfield(model,'rxns')
            %this code reads the conflict resolution file and replaces the
            %arbitrary names with the abbreviations of metabolites and reactions
            [nMet,nRxn]=size(model.A);
            totAbbr=nMet+nRxn;
            conStrFind=cell(nMet+nRxn,1);
            conStrReplace=cell(nMet+nRxn,1);
            %only equality constraint rows
            for m=1:nMet
                conStrFind{m,1}=['c' int2str(m) ':'];
                conStrReplace{m,1}=[model.mets{m} ':  '];
            end
            %reactions
            for n=1:nRxn
                conStrFind{nMet+n,1}=['x' int2str(n) ' '];
                conStrReplace{nMet+n,1}=[model.rxns{n} ' '];
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
end

% Try to give back COBRA Standardized solver status:
%           1   Optimal solution
%           2   Unbounded solution
%           0   Infeasible
%           -1  No solution reported (timelimit, numerical problem etc)
if solution.origStat==1
    solution.stat = 1;
else
    %use tomlab code to print out exit meassage
    [ExitText,ExitFlag] = cplexStatus(solution.origStat);
    solution.ExitText=ExitText;
    solution.ExitFlag=ExitFlag;
    if any(model.c~=0) && isfield(cplex.Solution,'x')
        fprintf('\n%s%g\n',[ExitText ', Objective '],  model.c'*cplex.Solution.x);
    end
    if solution.origStat==2
        solution.stat = 2;
    else
        if solution.origStat==3
            solution.stat = 0;
        else
            %this is a conservative view
            solution.stat = -1;
        end
    end
end

%return basis
if basisReuse
    model.LPBasis=basis;
end

if sum(minNorm)~=0 && printLevel>0
    fprintf('%s\n','This objective corresponds to a flux with minimum Euclidean norm.');
    if length(minNorm)==1
        fprintf('%s%d%s\n','The weighting for minimising the norm was ',minNorm,'.');
    else
        fprintf('%s%d%s\n','The sum of the weighting for minimising the norm was ',sum(minNorm),'.');
    end
    fprintf('%s\n','Check that the objective is the same without minimising the norm.');
end
