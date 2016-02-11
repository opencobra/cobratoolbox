function solution = solveCobraLP(LPproblem,varargin)
%solveCobraLP Solve constraint-based LP problems
%
% solution = solveCobraLP(LPproblem, parameters)
%
%INPUT
% LPproblem Structure containing the following fields describing the LP
% problem to be solved
%  A      LHS matrix
%  b      RHS vector
%  c      Objective coeff vector
%  lb     Lower bound vector
%  ub     Upper bound vector
%  osense Objective sense (-1 max, +1 min)
%  csense Constraint senses, a string containting the constraint sense for
%         each row in A ('E', equality, 'G' greater than, 'L' less than).
%
%OPTIONAL INPUTS
% Optional parameters can be entered in three different ways {A,B,C}
% A) as parameter followed by parameter value: 
% e.g.[solution]=solveCobraLP(LPCoupled,'printLevel',1,);
% e.g.[solution]=solveCobraLP(LPCoupled,'printLevel',1,'feasTol',1e-8);
%
% B) parameters structure with field names specific to a particular solvers
% internal parameter fields
% e.g.[solution]=solveCobraLP(LPCoupled,parameters);
%
% C) as parameter followed by parameter value, with a parameter structure 
% with field names specific to a particular solvers internal parameter,
% fields as the LAST argument
% e.g [solution]=solveCobraLP(LPCoupled,'printLevel',1,'feasTol',1e-6,parameters);
%
% printLevel    Printing level
%               = 0    Silent (Default)
%               = 1    Warnings and Errors
%               = 2    Summary information 
%               = 3    More detailed information
%               > 10   Pause statements, and maximal printing (debug mode)
% saveInput     Saves LPproblem to filename specified in field. 
%               i.e. parameters.saveInput = 'LPproblem.mat';
% minNorm       {(0), scalar , n x 1 vector}, where [m,n]=size(S); 
%               If not zero then, minimise the Euclidean length 
%               of the solution to the LP problem. minNorm ~1e-6 should be
%               high enough for regularisation yet maintain the same value for 
%               the linear part of the objective. However, this should be
%               checked on a case by case basis, by optimization with and
%               without regularisation.
% primalOnly    {(0),1} 1=only return the primal vector (lindo solvers)
%               
% optional parameters can also be set through the
% solver can be set through changeCobraSolver('LP', value);
% changeCobraSolverParams('LP', 'parameter', value) function.  This
% includes the minNorm and the printLevel flags
%
%OUTPUT
% solution Structure containing the following fields describing a LP
% solution
%  full         Full LP solution vector
%  obj          Objective value
%  rcost        Reduced costs, dual solution to lb <= v <= ub 
%  dual         dual solution to A*v ('E' | 'G' | 'L') b
%  solver       Solver used to solve LP problem
%  algorithm    Algorithm used by solver to solve LP problem 
%  stat         Solver status in standardized form
%               1   Optimal solution
%               2   Unbounded solution
%               0   Infeasible
%               -1   No solution reported (timelimit, numerical problem etc)
%
%  origStat     Original status returned by the specific solver
%  time         Solve time in seconds
%
%OPTIONAL OUTPUT
% solution.basis    LP basis corresponding to solution


% Markus Herrgard    08/29/06
% Ronan Fleming      11/12/08 'cplex_direct' allows for more refined control
%                             of cplex than tomlab tomrun
% Ronan Fleming      04/25/09 Option to minimise the Euclidean Norm of internal
%                             fluxes using either 'cplex_direct' solver or 'pdco'
% Jan Schellenberger 09/28/09 Changed header to be much simpler.  All parameters
%                             now accessed through 
%                             changeCobraSolverParams(LP, parameter,value)
% Richard Que        11/30/09 Changed handling of optional parameters to use
%                             getCobraSolverParams().
% Ronan Fleming      12/07/09 Commenting of input/output
% Ronan Fleming      21/01/10 Not having second input, means use the parameters as specified in the
%                             global paramerer variable, rather than 'default' parameters
% Steinn Gudmundsson 03/03/10 Added support for the Gurobi solver
% Ronan Fleming      01/24/01 Now accepts an optional parameter structure with nonstandard 
%                             solver specific parameter options
% Tim Harrington     05/18/12 Added support for the Gurobi 5.0 solver
% Ronan Fleming      07/04/13 Reinstalled support for optional parameter structure

%% Process arguments etc

global CBTLPSOLVER
global MINOSPATH
global DQQMINOSPATH

if (~isempty(CBTLPSOLVER))
    solver = CBTLPSOLVER;
elseif nargin==1
    error('No solver found.  call changeCobraSolver(solverName)');
end
%names_of_parameters that users can specify with values, using option
% A) as parameter followed by parameter value:
optParamNames = {'minNorm','printLevel','primalOnly','saveInput','feasTol','optTol','solver'};

%not a good idea to do this here for every solver as there would end up
%being hundreds of different parameters, so removed - Ronan
%,'EleNames','EqtNames','VarNames','EleNameFun', ...
%    'EqtNameFun','VarNameFun','PbName','MPSfilename'};
if nargin ~=1
    if mod(length(varargin),2)==0
        %expecting pairs of parameter names and parameter values
        for i=1:2:length(varargin)-1
            if ismember(varargin{i},optParamNames)
                if isstruct(varargin{i+1})
                    error('solveCobraLP: Invalid number of parameters/values')
                else
                    parameters.(varargin{i}) = varargin{i+1};
                end
                if strcmp(varargin{i},'solver');
                    solver=varargin{i+1};
                end 
            else
                error([varargin{i} ' is not a valid optional parameter']);
            end
        end
        parametersStructureFlag=0;
        parameters = '';
    elseif strcmp(varargin{1},'default')
        %default cobra parameters 
        parameters = 'default';
    elseif isstruct(varargin{1})
        %uses the structure for setting parameters in preference to those
        %of the optParamNames, where appropriate
        parametersStructureFlag=1;
        directParamStruct = varargin{1};
        parameters='';
    elseif isstruct(varargin{length(varargin)})
        %expecting pairs of parameter names and parameter values, then a
        %parameter structure at the end
        parametersStructureFlag=1;
        directParamStruct=varargin{length(varargin)};
        for i=1:2:length(varargin)-2
            if ismember(varargin{i},optParamNames)
                parameters.(varargin{i}) = varargin{i+1};
            else
                error([varargin{i} ' is not a valid optional parameter']);
            end
        end
        %pause(eps)
    else
        error('solveCobraLP: Invalid number of parameters/values')
    end
    [minNorm, printLevel, primalOnlyFlag, saveInput, feasTol, optTol] = ...
    getCobraSolverParams('LP',optParamNames(1:6),parameters);
else
    parametersStructureFlag=0;
    [minNorm, printLevel, primalOnlyFlag, saveInput, feasTol, optTol] = ...
    getCobraSolverParams('LP',optParamNames(1:6));
end

if max(minNorm)~=0 && ~any(strcmp(solver,{'cplex_direct','cplex'}))
  error('minNorm only works for LP solver ''cplex_direct'' from this interface, use optimizeCbModel for other solvers.')
