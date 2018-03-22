function solution = solveCobraQP(QPproblem, varargin)
% Solves constraint-based QP problems
%
% The solver is defined in the CBT_MILP_SOLVER global variable
% (set using changeCobraSolver). Solvers currently available are
% 'tomlab_cplex', 'mosek' and 'qpng' (limited support for small problems)
%
% Solves problems of the type
% :math:`min  0.5 x' * F * x + osense * c' * x`
% s/t :math:`lb <= x <= ub`
% :math:`A * x  <=/=/>= b`
%
% USAGE:
%
%    solution = solveCobraQP(QPproblem, varargin)
%
% INPUT:
%    QPproblem:       Structure containing the following fields describing the QP
%
%                       * .A - LHS matrix
%                       * .b - RHS vector
%                       * .F - F matrix for quadratic objective (see above)
%                       * .c - Objective coeff vector
%                       * .lb - Lower bound vector
%                       * .ub - Upper bound vector
%                       * .osense - Objective sense (-1 max, +1 min)
%                       * .csense - Constraint senses, a string containing the constraint sense for
%                         each row in A ('E', equality, 'G' greater than, 'L' less than).
%
% Optional parameters can be entered using parameters structure or as
% parameter followed by parameter value: i.e. ,'printLevel', 3)
% Setting `parameters` = 'default' uses default setting set in
% `getCobraSolverParameters`.
%
% OPTIONAL INPUTS:
%    parameters:      Structure containing optional parameters.
%    printLevel:      Print level for solver
%    saveInput:       Saves LPproblem to filename specified in field.
%
% OUTPUT:
%    solution:        Structure containing the following fields describing a QP solution
%
%                       * .full:        Full QP solution vector
%                       * .rcost:       Reduced costs, dual solution to :math:`lb <= x <= ub`
%                       * .dual:        dual solution to :math:`A*x <=/=/>= b`
%                       * .slack:       slack variable such that :math:`A*x + s = b`
%                       * .obj:         Objective value
%                       * .solver:      Solver used to solve QP problem
%                       * .origStat:    Original status returned by the specific solver
%                       * .time:        Solve time in seconds
%                       * .stat:        Solver status in standardized form (see below)
%
%                         * 1 - Optimal solution
%                         * 2 - Unbounded solution
%                         * 0 - Infeasible
%                         * -1 - No solution reported (timelimit, numerical problem etc)
%
% .. Author:
%       - Markus Herrgard        6/8/07
%       - Ronan Fleming         12/07/09  Added support for mosek
%       - Ronan Fleming         18 Jan 10 Added support for pdco
%       - Josh Lerman           04/17/10 changed def. parameters, THREADS, QPMETHOD
%       - Tim Harrington        05/18/12 Added support for the Gurobi 5.0 solver

global CBT_QP_SOLVER;

if (~isempty(CBT_QP_SOLVER))
    solver = CBT_QP_SOLVER;
else
    error('No solver found');
end

optParamNames = {'printLevel','saveInput','optTol','feasTol'};
parameters = struct();
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

% Defaults in case the solver does not return anything
x = [];
y = [];
w = [];
f = [];
s = [];%todo, implement slack variable return for all solvers (gurboi and mosek done)
xInt = [];
xCont = [];
stat = -99;
solStat = -99;

%parameters
[printLevel, saveInput,optTol,feasTol] = getCobraSolverParams('QP',optParamNames,parameters);

[A,b,F,c,lb,ub,csense,osense] = ...
    deal(QPproblem.A,QPproblem.b,QPproblem.F,QPproblem.c,QPproblem.lb,QPproblem.ub,...
    QPproblem.csense,QPproblem.osense);

