function solution = solveCobraLP(LPproblem, varargin)
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
% Optional parameters can be entered using parameters structure or as
% parameter followed by parameter value: i.e. ,'printLevel',3)
%
% parameters    Structure containing optional parameters as fields.
%               Setting parameters = 'default' uses default setting set in
%               getCobraSolverParameters.
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
% changeCobraSolverParames('LP', 'parameter', value) function.  This
% includes the minNorm and the printLevel flags
%
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
%
%  origStat Original status returned by the specific solver
%  time     Solve time in seconds
%
%
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
% Tim Harrington     05/18/12 Added support for the Gurobi 5.0 solver


%% Process arguments etc

global CBTLPSOLVER
if (~isempty(CBTLPSOLVER))
    solver = CBTLPSOLVER;
else
    error('No solver found.  call changeCobraSolver(solverName)');
end
optParamNames = {'minNorm','printLevel','primalOnly','saveInput', ...
    'feasTol','optTol','EleNames','EqtNames','VarNames','EleNameFun', ...
    'EqtNameFun','VarNameFun','PbName','MPSfilename'};
parameters = '';
if nargin ~=1
    if mod(length(varargin),2)==0
        for i=1:2:length(varargin)-1
            if ismember(varargin{i},optParamNames)
                parameters.(varargin{i}) = varargin{i+1};
            else
                error([varargin{i} ' is not a valid optional parameter']);
            end
        end
    elseif strcmp(varargin{1},'default')
        parameters = 'default';
    elseif isstruct(varargin{1})
        parameters = varargin{1};
    else
        display('Warning: Invalid number of parameters/values')
        solution=[];
        return;
    end
end
[minNorm, printLevel, primalOnlyFlag, saveInput, feasTol, optTol] = ...
    getCobraSolverParams('LP',optParamNames(1:6),parameters);


%Save Input if selected
if ~isempty(saveInput)
    fileName = parameters.saveInput;
    if ~find(regexp(fileName,'.mat'))
        fileName = [fileName '.mat'];
    end
    display(['Saving LPproblem in ' fileName]);
    save(fileName,'LPproblem')
end


[A,b,c,lb,ub,csense,osense] = deal(LPproblem.A,LPproblem.b,LPproblem.c,LPproblem.lb,LPproblem.ub,LPproblem.csense,LPproblem.osense);

% if any(any(~isfinite(A)))
%     error('Cannot perform LP on a stoichiometric matrix with NaN of Inf coefficents.')
% end

% Defaults in case the solver does not return anything
f = [];
x = [];
y = [];
w = [];
origStat = -99;
stat = -99;