end

%Save Input if selected
if ~isempty(saveInput)
    fileName = saveInput;
    if ~find(regexp(fileName,'.mat'))
        fileName = [fileName '.mat'];
    end
    display(['Saving LPproblem in ' fileName]);
    save(fileName,'LPproblem')
end

%support for lifting of ill scaled models
if parametersStructureFlag
    if isfield(directParamStruct,'lifting')
        if directParamStruct.lifting==1
            BIG=1e4;%suitable for double precision solvers
            [LPproblem] = reformulate(LPproblem, BIG, printLevel);
        end
    end
end

% Assume constraint matrix is S if no A provided.
if ~isfield(LPproblem,'A')
    if isfield(LPproblem,'S')
        LPproblem.A = LPproblem.S;
    end
end

% Assume constraint S*v = b if csense not provided
if ~isfield(LPproblem,'csense')
    % If csense is not declared in the model, assume that all
    % constraints are equalities.
    LPproblem.csense(:,1) = 'E';
end

% Assume constraint S*v = 0 if b not provided
if ~isfield(LPproblem,'b')
    warning('LP problem has no defined b in S*v=b. b should be defined, for now we assume b=0')
    LPproblem.b=zeros(size(LPproblem.A,1),1);
end

% Assume max c'v s.t. S v = b if osense not provided
if ~isfield(LPproblem,'osense')
    LPproblem.osense = -1;
end


%extract the problem from the structure
[A,b,c,lb,ub,csense,osense] = deal(LPproblem.A,LPproblem.b,LPproblem.c,LPproblem.lb,LPproblem.ub,LPproblem.csense,LPproblem.osense);

% Defaults in case the solver does not return anything
f = [];
x = [];
y = [];
w = [];
origStat = -99;
stat = -99;
algorithm='default';

t_start = clock;
switch solver
    case 'dqqMinos'
        if ~isunix 
            error('dqqMinos interface not yet implemented for non unix OS.')
        end
        
        if isfield(directParamStruct,'mpsParentFolderPath')
            mpsParentFolderPath=directParamStruct.mpsParentFolderPath;
        else
            %use current path for MPS folder
            mpsParentFolderPath=pwd;
        end
        if ~exist(mpsParentFolderPath,'dir')
            mkdir([mpsParentFolderPath filesep 'MPS'])
        end
        
        if parametersStructureFlag
            if isfield(directParamStruct,'MPSfilename')
                MPSfilename=directParamStruct.MPSfilename;
            else
                if isfield(LPproblem,'modelID')
                    MPSfilename=LPproblem.modelID;
                else
                    MPSfilename='file';
                end
            end
        end
        
        
        if 1
            %use Stanford code to write mps file
            %fname=writeMINOSMPS(LPproblem,mpsParentFolderPath,printLevel);
            tempFileName  = MPSfilename(1:min(8,length(MPSfilename)));
            if exist([mpsParentFolderPath filesep 'MPS' filesep tempFileName '.mps'],'file')
                MPSfilename=tempFileName;
            else
                longMPSfilename=MPSfilename;
                MPSfilename=writeMINOSMPS(A,b,c,lb,ub,csense,osense,longMPSfilename,mpsParentFolderPath,printLevel);
            end
        else
            %write out the mps file to the dataDirectory
            %% BuildMPS
            % This calls buildMPS and generates a MPS format description of the
            % problem as the result
            % Build MPS Author: Bruno Luong
            % Interfaced with CobraToolbox by Richard Que (12/18/09)
            display('Solver set to MPS. This function will write out a .MPS file and return a matrix string for the LP problem');
            
            %default MPS parameters are no longer global variables, but set
            %here inside this function
            if parametersStructureFlag
                param=directParamStruct;
            else
                param=struct();
            end
            if isfield(param,'EleNames')
                EleNames=param.EleNames;
            else
                EleNames='';
            end
            if isfield(param,'EqtNames')
                EqtNames=param.EqtNames;
            else
                EqtNames='';
            end
            if isfield(param,'VarNames')
                VarNames=param.VarNames;
            else
                VarNames='';
            end
            if isfield(param,'EleNameFun')
                EleNameFun=directParamStruct.EleNameFun;
            else
                EleNameFun = @(m)(['LE' num2str(m)]);
            end
            if isfield(param,'EqtNameFun')
                EqtNameFun=param.EqtNameFun;
            else
                EqtNameFun = @(m)(['EQ' num2str(m)]);
            end
            if isfield(param,'VarNameFun')
                VarNameFun=param.VarNameFun;
            else
                VarNameFun = @(m)(['X' num2str(m)]);
            end
            if isfield(param,'PbName')
                PbName=param.PbName;
            else
                PbName='LPproble';
            end
            if isfield(param,'MPSfilename')
                MPSfilename=param.MPSfilename;
            else
                MPSfilename=[dataDirectory '/dqqFBA'];
            end
            %split A matrix for L and E csense
            Ale = A(csense=='L',:);
            ble = b(csense=='L');
            Aeq = A(csense=='E',:);
            beq = b(csense=='E');
            
            %%%%Adapted from BuildMPS%%%%%
            [neq nvar]=size(Aeq);
            nle=size(Ale,1);
            if isempty(EleNames)
                EleNames=arrayfun(EleNameFun,(1:nle),'UniformOutput', false);
            end
            if isempty(EqtNames)
                EqtNames=arrayfun(EqtNameFun,(1:neq),'UniformOutput', false);
            end
            if isempty(VarNames)
                VarNames=arrayfun(VarNameFun,(1:nvar),'UniformOutput', false);
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            
            % input precision     ('double') or 'single' precision
            precision='double';
            
            %http://www.mathworks.com/matlabcentral/fileexchange/19618-mps-format-exporting-tool/content/BuildMPS/BuildMPS.m
            [solution] = BuildMPS(Ale, ble, Aeq, beq, c, lb, ub, PbName,'MPSfilename',[mpsParentFolderPath filesep MPSfilename '.mps'],'EleNames',EleNames,'EqtNames',EqtNames,'VarNames',VarNames);
        end
                
        %need to change to DDQ directory, need to improve on this - Ronan
        originalDirectory=pwd;
        cd(DQQMINOSPATH)
        sysCall=['run1DQQ ' MPSfilename ' ' mpsParentFolderPath];
        [status,cmdout]=system(sysCall);
        %why is status returned 1 here?
        if status~=0
            disp('\n')
            disp(sysCall)
            disp(cmdout)
            error('Call to dqq failed');
        end
        
        %read the solution
        solfname=[mpsParentFolderPath filesep 'results' filesep MPSfilename '.sol'];
        sol = readMinosSolution(solfname);
        %disp(sol)
        % The optimization problem solved by MINOS is assumed to be
        %        min   osense*s(iobj)
        %        st    Ax - s = 0    + bounds on x and s,
        % where A has m rows and n columns.  The output structure "sol"
        % contains the following data:
        %
        %        sol.inform          MINOS exit condition
        %        sol.m               Number of rows in A
        %        sol.n               Number of columns in A
        %        sol.osense          osense
        %        sol.objrow          Row of A containing a linear objective
        %        sol.obj             Value of MINOS objective (linear + nonlinear)
        %        sol.numinf          Number of infeasibilities in x and s.
        %        sol.suminf          Sum    of infeasibilities in x and s.
        %        sol.xstate          n vector: state of each variable in x.
        %        sol.sstate          m vector: state of each slack in s.
        %        sol.x               n vector: value of each variable in x.
        %        sol.s               m vector: value of each slack in s.
        %        sol.rc              n vector: reduced gradients for x.
        %        sol.y               m vector: dual variables for Ax - s = 0.
        x=sol.x
        f=c'*x;
        y=sol.y;
        w=sol.rc;
        origStat=sol.inform;
        
        k=sol.s;
        
        % Note that status handling may change (see lp_lib.h)
        if (origStat == 0)
            stat = 1; % Optimal solution found
