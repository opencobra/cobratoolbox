function solution = solveCobraQP(QPproblem, varargin)
% Solves constraint-based QP problems
%
% The solver is defined in the CBT_MILP_SOLVER global variable
% (set using changeCobraSolver). Solvers currently available are
% 'tomlab_cplex', 'mosek' and 'qpng' (limited support for small problems)
%
% Solves problems of the type
% :math:`min  osense * c' * x + 0.5 x' * F * x`
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
%                       * .F - positive semidefinite matrix for quadratic part of objective (see above)
%                       * .c - Objective coeff vector
%                       * .lb - Lower bound vector
%                       * .ub - Upper bound vector
%                       * .osense - Objective sense for the linear part (-1 max, +1 min)
%                       * .csense - Constraint senses, a string containing the constraint sense for
%                         each row in A ('E', equality, 'G' greater than, 'L' less than).
%
% Optional parameters can be entered using parameters structure or as
% parameter followed by parameter value: i.e. ,'printLevel', 3)
% Setting `parameters` = 'default' uses default setting set in
% `getCobraSolverParameters`.
%
% OPTIONAL INPUTS:
%    varargin:        Additional parameters either as parameter struct, or as
%                     parameter/value pairs. A combination is possible, if
%                     the parameter struct is either at the beginning or the
%                     end of the optional input.
%                     All fields of the struct which are not COBRA parameters
%                     (see `getCobraSolverParamsOptionsForType`) for this
%                     problem type will be passed on to the solver in a
%                     solver specific manner. Some optional parameters which
%                     can be passed to the function as parameter value pairs,
%                     or as part of the options struct are listed below:
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

[cobraSolverParams,solverParams] = parseSolverParameters('QP',varargin{:}); % get the solver parameters

% set the solver
solver = cobraSolverParams.solver;

% defaults in case the solver does not return anything
x = [];
y = [];
w = [];
f = [];
s = [];%todo, implement slack variable return for all solvers (gurboi and mosek done)
xInt = [];
xCont = [];
stat = -99;
solStat = -99;

[A,b,F,c,lb,ub,csense,osense] = ...
    deal(QPproblem.A,QPproblem.b,QPproblem.F,QPproblem.c,QPproblem.lb,QPproblem.ub,...
    QPproblem.csense,QPproblem.osense);


%Save Input if selected
if ~isempty(cobraSolverParams.saveInput)
    fileName = cobraSolverParams.saveInput;
    if ~find(regexp(fileName,'.mat'))
        fileName = [fileName '.mat'];
    end
    display(['Saving QPproblem in ' fileName]);
    save(fileName,'QPproblem')
end

