function [solution, LPProblem] = solveCobraLPCPLEX(LPProblem, printLevel, basisReuse, conflictResolve, contFunctName, minNorm, interface)
% Calls CPLEX to solve an LP problem
% By default, use the matlab interface to cplex written by TOMLAB, in
% preference to the one written by ILOG.
%
% USAGE:
%
%    [solution, LPProblem] = solveCobraLPCPLEX(LPProblem, printLevel, basisReuse, conflictResolve, contFunctName, minNorm, interface)
%
% INPUT:
%
%    LPProblem:          Structure containing the following fields describing the LP problem to be solved
%
%                          * .A - LHS matrix
%                          * .b - RHS vector
%                          * .c - Objective coeff vector
%                          * .lb - Lower bound vector
%                          * .ub - Upper bound vector
%                          * .osense - Objective sense (-1 max, +1 min)
%                          * .rxns - (optional) cell array of reaction abbreviations (necessary for
%                            making a readable confilict resolution file).
%                          * .csense - (optional) Constraint senses, a string containting the constraint sense for
%                            each row in `A` ('E', equality, 'G' greater than, 'L' less than).
%                          * .LPBasis - (optional) Basis from previous solution of similar LP problem.
%                            See `basisReuse`
% OPTIONAL INPUTS:
%    printLevel:         Printing level in the CPLEX m-file and CPLEX C-interface.
%
%                          * 0 - Silent
%                          * 1 - Warnings and Errors
%                          * 2 - Summary information (Default)
%                          * 3 - More detailed information
%                          * > 10 - Pause statements, and maximal printing (debug mode)
%    basisReuse:         0 - Use this for one of solution of an LP (Default);
%                        1 - Returns a basis for reuse in the next LP i.e. outputs `model.LPBasis`
%    conflictResolve:    0 (Default);
%                        1 If LP problem is proven to be infeasible by CPLEX,
%                        it will print out a 'conflict resolution file',
%                        which indicates the irreducible infeasible set of
%                        equaltiy & inequality constraints that together,
%                        combine to make the problem infeasible. This is
%                        useful for debugging an LP problem if you want to
%                        try to resolve a constraint conflict
%    contFunctName:      structure or function with parameters (only for `tomlab_cplex` or `ILOGcomplex`)
%
%                        - when using the `tomlab_cplex` interface
%
%                              1. contFunctName = [] Use all default CLPEX control parameters, (Default);
%                              2. contFunctName = someString e.g. 'someFunctionName'
%                                 uses the user specified control parameters defined
%                                 in `someFunctionName.m` (see template function CPLEXParamSet for details).
%                              3. contFunctName = `cpxControl` structure (output from a file like `CPLEXParamSet.m`)
%
%                        - when using the `ILOGcomplex` interface (parameter structure for Cplex). The full set of parameters can be obtained by calling `Cplex().Param`. For example:
%
%                              - `[solverParams.simplex.display, solverParams.tune.display, solverParams.barrier.display, solverParams.sifting.display, solverParams.conflict.display] = deal(0);`
%                              - `[solverParams.simplex.tolerances.optimality, solverParams.simplex.tolerances.feasibility] = deal(1e-9, 1e-8);`
%
%    minNorm:            {(0), 1 , `n x 1` vector} If not zero then, minimise the Euclidean length
%                        of the solution to the LP problem. Gives the same objective,
%                        but minimises the square of flux. `minNorm` ~1e-6 should be
%                        high enough for regularisation yet keep the same objective
%    interface:          {'ILOGcomplex', 'ILOGsimple', 'tomlab_cplex'}
%                        Default is the `tomlab_cplex` interface
%
% OUTPUT:
%    solution:           Structure containing the following fields describing a LP solution:
%
%                          * .full:               Full LP solution vector
%                          * .obj:                Objective value
%                          * .rcost:              Lagrangian multipliers to the simple inequalties (Reduced costs)
%                          * .dual:               Lagrangian multipliers to the equalities
%                          * .nInfeas:            Number of infeasible constraints
%                          * .sumInfeas:          Sum of constraint violation
%                          * .stat:               COBRA Standardized solver status code:
%
%                            * 1 - Optimal solution
%                            * 2 - Unbounded solution
%                            * 0 - Infeasible
%                            * -1 - No solution reported (timelimit, numerical problem etc)
%                          * .origStat:           CPLEX status code. Use `cplexStatus(solution.origStat)` for more information from the CPLEX solver
%                          * .solver              solver used by `cplex`
%                          * .time                time taken to solve the optimization problemtime taken to solve the optimization problem
%
% OPTIONAL OUTPUT:
%    LPProblem:          with field:
%
%                          * .LPBasis:            When input `basisReuse = 1`, we return a basis for reuse in the next LP
%
% CPLEX consists of 4 different LP solvers which can be used to solve sysbio optimization problems
% you can control which of the solvers, e.g. simplex vs interior point solver using the
% CPLEX control parameter cpxControl.LPMETHOD. At the moment, the solver is
% automatically chosen for you
%
% .. Note:
%       ILOG CPLEX parameters
%       https://www.ibm.com/support/knowledgecenter/SSSA5P_12.6.3/ilog.odms.studio.help/pdf/paramcplex.pdf
%
%       TOMLAB Cplex parameters
%       http://tomwiki.com/CPLEX_Parameter_Table
%
% .. Author: - Ronan Fleming