%         elseif (origStat == 3)
%             stat = 2; % Unbounded
%         elseif (origStat == 2)
%             stat = 0; % Infeasible
        else
            stat = -1; % Solution not optimal or solver problem
        end
        %cleanup
        if 0
            delete(solfname)
        end
        %return to original directory
        cd(originalDirectory);
    case 'quadMinos'
%         It is a prerequisite to have installed and compiled minos, qminos 
%         and the testFBA interface to minos and qminos, then don't alter
%         the directory structure.
%         cd quadLP  # top directory
%         0. Check Makefile.defs (in top directory) and edit if necessary
%         to select your Fortran compiler.
%         The same file exists in the top directory of minos56 and qminos56.
%         If necessary:
%         cp Makefile.defs  minos56
%         cp Makefile.defs qminos56
%         cd minos56
%         make       # makes lib/libminos.a and lib/minosdbg.a
%         cd ../qminos56
%         make       # makes lib/libquadminos.a and lib/libquadminosdbg.a
%         cd ../testFBA
%         make       # makes ../bin/solveLP and ../bin/qsolveLP
%         Test the installation:
%         ./runfba   solveLP TMA_ME lp1   # runs  solveLP with TMA_ME.txt, lp1.spc
%         ./qrunfba qsolveLP TMA_ME lp2   # runs qsolveLP with TMA_ME.txt, lp2.spc
   
        if ~isunix 
            error('Minos interface not yet implemented for non unix OS.')
        end
        % input precision     ('double') or 'single' precision
        precision='double';
        % modelName     name is the problem name (a character string)
        %modelName=['minosFBAprob-' date];
        modelName='qFBA';
        
        %TODO: for some reason repeated system call to find minos path does not work, this is a workaround
        if 0
            % directory     the directory where optimization problem file is saved
            [status,cmdout]=system('which minos');
            if isempty(cmdout)
                disp(cmdout);
                [status,cmdout2]=system('echo $PATH');
                disp(cmdout2);
                error('Minos not installed or not on system path.')
            else
                quadLPPath=cmdout(1:end-length('/bin/minos')-1);
            end
        else
            quadLPPath=MINOSPATH;
        end
        
        dataDirectory=[quadLPPath '/data/FBA'];
        %write out flat file to current folder
        %printLevel=2;
        [dataDirectory,fname]=writeMinosProblem(LPproblem,precision,modelName,dataDirectory,printLevel);
        %change system to testFBA directory
        originalDirectory=pwd;
        cd([quadLPPath '/testFBA'])
        %[status,cmdout]=system(['cd ' quadLPPath '/testFBA']); 
        %call minos
        sysCall=[quadLPPath '/testFBA/runfba solveLP ' fname ' lp1'];
        [status,cmdout]=system(sysCall);
        if status~=0
           disp(sysCall)
           disp(cmdout)
           disp('Error. if the error is /bin/tcsh: bad interpreter: No such file or directory, then install tsch on your system')
           error('Call to minos failed');
        end
        %call qminos
        [status,cmdout]=system([quadLPPath '/testFBA/qrunfba qsolveLP ' fname ' lp2']);
        %why is status returned 1 here?
%         if status~=0
%             disp(cmdout)
%             error('Call to qminos failed');
%         end
        %read the solution
        sol = readMinosSolution([quadLPPath '/testFBA/' fname '.sol']);
        %disp(sol)
        % The optimization problem solved by MINOS is assumed to be
        %        min   osense*s(iobj)
        %        st    Ax - s = 0    + bounds on x and s,
        % where A has m rows and n columns.  The output structure "sol"
        % contains the following data:
        %
        %        sol.inform          MINOS exit condition
        %        sol.m               Number of rows in A
        %        sol.n               Number of columns in A
        %        sol.osense          osense
        %        sol.objrow          Row of A containing a linear objective
        %        sol.obj             Value of MINOS objective (linear + nonlinear)
        %        sol.numinf          Number of infeasibilities in x and s.
        %        sol.suminf          Sum    of infeasibilities in x and s.
        %        sol.xstate          n vector: state of each variable in x.
        %        sol.sstate          m vector: state of each slack in s.
        %        sol.x               n vector: value of each variable in x.
        %        sol.s               m vector: value of each slack in s.
        %        sol.rc              n vector: reduced gradients for x.
        %        sol.y               m vector: dual variables for Ax - s = 0.
        x=sol.x;
        f=c'*x;
        y=sol.y;
        w=sol.rc;
        origStat=sol.inform;
        
        k=sol.s;
        
        % Note that status handling may change (see lp_lib.h)
        if (origStat == 0)
            stat = 1; % Optimal solution found