t_start = clock;
switch solver
    %%
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
        [x, s, y, w, f, ninf, sinf, origStat, basis] = cplex(osense*c, A, lb, ub, b_L, b_U,[], [],...
            cobraSolverParams.printLevel, [], [], [], [], [], [], [], F);
        
        %x primal variable
        %f objective value
        %f = osense*f;
        %y dual to the b_L <=   Ax   <= b_U constraints 
        %w dual to the x_L <=    x   <= x_U constraints 
        
        %debugging
        if cobraSolverParams.printLevel>2
            res1=A*x + s -b;
            norm(res1(csense == 'G'),inf)
            norm(s(csense == 'G'),inf)
            norm(res1(csense == 'L'),inf)
            norm(s(csense == 'L'),inf)
            norm(res1(csense == 'E'),inf)
            norm(s(csense == 'E'),inf)
            res1(~isfinite(res1))=0;
            nr1 = norm(res1,inf)

            res2 = osense*c + F*x-A'*y -w;
            nr2 = norm(res2,inf)
            if nr1 + nr2 > 1e-6
                pause(0.1)
            end
        end
        
        
        if (origStat == 1) || (origStat == 6)
            stat = 1; % Optimal
        elseif (origStat == 3 || origStat == 4)
            stat = 0; % Infeasible
        elseif (origStat == 2)
            stat = 2; % Unbounded
        elseif (origStat == 6) %origStat == 6  is 'Solution is available, but not proved optimal, due to numeric difficulties'
            stat = 3; % Solution exists, but either scaling problems or not proven to be optimal
        else %(origStat >= 10)
            stat = -1; % No optimal solution found (time or other limits reached, other infeasibility problems)
        end
        solution.nInfeas = ninf;
        solution.sumInfeas = sinf;
        
    case 'tomlab_cplex_tomRun'
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
        tomlabProblem.PriLvl=cobraSolverParams.printLevel;
        tomlabProblem.MIP.cpxControl.QPMETHOD = 1;
        tomlabProblem.MIP.cpxControl.THREADS = 1;

        %Adapt to given parameters
        tomlabProblem.MIP.cpxControl = updateStructData(tomlabProblem.MIP.cpxControl,solverParams);

        Result = tomRun('cplex', tomlabProblem);
        x = Result.x_k;
        f = Result.f_k;%should be 0.5*x'*F*x + osense*c*x;
        s = - A*x + b;
        origStat = Result.Inform;
        w = Result.v_k(1:length(lb));
        y = Result.v_k((length(lb)+1):end);
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
        
        %debugging
        if cobraSolverParams.printLevel>2
            res1=A*x + s -b;
            norm(res1(csense == 'G'),inf)
            norm(s(csense == 'G'),inf)
            norm(res1(csense == 'L'),inf)
            norm(s(csense == 'L'),inf)
            norm(res1(csense == 'E'),inf)
            norm(s(csense == 'E'),inf)
            res1(~isfinite(res1))=0;
            norm(res1,inf)
            
            res2 = osense*c + F*x-A'*y -w;
            norm(res2,inf)
        end
        
        %%
     case 'ibm_cplex'
     % Initialize the CPLEX object
     %https://www.ibm.com/support/knowledgecenter/SSSA5P_12.10.0/ilog.odms.cplex.help/refmatlabcplex/html/classCplex.html#a93e3891009533aaefce016703acb30d4
        CplexQPProblem = buildCplexProblemFromCOBRAStruct(QPproblem);
        [CplexQPProblem, logFile, logToFile] = setCplexParametersForProblem(CplexQPProblem,cobraSolverParams,solverParams,'QP');
        
        % optimize the problem
        Result = CplexQPProblem.solve();
        if logToFile
            % Close the output file
            fclose(logFile);
        end        
        
        if isfield(Result,'x')  % Cplex solution may not have x
            x = Result.x;
        end
        if isfield(Result, 'dual')
            y = Result.dual;
        end
        if isfield(Result, 'reducedcost')
            w = Result.reducedcost;
        end
        if isfield(Result, 'ax')
            s = QPproblem.b - Result.ax;
        end
        if isfield(Result,'objval')
            f = Result.objval;
        end
        origStat = Result.status;
        % See detailed table of result codes in
        % https://www.ibm.com/support/knowledgecenter/SSSA5P_12.6.3/ilog.odms.cplex.help/refcallablelibrary/macros/Solution_status_codes.html
        if (origStat == 1 || origStat == 101)
            stat = 1; % Optimal
        elseif (origStat == 3 || origStat == 4 || origStat == 103)
            stat = 0; % Infeasible
        elseif (origStat == 2 || origStat == 118 || origStat == 119)
            stat = 2; % Unbounded
        else
            stat = -1; % No optimal solution found (time or other limits reached, other infeasibility problems)
        end
        
        %Update Tolerance According to actual setting
        cobraSolverParams.feasTol = CplexQPProblem.Param.simplex.tolerances.feasibility.Cur;
        cobraSolverParams.optTol = CplexQPProblem.Param.simplex.tolerances.optimality.Cur;
        
    case 'cplex_direct'
        %% Tomlab cplex.m direct
        %Used with the current script, only some of the control affoarded with
        %this interface is provided. Primarily, this is to change the print
        %level and whether to minimise the Euclidean Norm of the internal
        %fluxes or not.
        %See solveCobraLPCPLEX.m for more refined control of cplex
        %Ronan Fleming 11/12/2008

        solution=solveCobraLPCPLEX(QPproblem,printLevel,[],[],[],minNorm,'tomlab_cplex');
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

        %f = 0.5*x'*QPproblem.F*x + c'*x;

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

        if cobraSolverParams.printLevel>0
            cmd='minimize';
        else
            cmd='minimize echo(0)';
        end

        %matching bounds and zero diagonal of F at the same time
        bool = lb == ub & diag(F)==0;
        if any(bool)
            %{
                %this helps to regularise the problem, but changes it
                %slightly
                F = spdiags(bool*1e-6,0,F);
                QPproblem.F=F;
            %}
            warning(['There are ' num2str(nnz(bool)) ' variables that have equal lower and upper bounds, and zero on the diagonal of F.'])
        end

        param = struct();
        % Set the printLevel, can be overwritten.
        if ~isfield(param, 'MSK_IPAR_LOG')
            switch cobraSolverParams.printLevel
                case 0
                    echolev = 0;
                case 1
                    echolev = 3;
                case 2
                    param.MSK_IPAR_LOG_INTPNT = 1;
                    param.MSK_IPAR_LOG_SIM = 1;
                    echolev = 3;
                otherwise
                    echolev = 0;
            end
            if echolev == 0
                param.MSK_IPAR_LOG = 0;
                cmd = ['minimize echo(' int2str(echolev) ')'];
            else
                cmd = 'minimize';
            end
        end
        %remove parameter fields that mosek does not recognise
        param.MSK_DPAR_BASIS_TOL_S = cobraSolverParams.optTol;
        param.MSK_DPAR_BASIS_REL_TOL_S = cobraSolverParams.optTol;
        param.MSK_DPAR_INTPNT_NL_TOL_DFEAS = cobraSolverParams.optTol;
        param.MSK_DPAR_INTPNT_QO_TOL_DFEAS = cobraSolverParams.optTol;
        param.MSK_DPAR_INTPNT_CO_TOL_DFEAS = cobraSolverParams.optTol;

        %https://docs.mosek.com/8.1/toolbox/solving-geco.html
        param.MSK_DPAR_INTPNT_NL_TOL_PFEAS=cobraSolverParams.feasTol;
        param.MSK_DPAR_INTPNT_NL_TOL_DFEAS=cobraSolverParams.feasTol;

        %Update with solver Specific Parameter struct
        param = updateStructData(param,solverParams);
        cobraSolverParams.feasTol = param.MSK_DPAR_INTPNT_NL_TOL_PFEAS;

        % Optimize the problem.
        % min 0.5*x'*F*x + osense*c'*x
        % st. blc <= A*x <= buc
        %     bux <= x   <= bux
        [res] = mskqpopt(F,osense*c,A,b_L,b_U,lb,ub,param,cmd);

        % stat   Solver status
        %           1   Optimal solution found
        %           2   Unbounded solution
        %           0   Infeasible QP
        %           3   Other problem (time limit etc)
        %%

        if isempty(res)
            stat=3;
        else
            if isfield(res,'sol')
                origStat=res.sol.itr.solsta;
                if strcmp(res.sol.itr.prosta,'PRIMAL_AND_DUAL_FEASIBLE') &&  (strcmp(res.sol.itr.solsta,'OPTIMAL') || strcmp(res.sol.itr.solsta,'NEAR_OPTIMAL'))
                    stat=1;
                    % x solution.
                    x = res.sol.itr.xx;
                    %f = 0.5*x'*F*x + c'*x;
                    f = res.sol.itr.pobjval;

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
                    %                     %slack for blc <= A*x <= buc
                    %                     s = b - A*x;
                else
                    stat=3;
                end
            else
                stat=3;
                origStat=[res.rmsg , res.rcodestr];
            end
        end

        %debugging
        if cobraSolverParams.printLevel>2
            res1=A*x + s -b;
            norm(res1(csense == 'G'),inf)
            norm(s(csense == 'G'),inf)
            norm(res1(csense == 'L'),inf)
            norm(s(csense == 'L'),inf)
            norm(res1(csense == 'E'),inf)
            norm(s(csense == 'E'),inf)
            res1(~isfinite(res1))=0;
            norm(res1,inf)

            norm(osense*c + F*x-A'*y -w,inf)
            y2=res.sol.itr.slc-res.sol.itr.suc;
            norm(osense*c + F*x -A'*y2 -w,inf)
        end


    case 'pdco'
        %-----------------------------------------------------------------------
        % pdco.m: Primal-Dual Barrier Method for Convex Objectives (16 Dec 2008)
        %-----------------------------------------------------------------------
        % AUTHOR:
        %    Michael Saunders, Systems Optimization Laboratory (SOL),
        %    Stanford University, Stanford, California, USA.
        %    minimize    phi(x) + 1/2 norm(D1*x)^2 + 1/2 norm(r)^2
        %      x,r
        %    subject to  A*x + D2*r = b,   bl <= x <= bu,   r unconstrained
        [nMet,nRxn]=size(A);
        
        options = pdcoSet;

        xsize = 1;
        zsize = 1;
        options.Method=2;
        options.MaxIter=1000;
        options.Print=cobraSolverParams.printLevel;
        %Update the options struct if it is provided
        options = updateStructData(options,solverParams);

        
        %pdco only works with equality constraints and box constraints so
        %any other linear constraints need to be reformulated in terms of
        %slack variables
        %indl = find(csense == 'L'); %  A*x + s =   b
        %indg = find(csense == 'G'); % -A*x + s = - b
        
        if ~any(csense == 'L' | csense == 'G')
            Aeq  =  A;
            beq  =  b;
            lbeq = lb;
            ubeq = ub;
            ceq  =  c;
            Feq = F;
        else
            Aeq = A;
            Aeq(csense == 'G',:) = -1*Aeq(csense == 'G',:);
            beq = b;
            beq(csense == 'G',:) = -1*beq(csense == 'G',:);
            K = speye(nMet);
            K = K(:,csense == 'L' | csense == 'G');
            Aeq = [Aeq K];
            nSlacks = nnz(csense == 'L' | csense == 'G');
            lbeq = [lb ; zeros(nSlacks,1)];
            ubeq = [ub ; inf*ones(nSlacks,1)];
            ceq  = [c  ; zeros(nSlacks,1)];
            Feq  = [F , sparse(nRxn, nSlacks);
                   sparse(nSlacks,nRxn), spdiags(ones(nSlacks,1)*0,0,nSlacks,nSlacks)];
        end
        
        x0 =  ones(size(Aeq,2),1);
        y0 = zeros(size(Aeq,1),1);
        z0 =  ones(size(Aeq,2),1);
        
        %get handle to helper function for objective
        pdObjHandle = @(x) QPObj(x);
        
        % setting d1 to zero is dangerous numerically, but is necessary to avoid
        % minimising the Euclidean norm of the optimal flux. A more
        % numerically stable way is to use pdco via solveCobraQP, which has
        % a more reasonable d1 and should be more numerically robust. -Ronan
        % d1=0;
        % d2=1e-6;
        d1 = 0;
        d2 = 5e-4;
           
        [z,y,w,inform,~,~,~] = pdco(pdObjHandle,Aeq,beq,lbeq,ubeq,d1,d2,options,x0,y0,z0,xsize,zsize);
        [f,~,~] = QPObj(z);
 
       
        % inform = 0 if a solution is found;
        %        = 1 if too many iterations were required;
        %        = 2 if the linesearch failed too often;
        %        = 3 if the step lengths became too small;
        %        = 4 if Cholesky said ADDA was not positive definite.
        if (inform == 0)
            stat = 1;
            if ~any(csense == 'L' | csense == 'G')
                s = zeros(nMet,1);
            else
                s = zeros(nMet,1);
                s(csense == 'L' | csense == 'G') = z(nRxn+1:end);
                s(csense == 'G') = -s(csense == 'G');
            end
            x=z(1:nRxn);
            w=w(1:nRxn);
            if 0
                norm(A*x + s - b,inf)
            end
        elseif (inform == 1 || inform == 2 || inform == 3)
            stat = 0;
        else
            stat = -1;
        end
        origStat=inform;
        
        %update parameters for testing optimality criterion
        cobraSolverParams.feasTol = options.FeaTol;
        cobraSolverParams.optTol = options.OptTol;
        
    case 'gurobi_mex'
        % Free academic licenses for the Gurobi solver can be obtained from
        % http://www.gurobi.com/html/academic.html
        %
        % The code below uses Gurobi Mex to interface with Gurobi. It can be downloaded from
        % http://www.convexoptimization.com/wikimization/index.php/Gurobi_Mex:_A_MATLAB_interface_for_Gurobi

        clear opts            % Use the default parameter settings
        if cobraSolverParams.printLevel == 0
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
        opts.Method = cobraSolverParams.method;    % 0 - primal, 1 - dual
        opts.FeasibilityTol = cobraSolverParams.feasTol;
        opts.OptimalityTol = cobraSolverParams.optTol;
        %opt.Quad=1;
        opts = updateStructData(opts,solverParams);
        cobraSolverParams.feasTol = opts.FeasibilityTol;


        %gurobi_mex doesn't cast logicals to doubles automatically
        c = osense*double(c);
        [x,f,origStat,output,y] = gurobi_mex(c,1,sparse(A),b, ...
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
        %% gurobi
        % Free academic licenses for the Gurobi solver can be obtained from
        % http://www.gurobi.com/html/academic.html
        % https://www.gurobi.com/documentation/9.0/refman/matlab_the_model_argument.html#matlab:model

        resultgurobi = struct('x',[],'objval',[],'pi',[]);
        %Set up the parameters
        params = struct();
        switch cobraSolverParams.printLevel
            case 0
                params.OutputFlag = 0;
                params.DisplayInterval = 1;
            case cobraSolverParams.printLevel>1
                params.OutputFlag = 1;
                params.DisplayInterval = 5;
            otherwise
                params.OutputFlag = 0;
                params.DisplayInterval = 1;
        end

        params.Method = cobraSolverParams.method;    %-1 = automatic, 0 = primal simplex, 1 = dual simplex, 2 = barrier, 3 = concurrent, 4 = deterministic concurrent
        params.Presolve = -1; % -1 - auto, 0 - no, 1 - conserv, 2 - aggressive
        params.FeasibilityTol = cobraSolverParams.feasTol;
        params.OptimalityTol = cobraSolverParams.optTol;
        %Update param struct with Solver Specific parameters
        params = updateStructData(params,solverParams);

        %Update feasTol in case it is changed by the solver Parameters
        cobraSolverParams.feasTol = params.FeasibilityTol;

        %Finished setting up options.

        if (isempty(QPproblem.csense))
            QPproblem=rmfield(QPproblem,'csense');
            QPproblem.csense(1:length(b),1) = '=';
        else
            QPproblem.csense(QPproblem.csense == 'L') = '<';
            QPproblem.csense(QPproblem.csense == 'G') = '>';
            QPproblem.csense(QPproblem.csense == 'E') = '=';
            QPproblem.csense = QPproblem.csense(:);
        end

        %Until Gurobi 9.0, it was required that the quadratic matrix Q is positive semi-definite, so that the model is convex. 
        %This is no longer the case for Gurobi 9.0, which supports general non-convex quadratic constraints and objective functions, 
        %including bilinear and quadratic equality constraints. 
        QPproblem.Q = sparse(QPproblem.F);
        
        %model.modelsense (optional) The optimization sense. 
        %Allowed values are 'min' (minimize) or 'max' (maximize). 
        %When absent, the default optimization sense is minimization.
        if QPproblem.osense == 1
            QPproblem.modelsense = 'min';
        else
            QPproblem.modelsense = 'max';
        end
        
        [QPproblem.A,QPproblem.rhs,QPproblem.obj,QPproblem.sense] = deal(sparse(QPproblem.A),QPproblem.b,double(QPproblem.c),QPproblem.csense);
        resultgurobi = gurobi(QPproblem,params);
        origStat = resultgurobi.status;
        if strcmp(resultgurobi.status,'OPTIMAL')
            stat = 1; % Optimal solution found
            %Ronan: I changed the signs of the dual variables to make it
            %consistent with the way solveCobraLP returns the dual
            %variables
            if 0
                [x,f,y,w,s] = deal(resultgurobi.x,resultgurobi.objval,resultgurobi.pi,resultgurobi.rc,resultgurobi.slack);
            else
                [x,f,y,w,s] = deal(resultgurobi.x,resultgurobi.objval,QPproblem.osense*resultgurobi.pi,QPproblem.osense*resultgurobi.rc,resultgurobi.slack);
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
    case 'dqqMinos'
        % find the solution to a QP problem by obtaining a solution to the 
        % optimality conditons using the LP solver 'dqqMinos'
        
        %    QPproblem:       Structure containing the following fields describing the QP
        %
        %                       * .A - LHS matrix
        %                       * .b - RHS vector
        %                       * .F - positive semidefinite matrix for quadratic part of objective (see above)
        %                       * .c - Objective coeff vector
        %                       * .lb - Lower bound vector
        %                       * .ub - Upper bound vector
        %                       * .osense - Objective sense for the linear part (-1 max, +1 min)
        %                       * .csense - Constraint senses, a string containing the constraint sense for
        %                         each row in A ('E', equality, 'G' greater than, 'L' less than).
        
        if 1
            %take care of zero segments of F
            jlt=size(QPproblem.F,1);
            boolF=false(jlt,1);
            for j=1:jlt
                if any(QPproblem.F(j,:)) || any(QPproblem.F(:,j))
                    boolF(j)=1;
                end
            end
        end
        if ~all(boolF)
            error('dqqMinos not validated for F matrices with zero rows/cols')
        end
        
        global CBTDIR %required for dqqMinos
        if ~isunix
            error('dqqMinos can only be used on UNIX systems (macOS or Linux).')
        end

        % save the original directory
        originalDirectory = pwd;

        % set the temporary path to the DQQ solver
        tmpPath = [CBTDIR filesep 'binary' filesep computer('arch') filesep 'bin' filesep 'DQQ'];
        cd(tmpPath);
        if ~cobraSolverParams.debug % if debugging leave the files in case of an error.
            cleanUp = onCleanup(@() DQQCleanup(tmpPath,originalDirectory));
        end
        % create the
        if ~exist([tmpPath filesep 'MPS'], 'dir')
            mkdir([tmpPath filesep 'MPS'])
        end

        % set the name of the MPS file
        if isfield(solverParams, 'MPSfilename')
            MPSfilename = solverParams.MPSfilename;
        else
            if isfield(QPproblem, 'modelID')
                MPSfilename = QPproblem.modelID;
            else
                MPSfilename = 'file';
            end
        end

        %create an LP problem from the optimality conditions to the QP
        %problem
        
        %pdco only works with equality constraints and box constraints so
        %any other linear constraints need to be reformulated in terms of
        %slack variables
        indl = find(csense == 'L'); %  A*x + s =   b
        indg = find(csense == 'G'); % -A*x + s = - b
        
        [m,n]=size(QPproblem.A);
        if isempty(indl) && isempty(indg)
            nSlacks = 0;
            Aeq  =  QPproblem.A;
            beq  =  QPproblem.b;
            lbeq =  QPproblem.lb;
            ubeq =  QPproblem.ub;
            ceq  =  QPproblem.c;
            Feq  =  QPproblem.F;
        else
            Aeq = QPproblem.A;
            Aeq(indg,:) = -1*Aeq(indg,:);
            beq = QPproblem.b;
            beq(indg,:) = -1*beq(indg,:);
            K = speye(m);
            K = K(:,csense == 'L' | csense == 'G');
            Aeq = [Aeq K];
            nSlacks = length(indl) + length(indg);
            lbeq = [QPproblem.lb ; zeros(nSlacks,1)];
            ubeq = [QPproblem.ub ; inf*ones(nSlacks,1)];
            ceq  = [QPproblem.c  ; zeros(nSlacks,1)];
            Feq  = [QPproblem.F , sparse(m, nSlacks);
                        sparse(nSlacks,n + nSlacks)];
        end
        
        %    LPproblem:    Structure containing the following fields describing the LP problem to be solved
        %
        %    * .A - LHS matrix
        %    * .b - RHS vector
        %    * .c - Objective coeff vector
        %    * .lb - Lower bound vector
        %    * .ub - Upper bound vector
        %    * .osense - Objective sense (max=-1, min=+1)
        %    * .csense - Constraint senses, a string containting the constraint sense for
        %                each row in A ('E', equality, 'G' greater than, 'L' less than).
        
        [mAeq,nAeq]  = size(Aeq);
        LPproblem.A =  [Aeq, sparse(mAeq,mAeq);
                        Feq, Aeq'];
        LPproblem.b = [beq;-1*QPproblem.osense*ceq];
        LPproblem.c = sparse(nAeq+mAeq,1);
        

        
        LPproblem.lb = [lbeq;-Inf*ones(mAeq,1)];
        LPproblem.ub = [ubeq; Inf*ones(mAeq,1)];
        LPproblem.osense = 1; %does not matter as objective is zero
        LPproblem.csense(1:nAeq+mAeq,1) = 'E';
        
        % write out an .MPS file
        MPSfilename = MPSfilename(1:min(8, length(MPSfilename)));
        if ~exist([tmpPath filesep 'MPS' filesep MPSfilename '.mps'], 'file')
            cd([tmpPath filesep 'MPS']);
            writeLPProblem(LPproblem,'fileName',MPSfilename);
            cd(tmpPath);
        end

        % run the DQQ procedure
        sysCall = ['./run1DQQ ' MPSfilename ' ' tmpPath];
        [status, cmdout] = system(sysCall);
        if status ~= 0
            fprintf(['\n', sysCall]);
            disp(cmdout)
            error('Call to dqq failed');
        end

        % read the solution
        solfname = [tmpPath filesep 'results' filesep MPSfilename '.sol'];
        sol = readMinosSolution(solfname);
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
        
        
%         solution.full = x;
%         solution.slack = s;
%         solution.dual = y;
%         solution.rcost = w;

        x = sol.x(1:n,1);
        y = - sol.x(n+nSlacks+1:n+nSlacks+m,1);
        w = sol.rc(1:n,1);
       
        %don't take the row corresponding to the objective
        if sol.objrow == 1
            sol.s = sol.s(2:end);
        else
            sol.s = sol.s(1:end-1);
        end
        
        if 0
            %both of these should be zero
            norm(LPproblem.A*sol.x - sol.s,inf) %minos solves A*x - s = 0
            norm(LPproblem.b - sol.s,inf) %all equalities
        end
        
        if isempty(indl) && isempty(indg)
            %no slack variables
            s = sparse(m,1);
        else          
            s = sparse(m,1);
            %slack variables correspoding to A*x <= b
            s(indl)=  sol.x(n+indl);
            %slack variables correspoding to A*x => b
            s(indg)= -sol.x(n+indg);
        end      
               
        % Translation of DQQ of exit codes from https://github.com/kerrickstaley/lp_solve/blob/master/lp_lib.h
        dqqStatMap = {-5, 'UNKNOWNERROR', -1;
            -4, 'DATAIGNORED',  -1;
            -3, 'NOBFP',        -1;
            -2, 'NOMEMORY',     -1;
            -1, 'NOTRUN',       -1;
            0, 'OPTIMAL',       1;
            1, 'SUBOPTIMAL',   -1;
            2, 'INFEASIBLE',    0;
            3, 'UNBOUNDED',     2;
            4, 'DEGENERATE',   -1;
            5, 'NUMFAILURE',   -1;
            6, 'USERABORT',    -1;
            7, 'TIMEOUT',      -1;
            8, 'RUNNING',      -1;
            9, 'PRESOLVED',    -1};
        
        origStat = dqqStatMap{[dqqStatMap{:,1}] == sol.inform, 2};
        stat = dqqStatMap{[dqqStatMap{:,1}] == sol.inform, 3};
        
        % return to original directory
        cd(originalDirectory);
        
    otherwise
        if isempty(solver)
            error('There is no solver for QP problems available');
        else
            error(['Unknown solver: ' solver]);
        end
end
%%

if stat==1 && ~strcmp(solver,'mps')
    %TODO: pull out slack variable from every solver interface (see list of solvers below)
    if ~exist('s','var')
        % slack variables required for optimality condition check, if they are
        % not already provided
        s = b - A * x;
        %optimality condition check should still check for satisfaction of the
        %optimality conditions
        s(csense == 'E')=0;
    else
        %optimality condition check should still check for satisfaction of the
        %optimality conditions
        s(csense == 'E')=0;
    end
end

t = etime(clock, t_start);
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
    if any(strcmp(solver,{'gurobi','mosek', 'ibm_cplex', 'tomlab_cplex','pdco','dqqMinos'}))
        if ~isempty(solution.slack) && ~isempty(solution.full)
            % determine the residual 1
            res1 = QPproblem.A*solution.full + solution.slack - QPproblem.b;
            res1(~isfinite(res1))=0;
            tmp1 = norm(res1, inf);
            
            % evaluate the optimality condition 1
            if tmp1 > cobraSolverParams.feasTol * 1e2
                disp(solution.origStat)
                error(['[' solver '] Primal optimality condition in solveCobraQP not satisfied, residual = ' num2str(tmp1) ', while feasTol = ' num2str(cobraSolverParams.feasTol)])
            else
                if cobraSolverParams.printLevel > 0
                    fprintf(['\n > [' solver '] Primal optimality condition in solveCobraQP satisfied.']);
                end
            end
        end
        if ~isempty(solution.full) && ~isempty(solution.rcost) && ~isempty(solution.dual) && ~any(strcmp(solver,{'gurobi','mosek'}))%todo, debug gurobi QP
            % determine the residual 2
            if strcmp(solver,'pdco')
                pause(1e-9)
            end
            res2 = QPproblem.osense * QPproblem.c  + QPproblem.F*solution.full - QPproblem.A' * solution.dual - solution.rcost;
            tmp2 = norm(res2, inf);
            
            % evaluate the optimality condition 2
            if tmp2 > cobraSolverParams.optTol * 1e2
                disp(solution.origStat)
                error(['[' solver '] Dual optimality condition in solveCobraQP not satisfied, residual = ' num2str(tmp2) ', while optTol = ' num2str(cobraSolverParams.optTol)])
            else
                if cobraSolverParams.printLevel > 0
                    fprintf(['\n > [' solver '] Dual optimality condition in solveCobraQP satisfied.\n']);
                end
            end
        end
        
        if ~isempty(solution.full)
            %set the value of the objective
            solution.obj = QPproblem.c'*solution.full + 0.5*solution.full'*QPproblem.F*solution.full;
            if norm(solution.obj - osense*f) > 1e-4
                warning('solveCobraQP: Objectives do not match. Switch to a different solver if you rely on the value of the optimal objective.')
                fprintf('%s\n%g\n%s\n%g\n%s\n%g\n',['The optimal value of the objective from ' solution.solver ' is:'],f, ...
                    'while the value constructed from osense*c''*x + 0.5*x''*F*x:', solution.obj,...
                    'while the value constructed from osense*c''*x + x''*F*x :', osense*QPproblem.c'*solution.full + solution.full'*QPproblem.F*solution.full)
            end
        else
            solution.obj = NaN;
        end
        
        %         residual = osense*QPproblem.c  + QPproblem.F*solution.full - QPproblem.A'*solution.dual - solution.rcost;
        %         tmp=norm(residual,inf);
        %
        %         %         % set the tolerance
        %         %         if strcmpi(solver, 'mosek')
        %         %             resTol = 1e-2;
        %         %         else
        %         %             resTol = cobraSolverParams.optTol * 100;
        %         %         end
        %
        %         resTol = cobraSolverParams.optTol * 100;
        %
        %         if tmp > resTol
        %             error(['Dual optimality condition in solveCobraQP not satisfied, residual = ' num2str(tmp) ', while optTol = ' num2str(cobraSolverParams.optTol)])
        %         else
        %             if cobraSolverParams.printLevel > 0
        %                 fprintf(['\n > [' solver '] Dual optimality condition in solveCobraQP satisfied.']);
        %             end
        %         end
    end
else
    solution.obj = NaN;
end

%Helper function for pdco
%%
    function [obj,grad,hess] = QPObj(x)
        obj  = osense*ceq'*x + 0.5*x'*Feq*x;
        grad = osense*ceq + Feq*x;
        hess = Feq;
    end

    function DQQCleanup(tmpPath, originalDirectory)
        % perform cleanup after DQQ.
        try
            % cleanup
            rmdir([tmpPath filesep 'results'], 's');
            fortFiles = [4, 9, 10, 11, 12, 13, 60, 81];
            for k = 1:length(fortFiles)
                delete([tmpPath filesep 'fort.', num2str(fortFiles(k))]);
            end
        catch
        end
        try        % remove the temporary .mps model file
            rmdir([tmpPath filesep 'MPS'], 's')
        catch
        end
        cd(originalDirectory);
    end
end
