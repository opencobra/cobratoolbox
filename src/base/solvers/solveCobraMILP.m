function solution = solveCobraMILP(MILPproblem, varargin)
% Solves constraint-based MILP problems
% The solver is defined in the CBT_MILP_SOLVER global variable
% (set using `changeCobraSolver`). Solvers currently available are
% 'tomlab_cplex' and 'glpk'
%
% USAGE:
%
%    solution = solveCobraMILP(MILPproblem, parameters)
%
% INPUT:
%    MILPproblem:     Structure containing the following fields describing the LP problem to be solved
%
%                       * .A - LHS matrix
%                       * .b - RHS vector
%                       * .c - Objective coeff vector
%                       * .lb - Lower bound vector
%                       * .ub - Upper bound vector
%                       * .osense - Objective sense (-1 max, +1 min)
%                       * .csense - Constraint senses, a string containting the constraint sense for
%                         each row in A ('E', equality, 'G' greater than, 'L' less than).
%                       * .vartype - Variable types ('C' continuous, 'I' integer, 'B' binary)
%                       * .x0 - Initial solution
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
%
%    timeLimit:       Global solver time limit
%    intTol:          Integrality tolerance
%    relMipGapTol:    Relative MIP gap tolerance
%    logFile:         Log file (for CPLEX)
%    printLevel:      Printing level
%
%                       * 0 - Silent (Default)
%                       * 1 - Warnings and Errors
%                       * 2 - Summary information
%                       * 3 - More detailed information
%                       * > 10 - Pause statements, and maximal printing (debug mode)
%    saveInput:       Saves LPproblem to filename specified in field.
%                     i.e. parameters.saveInput = 'LPproblem.mat';
%
%
% OUTPUT:
%    solution:        Structure containing the following fields describing a MILP solution
%
%                       * .cont:        Continuous solution
%                       * .int:         Integer solution
%                       * .full:        Full MILP solution vector
%                       * .obj:         Objective value
%                       * .solver:      Solver used to solve MILP problem
%                       * .stat:        Solver status in standardized form (see below)
%
%                         * 1 - Optimal solution found
%                         * 2 - Unbounded solution
%                         * 0 - Infeasible MILP
%                         * -1 - No integer solution exists
%                         * 3 - Other problem (time limit etc, but integer solution exists)
%                       * .origStat:    Original status returned by the specific solver
%                       * .time:        Solve time in seconds
%
% .. Authors:
%       - Markus Herrgard 1/23/07
%       - Tim Harrington  05/18/12 Added support for the Gurobi 5.0 solver
%       - Ronan (16/07/2013) default MPS parameters are no longer global variables
%       - Meiyappan Lakshmanan  11/14/14 Added support for the cplex_direct solver
%       - cplex_direct solver accesible through CPLEX m-file and CPLEX C-interface
%       - Thomas Pfau (12/11/2015) Added support for ibm_cplex (the IBM Matlab
%       interface) to the solvers.

[cobraParams,solverParams] = parseSolverParameters('MILP',varargin{:}); % get the solver parameters

solver = cobraParams.solver;

% Save Input if selected
if ~isempty(cobraParams.saveInput)
    fileName = cobraParams.saveInput;
    if ~find(regexp(fileName, '.mat'))
        fileName = [fileName '.mat'];
    end
    display(['Saving MILPproblem in ' fileName]);
    save(fileName, 'MILPproblem')
end

% Defaults in case the solver does not return anything
x = [];
xInt = [];
xCont = [];
f = [];

if ~isfield(MILPproblem, 'x0')
    MILPproblem.x0 = [];
end

[A, b, c, lb, ub, csense, osense, vartype, x0] = ...
    deal(MILPproblem.A, MILPproblem.b, MILPproblem.c, MILPproblem.lb, MILPproblem.ub, ...
    MILPproblem.csense, MILPproblem.osense, MILPproblem.vartype, MILPproblem.x0);

if any(~(vartype == 'C' | vartype == 'B' | vartype == 'I'))
    display('vartype not C or B or I:  Assuming C');
    vartype(vartype ~= 'C' & vartype ~= 'I'& vartype ~= 'B') = 'C';
end