%         elseif (origStat == 3)
%             stat = 2; % Unbounded
%         elseif (origStat == 2)
%             stat = 0; % Infeasible
        else
            stat = -1; % Solution not optimal or solver problem
        end
        %cleanup
        delete([dataDirectory '/' fname '.txt'])
        delete([quadLPPath '/testFBA/' fname '.sol'])
        %return to original directory
        cd(originalDirectory);
    case 'glpk'
        %% GLPK
        param.msglev = printLevel; % level of verbosity
        param.tolbnd = feasTol; %tolerance
        param.toldj = optTol; %tolerance
        if (isempty(csense))
            clear csense
            csense(1:length(b),1) = 'S';
        else
            csense(csense == 'L') = 'U';
            csense(csense == 'G') = 'L';
            csense(csense == 'E') = 'S';
            csense = columnVector(csense);
        end
        %glpk needs b to be full, not sparse -Ronan
        b=full(b);
        [x,f,y,w,stat,origStat] = solveGlpk(c,A,b,lb,ub,csense,osense,param);
        y=-y;
        w=-w;
        
    case {'lindo_new','lindo_old'}
        %% LINDO
        if (strcmp(solver,'lindo_new'))
            % Use new API (>= 2.0)
            [f,x,y,w,s,origStat] = solveCobraLPLindo(A,b,c,csense,lb,ub,osense,primalOnlyFlag,false);
            % Note that status handling may change (see Lindo.h)
            if (origStat == 1 || origStat == 2)
                stat = 1; % Optimal solution found
            elseif (origStat == 4)
                stat = 2; % Unbounded
            elseif (origStat == 3 || origStat == 6)
                stat = 0; % Infeasible
            else
                stat = -1; % Solution not optimal or solver problem
            end
        else
            % Use old API
            [f,x,y,w,s,origStat] = solveCobraLPLindo(A,b,c,csense,lb,ub,osense,primalOnlyFlag,true);
            % Note that status handling may change (see Lindo.h)
            if (origStat == 2 || origStat == 3)
                stat = 1; % Optimal solution found
            elseif (origStat == 5)
                stat = 2; % Unbounded
            elseif (origStat == 4 || origStat == 6)
                stat = 0; % Infeasible
            else
                stat = -1; % Solution not optimal or solver problem
            end
        end
        %[f,x,y,s,w,stat] = LMSolveLPNew(A,b,c,csense,lb,ub,osense,0);

    case 'lp_solve'
        %% lp_solve
        if (isempty(csense))
            [f,x,y,origStat] = lp_solve(c*(-osense),A,b,zeros(size(A,1),1),lb,ub);
            f = f*(-osense);
        else
            e(csense == 'E') = 0;
            e(csense == 'G') = 1;
            e(csense == 'L') = -1;
            [f,x,y,origStat] = lp_solve(c*(-osense),A,b,e,lb,ub);
            f = f*(-osense);
        end
        % Note that status handling may change (see lp_lib.h)
        if (origStat == 0)
            stat = 1; % Optimal solution found
        elseif (origStat == 3)
            stat = 2; % Unbounded
        elseif (origStat == 2)
            stat = 0; % Infeasible
        else
            stat = -1; % Solution not optimal or solver problem
        end
        s = [];
        w = [];
    case 'mosek'
        %% mosek
        %use msklpopt with full control over all mosek parameters
        %http://docs.mosek.com/7.0/toolbox/Parameters.html
        %see also
        %http://docs.mosek.com/7.0/toolbox/A_guided_tour.html#SEC:VIEWSETPARAM
        %e.g.
        %http://docs.mosek.com/7.0/toolbox/MSK_IPAR_OPTIMIZER.html
        
        %[rcode,res]         = mosekopt('param echo(0)',[],parameters);
        if parametersStructureFlag
            param=directParamStruct;
        else
            param=struct();
        end
        %only set the print level if not already set via parameters
        %structure
        if ~isfield(param,'MSK_IPAR_LOG')
            switch printLevel
                case 0
                    echolev                           = 0;
                case 1
                    echolev                           = 3;
                case 2
                    param.MSK_IPAR_LOG_INTPNT         = 1;
                    param.MSK_IPAR_LOG_SIM            = 1;
                    echolev                           = 3;
                otherwise
                    echolev                           = 0;
            end
            if echolev==0
                param.MSK_IPAR_LOG = 0;
                cmd=['minimize echo(' int2str(echolev) ')'];
            else
                cmd='minimize';
            end
        end
            
        %basis reuse - TODO
        %http://docs.mosek.com/7.0/toolbox/A_guided_tour.html#section-node-_A%20guided%20tour_Advanced%20start%20%28hot-start%29
        %if isfield(LPproblem,'basis') && ~isempty(LPproblem.basis)
        %    LPproblem.cbasis = full(LPproblem.basis);
        %end
        
        % Syntax:      [res] = msklpopt(c,a,blc,buc,blx,bux,param,cmd)
        %
        % Purpose:     Solves the optimization problem
        %
        %                min c'*x
        %                st. blc <= a*x <= buc
        %                    bux <= x   <= bux
        %
        % Description: Required arguments.
        %                c      Is a vector.
        %                a      Is a (preferably sparse) matrix.
        %
        %              Optional arguments.
        %                blc    Lower bounds on constraints.
        %                buc    Upper bounds on constraints.
        %                blx    Lower bounds on variables.
        %                bux    Upper bounds on variables.
        %                param  New MOSEK parameters.
        %                cmd    MOSEK commands.
        %
        %              blc=[] and buc=[] means that the
        %              lower and upper bounds are plus and minus infinite
        %              respectively. The same interpretation is used for
        %              blx and bux. Note -inf is allowed in blc and blx.
        %              Similarly, inf is allowed in buc and bux.
        
        if (isempty(csense))
            %assumes all equality constraints
            %[res] = msklpopt(      c,a,blc,buc,blx,bux,param,cmd)
            [res] = msklpopt(osense*c,A,b,b,lb,ub,param,cmd);
        else
            blc=b;
            buc=b;
            buc(csense == 'G')=inf;
            blc(csense == 'L')=-inf;
            %[res] = msklpopt(       c,a,blc,buc,blx,bux,param,cmd)
            [res] = msklpopt(osense*c,A,blc,buc,lb,ub,param,cmd);