t_start = clock;
switch solver
    %%
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
        tomlabProblem = qpAssign(F,osense*c,A,b_L,b_U,lb,ub,[],'CobraQP');

        %optional parameters
        tomlabProblem.PriLvl=printLevel;
        tomlabProblem.MIP.cpxControl.QPMETHOD = 1;
        tomlabProblem.MIP.cpxControl.THREADS = 1;

        %Save Input if selected
        if ~isempty(saveInput)
            fileName = saveInput;
            if ~find(regexp(fileName,'.mat'))
                fileName = [fileName '.mat'];
            end
            display(['Saving QPproblem in ' fileName]);
            save(fileName,'QPproblem')
        end

        Result = tomRun('cplex', tomlabProblem);
        x = Result.x_k;
        f = osense*Result.f_k;
        origStat = Result.Inform;
        if (origStat == 1)
            stat = 1; % Optimal
        elseif (origStat == 3 || origStat == 4)
            stat = 0; % Infeasible
        elseif (origStat == 2)
            stat = 2; % Unbounded
        elseif (origStat >= 10)
            stat = -1; % No optimal solution found (time or other limits reached, other infeasibility problems)
        else
            stat = 3; % Solution exists, but either scaling problems or not proven to be optimal
        end
        %%
     case 'ibm_cplex'
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

        %Set up the linear part
        CplexQPProblem = Cplex();
        CplexQPProblem.Model.A = A;
        CplexQPProblem.Model.lb = lb;
        CplexQPProblem.Model.ub = ub;
        CplexQPProblem.Model.rhs = b_U;
        CplexQPProblem.Model.lhs = b_L;
        CplexQPProblem.Model.obj = osense*c;
        CplexQPProblem.Model.Q = F;

        %optional parameters
        if printLevel == 0  % set display function as empty
            CplexQPProblem.DisplayFunc=[];
        end
        CplexQPProblem.Param.output.writelevel.Cur = printLevel;
        CplexQPProblem.Param.qpmethod.Cur = 1;

        % Set IBM-Cplex-specific parameters
        parameters = rmfield(parameters, intersect(fieldnames(parameters), optParamNames));
        CplexQPProblem = setCplexParam(CplexQPProblem, parameters, printLevel);
        
        %Save Input if selected
        if ~isempty(saveInput)
            fileName = saveInput;
            if ~find(regexp(fileName,'.mat'))
                fileName = [fileName '.mat'];
            end
            display(['Saving QPproblem in ' fileName]);
            save(fileName,'QPproblem')
        end

        Result = CplexQPProblem.solve();
        if isfield(Result,'x')  % Cplex solution may not have x
            x = Result.x;
        end
        if isfield(Result,'objval')  % Cplex solution may not have objval
            f = osense*Result.objval;
        end
        origStat = Result.status;
        if (origStat == 1 || origStat == 101)
            stat = 1; % Optimal
        elseif (origStat == 3 || origStat == 4 || origStat == 103)
            stat = 1; % Infeasible
        elseif (origStat == 2)
            stat = 2; % Unbounded
        else
            stat = -1; % No optimal solution found (time or other limits reached, other infeasibility problems)
        end
        %%
    case 'cplex_direct'
        %% Tomlab cplex.m direct
        %Used with the current script, only some of the control affoarded with
        %this interface is provided. Primarily, this is to change the print
        %level and whether to minimise the Euclidean Norm of the internal
        %fluxes or not.
        %See solveCobraLPCPLEX.m for more refined control of cplex
        %Ronan Fleming 11/12/2008

        solution=solveCobraLPCPLEX(QPproblem,printLevel,[],[],[],minNorm);
        %%
    case 'qpng'
        % qpng.m This file is part of GLPKMEX.
        % Copyright 2006-2007 Nicolo Giorgetti.
        %
        % Solves the general quadratic program
        %      min 0.5 x'*H*x + q'*x
        %       x
        % subject to
        %      A*x [ "=" | "<=" | ">=" ] b
        %      lb <= x <= ub
        ctype=csense;
        ctype(('G'==csense))='L';
        ctype(('E'==csense))='E';
        ctype(('L'==csense))='U';

        x0=ones(size(QPproblem.A,2),1);
        %equality constraint matrix must be full row rank
        [x, f, y, info] = qpng (QPproblem.F, QPproblem.c*QPproblem.osense, full(QPproblem.A), QPproblem.b, ctype, QPproblem.lb, QPproblem.ub, x0);

        f = 0.5*x'*QPproblem.F*x + c'*x;

        w=[];

        if (info.status == 0)
            stat = 1;
        elseif (info.status == 1)
            stat = 0;
        else
            stat = -1;
        end
        origStat=info.status;
        %%
    case 'mosek'
        if (~isempty(csense))
            b_L(csense == 'E',1) = b(csense == 'E');
            b_U(csense == 'E',1) = b(csense == 'E');
            b_L(csense == 'G',1) = b(csense == 'G');
            b_U(csense == 'G',1) = inf;
            b_L(csense == 'L',1) = -inf;
            b_U(csense == 'L',1) = b(csense == 'L');
        else
            b_L = b;
            b_U = b;
        end

        if printLevel>0
            cmd='minimize';
        else
            cmd='minimize echo(0)';
        end

        % Optimize the problem.
        % min 0.5*x'*F*x + osense*c'*x
        % st. blc <= A*x <= buc
        %     bux <= x   <= bux
        [res] = mskqpopt(F,osense*c,A,b_L,b_U,lb,ub,[],cmd);

        if isempty(res)
            stat=3;
        else
            if isfield(res,'sol')
                origStat=res.sol.itr.solsta;
                if strcmp(res.sol.itr.prosta,'PRIMAL_AND_DUAL_FEASIBLE') &&  (strcmp(res.sol.itr.solsta,'OPTIMAL') || strcmp(res.sol.itr.solsta,'NEAR_OPTIMAL'))
                    stat=1;
                    % x solution.
                    x = res.sol.itr.xx;
                    f = 0.5*x'*F*x + c'*x;

                    %dual to equality
                    y= res.sol.itr.y;

                    %dual to lower and upper bounds
                    w = (res.sol.itr.slx - res.sol.itr.sux);
                    
                    %slack for blc <= A*x <= buc
                    s = zeros(size(csense,1),1);
                    if ~isempty(csense)
                        %slack for A*x <= b
                        s_U =  b_L - A*x;
                        s(csense == 'L') = s_U(csense == 'L');
                        %slack for b <= A*x
                        s_L =  b_U + A*x;%TODO, needs testing
                        s(csense == 'G') = s_L(csense == 'G');
                        %norm(A*x + s -b)
                        %pause
                    end
                else
                    stat=3;
                end
            else
                stat=3;
                origStat=[res.rmsg , res.rcodestr];
            end
        end
        % stat   Solver status
        %           1   Optimal solution found
        %           2   Unbounded solution
        %           0   Infeasible QP
        %           3   Other problem (time limit etc)
        %%
    case 'pdco'
        %-----------------------------------------------------------------------
        % pdco.m: Primal-Dual Barrier Method for Convex Objectives (16 Dec 2008)
        %-----------------------------------------------------------------------
        % AUTHOR:
        %    Michael Saunders, Systems Optimization Laboratory (SOL),
        %    Stanford University, Stanford, California, USA.
        %Interfaced with Cobra toolbox by Ronan Fleming, 18 Jan 2010
        [nMet,nRxn]=size(A);
        d1=ones(nRxn,1)*1e-4;
        %dont minimise the norm of reactions in linear objective
        d1(c~=0)=0;
        d2=1e-5;
        options = pdcoSet;

        x0 = ones(nRxn,1);
        y0 = ones(nMet,1);
        z0 = ones(nRxn,1);
        xsize = 1000;
        zsize = 1000;
        options.Method=2; %QR
        options.MaxIter=100;
        options.Print=printLevel;
        %get handle to helper function for objective
        pdObjHandle = @(x) QPObj(x);
        %solve the QP
        [x,y,w,inform,PDitns,CGitns,time] = ...
            pdco(pdObjHandle,A,b,lb,ub,d1,d2,options,x0,y0,z0,xsize,zsize);
        f= c'*x + 0.5*x'*F*x;
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

    case 'gurobi'
        %% gurobi 5
        % Free academic licenses for the Gurobi solver can be obtained from
        % http://www.gurobi.com/html/academic.html
        resultgurobi = struct('x',[],'objval',[],'pi',[]);
        clear params            % Use the default parameter settings
        switch printLevel
            case 0
                params.OutputFlag = 0;
                params.DisplayInterval = 1;
            case printLevel>1
                params.OutputFlag = 1;
                params.DisplayInterval = 5;
            otherwise
                params.OutputFlag = 0;
                params.DisplayInterval = 1;
        end

        params.Method = 0;    %-1 = automatic, 0 = primal simplex, 1 = dual simplex, 2 = barrier, 3 = concurrent, 4 = deterministic concurrent
        params.Presolve = -1; % -1 - auto, 0 - no, 1 - conserv, 2 - aggressive
        params.IntFeasTol = 1e-5;
        params.FeasibilityTol = 1e-6;
        params.OptimalityTol = 1e-6;
        %params.Quad = 1;

        if (isempty(QPproblem.csense))
            clear QPproblem.csense
            %QPproblem.csense(1:length(b),1) = '=';
            QPproblem.csense(1:length(b),1) = '=';
        else
            QPproblem.csense(QPproblem.csense == 'L') = '<';
            QPproblem.csense(QPproblem.csense == 'G') = '>';
            QPproblem.csense(QPproblem.csense == 'E') = '=';
            QPproblem.csense = QPproblem.csense(:);
        end

        if QPproblem.osense == -1
            QPproblem.osense = 'max';
        else
            QPproblem.osense = 'min';
        end

        QPproblem.Q = 0.5*sparse(QPproblem.F);
        QPproblem.modelsense = QPproblem.osense;
        [QPproblem.A,QPproblem.rhs,QPproblem.obj,QPproblem.sense] = deal(sparse(QPproblem.A),QPproblem.b,double(QPproblem.c),QPproblem.csense);
        resultgurobi = gurobi(QPproblem,params);
        origStat = resultgurobi.status;
        if strcmp(resultgurobi.status,'OPTIMAL')
            stat = 1; % Optimal solution found
            %Ronan: I changed the signs of the dual variables to make it
            %consistent with the way solveCobraLP returns the dual
            %variables
            [x,f,y,w,s] = deal(resultgurobi.x,resultgurobi.objval,-resultgurobi.pi,-resultgurobi.rc,resultgurobi.slack);
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
solution.stat = stat;
solution.origStat = origStat;
solution.time = t;
solution.full = x;
solution.slack = s;
solution.dual = y;
solution.rcost = w;

if solution.stat==1
    %TODO slacks for other solvers
    if any(strcmp(solver,{'gurobi','mosek'}))
        tmp=norm(QPproblem.osense*QPproblem.c  + QPproblem.F*solution.full - QPproblem.A'*solution.dual - solution.rcost);
        %tmp=norm(QPproblem.osense*(QPproblem.c  - QPproblem.A'*solution.dual - solution.rcost) + QPproblem.F*solution.full);
        if tmp > feasTol*100%optTol/10
            error(['Optimality conditions in solveCobraQP not satisfied, residual = ' num2str(tmp) ', while feasTol = ' num2str(feasTol)])
        end
    end
end

%Helper function for pdco
%%
    function [obj,grad,hess] = QPObj(x)
        obj  = c'*x + 0.5*x'*F*x;
        grad = c + F*x;
        hess = F;
    end
end