if ~exist('printLevel','var')
    printLevel=0;
end
if ~exist('basisReuse','var')
    basisReuse=0;
end
if ~exist('conflictResolve','var')
    conflictResolve=0;
end
if ~exist('interface','var')
    interface='tomlab_cplex';
end
if strcmp(interface,'tomlab_cplex')
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
end
if ~exist('minNorm','var')
    minNorm=0;
end

if basisReuse
    if isfield(LPProblem, 'LPBasis')
        basis = LPProblem.LPBasis;
        % use advanced starting information when optimization is initiated.
        cpxControl.advance = 1;
        cpxControl.ADVIND = 1;
    else
        basis=[];
    end
else
    basis=[];
    % do not use advanced starting information when optimization is initiated.
    cpxControl.advance = 0;
    cpxControl.ADVIND = 0;
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
    % set to deterministic mode to get reproducible conflict resolve file
    if (isfield(cpxControl,'PARALLEL') && cpxControl.PARALLEL ~=1) || (isfield(cpxControl,'PARALLELMODE') && cpxControl.PARALLELMODE ~=1)
        fprintf('PARALLEL / PARALLELMODE Parameter was changed to 1 to ensure a reproducible log file\n');
        cpxControl.PARALLEL = 1;
        cpxControl.PARALLELMODE = 1;
    end
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
    conflictFile=[prefix filesep suffix];
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
else
    F=[];
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

%Report of incompatibility R2016b - ILOGcomplex interface
verMATLAB = version('-release');
if str2num(verMATLAB(1:end-1)) >= 2016 && strcmp(interface, 'ILOGcomplex')
    error(['MATLAB ',verMATLAB, ' and the ILOGcomplex interface are not compatible. Select ILOGsimple or tomlab_cplex as a CPLEX interface.'])
end

%call cplex
tic;
switch interface
    case 'ILOGcomplex'
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

        ILOGcplex.Model.sense = 'minimize';

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

        if ~exist('contFunctName','var')
            cpxControl= struct();
        else
            %Read ILOG cplex parameters
            ILOGcplex = setCplexParam(ILOGcplex, cpxControl, printLevel);
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
        %http://www-01.ibm.com/support/knowledgecenter/SSSA5P_12.2.0/ilog.odms.cplex.help/Content/Optimization/Documentation/CPLEX/_pubskel/CPLEX1210.html
        if ILOGcplex.Solution.status == 1
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
            solution.kappa      = ILOGcplex.Solution.quality.kappa.value;
        else
            warning(['IBM CPLEX STATUS = ' int2str(ILOGcplex.Solution.status) ', see: http://www-01.ibm.com/support/knowledgecenter/SSSA5P_12.2.0/ilog.odms.cplex.help/Content/Optimization/Documentation/CPLEX/_pubskel/CPLEX1210.html'])
            solution.origStat   = ILOGcplex.Solution.status;
            solution.full       = NaN;
            solution.obj        = NaN;
            solution.rcost      = NaN;
            solution.dual       = NaN;
            solution.nInfeas    = NaN;
            solution.sumInfeas  = NaN;
            solution.solver     = NaN;
            solution.time       = NaN;
        end
    case 'ILOGsimple'
        try
            ILOGcplex = Cplex('fba');
        catch ME
            error('CPLEX not installed or licence server not up')
        end
        %simple ibm ilog cplex interface
        options = cplexoptimset;
        if printLevel == 0
            options = cplexoptimset(options,'Display','off');
        else
            options = cplexoptimset(options,'Display','on');
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
    case 'tomlab_cplex'
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
    otherwise
        error([interface ' is not a recognised solveCobraLPCPLEX interface'])
end
solution.time=toc;
Inform = solution.origStat;

if Inform~=1 && conflictResolve ==1
    switch interface
        case {'ILOGcomplex','ILOGsimple'}
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
                fprintf('%s\n',['Conflict resolution file written to: ' prefix '\COBRA_' suffix]);
                fprintf('%s\n%s\n','The Conflict resolution file gives an irreducible infeasible subset ','of constraints which are making this LP Problem infeasible');
            else
                warning('Need reaction and metabolite abbreviations in order to make a readable conflict resolution file');
            end
    end
else
    if printLevel>0 && Inform~=1
        fprintf('%s\n','No conflict resolution file. Consider to set conflictResolve = 1 next time.');
    end
end

if strcmp(interface, 'tomlab_cplex')
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
end

%return basis
if basisReuse
    LPProblem.LPBasis=basis;
end

if sum(minNorm)~=0
    fprintf('%s\n','This objective corresponds to a flux with minimum Euclidean norm.');
    fprintf('%s%d%s\n','The weighting for minimising the norm was ',minNorm,'.');
    fprintf('%s\n','Check that the objective is the same without minimising the norm.');
end