%             res.sol.itr
%             min(buc(csense == 'E')-A((csense == 'E'),:)*res.sol.itr.xx)
%             min(A((csense == 'E'),:)*res.sol.itr.xx-blc(csense == 'E'))
%             pasue(eps)
        end
        if (isfield(res,'sol'))
            if isfield(res.sol,'itr')
                origStat=res.sol.itr.solsta;
                if  strcmp(res.sol.itr.solsta,'OPTIMAL') || ...
                        strcmp(res.sol.itr.solsta,'MSK_SOL_STA_OPTIMAL') || ...
                        strcmp(res.sol.itr.solsta,'MSK_SOL_STA_NEAR_OPTIMAL')
                    stat = 1; % Optimal solution found
                    x=res.sol.itr.xx; % primal solution.
                    y=res.sol.itr.y; % dual variable to blc <= A*x <= buc
                    w=res.sol.itr.slx-res.sol.itr.sux; %dual to bux <= x   <= bux
                    %TODO  -work this out with Erling
                    %override if specific solver selected
                    if isfield(param,'MSK_IPAR_OPTIMIZER')
                        switch param.MSK_IPAR_OPTIMIZER
                            case {'MSK_OPTIMIZER_PRIMAL_SIMPLEX','MSK_OPTIMIZER_DUAL_SIMPLEX'}
                                stat = 1; % Optimal solution found
                                x=res.sol.bas.xx; % primal solution.
                                y=res.sol.bas.y; % dual variable to blc <= A*x <= buc
                                w=res.sol.bas.slx-res.sol.bas.sux; %dual to bux <= x   <= bux
                            case 'MSK_OPTIMIZER_INTPNT'
                                stat = 1; % Optimal solution found
                                x=res.sol.itr.xx; % primal solution.
                                y=res.sol.itr.y; % dual variable to blc <= A*x <= buc
                                w=res.sol.itr.slx-res.sol.itr.sux; %dual to bux <= x   <= bux
                        end
                    end
                    if isfield(res.sol,'bas') && 0
                        %override
                        stat = 1; % Optimal solution found
                        x=res.sol.bas.xx; % primal solution.
                        y=res.sol.bas.y; % dual variable to blc <= A*x <= buc
                        w=res.sol.bas.slx-res.sol.bas.sux; %dual to bux <= x   <= bux
                    end
                    f=c'*x;
                elseif strcmp(res.sol.itr.solsta,'MSK_SOL_STA_PRIM_INFEAS_CER') ||...
                        strcmp(res.sol.itr.solsta,'MSK_SOL_STA_NEAR_PRIM_INFEAS_CER') ||...
                        strcmp(res.sol.itr.solsta,'MSK_SOL_STA_DUAL_INFEAS_CER') ||...
                        strcmp(res.sol.itr.solsta,'MSK_SOL_STA_NEAR_DUAL_INFEAS_CER')
                    stat=0; %infeasible
                    x=[];
                    y=[];
                    w=[];
                end
            elseif ( isfield(res.sol,'bas') )
                if strcmp(res.sol.bas.solsta,'OPTIMAL') || ...
                        strcmp(res.sol.bas.solsta,'MSK_SOL_STA_OPTIMAL') || ...
                        strcmp(res.sol.bas.solsta,'MSK_SOL_STA_NEAR_OPTIMAL')
                    stat = 1; % Optimal solution found
                    x=res.sol.bas.xx; % primal solution.
                    y=res.sol.bas.y; % dual variable to blc <= A*x <= buc
                    w=res.sol.bas.slx-res.sol.bas.sux; %dual to bux <= x   <= bux
                    %override if specific solver selected
                    if isfield(param,'MSK_IPAR_OPTIMIZER')
                        switch param.MSK_IPAR_OPTIMIZER
                            case {'MSK_OPTIMIZER_PRIMAL_SIMPLEX','MSK_OPTIMIZER_DUAL_SIMPLEX'}
                                stat = 1; % Optimal solution found
                                x=res.sol.bas.xx; % primal solution.
                                y=res.sol.bas.y; % dual variable to blc <= A*x <= buc
                                w=res.sol.bas.slx-res.sol.bas.sux; %dual to bux <= x   <= bux
                            case 'MSK_OPTIMIZER_INTPNT'
                                stat = 1; % Optimal solution found
                                x=res.sol.itr.xx; % primal solution.
                                y=res.sol.itr.y; % dual variable to blc <= A*x <= buc
                                w=res.sol.itr.slx-res.sol.itr.sux; %dual to bux <= x   <= bux
                        end
                    end
                    f=c'*x;
                elseif strcmp(res.sol.bas.solsta,'MSK_SOL_STA_PRIM_INFEAS_CER') ||...
                        strcmp(res.sol.bas.solsta,'MSK_SOL_STA_NEAR_PRIM_INFEAS_CER') ||...
                        strcmp(res.sol.bas.solsta,'MSK_SOL_STA_DUAL_INFEAS_CER') ||...
                        strcmp(res.sol.bas.solsta,'MSK_SOL_STA_NEAR_DUAL_INFEAS_CER')
                    stat=0; %infeasible
                    x=[];
                    y=[];
                    w=[];
                end
            end
        else
            origStat=[];
            stat=-1;
            x=[];
            y=[];
            w=[];
        end
        
        if isfield(param,'MSK_IPAR_OPTIMIZER')
            algorithm=param.MSK_IPAR_OPTIMIZER;
        end
    case 'mosek_linprog'
        %% mosek
        %if mosek is installed, and the paths are added ahead of matlab's
        %built in paths, then mosek linprog shaddows matlab linprog and
        %is used preferentially
        if parametersStructureFlag
            options=directParamStruct;
        else
            options=struct();
        end
        %only set print level if not set already
        if ~isfield(options,'Display')
            switch printLevel
                case 0
                    options.Display='off';
                case 1
                    options.Display='final';
                case 2
                    options.Display='iter';
                otherwise
                    options.Display='off';
            end
        end
        %generate proper mosek options structure for linprog
        options = mskoptimset(options);
        
        if (isempty(csense))
            [x,f,origStat,output,lambda] = linprog(c*osense,[],[],A,b,lb,ub,[],options);
        else
            Aeq = A(csense == 'E',:);
            beq = b(csense == 'E');
            Ag = A(csense == 'G',:);
            bg = b(csense == 'G');
            Al = A(csense == 'L',:);
            bl = b(csense == 'L');
            clear A;
            A = [Al;-Ag];
            clear b;
            b = [bl;-bg];
            [x,f,origStat,output,lambda] = linprog(c*osense,A,b,Aeq,beq,lb,ub,[],options);
        end
        y = [];
        if (origStat > 0)
            stat = 1; % Optimal solution found
            f = f*osense;
            y = zeros(size(A,1),1);
            y(csense == 'E',1) = -lambda.eqlin;
            y(csense == 'L' | csense == 'G',1) = -lambda.ineqlin;
            y(csense == 'G',1)=-y(csense == 'G',1); %change sign
            w = lambda.lower-lambda.upper;
        elseif (origStat < 0)
            stat = 0; % Infeasible
        else
            stat = -1; % Solution did not converge
        end
        
    case 'gurobi'
        %% gurobi
        % Free academic licenses for the Gurobi solver can be obtained from
        % http://www.gurobi.com/html/academic.html
        %
        % The code below uses Gurobi Mex to interface with Gurobi. It can be downloaded from
        % http://www.convexoptimization.com/wikimization/index.php/Gurobi_Mex:_A_MATLAB_interface_for_Gurobi

        if parametersStructureFlag
            opts=directParamStruct;
        else
            opts=struct();
        end    
        if ~isfield(opts,'Display')
            if printLevel == 0
                % Version v1.10 of Gurobi Mex has a minor bug. For complete silence
                % Remove Line 736 of gurobi_mex.c: mexPrintf("\n");
                opts.Display = 0;
                opts.DisplayInterval = 0;
            else
                opts.Display = 1;
            end
        end
        if ~isfield(opts,'FeasibilityTol')
            opts.FeasibilityTol = feasTol;
        end
        if ~isfield(opts,'OptimalityTol')
            opts.OptimalityTol = optTol;
        end
        
        if (isempty(csense))
            clear csense
            csense(1:length(b),1) = '=';
        else
            csense(csense == 'L') = '<';
            csense(csense == 'G') = '>';
            csense(csense == 'E') = '=';
            csense = csense(:);
        end
        %gurobi_mex doesn't cast logicals to doubles automatically
        c = double(c);
        [x,f,origStat,output,y] = gurobi_mex(c,osense,sparse(A),b, ...
                                             csense,lb,ub,[],opts);
        w=[];                               
        if origStat==2
            w = c - A'*y;%reduced cost added -Ronan Jan 19th 2011
           stat = 1; % Optimal solutuion found
        elseif origStat==3
           stat = 0; % Infeasible
        elseif origStat==5
           stat = 2; % Unbounded
        elseif origStat==4
           stat = 0; % Gurobi reports infeasible *or* unbounded
        else
           stat = -1; % Solution not optimal or solver problem
        end
        
    case {'gurobi5','gurobi6'}
        %% gurobi 5
        % Free academic licenses for the Gurobi solver can be obtained from
        % http://www.gurobi.com/html/academic.html
        %resultgurobi = struct('x',[],'objval',[],'pi',[]);
        
        %  The params struct contains Gurobi parameters. A full list may be
        %  found on the Parameter page of the reference manual:
        %     http://www.gurobi.com/documentation/5.5/reference-manual/node798#sec:Parameters
        %  For example:
        %   params.outputflag = 0;          % Silence gurobi
        %   params.resultfile = 'test.mps'; % Write out problem to MPS file
        
        % params.method gives the algorithm used to solve continuous models 
        % -1=automatic, 
        %  0=primal simplex,
        %  1=dual simplex,
        %  2=barrier,
        %  3=concurrent,
        %  4=deterministic concurrent 
        %i.e. params.method     = 1;          % Use dual simplex method

        if parametersStructureFlag
            param=directParamStruct;
        else
            param=struct();
        end
        if ~isfield(param,'OutputFlag')
            switch printLevel
                case 0
                    param.OutputFlag = 0;
                    param.DisplayInterval = 1;
                case printLevel>1
                    param.OutputFlag = 1;
                    param.DisplayInterval = 5;
                otherwise
                    param.OutputFlag = 0;
                    param.DisplayInterval = 1;
            end
        end
        if ~isfield(param,'FeasibilityTol')
            param.FeasibilityTol = feasTol;
        end
        if ~isfield(param,'OptimalityTol')
            param.OptimalityTol = optTol;
        end

        if (isempty(LPproblem.csense))
            clear LPproblem.csense
            LPproblem.csense(1:length(b),1) = '=';
        else
            LPproblem.csense(LPproblem.csense == 'L') = '<';
            LPproblem.csense(LPproblem.csense == 'G') = '>';
            LPproblem.csense(LPproblem.csense == 'E') = '=';
            LPproblem.csense = LPproblem.csense(:);
        end
	
        if LPproblem.osense == -1
            LPproblem.osense = 'max';
        else
            LPproblem.osense = 'min';
        end
        
        LPproblem.A = deal(sparse(LPproblem.A));
        LPproblem.modelsense = LPproblem.osense;
        [LPproblem.rhs,LPproblem.obj,LPproblem.sense] = deal(LPproblem.b,double(LPproblem.c),LPproblem.csense);
        
        %basis reuse - Ronan
        if isfield(LPproblem,'basis') && ~isempty(LPproblem.basis)
            LPproblem.cbasis = full(LPproblem.basis.cbasis);
            LPproblem.vbasis = full(LPproblem.basis.vbasis);
            LPproblem=rmfield(LPproblem,'basis');
        end
        
        %call the solver
        resultgurobi = gurobi(LPproblem,param);
        
        %see the solvers original status -Ronan
        origStat = resultgurobi.status;
        switch resultgurobi.status
            case 'OPTIMAL'
                stat = 1; % Optimal solution found
                [x,f,y,w] = deal(resultgurobi.x,resultgurobi.objval,-resultgurobi.pi,-resultgurobi.rc);
                %save the basis
                basis.vbasis=resultgurobi.vbasis;
                basis.cbasis=resultgurobi.cbasis;