t_start = clock;
switch solver
    %% GLPK
    case 'glpk'
        params.msglev = printLevel; % level of verbosity
        params.tolbnd = feasTol; %tolerance
        params.toldj = optTol; %tolerance
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
        [x,f,y,w,stat,origStat] = solveGlpk(c,A,b,lb,ub,csense,osense,params);

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
        %if mosek is installed, and the paths are added ahead of matlab's
        %built in paths, then mosek linprog shaddows matlab linprog and
        %is used preferentially
        switch printLevel
            case 0
               options.Display='off';
            case 1
                options.Display='final';
            case 2
                options.Display='iter';
            otherwise
                % Ask for default options for a function.
                options  = optimset;
        end
                     
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
            y = lambda.eqlin;
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

        clear opts            % Use the default parameter settings
        if printLevel == 0
           % Version v1.10 of Gurobi Mex has a minor bug. For complete silence
           % Remove Line 736 of gurobi_mex.c: mexPrintf("\n"); 
           opts.Display = 0;
           opts.DisplayInterval = 0;
        else
           opts.Display = 1;
        end

        opts.FeasibilityTol = feasTol;
        opts.OptimalityTol = optTol;
        
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
        if origStat==2
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
        
    case 'gurobi5'
        %% gurobi 5
        % Free academic licenses for the Gurobi solver can be obtained from
        % http://www.gurobi.com/html/academic.html
        resultgurobi = struct('x',[],'objval',[],'pi',[]);
        LPproblem.A = deal(sparse(LPproblem.A));
        clear params            % Use the default parameter settings
        
        if printLevel == 0 
           params.OutputFlag = 0;
           params.DisplayInterval = 1;
        else
           params.OutputFlag = 1;
           params.DisplayInterval = 5;
        end

        params.FeasibilityTol = feasTol;
        params.OptimalityTol = optTol;
        
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
        
        LPproblem.modelsense = LPproblem.osense;
        [LPproblem.rhs,LPproblem.obj,LPproblem.sense] = deal(LPproblem.b,double(LPproblem.c),LPproblem.csense);
        resultgurobi = gurobi(LPproblem,params);
        
        if strcmp(resultgurobi.status,'OPTIMAL')
           stat = 1; % Optimal solution found
           [x,f,y] = deal(resultgurobi.x,resultgurobi.objval,resultgurobi.pi);
        elseif strcmp(resultgurobi.status,'INFEASIBLE')
           stat = 0; % Infeasible
        elseif strcmp(resultgurobi.status,'UNBOUNDED')
           stat = 2; % Unbounded
        elseif strcmp(resultgurobi.status,'INF_OR_UNBD')
           stat = 0; % Gurobi reports infeasible *or* unbounded
        else
           stat = -1; % Solution not optimal or solver problem
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
        w = Result.v_k(1:length(lb));
        y = Result.v_k((length(lb)+1):end);
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
        %% Tomlab cplex.m direct
        %Used with the current script, only some of the control affoarded with
        %this interface is provided. Primarily, this is to change the print
        %level and whether to minimise the Euclidean Norm of the internal
        %fluxes or not.
        %See solveCobraLPCPLEX.m for more refined control of cplex
        %Ronan Fleming 11/12/2008
        if isfield(LPproblem,'basis') && ~isempty(LPproblem.basis)
            LPproblem.LPBasis = LPproblem.basis;
        end
        [solution LPprob] = solveCobraLPCPLEX(LPproblem,printLevel,1,[],[],minNorm);
        solution.basis = LPprob.LPBasis;
        solution.solver = solver;

    case 'lindo'
        error('Solver type lindo is obsolete - use lindo_new or lindo_old instead');
    case 'pdco'
        %-----------------------------------------------------------------------
        % pdco.m: Primal-Dual Barrier Method for Convex Objectives (16 Dec 2008)
        %-----------------------------------------------------------------------
        % AUTHOR:
        %    Michael Saunders, Systems Optimization Laboratory (SOL),
        %    Stanford University, Stanford, California, USA.
        %Interfaced with Cobra toolbox by Ronan Fleming, 27 June 2009
        [nMet,nRxn]=size(LPproblem.A);
        x0 = ones(nRxn,1);
        y0 = ones(nMet,1);
        z0 = ones(nRxn,1);
 
        %setting d1 to zero is dangerous numerically, but is necessary to avoid 
        %minimising the Euclidean norm of the optimal flux. A more
        %numerically stable way is to use pdco via solveCobraQP, which has
        %a more reasonable d1 and should be more numerically robust. -Ronan
        d1=0; 
        d2=1e-6;
        options = pdcoSet;
        options.FeaTol    = 1e-12;
        options.OptTol    = 1e-12;
        %pdco is a general purpose convex optization solver, not only a
        %linear optimization solver. As such, much control over the optimal
        %solution and the method for solution is available. However, this
        %also means you may have to tune the various parameters here,
        %especially xsize and zsize (see pdco.m) to get the real optimal
        %objective value
        xsize = 1000;
        zsize = 10000;
        
        options.Method=2; %QR
        options.MaxIter=100;
        options.Print=printLevel;
        [x,y,w,inform,PDitns,CGitns,time] = ...
            pdco(osense*c*10000,A,b,lb,ub,d1,d2,options,x0,y0,z0,xsize,zsize);
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
        display('Solver set to MPS. This function will output an MPS matrix string for the LP problem');
        %Get optional parameters
        [EleNames,EqtNames,VarNames,EleNameFun,EqtNameFun,VarNameFun,PbName,MPSfilename] = ...
            getCobraSolverParams('LP',{'EleNames','EqtNames','VarNames','EleNameFun','EqtNameFun','VarNameFun','PbName','MPSfilename'},parameters);
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
        
        [solution] = BuildMPS(Ale, ble, Aeq, beq, c, lb, ub, PbName,'MPSfilename',MPSfilename,'EleNames',EleNames,'EqtNames',EqtNames,'VarNames',VarNames);
        
        
    otherwise
        error(['Unknown solver: ' solver]);
        
end
if ~strcmp(solver,'cplex_direct') && ~strcmp(solver,'mps')
    %% Assign solution
    t = etime(clock, t_start);
    if ~exist('basis','var'), basis=[]; end
    [solution.full,solution.obj,solution.rcost,solution.dual,solution.solver,solution.stat,solution.origStat,solution.time,solution.basis] = ...
        deal(x,f,w,y,solver,stat,origStat,t,basis);
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
