function solution = solveCobraMIQP(MIQPproblem,varargin)
%solveCobraQP Solve constraint-based QP problems
%
% solution = solveCobraQP(MIQPproblem,solver,verbFlag,solverParams)
%
% % Solves problems of the type
%
%      min   osense * 0.5 x' * F * x + osense * c' * x
%      s/t   lb <= x <= ub
%            A * x  <=/=/>= b
%            xi = integer
%
%INPUT
%MIQPproblem    Structure containing the following fields describing the QP
%               problem to be solved
%  A                LHS matrix
%  b                RHS vector
%  F                F matrix for quadratic objective (see above)
%  c                Objective coeff vector
%  lb               Lower bound vector
%  ub               Upper bound vector
%  osense           Objective sense (-1 max, +1 min)
%  csense           Constraint senses, a string containting the constraint
%                   sense for each row in A ('E', equality, 'G' greater
%                   than, 'L' less than).
%
%OPTIONAL INPUTS
% Optional parameters can be entered using parameters structure or as
% parameter followed by parameter value: i.e. ,'printLevel',3)
%
% parameters    Structure containing optional parameters as fields.
%  printLevel   Print level for solver
%  saveInput    Saves LPproblem to filename specified in field.
%               Setting parameters = 'default' uses default setting set in
%               getCobraSolverParameters.
%
% the solver defined in the CBT_MIQP_SOLVER global variable (set using
% changeCobraSolver). Solvers currently available are 'tomlab_cplex'
%
%OUTPUT
% solution      Structure containing the following fields describing a QP
%               solution
%  full             Full QP solution vector
%  obj              Objective value
%  solver           Solver used to solve QP problem
%  stat             Solver status in standardized form (see below)
%                       1   Optimal solution found
%                       2   Unbounded solution
%                       0   Infeasible QP
%                      -1   No optimal solution found (time limit etc)
%                       3   Solution exists but with problems
%  origStat         Original status returned by the specific solver
%  time             Solve time in seconds
%
%
% Markus Herrgard 6/8/07
% Tim Harrington  05/18/12 Added support for the Gurobi 5.0 solver

global CBT_MIQP_SOLVER;
solver = CBT_MIQP_SOLVER;

%optional parameters
optParamNames = {'printLevel', 'saveInput', 'timeLimit'};
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
[printLevel, saveInput, timeLimit] = getCobraSolverParams('QP',optParamNames,parameters);

[A,b,F,c,lb,ub,csense,osense, vartype] = ...
    deal(MIQPproblem.A,MIQPproblem.b,MIQPproblem.F,MIQPproblem.c,MIQPproblem.lb,MIQPproblem.ub,...
    MIQPproblem.csense,MIQPproblem.osense, MIQPproblem.vartype);