%                 if isfield(LPproblem,'cbasis')
%                     LPproblem=rmfield(LPproblem,'cbasis');
%                 end
%                 if isfield(LPproblem,'vbasis')
%                     LPproblem=rmfield(LPproblem,'vbasis');
%                 end
            case 'INFEASIBLE'
                stat = 0; % Infeasible
            case 'UNBOUNDED'
                stat = 2; % Unbounded
            case 'INF_OR_UNBD'
                stat = 0; % Gurobi reports infeasible *or* unbounded
            otherwise
                stat = -1; % Solution not optimal or solver problem
        end
        
        if isfield(param,'Method')
            % -1=automatic,
            %  0=primal simplex,
            %  1=dual simplex,
            %  2=barrier,
            %  3=concurrent,
            %  4=deterministic concurrent
            %i.e. params.method     = 1;          % Use dual simplex method
            switch param.Method
                case -1
                    algorithm='automatic';
                case 1
                    algorithm='primal simplex';
                case 2
                    algorithm='dual simplex';
                case 3
                    algorithm='barrier';
                case 4
                    algorithm='concurrent';
                otherwise
                    algorithm='deterministic concurrent';
            end
        end
        
    case 'matlab'
        %matlab is not a reliable LP solver
        if (isempty(csense))
            [x,f,origStat,output,lambda] = linprog(c*osense,[],[],A,b,lb,ub);
        else
            Aeq = A(csense == 'E',:);
            beq = b(csense == 'E');
            Ag = A(csense == 'G',:);
            bg = b(csense == 'G');
            Al = A(csense == 'L',:);
            bl = b(csense == 'L');
            clear A;
            A = [Al;-Ag];
            clear b;
            b = [bl;-bg];
            [x,f,origStat,output,lambda] = linprog(c*osense,A,b,Aeq,beq,lb,ub);
        end
        y = [];
        if (origStat > 0)
            stat = 1; % Optimal solution found
            f = f*osense;
            y = lambda.eqlin;
            w = lambda.lower-lambda.upper;
        elseif (origStat < 0)
            stat = 0; % Infeasible
        else
            stat = -1; % Solution did not converge
        end

    case 'tomlab_cplex'
        %% Tomlab
        if (~isempty(csense))
            b_L(csense == 'E') = b(csense == 'E');
            b_U(csense == 'E') = b(csense == 'E');
            b_L(csense == 'G') = b(csense == 'G');
            b_U(csense == 'G') = 1e6;
            b_L(csense == 'L') = -1e6;
            b_U(csense == 'L') = b(csense == 'L');
        else
            b_L = b;
            b_U = b;
        end
        tomlabProblem = lpAssign(osense*c,A,b_L,b_U,lb,ub);
        %Result = tomRun('cplex', tomlabProblem, 0);
        % This is faster than using tomRun
        
        %set parameters
        tomlabProblem.optParam = optParamDef('cplex',tomlabProblem.probType);
        tomlabProblem.QP.F = [];
        tomlabProblem.PriLevOpt = printLevel;
        
        %if basis is availible use it
        if isfield(LPproblem,'basis') && ~isempty(LPproblem.basis)
            tomlabProblem.MIP.basis = LPproblem.basis;
        end
        
        %set tolerance
        tomlabProblem.MIP.cpxControl.EPRHS = feasTol;
        tomlabProblem.MIP.cpxControl.EPOPT = optTol;
        
        %solve
        Result = cplexTL(tomlabProblem);

        % Assign results
        x = Result.x_k;
        f = osense*sum(tomlabProblem.QP.c.*Result.x_k);
        %        [Result.f_k f]

        origStat = Result.Inform;
        w = osense*Result.v_k(1:length(lb));
        y = osense*Result.v_k((length(lb)+1):end);
        basis = Result.MIP.basis;
        if (origStat == 1)
            stat = 1;
        elseif (origStat == 3)
            stat = 0;
        elseif (origStat == 2 || origStat == 4)
            stat = 2;
        else
            stat = -1;
        end
    case 'cplex_direct'
        %% 
        %Tomlab cplex.m direct
        %Used with the current script, only some of the control affoarded with
        %this interface is provided. Primarily, this is to change the print
        %level and whether to minimise the Euclidean Norm of the internal
        %fluxes or not.
        %See solveCobraLPCPLEX.m for more refined control of cplex
        %Ronan Fleming 11/12/2008
        if isfield(LPproblem,'basis') && ~isempty(LPproblem.basis)
            LPproblem.LPBasis = LPproblem.basis;
        end
        [solution,LPprob] = solveCobraLPCPLEX(LPproblem,printLevel,1,[],[],minNorm);
        solution.basis = LPprob.LPBasis;
        solution.solver = solver;
        solution.algorithm = algorithm; %dummy
        if exist('clone1.log','file')
            delete('clone1.log')
        end
    case 'ibm_cplex'
        %%
        %By default use the complex ILOG-CPLEX interface as it seems to be faster
        %IBM(R) ILOG(R) CPLEX(R) Interactive Optimizer 12.5.1.0
        ILOGcomplex=1;
        if ILOGcomplex
            % Initialize the CPLEX object
            try
                ILOGcplex = Cplex('fba');
            catch ME
                error('CPLEX not installed or licence server not up')
            end
            %complex ILOG-CPLEX interface
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
            ILOGcplex.Model.sense = 'minimize';
            
            % Now populate the problem with the data
            ILOGcplex.Model.obj   = osense*c;
            ILOGcplex.Model.lb    = lb;
            ILOGcplex.Model.ub    = ub;
            ILOGcplex.Model.A     = LPproblem.A;
            ILOGcplex.Model.lhs   = b_L;
            ILOGcplex.Model.rhs   = b_U;
            
            % ILOGcplex.Param.lpmethod.Cur
            % Determines which algorithm is used. Currently, the behavior of the Automatic setting is that CPLEX almost
            % always invokes the dual simplex method. The one exception is when solving the relaxation of an MILP model
            % when multiple threads have been requested. In this case, the Automatic setting will use the concurrent optimization
            % method. The Automatic setting may be expanded in the future so that CPLEX chooses the method
            % based on additional problem characteristics.
            %  0 Automatic
            % 1 Primal Simplex
            % 2 Dual Simplex
            % 3 Network Simplex (Does not work for almost all stoichiometric matrices)
            % 4 Barrier (Interior point method)
            % 5 Sifting
            % 6 Concurrent Dual, Barrier and Primal
            % Default: 0
            
            if parametersStructureFlag
                %TODO assign all parameters
                if isfield(directParamStruct,'lpmethod')
                    if isfield(directParamStruct.lpmethod,'Cur')
                        ILOGcplex.Param.lpmethod.Cur=directParamStruct.lpmethod.Cur;
                    end
                end
            else
                %automatically chooses algorithm
                ILOGcplex.Param.lpmethod.Cur=0;
            end

            %set the print level
            if printLevel==0
                ILOGcplex.DisplayFunc=[];
            else
                %print level
                ILOGcplex.Param.barrier.display.Cur = printLevel;
                ILOGcplex.Param.simplex.display.Cur = printLevel;
                ILOGcplex.Param.sifting.display.Cur = printLevel;
            end
            if isfield(ILOGcplex.Param,'printLevel')
                ILOGcplex.Param=rmfield(ILOGcplex.Param,'printLevel');
            end
            
            % Optimize the problem
            ILOGcplex.solve();
            
            origStat   = ILOGcplex.Solution.status;
            if origStat==1
                f = osense*ILOGcplex.Solution.objval;
                x = ILOGcplex.Solution.x;
                w = ILOGcplex.Solution.reducedcost;
                y = ILOGcplex.Solution.dual;
            end
            
            switch ILOGcplex.Param.lpmethod.Cur
                case 0
                    algorithm='Automatic';
                case 1
                    algorithm='Primal Simplex';
                case 2
                    algorithm='Dual Simplex';
                case 3
                    algorithm='Network Simplex (Does not work for almost all stoichiometric matrices)';
                case 4
                    algorithm='Barrier (Interior point method)';
                case 5
                    algorithm='Sifting';
                case 6
                    algorithm='Concurrent Dual, Barrier and Primal';
            end
        else
            %simple ibm ilog cplex interface
            if parametersStructureFlag
            	options = cplexoptimset(parameters,'param',default);
            else
                options = cplexoptimset('cplex');
            end
            switch printLevel
                case 0
                    %tries to stop print out of file
                    options.output.clonelog=0;
                    options = cplexoptimset(options,'diagnostics','off');
                case 1
                    options = cplexoptimset(options,'diagnostics','on');
            end
            if isfield(ILOGcplex.Param,'printLevel')
                options=rmfield(options,'printLevel');
            end
            
            if ~isempty(csense)
                if norm(minNorm,inf)~=0
                    Aineq = [LPproblem.A(csense == 'L',:); - LPproblem.A(csense == 'G',:)];
                    bineq = [b(csense == 'L',:); - b(csense == 'G',:)];
                    %             min      0.5*x'*H*x+f*x or f*x
                    %             st.      Aineq*x     <= bineq
                    %             Aeq*x    = beq
                    %             lb <= x <= ub
                    [x,fval,exitflag,output,lambda] = cplexqp(F,c,Aineq,bineq,LPproblem.A(csense == 'E',:),b(csense == 'E',1),lb,ub,[],options);
                else
                    Aineq = [LPproblem.A(csense == 'L',:); - LPproblem.A(csense == 'G',:)];
                    bineq = [b(csense == 'L',:); - b(csense == 'G',:)];
                    %        min      c*x
                    %        st.      Aineq*x <= bineq
                    %                 Aeq*x    = beq
                    %                 lb <= x <= ub
                    [x,fval,exitflag,output,lambda] = cplexlp(c,Aineq,bineq,LPproblem.A(csense == 'E',:),b(csense == 'E',1),lb,ub,[],options);
                end
                %primal
                f=osense*fval;
                %this is the dual to the equality constraints
                y=sparse(size(LPproblem.A,1),1);
                y(csense == 'E')=lambda.eqlin;
                %this is the dual to the inequality constraints
                y(csense == 'L')=lambda.ineqlin(1:nnz(csense == 'L'),1);
                y(csense == 'G')=lambda.ineqlin(nnz(csense == 'L')+1:end,1);
            else
                Aineq=[];
                bineq=[];
                if norm(minNorm,inf)~=0
                    [x,fval,exitflag,output,lambda] = cplexqp(F,c,Aineq,bineq,LPproblem.A,b,x_L,x_U,[],options);
                else
                    [x,fval,exitflag,output,lambda] = cplexlp(c,Aineq,bineq,LPproblem.A,b,x_L,x_U,[],options);
                end
                f=osense*fval;
                %this is the dual to the equality constraints
                y=sparse(size(LPproblem.A,1),1);
                y(csense == 'E')=lambda.eqlin;
                %this is the dual to the inequality constraints
                y(csense == 'L')=lambda.ineqlin(1:nnz(csense == 'L'),1);
                y(csense == 'G')=lambda.ineqlin(nnz(csense == 'L')+1:end,1);
            end
            %this is the dual to the simple ineequality constraints : reduced costs
            w=lambda.lower-lambda.upper;
            origStat = output.cplexstatus;
            algorithm='Automatic';
        end
        %1 = (Simplex or Barrier) Optimal solution is available.
        stat=origStat;
	if exist([pwd filesep 'clone1.log'],'file')
            delete('clone1.log')
        end
    case 'lindo'
        %%
        error('Solver type lindo is obsolete - use lindo_new or lindo_old instead');
    case 'pdco'
        %changed 30th May 2015 with Michael Saunders
        %%-----------------------------------------------------------------------
        % pdco.m: Primal-Dual Barrier Method for Convex Objectives (16 Dec 2008)
        %-----------------------------------------------------------------------
        % AUTHOR:
        %    Michael Saunders, Systems Optimization Laboratory (SOL),
        %    Stanford University, Stanford, California, USA.
        %Interfaced with Cobra toolbox by Ronan Fleming, 27 June 2009
        [nMet,nRxn]=size(LPproblem.A);
        x0 = ones(nRxn,1);
        y0 = zeros(nMet,1); 
        z0 = ones(nRxn,1);
        
        if 0
            %setting d1 to zero is dangerous numerically, but is necessary to avoid
            %minimising the Euclidean norm of the optimal flux. A more
            %numerically stable way is to use pdco via solveCobraQP, which has
            %a more reasonable d1 and should be more numerically robust. -Ronan
            d1=0;
            d2=1e-6;
        else
            d1=5e-4;
            d2=5e-4;
        end
        
        options = pdcoSet;
        if 0
            options.FeaTol    = 1e-12;
            options.OptTol    = 1e-12;
        end
        
        %pdco is a general purpose convex optization solver, not only a
        %linear optimization solver. As such, much control over the optimal
        %solution and the method for solution is available. However, this
        %also means you may have to tune the various parameters here,
        %especially xsize and zsize (see pdco.m) to get the real optimal
        %objective value
        xsize = 100;
        zsize = 100;
        
        options.Method=1; %Cholesky
        options.MaxIter=200;
        options.Print=printLevel;
        [x,y,w,inform,PDitns,CGitns,time] = ...
            pdco(osense*c,A,b,lb,ub,d1,d2,options,x0,y0,z0,xsize,zsize);
        f= c'*x;
        % inform = 0 if a solution is found;
        %        = 1 if too many iterations were required;
        %        = 2 if the linesearch failed too often;
        %        = 3 if the step lengths became too small;
        %        = 4 if Cholesky said ADDA was not positive definite.
        if (inform == 0)
            stat = 1;
        elseif (inform == 1 || inform == 2 || inform == 3)
            stat = 0;
        else
            stat = -1;
        end
        origStat=inform;
    case 'mps'
        %% BuildMPS
        % This calls buildMPS and generates a MPS format description of the
        % problem as the result
        % Build MPS Author: Bruno Luong
        % Interfaced with CobraToolbox by Richard Que (12/18/09)
        display('Solver set to MPS. This function will write out a .MPS file and return a matrix string for the LP problem');

        %default MPS parameters are no longer global variables, but set
        %here inside this function
        if parametersStructureFlag
            param=directParamStruct;
        else
            param=struct();
        end
        if isfield(param,'EleNames')
            EleNames=param.EleNames;
        else
            EleNames='';
        end
        if isfield(param,'EqtNames')
            EqtNames=param.EqtNames;
        else
            EqtNames='';
        end
        if isfield(param,'VarNames')
            VarNames=param.VarNames;
        else
            VarNames='';
        end
        if isfield(param,'EleNameFun')
            EleNameFun=directParamStruct.EleNameFun;
        else
            EleNameFun = @(m)(['LE' num2str(m)]);
        end
        if isfield(param,'EqtNameFun')
            EqtNameFun=param.EqtNameFun;
        else
            EqtNameFun = @(m)(['EQ' num2str(m)]);
        end
        if isfield(param,'VarNameFun')
            VarNameFun=param.VarNameFun;
        else
            VarNameFun = @(m)(['X' num2str(m)]);
        end
        if isfield(param,'PbName')
            PbName=param.PbName;
        else
            PbName='LPproble';
        end
        if isfield(param,'MPSfilename')
            MPSfilename=[param.MPSfilename '.mps'];
        else
            MPSfilename='LP.mps';
        end
        %split A matrix for L and E csense
        Ale = A(csense=='L',:);
        ble = b(csense=='L');
        Aeq = A(csense=='E',:);
        beq = b(csense=='E');
        
        %%%%Adapted from BuildMPS%%%%%
        [neq nvar]=size(Aeq);
        nle=size(Ale,1);
        if isempty(EleNames)
            EleNames=arrayfun(EleNameFun,(1:nle),'UniformOutput', false);
        end
        if isempty(EqtNames)
            EqtNames=arrayfun(EqtNameFun,(1:neq),'UniformOutput', false);
        end
        if isempty(VarNames)
            VarNames=arrayfun(VarNameFun,(1:nvar),'UniformOutput', false);
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        %http://www.mathworks.com/matlabcentral/fileexchange/19618-mps-format-exporting-tool/content/BuildMPS/BuildMPS.m
        %31st Jan 2016, changed c to osense*c as most solvers assume minimisation
        [solution] = BuildMPS(Ale, ble, Aeq, beq, osense*c, lb, ub, PbName,'MPSfilename',MPSfilename,'EleNames',EleNames,'EqtNames',EqtNames,'VarNames',VarNames);
    otherwise
        error(['Unknown solver: ' solver]);
        