t_start = clock;
switch solver

    case 'glpk'
        %% glpk

        % Set up problem
        if (isempty(csense))
            clear csense
            csense(1:length(b), 1) = 'S';
        else
            csense(csense == 'L') = 'U';
            csense(csense == 'G') = 'L';
            csense(csense == 'E') = 'S';
            csense = columnVector(csense);
        end

        if ~isfield(solverParams,'msglev')
            solverParams.msglev = cobraParams.printLevel;
        end
        if ~isfield(solverParams,'tmlim')
            solverParams.tmlim = cobraParams.timeLimit;
        end

        % whos csense vartype
        csense = char(csense);
        vartype = char(vartype);
        % whos csense vartype

        % Solve problem
        [x, f, stat, extra] = glpk(c, A, b, lb, ub, csense, vartype, osense, solverParams);
        % Handle solution status reports
        if (stat == 5)
            solStat = 1;  % optimal
        elseif(stat == 6)
            solStat = 2;  % unbounded
        elseif(stat == 4)
            solStat = 0;  % infeasible

        elseif(stat == 171)
            solStat = 1;  % Opt integer within tolerance
        elseif(stat == 173)
            solStat = 0;  % Integer infeas
        elseif(stat == 184)
            solStat = 2;  % Unbounded
        elseif(stat == 172)
            solStat = 3;  % Other problem, but integer solution exists
        else
            solStat = -1;  % No integer solution exists
        end

    case 'cplex_direct'
        %% cplex_direct

        % Set up problem
        b = full(b);
        [m_lin, n] = size(MILPproblem.A);
        if ~isempty(csense)
            Aineq = [MILPproblem.A(csense == 'L', :); - MILPproblem.A(csense == 'G', :)];
            bineq = [b(csense == 'L', :); - b(csense == 'G', :)];
            %        min      c*x
            %        st.      Aineq*x <= bineq
            %                 Aeq*x    = beq
            %                 lb <= x <= ub
            A = MILPproblem.A(csense == 'E', :);
            b = b(csense == 'E', 1);
            [x, f, exitflag, output] = cplexmilp(c, Aineq, bineq, A, b, [], [], [], lb, ub, vartype');

            % primal
            solution.obj = osense * f;
            solution.full = x;
            % this is the dual to the equality constraints but it's not the chemical potential
            %             solution.dual=lambda.eqlin;
        else
            Aineq = [];
            bineq = [];
            [x, f, exitflag, output] = cplexmilp(c, Aineq, bineq, MILPproblem.A, b, lb, ub, vartype);
            solution.obj = osense * f;
            solution.full = x;
            % this is the dual to the equality constraints but it's not the chemical potential
            solution.dual = sparse(size(MILPproblem.A, 1), 1);
            %             solution.dual(csense == 'E')=lambda.eqlin;
            % this is the dual to the inequality constraints but it's not the chemical potential
            %             solution.dual(csense == 'L')=lambda.ineqlin(1:nnz(csense == 'L'),1);
            %             solution.dual(csense == 'G')=lambda.ineqlin(nnz(csense == 'L')+1:end,1);
        end
        solution.nInfeas = [];
        solution.sumInfeas = [];
        solution.origStat = output.cplexstatus;

        Inform = solution.origStat;
        stat = Inform;
        if (stat == 101 || stat == 102)
            solStat = 1;  % Opt integer within tolerance
        elseif(stat == 103)
            solStat = 0;  % Integer infeas
        elseif(stat == 118 || stat == 119)
            solStat = 2;  % Unbounded
        elseif(stat == 106 || stat == 106 || stat == 108 || stat == 110 || stat == 112 || stat == 114 || stat == 117)
            solStat = -1;  % No integer solution exists
        else
            solStat = 3;  % Other problem, but integer solution exists
        end

    case 'gurobi_mex'
        % Free academic licenses for the Gurobi solver can be obtained from
        % http://www.gurobi.com/html/academic.html
        %
        % The code below uses Gurobi Mex to interface with Gurobi. It can be downloaded from
        % http://www.convexoptimization.com/wikimization/index.php/Gurobi_Mex:_A_MATLAB_interface_for_Gurobi

        opts = solverParams;
        if cobraParams.printLevel == 0
            % Version v1.10 of Gurobi Mex has a minor bug. For complete silence
            % Remove Line 736 of gurobi_mex.c: mexPrintf("\n");
            if ~isfield(opts,'Display')
                opts.Display = 0;
            end
            if ~isfield(opts,'DisplayInterval')
                opts.DisplayInterval = 0;
            end
        else
            if ~isfield(opts,'Display')
                opts.Display = 1;
            end
        end

        if ~isfield(opts,'TimeLimit')
            opts.TimeLimit = solverParams.timeLimit;
        end
        if ~isfield(opts,'MIPGap')
            opts.MIPGap = solverParams.relMipGapTol;
        end
        if ~isfield(opts,'IntFeasTol')
            opts.IntFeasTol = solverParams.intTol;
        end
        if ~isfield(opts,'FeasibilityTol')
            % minimum intTol for gurobi = 1e-9
            opts.FeasibilityTol = max(solverParams.feasTol,1e-9);
        end
        if ~isfield(opts,'OptimalityTol')
            opts.OptimalityTol = solverParams.optTol;
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
        % gurobi_mex doesn't automatically cast logicals to doubles
        c = double(c);
        [x,f,stat,output] = gurobi_mex(c,osense,sparse(A),b, ...
            csense,lb,ub,vartype,opts);
        if stat == 2
            solStat = 1; % Optimal solutuion found
        elseif stat == 3
            solStat = 0; % Infeasible
        elseif stat == 5
            solStat = 2; % Unbounded
        elseif stat == 4
            solStat = 0; % Gurobi reports infeasible *or* unbounded
        else
            solStat = -1; % Solution not optimal or solver problem
        end

    case 'ibm_cplex'
        % Free academic licenses for the IBM CPLEX solver can be obtained from
        % https://www.ibm.com/developerworks/community/blogs/jfp/entry/CPLEX_Is_Free_For_Students?lang=en
        cplexlp = buildCplexProblemFromCOBRAStruct(MILPproblem);
        [cplexlp, logFile, logToFile] = setCplexParametersForProblem(cplexlp,cobraParams,solverParams,'MILP');
        
        % Solve problem
        Result = cplexlp.solve();

        if logToFile
            % Close the output file
            fclose(logFile);
        end

        % Get results
        stat = Result.status;
        if (stat == 101 || stat == 102 || stat == 1)
            solStat = 1; % Opt integer within tolerance
            % Return solution if problem is feasible, bounded and optimal
            x = Result.x;
            f = osense*Result.objval;
        elseif (stat == 103 || stat == 3)
            solStat = 0; % Integer infeas
        elseif (stat == 118 || stat == 119 || stat == 2)
            solStat = 2; % Unbounded
        elseif (stat == 106 || stat == 106 || stat == 108 || stat == 110 || stat == 112 || stat == 114 || stat == 117)
            solStat = -1; % No integer solution exists
        else
            solStat = 3; % Other problem, but integer solution exists
        end
        if exist([pwd filesep 'clone1.log'],'file')
            delete('clone1.log')
        end
    case 'gurobi'
        %% gurobi 5
        % Free academic licenses for the Gurobi solver can be obtained from
        % http://www.gurobi.com/html/academic.html
        MILPproblem.A = deal(sparse(MILPproblem.A));

        if cobraParams.printLevel == 0
            params.OutputFlag = 0;
            params.DisplayInterval = 1;
        else
            params.OutputFlag = 1;
            params.DisplayInterval = 5;
        end

        %return solution when time limit is reached and save the log file
        if ~isempty(cobraParams.logFile)
            params.LogFile = cobraParams.logFile;
        end
        params.TimeLimit = cobraParams.timeLimit;

        % set tolerances
        params.MIPGap = cobraParams.relMipGapTol;
        if cobraParams.intTol <= 1e-09
            params.IntFeasTol = 1e-09;
        else
            params.IntFeasTol = cobraParams.intTol;
        end
        params.FeasibilityTol = cobraParams.feasTol;
        params.OptimalityTol = cobraParams.optTol;

        if (isempty(csense))
            clear csense
            csense(1:length(b),1) = '=';
        else
            csense(csense == 'L') = '<';
            csense(csense == 'G') = '>';
            csense(csense == 'E') = '=';
            MILPproblem.csense = csense(:);
        end

        if osense == -1
            MILPproblem.osense = 'max';
        else
            MILPproblem.osense = 'min';
        end

        % overwrite default params with directParams
        fieldNames = fieldnames(solverParams);
        for i = 1:size(fieldNames,1)
            params.(fieldNames{i}) = solverParams.(fieldNames{i});
        end


        MILPproblem.vtype = vartype;
        MILPproblem.modelsense = MILPproblem.osense;
        [MILPproblem.A,MILPproblem.rhs,MILPproblem.obj,MILPproblem.sense] = deal(sparse(MILPproblem.A),MILPproblem.b,double(MILPproblem.c),MILPproblem.csense);
        if ~isempty(x0)
            MILPproblem.start = x0;
        end
        resultgurobi = gurobi(MILPproblem,params);

        stat = resultgurobi.status;
        if strcmp(resultgurobi.status,'OPTIMAL')
            solStat = 1; % Optimal solution found
            [x,f] = deal(resultgurobi.x,resultgurobi.objval);
        elseif strcmp(resultgurobi.status,'INFEASIBLE')
            solStat = 0; % Infeasible
        elseif strcmp(resultgurobi.status,'UNBOUNDED')
            solStat = 2; % Unbounded
        elseif strcmp(resultgurobi.status,'INF_OR_UNBD')
            solStat = 0; % Gurobi reports infeasible *or* unbounded
        elseif strcmp(resultgurobi.status,'TIME_LIMIT')
            solStat = 3; % Time limit reached
            warning('Time limit reached, solution might not be optimal (gurobi)')
            try
                [x,f] = deal(resultgurobi.x,resultgurobi.objval);
            catch
                %x and f could not be assigned, as there is no solution
                %yet
            end
        else
            solStat = -1; % Solution not optimal or solver problem
        end

    case 'tomlab_cplex'
        %% CPLEX through tomlab
        if (~isempty(csense))
            b_L(csense == 'E') = b(csense == 'E');
            b_U(csense == 'E') = b(csense == 'E');
            b_L(csense == 'G') = b(csense == 'G');
            b_U(csense == 'G') = inf;
            b_L(csense == 'L') = -inf;
            b_U(csense == 'L') = b(csense == 'L');
        elseif isfield(MILPproblem, 'b_L') && isfield(MILPproblem, 'b_U')
            b_L = MILPproblem.b_L;
            b_U = MILPproblem.b_U;
        else
            b_L = b;
            b_U = b;
        end
        intVars = (vartype == 'B') | (vartype == 'I');
        % intVars
        % pause;
        tomlabProblem = mipAssign(osense*c,A,b_L,b_U,lb,ub,x0,'CobraMILP',[],[],intVars);

        % Set parameters for CPLEX
        tomlabProblem.MIP.cpxControl.EPINT = cobraParams.intTol;
        tomlabProblem.MIP.cpxControl.EPGAP = cobraParams.relMipGapTol;
        tomlabProblem.MIP.cpxControl.TILIM = cobraParams.timeLimit;
        tomlabProblem.CPLEX.LogFile = cobraParams.logFile;
        tomlabProblem.PriLev = cobraParams.printLevel;
        tomlabProblem.MIP.cpxControl.THREADS = 1; % by default use only one thread


        % Strict numerical tolerances
        tomlabProblem.MIP.cpxControl.EPRHS = cobraParams.feasTol;
        tomlabProblem.MIP.cpxControl.EPOPT = cobraParams.optTol;
        tomlabProblem.MIP.cpxControl.EPAGAP = cobraParams.absMipGapTol;

        %Now, replace anything that is in the solver Specific field.
        tomlabProblem = updateStruct(tomlabProblem.MIP.cpxControl,solverParams);

        % Set initial solution
        tomlabProblem.MIP.xIP = x0;

        % Set up callback to print out intermediate solutions
        % only set this up if you know that you actually need these
        % results.  Otherwise do not specify intSolInd and contSolInd
        global cobraIntSolInd;
        global cobraContSolInd;
        if(~isfield(MILPproblem, 'intSolInd'))
            MILPproblem.intSolInd = [];
        else
            tomlabProblem.MIP.callback(14) = 1;
        end
        cobraIntSolInd = MILPproblem.intSolInd;
        if(~isfield(MILPproblem, 'contSolInd'))
            MILPproblem.contSolInd = [];
        end
        cobraContSolInd = MILPproblem.contSolInd;
        tomlabProblem.MIP.callbacks = [];
        tomlabProblem.PriLevOpt = 0;


        % Solve problem
        Result = tomRun('cplex', tomlabProblem);

        % Get results
        x = Result.x_k;
        f = osense*Result.f_k;
        stat = Result.Inform;
        if (stat == 101 || stat == 102)
            solStat = 1; % Opt integer within tolerance
        elseif (stat == 103)
            solStat = 0; % Integer infeas
        elseif (stat == 118 || stat == 119)
            solStat = 2; % Unbounded
        elseif (stat == 106 || stat == 106 || stat == 108 || stat == 110 || stat == 112 || stat == 114 || stat == 117)
            solStat = -1; % No integer solution exists
        else
            solStat = 3; % Other problem, but integer solution exists
        end
    case 'mps'
        fprintf(' > The interface to ''mps'' from solveCobraMILP will not be supported anymore.\n -> Use >> writeCbModel(model, ''mps'');\n');
        % temporary legacy support
        solverParams = updateStructData(cobraParams,solverParams);
        writeLPProblem(MILPproblem, 'problemName','COBRAMILPProblem','fileName','MILP.mps','solverParams',solverParams);
        return
    otherwise
        if isempty(solver)
            error('There is no solver for MILP problems available');
        else
            error(['Unknown solver: ' solver]);
        end
end
t = etime(clock, t_start);

%% Store results
if ~strcmp(solver,'mps')
    if (~isempty(x))
        % xInt = x(MILPproblem.intSolInd);
        % xCont = x(MILPproblem.contSolInd);
        xInt = x(vartype == 'B' | vartype == 'I');
        xCont = x(vartype == 'C');
    end

    solution.cont = xCont;
    solution.int = xInt;
    solution.obj = f;
    solution.solver = solver;
    solution.stat = solStat;
    solution.origStat = stat;
    solution.time = t;
    solution.full = x;
    if(isfield(MILPproblem, 'intSolInd'))
        solution.intInd = MILPproblem.intSolInd;
    end
end

%% Redirection function such that cplex redirects its output to the defined outputfile.
    function redirect(l)
        % Write the line of log output
        fprintf(outputfile, '%s\n', l);
    end

end