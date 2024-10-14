function solution = solveCobraQP(QPproblem, varargin)
% Solves constraint-based QP problems
%
% The solver is defined in the CBT_MILP_SOLVER global variable
% (set using changeCobraSolver). Solvers currently available are
% 'tomlab_cplex', 'mosek' and 'qpng' (limited support for small problems)
%
% Solves problems of the type
% :math:`min/max  osense * c' * x + 0.5 x' * F * x`
% s/t :math:`lb <= x <= ub`
% :math:`A * x  <=/=/>= b`
%
% If minimising, then F must be positive semi-definite i.e. chol(F) does
% not return an error. If maximising, then chol(-F) must not return an
% error.
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
%                       * .osense - linear objective sense (-1 max, +1 min),
%                                   it is assumed that the quadratic part
%                                   is minimised and the F matrix is
%                                   positive semi-definite
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
%                       * 0 - Infeasible problem
%                       * 1 - Optimal solution
%                       * 2 - Unbounded solution
%                       * 3 - Almost optimal solution
%                       * -1 - Some other problem (timelimit, numerical problem etc)
%
% .. Author:
%       - Markus Herrgard        6/8/07
%       - Ronan Fleming         12/07/09  Added support for mosek
%       - Ronan Fleming         18 Jan 10 Added support for pdco
%       - Josh Lerman           04/17/10 changed def. parameters, THREADS, QPMETHOD
%       - Tim Harrington        05/18/12 Added support for the Gurobi 5.0 solver

[problemTypeParams,solverParams] = parseSolverParameters('QP',varargin{:}); % get the solver parameters

% set the solver
solver = problemTypeParams.solver;

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

if 0
    F2 = QPproblem.F;
    %This line modifies the diagonal elements of F2 by setting them to zero.
    F2(1:size(QPproblem.F,1):end)=0;
    if all(all(F2)) == 0
        %only nonzeros in QPproblem.F are on the diagonal
        try
            %try cholesky decomposition
            B = chol(QPproblem.F);
        catch
            QPproblem.F = QPproblem.F + diag((diag(QPproblem.F)==0)*1e-16);
        end
        try
            B = chol(QPproblem.F);
        catch
            error('QPproblem.F only has non-zeros along the main diagnoal and is still not positive semidefinite after adding 1e-16')
        end
    end
end

[A,b,F,c,lb,ub,csense,osense] = ...
    deal(sparse(QPproblem.A),QPproblem.b,QPproblem.F,QPproblem.c,QPproblem.lb,QPproblem.ub,...
    QPproblem.csense,QPproblem.osense);


%Save Input if selected
if ~isempty(problemTypeParams.saveInput)
    fileName = problemTypeParams.saveInput;
    if ~find(regexp(fileName,'.mat'))
        fileName = [fileName '.mat'];
    end
    display(['Saving QPproblem in ' fileName]);
    save(fileName,'QPproblem')
end

if strcmp(solver,'ibm_cplex')
    % Initialize the CPLEX object
    %https://www.ibm.com/support/knowledgecenter/SSSA5P_12.10.0/ilog.odms.cplex.help/refmatlabcplex/html/classCplex.html#a93e3891009533aaefce016703acb30d4
    cplexProblem = buildCplexProblemFromCOBRAStruct(QPproblem);
end