end
if stat == -1
    %this is slow, so only check it if there is a problem
    if any(any(~isfinite(A)))
        error('Cannot perform LP on a stoichiometric matrix with NaN of Inf coefficents.')
    end
end

if ~strcmp(solver,'cplex_direct') && ~strcmp(solver,'mps')
    %% Assign solution
    t = etime(clock, t_start);
    if ~exist('basis','var'), basis=[]; end
    [solution.full,solution.obj,solution.rcost,solution.dual,solution.solver,solution.algorithm,solution.stat,solution.origStat,solution.time,solution.basis] = ...
        deal(x,f,w,y,solver,algorithm,stat,origStat,t,basis);
end

%% solveGlpk Solve actual LP problem using glpk and return relevant results
function [x,f,y,w,stat,origStat] = solveGlpk(c,A,b,lb,ub,csense,osense,params)

% Old way of calling glpk
%[x,f,stat,extra] = glpkmex(osense,c,A,b,csense,lb,ub,[],params);
[x,f,origStat,extra] = glpk(c,A,b,lb,ub,csense,[],osense,params);
y = extra.lambda;
w = extra.redcosts;
% Note that status handling may change (see glplpx.h)
if (origStat == 180 || origStat == 5)
    stat = 1; % Optimal solution found
elseif (origStat == 182 || origStat == 183 || origStat == 3 || origStat == 110)
    stat = 0; % Infeasible
elseif (origStat == 184 || origStat == 6)
    stat = 2; % Unbounded
else
    stat = -1; % Solution not optimal or solver problem
end