t_start = clock;
switch solver
%% CPLEX through TOMLAB
    case 'tomlab_cplex'
        if (~isempty(csense))
            b_L(csense == 'E') = b(csense == 'E');
            b_U(csense == 'E') = b(csense == 'E');
            b_L(csense == 'G') = b(csense == 'G');
            b_U(csense == 'G') = inf;
            b_L(csense == 'L') = -inf;
            b_U(csense == 'L') = b(csense == 'L');
        else
            b_L = b;
            b_U = b;
        end
        intVars = find((vartype == 'B') | (vartype == 'I'));
        %tomlabProblem = qpAssign(osense*F,osense*c,A,b_L,b_U,lb,ub,[],'CobraQP');
        tomlabProblem  = miqpAssign(osense*F, osense*c, A, b_L, b_U, lb, ub,[], ...
                             intVars, [],[],[],'CobraMIQP');
        tomlabProblem.CPLEX.LogFile = 'MIQPproblem.log';

        %optional parameters
        PriLvl = printLevel;

        %Save Input if selected
        if ~isempty(saveInput)
            fileName = parameters.saveInput;
            if ~find(regexp(fileName,'.mat'))
                fileName = [fileName '.mat'];
            end
            display(['Saving MIQPproblem in ' fileName]);
            save(fileName,'MIQPproblem')
        end
        tomlabProblem.MIP.cpxControl.TILIM = timeLimit; % time limit
        tomlabProblem.MIP.cpxControl.THREADS = 1; % by default use only one thread
        Result = tomRun('cplex', tomlabProblem, PriLvl);

        x = Result.x_k;
        f = osense*Result.f_k;
        stat = Result.Inform;
        if (stat == 1 ||stat == 101 || stat == 102)
            solStat = 1; % Optimal
        elseif (stat == 3 || stat == 4)
            solStat = 0; % Infeasible
        elseif (stat == 103)
            solStat = 0; % Integer Infeasible
        elseif (stat == 2 || stat == 118 || stat == 119)
            solStat = 2; % Unbounded
        elseif (stat == 106 || stat == 108 || stat == 110 || stat == 112 || stat == 114 || stat == 117)
            solStat = -1; % No integer solution exists
        elseif (stat >= 10)
            solStat = -1; % No optimal solution found (time or other limits reached, other infeasibility problems)
        else
            solStat = 3; % Solution exists, but either scaling problems or not proven to be optimal
        end
            %%
    case 'gurobi_mex'
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



        if (isempty(csense))
            clear csense
            csense(1:length(b),1) = '=';
        else
            csense(csense == 'L') = '<';
            csense(csense == 'G') = '>';
            csense(csense == 'E') = '=';
            csense = csense(:);
        end

        % Gurobi passes individual terms instead of an F matrix. qrow and
        % qcol specify which variables are multipled to get each term,
        % while qval specifies the coefficients of each term.

        [qrow,qcol,qval]=find(F);
        qrow=qrow'-1;   % -1 because gurobi numbers indices from zero, not one.
        qcol=qcol'-1;
        qval=0.5*qval';

        opts.QP.qrow = int32(qrow);
        opts.QP.qcol = int32(qcol);
        opts.QP.qval = qval;
        opts.Method = 0;    % 0 - primal, 1 - dual
        opts.Presolve = -1; % -1 - auto, 0 - no, 1 - conserv, 2 - aggressive
        opts.FeasibilityTol = 1e-6;
        opts.IntFeasTol = 1e-5;
        opts.OptimalityTol = 1e-6;
        %opt.Quad=1;

        %gurobi_mex doesn't cast logicals to doubles automatically
    	c = double(c);
        [x,f,origStat,output,y] = gurobi_mex(c,osense,sparse(A),b, ...
                                             csense,lb,ub,vartype,opts);
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
        solStat = stat;
    case 'gurobi'
     %% gurobi5
     % Free academic licenses for the Gurobi solver can be obtained from
        % http://www.gurobi.com/html/academic.html
        resultgurobi = struct('x',[],'objval',[],'pi',[]);
        clear params            % Use the default parameter settings
        if printLevel == 0
            params.OutputFlag = 0;
            params.DisplayInterval = 1;
        else
            params.OutputFlag = 1;
            params.DisplayInterval = 5;
        end

        params.Method = 0;    %-1 = automatic, 0 = primal simplex, 1 = dual simplex, 2 = barrier, 3 = concurrent, 4 = deterministic concurrent
        params.Presolve = -1; % -1 - auto, 0 - no, 1 - conserv, 2 - aggressive
        params.IntFeasTol = 1e-5;
        params.FeasibilityTol = 1e-6;
        params.OptimalityTol = 1e-6;

        if (isempty(MIQPproblem.csense))
            clear MIQPproblem.csense
            MIQPproblem.csense(1:length(b),1) = '=';
        else
            MIQPproblem.csense(MIQPproblem.csense == 'L') = '<';
            MIQPproblem.csense(MIQPproblem.csense == 'G') = '>';
            MIQPproblem.csense(MIQPproblem.csense == 'E') = '=';
            MIQPproblem.csense = MIQPproblem.csense(:);
        end

        if MIQPproblem.osense == -1
            MIQPproblem.osense = 'max';
        else
            MIQPproblem.osense = 'min';
        end

        MIQPproblem.vtype = vartype;
        MIQPproblem.Q = 0.5*sparse(MIQPproblem.F);
        MIQPproblem.modelsense = MIQPproblem.osense;
        [MIQPproblem.A,MIQPproblem.rhs,MIQPproblem.obj,MIQPproblem.sense] = deal(sparse(MIQPproblem.A),MIQPproblem.b,MIQPproblem.c,MIQPproblem.csense);
        resultgurobi = gurobi(MIQPproblem,params);
        solStat = resultgurobi.status;
        if strcmp(resultgurobi.status,'OPTIMAL')
           stat = 1; % Optimal solution found

           if exist('resultgurobi.pi')
               [x,f,y] = deal(resultgurobi.x,resultgurobi.objval,resultgurobi.pi);
           else
               [x,f] = deal(resultgurobi.x,resultgurobi.objval);
           end
        elseif strcmp(resultgurobi.status,'INFEASIBLE')
           stat = 0; % Infeasible
        elseif strcmp(resultgurobi.status,'UNBOUNDED')
           stat = 2; % Unbounded
        elseif strcmp(resultgurobi.status,'INF_OR_UNBD')
           stat = 0; % Gurobi reports infeasible *or* unbounded
        else
           stat = -1; % Solution not optimal or solver problem
        end
        %%
    otherwise
        error(['Unknown solver: ' solver]);
end
%%
t = etime(clock, t_start);

solution.obj = f;
solution.solver = solver;
solution.stat = solStat;
solution.origStat = stat;
solution.time = t;
solution.full = x;