%clear the problem structure so it does not interfere later
if ~any(strcmp(solver,{'cplex_direct','dqqMinos'}))
    %clear the problem structure so it does not interfere later
    clear QPproblem
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
        
        % function [x, slack, v, rc, f_k, ninf, sinf, Inform, basis, lpiter, ...
        %          glnodes, confstat, iconfstat, sa, cpxControl, presolve] = ...
        %          cplex(c, A, x_L, x_U, b_L, b_U, ...
        %          cpxControl, callback, PriLev, Prob, IntVars, PI, SC, SI, ...
        %          sos1, sos2, F, logfile, savefile, savemode, qc, ...
        %          confgrps, conflictFile, saRequest, basis, xIP, logcon, branchprio, ...
        %          branchdir, cpxSettings);
        [x, s, y, w, f, ninf, sinf, origStat, basis] = cplex(osense*c, A, lb, ub, b_L, b_U,[], [],...
            problemTypeParams.printLevel, [], [], [], [], [], [], [], F);
        
        %x primal variable
        %f objective value
        %f = osense*f;
        %y dual to the b_L <=   Ax   <= b_U constraints
        %w dual to the x_L <=    x   <= x_U constraints
        
        %debugging
        if problemTypeParams.printLevel>2
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
        
        %       1 (S,B) Optimal solution found
        %       2 (S,B) Model has an unbounded ray
        %       3 (S,B) Model has been proved infeasible
        %       4 (S,B) Model has been proved either infeasible or unbounded
        %       5 (S,B) Optimal solution is available, but with infeasibilities after unscaling
        %       6 (S,B) Solution is available, but not proved optimal, due to numeric difficulties
        if origStat == 1
            stat = 1; % Optimal
        elseif origStat == 3
            stat = 0; % Infeasible
        elseif origStat == 2 || origStat == 4
            stat = 2; % Unbounded
        elseif origStat == 5 || origStat == 6 %origStat == 6  is 'Solution is available, but not proved optimal, due to numeric difficulties'
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
        tomlabProblem.PriLvl=problemTypeParams.printLevel;
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
        
        %       1 (S,B) Optimal solution found
        %       2 (S,B) Model has an unbounded ray
        %       3 (S,B) Model has been proved infeasible
        %       4 (S,B) Model has been proved either infeasible or unbounded
        %       5 (S,B) Optimal solution is available, but with infeasibilities after unscaling
        %       6 (S,B) Solution is available, but not proved optimal, due to numeric difficulties
        if origStat == 1
            stat = 1; % Optimal
        elseif origStat == 3
            stat = 0; % Infeasible
        elseif origStat == 2 || origStat == 4
            stat = 2; % Unbounded
        elseif origStat == 5 || origStat == 6 %origStat == 6  is 'Solution is available, but not proved optimal, due to numeric difficulties'
            stat = 3; % Solution exists, but either scaling problems or not proven to be optimal
        else %(origStat >= 10)
            stat = -1; % No optimal solution found (time or other limits reached, other infeasibility problems)
        end
        
        %debugging
        if problemTypeParams.printLevel>2
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
        [cplexProblem, logFile, logToFile] = setCplexParametersForProblem(cplexProblem,problemTypeParams,solverParams,'QP');
        
        % optimize the problem
        Result = cplexProblem.solve();
        if logToFile
            % Close the output file
            fclose(logFile);
        end
        
        if isfield(Result,'x')  % Cplex solution may not have x
            x = Result.x;
        end
        if isfield(Result, 'dual')
            y = osense*Result.dual;
        end
        if isfield(Result, 'reducedcost')
            w = osense*Result.reducedcost;
        end
        if isfield(Result, 'ax')
            s = b - Result.ax;
        end
        if isfield(Result,'objval')
            f = Result.objval;
        end
        origStat = Result.status;
        % See detailed table of result codes in
        % https://www.ibm.com/support/knowledgecenter/SSSA5P_12.6.3/ilog.odms.cplex.help/refcallablelibrary/macros/Solution_status_codes.html
        if origStat == 1
            stat = 1; % Optimal
        elseif origStat == 3
            stat = 0; % Infeasible
        elseif origStat == 2 || origStat == 4
            stat = 2; % Unbounded
        elseif origStat == 5 || origStat == 6 %origStat == 6  is 'Solution is available, but not proved optimal, due to numeric difficulties'
            stat = 3; % Solution exists, but either scaling problems or not proven to be optimal
        else %(origStat >= 10)
            stat = -1; % No optimal solution found (time or other limits reached, other infeasibility problems)
        end
        
        %Update Tolerance According to actual setting
        problemTypeParams.feasTol = cplexProblem.Param.simplex.tolerances.feasibility.Cur;
        problemTypeParams.optTol = cplexProblem.Param.simplex.tolerances.optimality.Cur;
        
    case 'cplex_direct'
        %% Tomlab cplex.m direct
        %Used with the current script, only some of the control affoarded with
        %this interface is provided. Primarily, this is to change the print
        %level and whether to minimise the Euclidean Norm of the internal
        %fluxes or not.
        %See solveCobraLPCPLEX.m for more refined control of cplex
        %Ronan Fleming 11/12/2008
        error('not setup for QP in general')
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
        [x, f, y, info] = qpng (QPproblem.F, osense*QPproblem.c, full(QPproblem.A), QPproblem.b, ctype, QPproblem.lb, QPproblem.ub, x0);
        
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
        
        if problemTypeParams.printLevel>0
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
            switch problemTypeParams.printLevel
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
        param.MSK_DPAR_INTPNT_QO_TOL_DFEAS = problemTypeParams.optTol;
        param.MSK_DPAR_INTPNT_QO_TOL_PFEAS = problemTypeParams.feasTol;
        
        %Update with solver Specific Parameter struct
        param = updateStructData(param,solverParams);
        %problemTypeParams.feasTol = param.MSK_DPAR_INTPNT_NL_TOL_PFEAS;
        
        param = mosekParamStrip(param);

        blc = b;
        buc = b;
        if (~isempty(csense))
            buc(csense == 'G') = inf;
            blc(csense == 'L') = -inf;
        end

        prob.c = osense * c;
        prob.a = A;
        prob.blc     = blc;
        prob.buc     = buc;
        prob.blx     = lb;
        prob.bux     = ub;
        %https://docs.mosek.com/latest/toolbox/data-types.html#prob
        [prob.qosubi,prob.qosubj,prob.qoval]=find(F);

        [rcode,res] = mosekopt(cmd,prob,param);
      
        % stat   Solver status
        %           1   Optimal solution found
        %           2   Unbounded solution
        %           0   Infeasible QP
        %           3   Other problem (time limit etc)
        %%
        
        if rcode~=0
            % MSK_RES_TRM_STALL
            % https://docs.mosek.com/latest/toolbox/response-codes.html#mosek.rescode.trm_stall
            suffix = res.rcodestr;
            suffix = lower(replace(suffix,'MSK_RES_',''));
            url  = 'https://docs.mosek.com/latest/toolbox/response-codes.html';
            url2 = ['https://docs.mosek.com/latest/toolbox/response-codes.html#mosek.rescode.' suffix];
            fprintf('Mosek returned an error or warning, open the following link in your browser:\n');
            %fprintf('<a href="%s">%s</a>\n', url, url);
            fprintf('<a href="%s">%s</a>\n', url2, url2);
        end

        %parse mosek result structure
        [stat,origStat,x,y,yl,yu,z,zl,zu,k,basis,pobjval,dobjval] = parseMskResult(res,solverParams,problemTypeParams.printLevel);
        
        %debugging
        if problemTypeParams.printLevel>2
            res1=A*x + s -b;
            norm(res1(csense == 'G'),inf)
            norm(s(csense == 'G'),inf)
            norm(res1(csense == 'L'),inf)
            norm(s(csense == 'L'),inf)
            norm(res1(csense == 'E'),inf)
            norm(s(csense == 'E'),inf)
            res1(~isfinite(res1))=0;
            norm(res1,inf)
            
            norm(osense*c + F*x -A'*y -w,inf)
            y2=res.sol.itr.slc-res.sol.itr.suc;
            norm(osense*c + F*x -A'*y2 -w,inf)
        end

        if stat ==1 || stat ==3
            f = c'*x + 0.5*x'*F*x;
            %slacks
            sbl = prob.a*x - prob.blc;
            sbu = prob.buc - prob.a*x;
            s = sbu - sbl; %TODO -double check this
            if problemTypeParams.printLevel>1
                fprintf('%8.2g %s\n',min(sbl), ' min(sbl) = min(A*x - bl), (should be positive)');
                fprintf('%8.2g %s\n',min(sbu), ' min(sbu) = min(bu - A*x), (should be positive)');
            end
        else
            f = NaN;
            s = NaN*ones(size(A,1),1);
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
        
        
        % generate set of default parameters for this solver
        options = pdcoSet;
        options.Method = 22;
        
        % set the printLevel
        options.Print=problemTypeParams.printLevel;
        
        % overwrite with problem type parameters
        options.FeaTol = problemTypeParams.feasTol;
        options.OptTol = problemTypeParams.optTol;
        
        % overwrite with solver specific parameters if provided
        options = updateStructData(options,solverParams);
        
        % setting d1 to zero is dangerous numerically, but is necessary to avoid
        % minimising the Euclidean norm of the optimal flux. A more
        % numerically stable way is to use pdco via solveCobraQP, which has
        % a more reasonable d1 and should be more numerically robust. -Ronan
        if isfield(solverParams,'d1')
            d1 = solverParams.d1;
        else
            d1 = 1e-4;
        end
        if isfield(solverParams,'d2')
            d2 = solverParams.d2;
        else
            d2 = 5e-4;
        end
        if isfield(solverParams,'x0')
            x0 = solverParams.x0;
        else
            x0 = ones(size(Aeq,2),1);
        end
        if isfield(solverParams,'y0')
            y0 = solverParams.y0;
        else
            y0 = ones(size(Aeq,1),1);
        end
        if isfield(solverParams,'z0')
            z0 = solverParams.z0;
        else
            z0 = ones(size(Aeq,2),1);
        end
        if isfield(solverParams,'xsize')
            xsize = solverParams.xsize;
        else
            xsize = 1;
        end
        if isfield(solverParams,'zsize')
            zsize = solverParams.zsize;
        else
            zsize = 1;
        end
        
        %get handle to helper function for objective
        pdObjHandle = @(x) QPObj(x,ceq,Feq,osense);
        
        [z,y,w,inform,~,~,~] = pdco(pdObjHandle,Aeq,beq,lbeq,ubeq,d1,d2,options,x0,y0,z0,xsize,zsize);
        [f,~,~] = QPObj(z,ceq,Feq,osense);
        f = f*osense;
        
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
        problemTypeParams.feasTol = options.FeaTol;
        problemTypeParams.optTol = options.OptTol;
        
    case 'gurobi'
        %% gurobi
        % Free academic licenses for the Gurobi solver can be obtained from
        % http://www.gurobi.com/html/academic.html

        %  The param struct contains Gurobi parameters. A full list may be
        %  found on the Parameter page of the reference manual:
        %  https://www.gurobi.com/documentation/current/refman/parameter_descriptions.html
        % MATLAB Parameter Examples
        % In the MATLAB interface, parameters are passed to Gurobi through a struct. 
        % To modify a parameter, you create a field in the struct with the appropriate name, 
        % and set it to the desired value. For example, to set the TimeLimit parameter to 100 you'd do:
        % 
        % param.timelimit = 100;
        % The case of the parameter name is ignored, as are underscores. Thus, you could also do:
        % param.timeLimit = 100;
        % ...or...
        % param.TIME_LIMIT = 100;
        % All desired parameter changes should be stored in a single struct, which is passed as the second parameter to the gurobi function.
        param=solverParams;

        % param.method gives the method used to solve continuous models
        % -1=automatic,
        %  0=primal simplex,
        %  1=dual simplex,
        %  2=barrier,
        %  3=concurrent,
        %  4=deterministic concurrent
        % i.e. param.method     = 1;          % use dual simplex method
        if isfield(param,'lpmethod')
            %gurobiAlgorithms = {'AUTOMATIC','PRIMAL','DUAL','BARRIER','CONCURRENT','CONCURRENT_DETERMINISTIC'};
            % -1=automatic,
            % 0=primal simplex,
            % 1=dual simplex,
            % 2=barrier,
            % 3=concurrent,
            % 4=deterministic concurrent
            switch param.lpmethod
                case 'AUTOMATIC' 
                    param.method = -1;
                case 'PRIMAL'
                    param.method = 0;
                case 'DUAL'
                    param.method = 2;
                case 'BARRIER'
                    param.method = 2;
                otherwise
                    %https://www.gurobi.com/documentation/current/refman/method.html
                    %Concurrent methods aren't available for QP and QCP. 
                    error('Unrecognised param.lpmethod for gurobi')
            end
            param = rmfield(param,'lpmethod');
        end

        switch problemTypeParams.printLevel
            case 0
                param.OutputFlag = 0;
                param.DisplayInterval = 1;
            case problemTypeParams.printLevel>1
                param.OutputFlag = 1;
                param.DisplayInterval = 5;
            otherwise
                param.OutputFlag = 0;
                param.DisplayInterval = 1;
        end

        param.FeasibilityTol = problemTypeParams.feasTol;
        param.OptimalityTol = problemTypeParams.optTol;
        %Update param struct with Solver Specific parameters
        param = updateStructData(param,solverParams);
        
        %Update feasTol in case it is changed by the solver Parameters
        problemTypeParams.feasTol = param.FeasibilityTol;
        
        gurobiQP.sense(1:length(b),1) = '=';
        gurobiQP.sense(csense == 'L') = '<';
        gurobiQP.sense(csense == 'G') = '>';
        
        % minimization always
        gurobiQP.modelsense = 'min';
        %if maximisation, only change the linear part of the objective
        gurobiQP.obj = (double(c)+0)*osense;%gurobi wants a dense double vector as an objective
        
        gurobiQP.A = A;
        gurobiQP.rhs = full(b); %model.rhs must be a dense double vector
        gurobiQP.lb = lb;
        gurobiQP.ub = ub;

        
        gurobiQP.sense(1:length(b),1) = '=';
        gurobiQP.sense(csense == 'L') = '<';
        gurobiQP.sense(csense == 'G') = '>';
        
        %Until Gurobi 9.0, it was required that the quadratic matrix Q is positive semi-definite, so that the model is convex.
        %This is no longer the case for Gurobi 9.0, which supports general non-convex quadratic constraints and objective functions,
        %including bilinear and quadratic equality constraints.
        if any(any(F)) %if any(F, 'all') not backward compatible
            %For gurobi model.Q must be a sparse double matrix
            gurobiQP.Q = sparse(0.5*F);
        end
        
        try
            resultgurobi = gurobi(gurobiQP,param);
        catch ME
            if contains(ME.message,'Gurobi error 10020: Objective Q not PSD (negative diagonal entry)')
                warning('%s\n','Gurobi cannot solve a QP problem if it is given a diagonal Q with some of those diagonals equal to zero')
            end
            rethrow(ME)
            %Error using gurobi
            %Gurobi error 10020: Objective Q not PSD (negative diagonal entry)
        end
        origStat = resultgurobi.status;
        if strcmp(resultgurobi.status,'OPTIMAL')
            stat = 1; % Optimal solution found
            if stat ==1 && isempty(resultgurobi.x)
                error('solveCobraQP: gurobi reporting OPTIMAL but no solution')
            end
            
            [x,f,y,w,s] = deal(resultgurobi.x,resultgurobi.objval,osense*resultgurobi.pi,osense*resultgurobi.rc,resultgurobi.slack);
            
            if problemTypeParams.printLevel>2 %|| 1
                res1 = A*x + s - b;
                disp('Check A*x + s - b = 0 (feasiblity):');
                disp(norm(res1,inf))
                if any(any(F))
                    %res21 = c  + F*x - A' * y - w;
                    %tmp2 = norm(res21, inf)
                    disp('Check 2*Q*x + c - A''*lam = 0 (stationarity):');
                    res22 =  (2*gurobiQP.Q*resultgurobi.x + gurobiQP.obj) - gurobiQP.A'*resultgurobi.pi - resultgurobi.rc;
                    disp(norm(res22,inf))
                    if norm(res22,inf)>1e-8
                        pause(0.1);
                    end
                else
                    res1 = A*x + s - b;
                    disp(norm(res1,inf))
                    res2 = osense*c  - A' * y - w;
                    disp(norm(res2,inf))
                    disp('Check osense*c - A''*lam - w = 0 (stationarity):');
                    res22 = gurobiQP.obj - gurobiQP.A'*resultgurobi.pi - resultgurobi.rc;
                    disp(norm(res22,inf))
                    if norm(res22,inf)>1e-8
                        pause(0.1);
                    end
                end
            end
            
        elseif strcmp(resultgurobi.status,'INFEASIBLE')
            stat = 0; % Infeasible
        elseif strcmp(resultgurobi.status,'UNBOUNDED')
            stat = 2; % Unbounded
        elseif strcmp(resultgurobi.status,'INF_OR_UNBD')
            % we simply remove the objective and solve again.
            % if the status becomes 'OPTIMAL', it is unbounded, otherwise it is infeasible.
            gurobiQP.obj(:) = 0;
            gurobiQP.F(:,:) = 0;
            resultgurobi = gurobi(gurobiQP,param);
            if strcmp(resultgurobi.status,'OPTIMAL')
                stat = 2;
            else
                stat = 0;
            end
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
        if ~problemTypeParams.debug % if debugging leave the files in case of an error.
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
        LPproblem.b = [beq;-1*osense*ceq];
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
        
        %         %don't take the row corresponding to the objective
        %         if sol.objrow == 1
        %             sol.s = sol.s(2:end);
        %         else
        %             sol.s = sol.s(1:end-1);
        %         end
        %to allow for any row.
        sol.s(sol.objrow) = [];
        
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

if (stat==1 || stat == 3) && ~any(strcmp(solver,{'gurobi'}))
    %TODO: pull out slack variable from every solver interface (see list of solvers below)
    if ~exist('s','var')
        % slack variables required for optimality condition check, if they are
        % not already provided
        s = b - A * x;
        %optimality condition check should still check for satisfaction of the
        %optimality conditions
        s(csense == 'E')=0;
    else
        sOld = s; %keep for debugging
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
if any(contains(solver,'cplex'))
    [ExitText,~] = cplexStatus(solution.origStat);
    solution.origStatText = ExitText;
else
    solution.origStatText = [];
end

if solution.stat==1
    %TODO slacks for other solvers
    if any(strcmp(solver,{'gurobi','mosek', 'ibm_cplex', 'tomlab_cplex','pdco','dqqMinos'}))
        if ~isempty(solution.slack) && ~isempty(solution.full)
            % determine the residual 1
            res1 = A*solution.full + solution.slack - b;
            res1(~isfinite(res1))=0;
            tmp1 = norm(res1, inf);
            
            % evaluate the optimality condition 1
            if tmp1 > problemTypeParams.feasTol * 1e2
                fprintf('%s\n',['[' solver '] reports ' solution.origStat ' but Primal optimality condition in solveCobraQP not satisfied, residual = ' num2str(tmp1) ', while feasTol = ' num2str(problemTypeParams.feasTol)])
            else
                if problemTypeParams.printLevel > 0
                    fprintf(['\n > [' solver '] Primal optimality condition in solveCobraQP satisfied.']);
                end
            end
        end
        if ~isempty(solution.full) && ~isempty(solution.rcost) && ~isempty(solution.dual) && any(strcmp(solver,{'mosek','ibm_cplex','gurobi'}))
            % determine the residual 2
            res2 = c  + F*solution.full - A' * solution.dual - solution.rcost;
            tmp2 = norm(res2, inf);
            
            % evaluate the optimality condition 2
            if tmp2 > problemTypeParams.optTol * 1e2
                fprintf('%s\n',['[' solver '] reports ' solution.origStat ' but Dual optimality condition in solveCobraQP not satisfied, residual = ' num2str(tmp2) ', while optTol = ' num2str(problemTypeParams.optTol)])
            else
                if problemTypeParams.printLevel > 0
                    fprintf(['\n > [' solver '] Dual optimality condition in solveCobraQP satisfied.\n']);
                end
            end
        end
        
        if ~isempty(solution.full)
            %set the value of the objective
            solution.obj = c'*solution.full + 0.5*solution.full'*F*solution.full;
            solution.objLinear = c'*solution.full;
            solution.objQuadratic = (1/2)*solution.full'*F*solution.full;
            %expect some variability if the norm of the optimal flux vector is large
            %TODO how to scale this
            if (abs(solution.obj) - abs(f)) > getCobraSolverParams('LP', 'feasTol')*100 && norm(solution.full)<1e2 && ~any(strcmp(solver,{'mosek'}))
                % TODO - mosek is passing back a slightly different
                % objective for testSolveCobraQP.m problem 1 - why?
                warning('solveCobraQP: Objectives do not match. Rescale problem if you rely on the exact value of the optimal objective.')
                fprintf('%s%g\n',['The difference between the value the optimal objective c''*x + 0.5*x''*F*x minus the ' solver ' objective is: '] ,f - solution.obj)
            end
        else
            solution.obj = NaN;
            solution.objLinear = NaN;
            solution.objQuadratic = NaN;
        end
        
        %         residual = osense*QPproblem.c  + QPproblem.F*solution.full - QPproblem.A'*solution.dual - solution.rcost;
        %         tmp=norm(residual,inf);
        %
        %         %         % set the tolerance
        %         %         if strcmpi(solver, 'mosek')
        %         %             resTol = 1e-2;
        %         %         else
        %         %             resTol = problemTypeParams.optTol * 100;
        %         %         end
        %
        %         resTol = problemTypeParams.optTol * 100;
        %
        %         if tmp > resTol
        %             error(['Dual optimality condition in solveCobraQP not satisfied, residual = ' num2str(tmp) ', while optTol = ' num2str(problemTypeParams.optTol)])
        %         else
        %             if problemTypeParams.printLevel > 0
        %                 fprintf(['\n > [' solver '] Dual optimality condition in solveCobraQP satisfied.']);
        %             end
        %         end
    end
else
    if ~isempty(solution.full)
        %set the value of the objective
        solution.obj = c'*solution.full + 0.5*solution.full'*F*solution.full;
        solution.objLinear = c'*solution.full;
        solution.objQuadratic = (1/2)*solution.full'*F*solution.full;
    else
        solution.obj = NaN;
        solution.objLinear = NaN;
        solution.objQuadratic = NaN;
    end
end
end

%Helper function for pdco
function [obj,grad,hess] = QPObj(x,ceq,Feq,osense)
obj  = osense*ceq'*x + 0.5*x'*Feq*x;
grad = osense*ceq + Feq*x;
hess = osense*Feq;
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
