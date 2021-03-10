function solution = solveCobraLP(LPproblem, varargin)
% Solves constraint-based LP problems
%
% USAGE:
%
%    solveCobraLP(LPproblem, varargin)
%
% INPUT:
%    LPproblem:     Structure containing the following fields describing the LP problem to be solved
%
%                     * .A - LHS matrix
%                     * .b - RHS vector
%                     * .c - Objective coeff vector
%                     * .lb - Lower bound vector
%                     * .ub - Upper bound vector
%                     * .osense - Objective sense (-1 means maximise (default), 1 means minimise)
%                     * .csense - Constraint senses, a string containting the constraint sense for
%                       each row in A ('E', equality, 'G' greater than, 'L' less than).
%
% OPTIONAL INPUTS:
%    varargin:      Additional parameters either as parameter struct, or as
%                   parameter/value pairs. A combination is possible, if
%                   the parameter struct is either at the beginning or the
%                   end of the optional input.
%                   All fields of the struct which are not COBRA parameters
%                   (see `getCobraSolverParamsOptionsForType`) for this
%                   problem type will be passed on to the solver in a
%                   solver specific manner. Some optional parameters which
%                   can be passed to the function as parameter value pairs,
%                   or as part of the options struct are listed below:
%
%    printLevel:    Printing level
%
%                     * 0 - Silent (Default)
%                     * 1 - Warnings and Errors
%                     * 2 - Summary information
%                     * 3 - More detailed information
%                     * > 10 - Pause statements, and maximal printing (debug mode)
%
%    saveInput:     Saves LPproblem to filename specified in field.
%                   i.e. parameters.saveInput = 'LPproblem.mat';
%
%    minNorm:       {(0), scalar , `n x 1` vector}, where `[m, n] = size(S)`;
%                   If not zero then, minimise the Euclidean length
%                   of the solution to the LP problem. minNorm ~1e-6 should be
%                   high enough for regularisation yet maintain the same value for
%                   the linear part of the objective. However, this should be
%                   checked on a case by case basis, by optimization with and
%                   without regularisation.
%
%    primalOnly:    {(0), 1}; 1 = only return the primal vector (lindo solvers)
%
%    solverParams:  solver-specific parameter structure with field names
%                   that match exactly those in that solvers matlab interface.
%
%
% OUTPUT:
%    solution:      Structure containing the following fields describing a LP solution:
%                     * .full:         Full LP solution vector
%                     * .obj:          Objective value
%                     * .rcost:        Reduced costs, dual solution to :math:`lb <= v <= ub`
%                     * .dual:         dual solution to `A*v ('E' | 'G' | 'L') b`
%                     * .solver:       Solver used to solve LP problem
%                     * .algorithm:    Algorithm used by solver to solve LP problem
%                     * .stat:         Solver status in standardized form
%
%                       * 0 - Infeasible problem
%                       * 1 - Optimal solution
%                       * 2 - Unbounded solution
%                       * 3 - Almost optimal solution
%                       * -1 - Some other problem (timelimit, numerical problem etc)
%                     * .origStat:         Original status returned by the specific solver
%                     * .origStatText:     Original status text returned by the specific solver
%                     * .time:         Solve time in seconds
%                     * .basis:        (optional) LP basis corresponding to solution
%
% NOTE:
%           Optional parameters can also be set through the
%           solver can be set through `changeCobraSolver('LP', value)`;
%           `changeCobraSolverParams('LP', 'parameter', value)` function. This
%           includes the minNorm and the `printLevel` flags.
%
% EXAMPLE:
%
%    %Optional parameters can be entered in three different ways {A,B,C}
%
%    %A) as a problem specific parameter followed by parameter value:
%    [solution] = solveCobraLP(LP, 'printLevel', 1);
%    [solution] = solveCobraLP(LP, 'printLevel', 1, 'feasTol', 1e-8);
%
%    %B) as a parameters structure with field names specific to a specific solver
%    [solution] = solveCobraLP(LPCoupled, parameters);
%
%    %C) as parameter followed by parameter value, with a parameter structure
%    %with field names specific to a particular solvers internal parameter,
%    %fields as the LAST argument
%    [solution] = solveCobraLP(LPCoupled, 'printLevel', 1, 'feasTol', 1e-6, parameters);
%
% .. Authors:
%       - Markus Herrgard, 08/29/06
%       - Ronan Fleming, 11/12/08 'cplex_direct' allows for more refined control
%       of cplex than tomlab tomrun
%       - Ronan Fleming, 04/25/09 Option to minimise the Euclidean Norm of internal
%       fluxes using either 'cplex_direct' solver or 'pdco'
%       - Jan Schellenberger, 09/28/09 Changed header to be much simpler.  All parameters
%       now accessed through changeCobraSolverParams(LP, parameter,value)
%       - Richard Que, 11/30/09 Changed handling of optional parameters to use
%       getCobraSolverParams().
%       - Ronan Fleming, 12/07/09 Commenting of input/output
%       - Ronan Fleming, 21/01/10 Not having second input, means use the parameters as specified in the
%       global paramerer variable, rather than 'default' parameters
%       - Steinn Gudmundsson, 03/03/10 Added support for the Gurobi solver
%       - Ronan Fleming, 01/24/01 Now accepts an optional parameter structure with nonstandard
%       solver specific parameter options
%       - Tim Harrington, 05/18/12 Added support for the Gurobi 5.0 solver
%       - Ronan Fleming, 07/04/13 Reinstalled support for optional parameter structure

global CBTDIR % process arguments etc
global MINOS_PATH

% gets the problem type and solver specific parameters
[problemTypeParams, solverParams] = parseSolverParameters('LP',varargin{:});

% set the solver
solver = problemTypeParams.solver;

% check solver compatibility with minNorm option
if ~isempty(problemTypeParams.minNorm)
    if ~any(strcmp(solver, {'cplex_direct'}))
        error(['Solver is ' solver ' but minNorm only works for LP solver ''cplex_direct'' from this interface, use optimizeCbModel for other solvers.'])
    end
end

% save Input if selected
if ~isempty(problemTypeParams.saveInput)
    fileName = problemTypeParams.saveInput;
    if ~find(regexp(fileName, '.mat'))
        fileName = [fileName '.mat'];
    end
    disp(['Saving LPproblem in ' fileName]);
    save(fileName, 'LPproblem')
end

% support for lifting of ill-scaled models
if problemTypeParams.lifting == 1
    largeNb = 1e4;  % suitable for double precision solvers
    [LPproblem] = reformulate(LPproblem, largeNb, printLevel);
end

% assume constraint matrix is S if no A provided.
if ~isfield(LPproblem, 'A') && isfield(LPproblem, 'S')
    LPproblem.A = LPproblem.S;
end

% assume constraint A*v = b if csense not provided
if ~isfield(LPproblem, 'csense')
    % if csense is not declared in the model, assume that all
    % constraints are equalities.
    LPproblem.csense(1:size(LPproblem.A,1), 1) = 'E';
end

% assume constraint S*v = 0 if b not provided
if ~isfield(LPproblem, 'b')
    warning('LP problem has no defined b in S*v=b. b should be defined, for now we assume b=0')
    LPproblem.b = zeros(size(LPproblem.A, 1), 1);
end

% assume max c'v s.t. S v = b if osense not provided
if ~isfield(LPproblem, 'osense')
    LPproblem.osense = -1;
end

if ~isfield(LPproblem, 'modelID')
    LPproblem.modelID = 'aModelID';
end
            
% extract the problem from the structure
[A, b, c, lb, ub, csense, osense, modelID] = deal(sparse(LPproblem.A), LPproblem.b, LPproblem.c, LPproblem.lb, LPproblem.ub, LPproblem.csense, LPproblem.osense, LPproblem.modelID);

if isfield(LPproblem,'basis') && ~isempty(LPproblem.basis)
    basis = LPproblem.basis;
else
    basis = [];
end

if strcmp(solver,'ibm_cplex') %debug
    CplexLPproblem = buildCplexProblemFromCOBRAStruct(LPproblem);
end

if ~any(strcmp(solver,{'cplex_direct','dqqMinos','quadMinos','mps'}))
    %clear the problem structure so it does not interfere later
    clear LPproblem
end

% defaults in case the solver does not return anything
f = [];
x = [];
y = [];
w = [];
stat = 0;
origStat = [];
origStatText = [];
algorithm = 'default';

t_start = clock;
switch solver
    case 'opti'
        if verLessThan('matlab', '8.4')
            error('OPTI is not compatible with a version of MATLAB later than 2014b.');
        end

        if isunix
            error('OPTI is not compatible with UNIX systems (macOS or Linux).')
        else
            error('The OPTI interface is a legacy interface and is currently not maintained.');
        end

        % J. Currie and D. I. Wilson, "OPTI: Lowering the Barrier Between Open
        % Source Optimizers and the Industrial MATLAB User," Foundations of
        % Computer-Aided Process Operations, Georgia, USA, 2012
        % option to call solvers provided by OPTI TB for MATLAB from
        % http://www.i2c2.aut.ac.nz/Wiki/OPTI/index.php
        % OPTI supports: CLP, CSDP, DSDP, GLPK, LP_SOLVE, OOQP and SCIP
        % since solveCobraLP already includes calls to LP_SOLVE and GLPK, they
        % will not be included. In case the solver is not specified by user,
        % opti auto selects the solver depending on problem type
        % if parametersStructureFlag
        %     opts = setupOPTIoptions(parametersStructureFlag,directParamStruct);
        % else
        %     opts = setupOPTIoptions(printLevel,optTol,...
        %     OPTIsolver,OPTIalgorithm);
        % end
        % if ~isempty(fieldnames(solverParams))
        %     opts = setupOPTIoptions(solverParams, 'printLevel', printLevel, ...
        %                                     'optTol', optTol);
        % else
        %     opts = setupOPTIoptions('printLevel', printLevel, ...
        %                                     'optTol', optTol);
        % end

        % auto = 0;
        % switch opts.solver
        %     case 'clp'
        %         % https://projects.coin-or.org/Clp
        %         % set CLP algorithm  - options
        %         % 1. automatic
        %         % 2. barrier
        %         % 3. primalsimplex - primal simplex
        %         % 4. dualsimplex - dual simplex
        %         % 5. primalsimplexorsprint - primal simplex or sprint
        %         % 6. barriernocross - barrier without simplex crossover
        %         % opts.solver = [];
        %         % setup problem for OPTI based solver
        %         [f, A, rl, ru] = setupOPTIproblem(c, A, b, osense, csense, 'clp');
        %         % solve optimization problem
        %         [x, obj, exitflag, info] = ...
        %         opti_clp([], f, A, rl, ru, lb, ub, opts);
        %     case 'csdp'
        %         % https://projects.coin-or.org/Csdp/
        %         % not recommended for solving LPs
        %         [f, A, b] = setupOPTIproblem(c, A, b, osense, csense, 'csdp');
        %         % solve problem using csdp
        %         [x, obj, exitflag, info] = opti_csdp(f, A, b, lb, ub, [], [], opts);
        %     case 'dsdp'
        %         % http://www.mcs.anl.gov/hs/software/DSDP/
        %         % not recommended for solving large LPs
        %         [f, A, b] = setupOPTIproblem(c, A, b, osense, csense, 'dsdp');
        %         % solve problem using dsdp
        %         [x, obj, exitflag, info] = opti_dsdp(f, A, b, lb, ub, [], [], opts);
        %     case 'ooqp'
        %         % http://pages.cs.wisc.edu/~swright/ooqp/
        %         % not recommended for solving large LPs
        %         [f, Aineq, rl, ru, Aeq, beq] = ...
        %         setupOPTIproblem(c, A, b, osense, csense, 'ooqp');
        %         % solve problem using ooqp
        %         [x, obj, exitflag, info] = ...
        %         opti_ooqp([], f, Aineq, rl, ru, Aeq, beq, lb, ub, opts);
        %     case 'scip'
        %         % http://scip.zib.de/
        %         % http://scip.zib.de/scip.shtml
        %         [f, A, rl, ru, xtype] = ...
        %         setupOPTIproblem(c, A, b, osense, csense, 'scip');
        %         [x, obj, exitflag, info] = ...
        %         opti_scip([], f, A, rl, ru, lb, ub, xtype, [], [], opts);
        %     otherwise
        %         % construct opti object and solve using an automatically
        %         % chosen solver
        %         [f, A, b, e] = setupOPTIproblem(c, A, b, osense, csense, 'auto');
        %         optiobj = opti('f', f, 'mix', A, b, e, 'bounds', lb, ub, ...
        %                     'sense', osense, 'options', opts);
        %         [x, obj, exitflag, info] = solve(optiobj);
        %         auto = 1;
        % end
        % % parse results for solution output structure
        % if ~auto
        %     f = obj * osense;
        % else
        %     f = obj;
        % end
        % [w, y, algorithm, stat, origStat, t] = parseOPTIresult(exitflag, info);

    case 'dqqMinos'
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
            MPSfilename = modelID;
        end

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
        x = sol.x;
        f = c'* x;
        w = sol.rc;

        
%         %don't take the row corresponding to the objective
%         if sol.objrow == 1
%             y = sol.y(2:end);
%             s = sol.s(2:end);
%         else
%             y = sol.y(1:end-1);
%             s = sol.s(1:end-1);
%         end
        %to allow for any row.
        sol.y(sol.objrow) = [];
        sol.s(sol.objrow) = [];
        
        %writeMPS solves A*x <= 0, so reverse sign of slacks where input 
        %problem was of the form A*x >= 0
        bool = csense == 'G';
        y(bool) = - y(bool);
        s(bool) = - s(bool);
        % A*x + s <=> 0 translated to A*x + s = b 
        s = b - s;
        
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

    case 'quadMinos'
        if ~isunix
            error('Minos and quadMinos can only be used on UNIX systems (macOS or Linux).')
        end
        originalDirectory = pwd;

        % input precision
        precision = 'double';  % 'single'

        % set the name of the model
        modelName = 'qFBA';

        % define the data directory
        dataDirectory = [MINOS_PATH filesep 'data' filesep 'FBA'];
        mkdir(dataDirectory);

        % write out flat file to current folder
        [dataDirectory, fname] = writeMinosProblem(LPproblem, precision, modelName, dataDirectory, problemTypeParams.printLevel);

        if ~problemTypeParams.debug % if debugging leave the files in case of an error.
            cleanUp = onCleanup(@() minosCleanUp(MINOS_PATH,fname,originalDirectory));
        end

        % change system to testFBA directory
        cd(MINOS_PATH);

        % call minos
        sysCall = [MINOS_PATH filesep 'runfba solveLP ' fname ' lp1'];
        [status, cmdout] = system(sysCall);

        if contains(cmdout, 'error')
           disp(sysCall);
           disp(cmdout);
           error('Call to runfba failed.');
        end

        % call qminos
        sysCall = [MINOS_PATH filesep 'qrunfba qsolveLP ' fname ' lp2'];
        [status, cmdout] = system(sysCall);

        if contains(cmdout, 'error')
           disp(sysCall);
           disp(cmdout);
           error('Call to qrunfba failed.');
        end

        % read the solution
        sol = readMinosSolution([MINOS_PATH filesep 'q' fname '.sol']);

        % The optimization problem solved by MINOS is assumed to be
        %        min   osense*s(iobj)
        %        st    Ax - s = 0    + bounds on x and s,
        % where A has m rows and n columns.  The output structure "sol" contains the following data:
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
        x = sol.x;

        f = c' * x;
        
        w = sol.rc;
        origStat = sol.inform;

        %don't take the row corresponding to the objective
        if sol.objrow == 1
            y = sol.y(2:end);
            s = b - sol.s(2:end);
        else
            y = sol.y(1:end-1);
            s = b - sol.s(1:end-1);
        end
        
        % note that status handling may change (see lp_lib.h)
        if (origStat == 0)
            stat = 1;  % optimal solution found
        % elseif (origStat == 3)
        %     stat = 2; % unbounded
        % elseif (origStat == 2)
        %     stat = 0; % infeasible
        else
            stat = -1;  % Solution not optimal or solver problem
        end

        % return to original directory
        cd(originalDirectory);

    case 'glpk'
        %% GLPK
        param.msglev = problemTypeParams.printLevel;  % level of verbosity
        param.tolbnd = problemTypeParams.feasTol;  % tolerance
        param.toldj = problemTypeParams.optTol;  % tolerance
        if (isempty(csense))
            clear csense
            csense(1:length(b), 1) = 'S';
        else
            csense(csense == 'L') = 'U';
            csense(csense == 'G') = 'L';
            csense(csense == 'E') = 'S';
            csense = columnVector(csense);
        end
        param = updateStructData(param,solverParams);
        %If the feasibility tolerance is changed by the solverParams
        %struct, this needs to be forwarded to the cobra Params for the
        %final consistency test!
        if isfield(solverParams,'tolbnd')
            problemTypeParams.feasTol = solverParams.tolbnd;
        end
        % glpk needs b to be full, not sparse -Ronan
        b = full(b);
        [x, f, y, w, stat, origStat] = solveGlpk(c, A, b, lb, ub, csense, osense, param);
        y = -y;
        w = -w;
        s = b - A * x; % output the slack variables

    case {'lindo_new', 'lindo_old'}
        error('The lindo interfaces are legacy interfaces and will be no longer maintained.');
        %% LINDO
        % if (strcmp(solver, 'lindo_new'))
        %     % use new API (>= 2.0)
        %     [f, x, y, w, s, origStat] = solveCobraLPLindo(A, b, c, csense, lb, ub, osense, problemTypeParams.primalOnlyFlag, false);
        %     % note that status handling may change (see Lindo.h)
        %     if (origStat == 1 || origStat == 2)
        %         stat = 1;  % optimal solution found
        %     elseif(origStat == 4)
        %         stat = 2;  % unbounded
        %     elseif(origStat == 3 || origStat == 6)
        %         stat = 0;  % infeasible
        %     else
        %         stat = -1;  % Solution not optimal or solver problem
        %     end
        % else
        %     % use old API
        %     [f, x, y, w, s, origStat] = solveCobraLPLindo(A, b, c, csense, lb, ub, osense, problemTypeParams.primalOnlyFlag, true);
        %     % Note that status handling may change (see Lindo.h)
        %     if (origStat == 2 || origStat == 3)
        %         stat = 1;  % optimal solution found
        %     elseif(origStat == 5)
        %         stat = 2;  % unbounded
        %     elseif(origStat == 4 || origStat == 6)
        %         stat = 0;  % infeasible
        %     else
        %         stat = -1;  % solution not optimal or solver problem
        %     end
        % end
        %[f,x,y,s,w,stat] = LMSolveLPNew(A,b,c,csense,lb,ub,osense,0);

    case 'lp_solve'
        % lp_solve
        if (isempty(csense))
            [f, x, y, origStat] = lp_solve(c * (-osense), A, b, zeros(size(A, 1), 1), lb, ub);
            f = f * (-osense);
        else
            e(csense == 'E') = 0;
            e(csense == 'G') = 1;
            e(csense == 'L') = -1;
            [f, x, y, origStat] = lp_solve(c * (-osense), A, b, e, lb, ub);
            f = f * (-osense);
        end

        % note that status handling may change (see lp_lib.h)
        if (origStat == 0)
            stat = 1;  % optimal solution found
        elseif(origStat == 3)
            stat = 2;  % unbounded
        elseif(origStat == 2)
            stat = 0;  % infeasible
        else
            stat = -1;  % solution not optimal or solver problem
        end
        s = [];
        w = [];
    case 'mosek'
        % mosek
        % use msklpopt with full control over all mosek parameters
        % http://docs.mosek.com/7.0/toolbox/Parameters.html
        % see also
        % http://docs.mosek.com/7.0/toolbox/A_guided_tour.html#SEC:VIEWSETPARAM
        % e.g.
        % http://docs.mosek.com/7.0/toolbox/MSK_IPAR_OPTIMIZER.html

        %[rcode,res]         = mosekopt('param echo(0)',[],solverParams);

        param = solverParams;
        % only set the print level if not already set via solverParams structure
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

        %https://docs.mosek.com/8.1/toolbox/solving-linear.html
        if ~isfield(param, 'MSK_DPAR_INTPNT_TOL_PFEAS')
            param.MSK_DPAR_INTPNT_TOL_PFEAS=problemTypeParams.feasTol;
        end
        if ~isfield(param, 'MSK_DPAR_INTPNT_TOL_DFEAS.')
            param.MSK_DPAR_INTPNT_TOL_DFEAS=problemTypeParams.feasTol;
        end
        %If the feasibility tolerance is changed by the solverParams
        %struct, this needs to be forwarded to the cobra Params for the
        %final consistency test!
        if isfield(param,'MSK_DPAR_INTPNT_TOL_PFEAS')
            problemTypeParams.feasTol = param.MSK_DPAR_INTPNT_TOL_PFEAS;
        end
        % basis reuse - TODO
        % http://docs.mosek.com/7.0/toolbox/A_guided_tour.html#section-node-_A%20guided%20tour_Advanced%20start%20%28hot-start%29

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

        if isempty(csense)
            % assumes all equality constraints
            % [res] = msklpopt(c,a,blc,buc,blx,bux,param,cmd)
            [res] = msklpopt(osense * c, A, b, b, lb, ub, param, cmd);
        else
            blc = b;
            buc = b;
            buc(csense == 'G') = inf;
            blc(csense == 'L') = -inf;
            % [res] = msklpopt(       c,a,blc,buc,blx,bux,param,cmd)
            [res] = msklpopt(osense * c, A, blc, buc, lb, ub, param, cmd);
%             res.sol.itr
%             min(buc(csense == 'E')-A((csense == 'E'),:)*res.sol.itr.xx)
%             min(A((csense == 'E'),:)*res.sol.itr.xx-blc(csense == 'E'))
%             pasue(eps)
        end

        % initialise variables
        x = [];
        y = [];
        w = [];

        % https://docs.mosek.com/8.1/toolbox/data-types.html?highlight=res%20sol%20itr#data-types-and-structures
        if isfield(res, 'sol')
            if isfield(res.sol, 'itr')
                origStat = res.sol.itr.solsta;
                if strcmp(res.sol.itr.solsta, 'OPTIMAL') || ...
                        strcmp(res.sol.itr.solsta, 'MSK_SOL_STA_OPTIMAL') || ...
                        strcmp(res.sol.itr.solsta, 'MSK_SOL_STA_NEAR_OPTIMAL')
                    stat = 1; % optimal solution found
                    x=res.sol.itr.xx; % primal solution.
                    y=res.sol.itr.y; % dual variable to blc <= A*x <= buc

                    w=res.sol.itr.slx-res.sol.itr.sux; %dual to bux <= x   <= bux

                    % TODO  -work this out with Erling
                    % override if specific solver selected
                    if isfield(param,'MSK_IPAR_OPTIMIZER')
                        switch param.MSK_IPAR_OPTIMIZER
                            case {'MSK_OPTIMIZER_PRIMAL_SIMPLEX','MSK_OPTIMIZER_DUAL_SIMPLEX'}
                                stat = 1; % optimal solution found
                                x=res.sol.bas.xx; % primal solution.
                                y=res.sol.bas.y; % dual variable to blc <= A*x <= buc
                                w=res.sol.bas.slx-res.sol.bas.sux; %dual to bux <= x   <= bux
                            case 'MSK_OPTIMIZER_INTPNT'
                                stat = 1; % optimal solution found
                                x=res.sol.itr.xx; % primal solution.
                                y=res.sol.itr.y; % dual variable to blc <= A*x <= buc
                                w=res.sol.itr.slx-res.sol.itr.sux; %dual to bux <= x   <= bux
                        end
                    end
                    if isfield(res.sol,'bas') && 0
                        % override
                        stat = 1; % optimal solution found
                        x=res.sol.bas.xx; % primal solution.
                        y=res.sol.bas.y; % dual variable to blc <= A*x <= buc
                        w=res.sol.bas.slx-res.sol.bas.sux; %dual to bux <= x   <= bux
                    end
                    f=c'*x;
                    % slack for blc <= A*x <= buc
                    s = b - A * x; % output the slack variables
                elseif strcmp(res.sol.itr.solsta,'MSK_SOL_STA_PRIM_INFEAS_CER') ||...
                        strcmp(res.sol.itr.solsta,'MSK_SOL_STA_NEAR_PRIM_INFEAS_CER') ||...
                        strcmp(res.sol.itr.solsta,'MSK_SOL_STA_DUAL_INFEAS_CER') ||...
                        strcmp(res.sol.itr.solsta,'MSK_SOL_STA_NEAR_DUAL_INFEAS_CER')
                    stat=0; % infeasible
                end
            end
            if ( isfield(res.sol,'bas') )
                if strcmp(res.sol.bas.solsta,'OPTIMAL') || ...
                        strcmp(res.sol.bas.solsta,'MSK_SOL_STA_OPTIMAL') || ...
                        strcmp(res.sol.bas.solsta,'MSK_SOL_STA_NEAR_OPTIMAL')
                    stat = 1; % optimal solution found
                    x=res.sol.bas.xx; % primal solution.
                    y=res.sol.bas.y; % dual variable to blc <= A*x <= buc
                    w=res.sol.bas.slx-res.sol.bas.sux; %dual to bux <= x   <= bux
                    % override if specific solver selected
                    if isfield(param,'MSK_IPAR_OPTIMIZER')
                        switch param.MSK_IPAR_OPTIMIZER
                            case {'MSK_OPTIMIZER_PRIMAL_SIMPLEX','MSK_OPTIMIZER_DUAL_SIMPLEX'}
                                stat = 1; % optimal solution found
                                x=res.sol.bas.xx; % primal solution.
                                y=res.sol.bas.y; % dual variable to blc <= A*x <= buc
                                w=res.sol.bas.slx-res.sol.bas.sux; %dual to bux <= x   <= bux
                            case 'MSK_OPTIMIZER_INTPNT'
                                stat = 1; % optimal solution found
                                x=res.sol.itr.xx; % primal solution.
                                y=res.sol.itr.y; % dual variable to blc <= A*x <= buc
                                w=res.sol.itr.slx-res.sol.itr.sux; %dual to bux <= x   <= bux
                        end
                    end
                    f=c'*x;
                    % slack for blc <= A*x <= buc
                    s = b - A * x; % output the slack variables
                elseif strcmp(res.sol.bas.solsta,'MSK_SOL_STA_PRIM_INFEAS_CER') ||...
                        strcmp(res.sol.bas.solsta,'MSK_SOL_STA_NEAR_PRIM_INFEAS_CER') ||...
                        strcmp(res.sol.bas.solsta,'MSK_SOL_STA_DUAL_INFEAS_CER') ||...
                        strcmp(res.sol.bas.solsta,'MSK_SOL_STA_NEAR_DUAL_INFEAS_CER')
                    stat=0; % infeasible
                end
            end

            %debugging
            % if printLevel>2
            %     res1=A*x + s -b;
            %     norm(res1(csense == 'G'),inf)
            %     norm(s(csense == 'G'),inf)
            %     norm(res1(csense == 'L'),inf)
            %     norm(s(csense == 'L'),inf)
            %     norm(res1(csense == 'E'),inf)
            %     norm(s(csense == 'E'),inf)
            %     res1(~isfinite(res1))=0;
            %     norm(res1,inf)

            %     norm(osense*c -A'*y -w,inf)
            %     y2=res.sol.itr.slc-res.sol.itr.suc;
            %     norm(osense*c -A'*y2 -w,inf)
            % end
        else
            disp(res);
            origStat = [];
            stat = -1;
        end


        if isfield(param,'MSK_IPAR_OPTIMIZER')
            algorithm=param.MSK_IPAR_OPTIMIZER;
        end
    case 'mosek_linprog'
        %% mosek
        % if mosek is installed, and the paths are added ahead of matlab's
        % built in paths, then mosek linprog shaddows matlab linprog and
        % is used preferentially

        options=solverParams;
        % only set print level if not set already
        if ~isfield(options,'Display')
            switch problemTypeParams.printLevel
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
        % generate proper mosek options structure for linprog
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
            stat = 1; % optimal solution found
            f = f*osense;
            y = zeros(size(A,1),1);
            y(csense == 'E',1) = -lambda.eqlin;
            y(csense == 'L' | csense == 'G',1) = -lambda.ineqlin;
            y(csense == 'G',1)=-y(csense == 'G',1); %change sign
            w = lambda.lower-lambda.upper;
        elseif (origStat < 0)
            stat = 0; % infeasible
        else
            stat = -1; % Solution did not converge
        end

    case 'gurobi'
        % Free academic licenses for the Gurobi solver can be obtained from
        % http://www.gurobi.com/html/academic.html
        % resultgurobi = struct('x',[],'objval',[],'pi',[]);

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
        % i.e. params.method     = 1;          % use dual simplex method

        param=solverParams;
        if ~isfield(param,'OutputFlag')
            switch problemTypeParams.printLevel
                case 0
                    param.OutputFlag = 0;
                    param.DisplayInterval = 1;
                case 1
                    param.OutputFlag = 0;
                    param.DisplayInterval = 1;
                otherwise
                    % silent
                    param.OutputFlag = 0;
                    param.DisplayInterval = 1;
            end
        end

        if isfield(param,'FeasibilityTol')
            % update tolerance according to actual setting
            problemTypeParams.feasTol = param.FeasibilityTol;
        else
            param.FeasibilityTol = problemTypeParams.feasTol;
        end
            
        if isfield(param,'OptimalityTol')
            % update tolerance according to actual setting
            problemTypeParams.optTol = param.OptimalityTol;
        else      
            param.OptimalityTol = problemTypeParams.optTol;
        end

        gurobiLP.sense(1:length(b),1) = '=';
        gurobiLP.sense(csense == 'L') = '<';
        gurobiLP.sense(csense == 'G') = '>';

        %modelsense (optional)
        %The optimization sense. Allowed values are 'min' (minimize) or 'max' (maximize). When absent, the default optimization sense is minimization.
        if osense == -1
            gurobiLP.modelsense = 'max';
        else
            gurobiLP.modelsense = 'min';
        end

        gurobiLP.A = A;
        gurobiLP.rhs = b;
        gurobiLP.lb = lb;
        gurobiLP.ub = ub;
        %gurobi wants a dense double vector as an objective
        gurobiLP.obj = double(c)+0;%full


        % basis reuse - Ronan
        if ~isempty(basis)
            gurobiLP.cbasis = full(basis.cbasis);
            gurobiLP.vbasis = full(basis.vbasis);
        end
        % set the solver specific parameters
        param = updateStructData(param,solverParams);

%         LPproblem = rmfield(LPproblem,'c');
%         LPproblem = rmfield(LPproblem,'b');
%         LPproblem = rmfield(LPproblem,'lb');
%         LPproblem = rmfield(LPproblem,'ub');
%         LPproblem = rmfield(LPproblem,'osense');
%         LPproblem = rmfield(LPproblem,'csense');
        
        % call the solver
        resultgurobi = gurobi(gurobiLP,param);

        % see the solvers original status -Ronan
        origStat = resultgurobi.status;
        switch resultgurobi.status
            case 'OPTIMAL'
                stat = 1; % optimal solution found
                
                if stat ==1 && isempty(resultgurobi.x)
                    error('solveCobraLP: gurobi reporting OPTIMAL but no solution')
                end
                [x,f,y,w,s] = deal(resultgurobi.x,resultgurobi.objval,osense*resultgurobi.pi,osense*resultgurobi.rc,resultgurobi.slack);
                
                if problemTypeParams.printLevel>2
                    res1 = A*x + s - b;
                    disp(norm(res1,inf))
                    res2 = osense*c  - A' * y - w;
                    disp(norm(res2,inf))
                    disp('Check osense*c - A''*lam - w = 0 (stationarity):');
                    res22 = gurobiLP.obj - gurobiLP.A'*resultgurobi.pi - resultgurobi.rc;
                    disp(res22)
                    if ~all(res22<1e-8)
                        pause(0.1);
                    end
                    
                    pause(0.1)
                end
            
                % save the basis
                basis.vbasis=resultgurobi.vbasis;
                basis.cbasis=resultgurobi.cbasis;
            case 'INFEASIBLE'
                stat = 0; % infeasible
            case 'UNBOUNDED'
                stat = 2; % unbounded
            case 'INF_OR_UNBD'
                % we simply remove the objective and solve again.
                % if the status becomes 'OPTIMAL', it is unbounded, otherwise it is infeasible.
                gurobiLP.obj(:) = 0;
                resultgurobi = gurobi(gurobiLP,param);
                if strcmp(resultgurobi.status,'OPTIMAL')
                    stat = 2;
                else
                    stat = 0; % Gurobi reports infeasible *or* unbounded
                end
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
            % i.e. params.method     = 1;          % use dual simplex method
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
        % matlab is not a reliable LP solver
        switch problemTypeParams.printLevel
           case 0
               matlabPrintLevel = 'off';
           case 1
               matlabPrintLevel = 'final';
           case 2
               matlabPrintLevel = 'iter';
           otherwise
               matlabPrintLevel = 'off';
        end

        % Set the solver Options.
        % Seems like matlab tends to ignore the optimalityTolerance (or at
        % least vilates it (e.g. 3*e-6 when tol is set to 1e-6, so we will
        % make this tolerance smaller...)
        if verLessThan('matlab','9.0')
            optToleranceParam = 'TolFun';
            constTolParam = 'TolCon';
        else
            optToleranceParam = 'OptimalityTolerance';
            constTolParam = 'ConstraintTolerance';
        end

        % define clinprog depending on the version of MATLAB
        if verLessThan('matlab','9.1')
            clinprog = @(f,A,b,Aeq,beq,lb,ub,options) linprog(f,A,b,Aeq,beq,lb,ub,[],options);
        else
            clinprog = @(f,A,b,Aeq,beq,lb,ub,options) linprog(f,A,b,Aeq,beq,lb,ub,options);
        end

        if problemTypeParams.optTol < 1e-8
            problemTypeParams.optTol = problemTypeParams.optTol * 100; %make sure, that we are within the range of allowed values.
        end

        linprogOptions = optimoptions('linprog','Display',matlabPrintLevel,optToleranceParam,problemTypeParams.optTol*0.01,constTolParam,problemTypeParams.feasTol);
        % replace all options if they are provided by the solverParameters struct
        linprogOptions = updateStructData(linprogOptions,solverParams);
        %UPdate Tolerance according to actual tolerance used.
        problemTypeParams.feasTol = linprogOptions.(constTolParam);

        if (isempty(csense))
            [x,f,origStat,output,lambda] = clinprog(c*osense,[],[],A,b,lb,ub,linprogOptions);
        else
            Aeq = A(csense == 'E',:);
            beq = b(csense == 'E');
            Ag = A(csense == 'G',:);
            bg = b(csense == 'G');
            Al = A(csense == 'L',:);
            bl = b(csense == 'L');
            Aineq = [Al;-Ag];
            bineq = [bl;-bg];
            [x,f,origStat,output,lambda] = clinprog(c*osense,Aineq,bineq,Aeq,beq,lb,ub,linprogOptions);
        end
        y = [];
        
        if (origStat > 0)
            stat = 1; % optimal solution found
            f = f*osense;
            y = zeros(size(A,1),1);
            y(csense == 'E') = -lambda.eqlin;
            if isfield(lambda,'ineqlin')
                y(csense == 'L' | csense == 'G',1) = lambda.ineqlin;
                y(csense == 'G',1) = - y(csense == 'G',1); %change sign
            end
            w = lambda.lower - lambda.upper;
            
            s = b - A*x;
        elseif (origStat < -1)
            stat = 0; % infeasible
        elseif origStat == -1
            stat = 3; % Maybe some partial success
            try
                f = f*osense;
                y = zeros(size(A,1),1);
                y(csense == 'E') = -lambda.eqlin;
                if isfield(lambda,'ineqlin')
                    y(csense == 'L' | csense == 'G',1) = lambda.ineqlin;
                    y(csense == 'G',1) = - y(csense == 'G',1); %change sign
                end
                w = osense*(lambda.upper-lambda.lower);
                s = b - A*x;
            catch ME
                % if values cant be assigned, we report a fail.
                stat = 0;
            end
        else
            stat = -1;
        end
        
    case 'tomlab_cplex'
        %% Tomlab
        if (~isempty(csense))
            b_L(csense == 'E') = b(csense == 'E');
            b_U(csense == 'E') = b(csense == 'E');
            b_L(csense == 'G') = b(csense == 'G');
            b_U(csense == 'G') = Inf;
            b_L(csense == 'L') = -Inf;
            b_U(csense == 'L') = b(csense == 'L');
        else
            b_L = b;
            b_U = b;
        end
        tomlabProblem = lpAssign(osense*c,A,b_L,b_U,lb,ub);
        % Result = tomRun('cplex', tomlabProblem, 0);
        % This is faster than using tomRun

        % set parameters
        tomlabProblem.optParam = optParamDef('cplex',tomlabProblem.probType);
        tomlabProblem.QP.F = [];
        tomlabProblem.PriLevOpt = problemTypeParams.printLevel;

        if ~isempty(basis) && ...
                ~ismember('basis',fieldnames(solverParams))
            tomlabProblem.MIP.basis = basis;
        end

        % set tolerance
        tomlabProblem.MIP.cpxControl.EPRHS = problemTypeParams.feasTol;
        tomlabProblem.MIP.cpxControl.EPOPT = problemTypeParams.optTol;

        %Update the parameter struct according to provided parameters
        %This may overwrite feasTol and optTol if provided
        tomlabProblem.MIP.cpxControl = updateStructData(tomlabProblem.MIP.cpxControl,solverParams);

        %UPdate Tolerance according to actual tolerance used.
        problemTypeParams.feasTol = tomlabProblem.MIP.cpxControl.EPRHS;
        problemTypeParams.optTol = tomlabProblem.MIP.cpxControl.EPOPT;

        % solve
        Result = cplexTL(tomlabProblem);

        % Assign results
        x = Result.x_k;
        w = Result.v_k(1:length(lb));
        y = Result.v_k((length(lb)+1):end);
        f = osense*sum(tomlabProblem.QP.c.*Result.x_k);
        s = b - A * x; % output the slack variables
        
        basis = Result.MIP.basis;
        
        origStat = Result.Inform;
%       1 (S,B) Optimal solution found
%       2 (S,B) Model has an unbounded ray
%       3 (S,B) Model has been proved infeasible
%       4 (S,B) Model has been proved either infeasible or unbounded
%       5 (S,B) Optimal solution is available, but with infeasibilities after unscaling
%       6 (S,B) Solution is available, but not proved optimal, due to numeric difficulties
        
        if origStat == 1
            stat = 1; % 1 - Optimal solution
        elseif origStat == 3 
            stat = 0;  % 0 - Infeasible problem
        elseif origStat == 2 || origStat == 4
            stat = 2; % 2 - Unbounded solution
        elseif (origStat == 5 || origStat == 6)
            stat = 3; % 3 - Almost optimal solution
        else
            stat = -1; %-1 - Some other problem (timelimit, numerical problem etc)
        end
        
        % cplexStatus analyzes the CPLEX output Inform code and returns
        % the CPLEX solution status message in ExitText and the TOMLAB exit flag
        % in ExitFlag
        [origStatText, ~] = cplexStatus(origStat);
        
    case 'cplex_direct'
        % used with the current script, only some of the control affoarded with
        % this interface is provided. Primarily, this is to change the print
        % level and whether to minimise the Euclidean Norm of the internal
        % fluxes or not.
        % See solveCobraLPCPLEX.m for more refined control of cplex
        % Ronan Fleming 11/12/2008
        if isfield(LPproblem,'basis') && ~isempty(LPproblem.basis)
            LPproblem.LPBasis = LPproblem.basis;
        end
        [solution,LPprob] = solveCobraLPCPLEX(LPproblem,problemTypeParams.printLevel,1,[],[],minNorm);
        solution.basis = LPprob.LPBasis;
        solution.solver = solver;
        solution.algorithm = algorithm; % dummy
        if exist([pwd filesep 'clone1.log'],'file')
            delete('clone1.log')
        end
    case 'cplexlp'
        %https://www.ibm.com/support/knowledgecenter/SSSA5P_12.9.0/ilog.odms.cplex.help/refmatlabcplex/html/cplexlp-m.html
        
%         Inpuy:
%         problem 	Structure containing the following fields
%         f         Double column vector for linear objective function
%         Aineq 	Double matrix for linear inequality constraints
%         bineq 	Double column vector for linear inequality constraints
%         Aeq       Double matrix for linear equality constraints
%         beq       Double column vector for linear equality constraints
%         lb        Double column vector of lower bounds
%         ub        Double column vector of upper bounds
%         x0        Double column vector of initial point of x
%         options 	Options structure created with cplexoptimset

%         Output:
%         x             Solution found by the optimization function. If exitflag > 0, then x is a solution; otherwise, x is the value of the optimization routine when it terminated prematurely.
%         fval          Value of the objective function at the solution x
%         exitflag 	    Integer identifying the reason the optimization algorithm terminated
%         output 	    Structure containing information about the optimization. The fields of the structure are:
%           iterations:   Number of iterations
%           algorithm:    Optimization algorithm used
%           message:      Exit message
%           time:         Execution time of the algorithm
%           cplexstatus:  Status code of the solution
%           cplexstatusstring: Status string of the solution
%         lambda 	    Structure containing the Lagrange multipliers at the solution x (separated by constraint type). This is only available for problems that do not contain quadratic constraints. See cplexqp() for details.

%         try
%             CplexLPproblem = Cplex('fba');
%         catch ME
%             error('CPLEX not installed or licence server not up')
%         end
        
        %https://www.ibm.com/support/knowledgecenter/SSSA5P_12.10.0/ilog.odms.cplex.help/refmatlabcplex/html/cplexoptimset-m.html
        % options = cplexoptimset ('cplex') creates a structure options, which
        % contains all of the CPLEX parameters. 
        options = cplexoptimset('cplex');

        % set the printLevel to the cobra Parameters (dont use .Cur)
        options.output.writelevel = problemTypeParams.printLevel;
        options.barrier.display = problemTypeParams.printLevel;
        options.simplex.display = problemTypeParams.printLevel;
        options.sifting.display = problemTypeParams.printLevel;
        options.paramdisplay = problemTypeParams.printLevel~=0;
        options.output.clonelog = problemTypeParams.printLevel-1;

        if ~isempty(csense)
            boolE=csense == 'E';
            boolL=csense == 'L';
            boolG=csense == 'G';
            %Aineq = [A(boolL,:); - A(boolG,:)];
            %bineq = [b(boolL,:); - b(boolG,:)];
            %        min      c*x
            %        st.      Aineq*x <= bineq
            %                 Aeq*x    = beq
            %                 lb <= x <= ub
            %[x,~,~,output,lambda] = cplexlp(osense*c,Aineq,bineq,A(csense == 'E',:),b(csense == 'E',1),lb,ub,[],options);
            [x,~,~,output,lambda] = cplexlp(osense*c,[A(boolL,:); - A(boolG,:)],[b(boolL,:); - b(boolG,:)],A(boolE,:),b(boolE,1),lb,ub,[],options);
        else
            Aineq=[];
            bineq=[];
            [x,~,~,output,lambda] = cplexlp(osense*c,Aineq,bineq,A,b,lb,ub,[],options);

        end
        
        %check the satus of the solution
        %Note that we are using the original cplex output satus, not the
        %simplified one invented by ibm
        origStat = output.cplexstatus;

%       1 (S,B) Optimal solution found
%       2 (S,B) Model has an unbounded ray
%       3 (S,B) Model has been proved infeasible
%       4 (S,B) Model has been proved either infeasible or unbounded
%       5 (S,B) Optimal solution is available, but with infeasibilities after unscaling
%       6 (S,B) Solution is available, but not proved optimal, due to numeric difficulties
        if origStat == 1
            stat = 1; % 1 - Optimal solution
        elseif origStat == 3
            stat = 0;  % 0 - Infeasible problem
        elseif origStat == 2 || origStat == 4
            stat = 2; % 2 - Unbounded solution
        elseif origStat == 5 || origStat == 6
            stat = 3; % 3 - Almost optimal solution
        else
            stat = -1; %-1 - Some other problem (timelimit, numerical problem etc)
        end
        
        if stat==1 || stat==3
            if all(boolE)
                %this is the dual to the equality constraints
                y = -lambda.eqlin;
            else
                %this is the dual to the equality constraints
                y = sparse(size(A,1),1);
                y(boolE) = -lambda.eqlin;
                y(boolL | boolG,1) = -lambda.ineqlin;
                y(boolG,1) = - y(boolG,1); %change sign
            end
            %objective
            f = c'*x;
            % output the slack variables
            s = b - A * x;
            
            %this is the dual to the simple ineequality constraints : reduced costs
            w =  lambda.lower - lambda.upper;
            
            algorithm = output.algorithm;
            if 0 %debug
                disp(algorithm)
                norm(osense * c  - A' * y - w,inf)
            end
        else
            x=[];
            y=[];
            s=[];
            w=[];
            f=[];
        end

        % cplexStatus analyzes the CPLEX output Inform code and returns
        % the CPLEX solution status message in ExitText and the TOMLAB exit flag
        % in ExitFlag
        [origStatText, ~] = cplexStatus(origStat);
    case 'ibm_cplex'
        % By default use the complex ILOG-CPLEX interface as it seems to be faster
        % iBM(R) ILOG(R) CPLEX(R) Interactive Optimizer 12.5.1.0

        % Initialize the CPLEX object
        %ILOGcplex = buildCplexProblemFromCOBRAStruct(LPproblem);
        [CplexLPproblem, logFile, logToFile] = setCplexParametersForProblem(CplexLPproblem,problemTypeParams,solverParams,'LP');
        %logToFile=0;
        
        % optimize the problem
        CplexLPproblem.solve();
    
        if logToFile
            % Close the output file
            fclose(logFile);
        end
                
        % http://www-eio.upc.edu/lceio/manuals/cplex-11/html/overviewcplex/statuscodes.html
        % https://www.ibm.com/support/knowledgecenter/SSSA5P_12.5.1/ilog.odms.cplex.help/refmatlabcplex/html/classCplex.html#a93e3891009533aaefce016703acb30d4
        origStat   = CplexLPproblem.Solution.status;
        %stat = origStat;
        if origStat==1 && isfield(CplexLPproblem.Solution,'dual')
            stat = 1;
            f = CplexLPproblem.Solution.objval;
            if ~isfield(CplexLPproblem.Solution,'x')
                disp(CplexLPproblem)
            end
            x = CplexLPproblem.Solution.x;
            w = osense*CplexLPproblem.Solution.reducedcost;
            y = osense*CplexLPproblem.Solution.dual;
            %res1 = A*solution.full + solution.slack - b;
            s = b - A * x; % output the slack variables
        elseif origStat == 2 ||   origStat == 20
            stat = 2; %unbounded
        elseif origStat == 3
            stat = 0;%infeasible
        elseif origStat == 4
            % this is likely unbounded, but could be infeasible
            % lets check, by solving an additional LP with no objective.
            % if that LP has a solution, it's unbounded. If it doesn't, it's infeasible.
            Solution = CplexLPproblem.Solution;
            CplexLPproblem.Model.obj(:) = 0;
            CplexLPproblem.solve();
            origStatNew   = CplexLPproblem.Solution.status;
            if origStatNew == 1
                stat = 2;
            else
                stat = 0;
            end
            % restore the original solution.
            % restore the original solution.
            CplexLPproblem.Solution = Solution;
        elseif origStat == 5 || origStat == 6
            stat = 3;% Almost optimal solution
            f = CplexLPproblem.Solution.objval;
            x = CplexLPproblem.Solution.x;
            w = osense*CplexLPproblem.Solution.reducedcost;
            y = osense*CplexLPproblem.Solution.dual;
            s = b - A * x; % output the slack variables
        elseif (origStat >= 10 && origStat <= 12) || origStat == 21 || origStat == 22
            % abort due to reached limit. check if there is a solution and return it.
            stat = 3;
            if isfield(CplexLPproblem.Solution ,'x')
                x = CplexLPproblem.Solution.x;
            else
               % no solution returned
                stat = -1;
            end
            if isfield(CplexLPproblem.Solution ,'reducedcost')
                w = osense*CplexLPproblem.Solution.reducedcost;
            end
            if isfield(CplexLPproblem.Solution ,'dual')
                y = osense*CplexLPproblem.Solution.dual;
            end
        else
            stat = -1;
        end
        
        % cplexStatus analyzes the CPLEX output Inform code and returns
        % the CPLEX solution status message in ExitText and the TOMLAB exit flag
        % in ExitFlag
        [origStatText, ~] = cplexStatus(origStat);

        switch CplexLPproblem.Param.lpmethod.Cur
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
        % 1 = (Simplex or Barrier) Optimal solution is available.
        labindex = 1;
        if exist([pwd filesep 'clone1_' labindex '.log'],'file')
            delete([pwd filesep 'clone1_' labindex '.log'])
        end
        if exist([pwd filesep 'clone2_' labindex '.log'],'file')
            delete([pwd filesep 'clone2_' labindex '.log'])
        end
    case 'lindo'
        %%
        error('The lindo interface is obsolete.');
    case 'pdco'
        % changed 30th May 2015 with Michael Saunders
        % -----------------------------------------------------------------------
        % pdco.m: Primal-Dual Barrier Method for Convex Objectives (16 Dec 2008)
        % -----------------------------------------------------------------------
        % AUTHOR:
        %    Michael Saunders, Systems Optimization Laboratory (SOL),
        %    Stanford University, Stanford, California, USA.
        %    interfaced with Cobra toolbox by Ronan Fleming, 27 June 2009
        
        % pdco is a general purpose convex optization solver, not only a
        % linear optimization solver. As such, much control over the optimal
        % solution and the method for solution is available. However, this
        % also means you may have to tune the various parameters here,
        % especially xsize and zsize (see pdco.m) to get the real optimal
        % objective value

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
        end
        
        %parameters to provide to pdco are the following:
        % d1,d2,options,x0,y0,z0,xsize,zsize
        
        % generate set of default parameters for this solver
        options = pdcoSet;
        options.Method = 2;
        
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
        
        [x,y,w,inform,~,~,~] = pdco(osense*ceq,Aeq,beq,lbeq,ubeq,d1,d2,options,x0,y0,z0,xsize,zsize);
        
        if 0%1 for debug
            norm(Aeq*x - beq,inf)
            norm(Aeq*x - beq + (d2^2)*y,inf)
        end
        
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
                %switch the sign of the dual to the constraint that was
                %switched
                y(csense == 'G') = -y(csense == 'G');
            end
            if 0
                norm(A*x + s - b + (d2^2)*y,inf)
                norm(c - A'*y - w,inf)
                norm(osense*c - A'*y - w,inf)
            end
            x =   x(1:nRxn);
            w =   w(1:nRxn);

            f = c'*x;
        elseif (inform == 1 || inform == 2 || inform == 3)
            stat = 0;
            f = NaN;
        else
            stat = -1;
            f = NaN;
        end
        origStat = inform;
          
        %update parameters for testing optimality criterion
        problemTypeParams.feasTol = options.FeaTol;
        problemTypeParams.optTol = options.OptTol;
    case 'mps'
        fprintf(' > The interface to ''mps'' from solveCobraLP is not supported anymore.\n -> Instead use >> writeCbModel(model, ''mps'');\n');
        % temporary legacy support
        writeLPProblem(LPproblem,'fileName','LP.mps','solverParams',solverParams);
    otherwise
        if isempty(solver)
            error('There is no solver for LP problems available');
        else
            error(['Unknown solver: ' solver]);
        end

end
if stat == -1
    % this is slow, so only check it if there is a problem
    if any(any(~isfinite(A(A~=0))))
        error('Cannot perform LP on a stoichiometric matrix with NaN of Inf coefficents.')
    end
end

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
else
    s = [];
end

if ~strcmp(solver,'cplex_direct') && ~strcmp(solver,'mps')
    % assign solution
    t = etime(clock, t_start);
    if ~exist('basis','var'), basis=[]; end
    [solution.full, solution.obj, solution.rcost, solution.dual, solution.slack, ...
     solution.solver, solution.algorithm, solution.stat, solution.origStat, ...
     solution.origStatText,solution.time,solution.basis] = deal(x,f,w,y,s,solver,algorithm,stat,origStat,origStatText,t,basis);
elseif strcmp(solver,'mps')
    solution = [];
end

% check the optimality conditions for various solvers
 %if ~any(strcmp(solver, {'mps','dqqMinos'}))
 if ~any(strcmp(solver, {'mps'}))
     if solution.stat == 1
         if ~isempty(solution.slack) && ~isempty(solution.full)
             % determine the residual 1
             res1 = A*solution.full + solution.slack - b;
             res1(~isfinite(res1))=0;
             tmp1 = norm(res1, inf);
             
             % evaluate the optimality condition 1
             if tmp1 > problemTypeParams.feasTol * 1e2
                 disp(solution.origStat)
                 error(['[' solver '] Primal optimality condition in solveCobraLP not satisfied, residual = ' num2str(tmp1) ', while feasTol = ' num2str(problemTypeParams.feasTol)])
             else
                 if problemTypeParams.printLevel > 0
                     fprintf(['\n > [' solver '] Primal optimality condition in solveCobraLP satisfied.']);
                 end
             end
         end
         
         if ~isempty(solution.rcost) && ~isempty(solution.dual) && ~any(strcmp(solver, {'glpk','matlab'})) 
             
             % determine the residual 2
             res2 = osense * c  - A' * solution.dual - solution.rcost;
             tmp2 = norm(res2, inf); %TODO matlab linprog still does not pass Testing testDifferentLPSolvers using matlab
             
             % evaluate the optimality condition 2
             if tmp2 > problemTypeParams.optTol * 1e2
                 disp(solution.origStat)
                 if ~(length(A)==1 && strcmp(solver,'pdco')) %todo, why does pdco choke on small A?
                    error(['[' solver '] Dual optimality condition in solveCobraLP not satisfied, residual = ' num2str(tmp2) ', while optTol = ' num2str(problemTypeParams.optTol)])
                 end
             else
                 if problemTypeParams.printLevel > 0
                     fprintf(['\n > [' solver '] Dual optimality condition in solveCobraLP satisfied.\n']);
                 end
             end
         end
     end
end

end


%%%%%%%%%%%%%%% Private functions %%%%%%%%%%%%%%%%%%%%%%%%%55
%% solveGlpk Solve actual LP problem using glpk and return relevant results
function [x,f,y,w,stat,origStat] = solveGlpk(c,A,b,lb,ub,csense,osense,params)

% old way of calling glpk
%[x,f,stat,extra] = glpkmex(osense,c,A,b,csense,lb,ub,[],params);
[x,f,origStat,extra] = glpk(c,A,b,lb,ub,csense,[],osense,params);
y = extra.lambda;
w = extra.redcosts;
% Note that status handling may change (see glplpx.h)
if (origStat == 180 || origStat == 5)
    stat = 1; % optimal solution found
elseif (origStat == 182 || origStat == 183 || origStat == 3 || origStat == 110)
    stat = 0; % infeasible
elseif (origStat == 184 || origStat == 6)
    stat = 2; % unbounded
else
    stat = -1; % Solution not optimal or solver problem
end
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

function minosCleanUp(MINOS_PATH,fname, originalDirectory)
% CleanUp after Minos Solver.

fileEnding = {'.sol', '.out', '.newbasis', '.basis', '.finalbasis'};
addFileName = {'', 'q'};

% remove temporary data directories
tmpFileName = [MINOS_PATH filesep 'data'];
try
    if exist(tmpFileName, 'dir') == 7
        rmdir(tmpFileName, 's')
    end
catch
end

% remove temporary solver files
for k = 1:length(fileEnding)
    for q = 1:length(addFileName)
        tmpFileName = [MINOS_PATH filesep addFileName{q} fname fileEnding{k}];
        if exist(tmpFileName, 'file') == 2
            delete(tmpFileName);
        end
    end
end

cd(originalDirectory);
end

% function [varargout] = setupOPTIproblem(c,A,b,osense,csense,solver)
% % setup the constraint coeffiecient matrix and rhs vector for OPTI solvers
% % this can be done here for lower level calls or disregarded when solver is
% % called using an OPTI object as argument

% % set constraint type
% e = zeros(size(A,1),1);
% e(strcmpi(cellstr(csense),'L')) = -1;
% e(strcmpi(cellstr(csense),'E')) = 0;
% e(strcmpi(cellstr(csense),'G')) = 1;
% Aeq = A(e==0,:);
% Ainl = A(e<0,:);
% Aing = A(e>0,:);
% beq = b(e==0,:);
% binl = b(e<0,:);
% bing = b(e>0,:);
% Aineq = [Ainl;-Aing];
% bineq = [binl;-bing];

% switch solver
%     case 'clp'
%         varargout{1} = full(c*osense);
%         varargout{2} = [Aineq;Aeq];
%         ru = [bineq;beq];
%         rl = -Inf(size(Aineq,1)+size(Aeq,1),1);
%         rl(size(Aineq,1)+1:end) = beq;
%         varargout{3} = rl;
%         varargout{4} = ru;
%     case 'csdp'
%         varargout{1} = full(c*osense);
%         varargout{2} = [Aineq;Aeq;-Aeq];
%         varargout{3} = [bineq;beq;-beq];
%     case 'dsdp'
%         varargout{1} = full(c*osense);
%         varargout{2} = [Aineq;Aeq;-Aeq];
%         varargout{3} = [bineq;beq;-beq];
%     case 'ooqp'
%         varargout{1} = full(c*osense);
%         varargout{2} = Aineq;
%         ru = bineq;
%         rl = -Inf(size(Aineq,1),1);
%         varargout{3} = rl;
%         varargout{4} = ru;
%         varargout{5} = Aeq;
%         varargout{6} = beq;
%     case 'scip'
%         varargout{1} = full(c*osense);
%         varargout{2} = [Aineq;Aeq];
%         ru = [bineq;beq];
%         rl = -Inf(size(Aineq,1)+size(Aeq,1),1);
%         rl(size(Aineq,1)+1:end) = beq;
%         varargout{3} = rl;
%         varargout{4} = ru;
%         varargout{5} = repmat('C',size(c*osense));
%     case 'auto'
%         varargout{1} = full(c);
%         varargout{2} = A;
%         varargout{3} = b;
%         varargout{4} = e;
%     otherwise
%         warning('Unsupported solver specified.\n OPTI will automatically determine problem type and solver');
% end
% if ~issparse(A)
%     varargout{2} = sparse(varargout{2});
% end


% function [w,y,algorithm,stat,exitflag,t] = parseOPTIresult(varargin)
% exitflag = varargin{1};
% info = varargin{2};
% w = [];
% y = [];
% algorithm = [];
% stat = exitflag;
% t = [];
% if isfield(info,'Lambda')
%     if isfield(info.Lambda,'bounds')
%         w = info.Lambda.bounds;
%     end
%     if isfield(info.Lambda,'eqlin') & isfield(info.Lambda,'ineqlin')
%         % need to check whether duals from all constraints are included
%         y = [info.Lambda.ineqlin;info.Lambda.eqlin];
%     end
% end
% if isfield(info,'Algorithm')
%     algorithm = info.Algorithm;
% end
% switch exitflag
%     case -5 % user exit
%         stat = -1;
%     case -4 % unknown exit
%         stat = -1;
%     case -3 % clp error/lack of progress/numerical error
%         stat = -1;
%     case -2 % stuck at edge primal/dual infeasibility
%         stat = 0;
%     case -1 % primal/dual infeasible
%         stat = 0;
%     case 0 % exceeded maximum iterations - no solution
%         stat = -1;
%     case 1 % primal optimal
%         stat = 1;
%     case 3 % partial success - csdp
%         stat = 3;
% end
% if isfield(info,'Time')
%     t = info.Time;
% end

% function opts = setupOPTIoptions(varargin)
% % since most mex files for solvers and OPTI do error handling from within
% % only the basic options compliant with other cobra methods has been setup
% % with with similar exception handling
% % input accepted is either a list of parameters or structure with fields
% % corresponding to opti parameters
% opts = optiset();
% setdisp = 0;
% setwarn = 0;
% % if first argument is structure
% if isstruct(varargin{1})
%     params = varargin{1};
%     if isfield(params,'solver')
%         opts = optiset(opts,'solver',params.solver);
%     else
%         opts = optiset(opts,'solver','auto');
%     end
%     if isfield(params,'printLevel')
%         printLevel = params.printLevel;
%         params = rmfield(params,'printLevel');
%     end
%     if isfield(params,'display')
%         opts = optiset(opts,'display',params.display);
%         setdisp = 1;
%     end
%     if isfield(params,'warnings')
%         opts = optiset(opts,'warnings',params.warnings);
%         setwarn = 1;
%     end
%     if isfield(params,'tolrfun')
%         opts = optiset(opts,'tolrfun',params.tolrfun);
%     end
%     if isfield(params,'tolafun')
%         opts = optiset(opts,'tolafun',params.tolafun);
%     end
%     if isfield(params,'solverOpts')
%         solverOpts = params.solverOpts;
%     else
%         solverOpts = [];
%     end
%     if strcmp(params.solver,'clp') | strcmp(params.solver,'ooqp') |...
%        strcmp(params.solver,'scip') | strcmp(params.solver,'auto')
%         if isfield(params,'algorithm')
%             solverOpts.algorithm = params.algorithm;
%         end
%     else
%         warning('OPTI algorithm cannot be set for LP solvers other than CLP, OOQP and SCIP');
%     end
%     varargin = varargin(2:end);
% end
% % other input arguments are name value pairs
% optname = varargin(1:2:length(varargin));
% optval = varargin(2:2:length(varargin));
% % optlist = {'solver','algorithm','printLevel','display','warnings',...
% %            'tolrfun','tolafun','optTol','solverOpts'};
% if any(strcmpi(optname,'solver'))
%     opts = optiset(opts,'solver',optval{strcmpi(optname,'solver')});
% end
% if any(strcmpi(optname,'printLevel'))
%     printLevel = optval{strcmpi(optname,'printLevel')};
% end
% % override printLevel using display and warning fields in params
% if any(strcmpi(optname,'display'))
%     opts = optiset(opts,'display',optval{strcmpi(optname,'display')});
%     setdisp = 1;
% end
% if any(strcmpi(optname,'warnings'))
%     opts = optiset(opts,'warnings',optval{strcmpi(optname,'warnings')});
%     setwarn = 1;
% end
% if any(strcmpi(optname,'tolrfun'))
%     opts = optiset(opts,'tolrfun',optval{strcmpi(optname,'tolrfun')});
% end
% if any(strcmpi(optname,'tolafun'))
%     opts = optiset(opts,'tolafun',optval{strcmpi(optname,'tolafun')});
% end
% % functionality to be added later
% % if any(strcmpi(optname,'solverOpts'))
% %     if ~exist('solverOpts','var')||(exist('solverOpts','var') && isempty(solverOpts))
% %         solverOpts = optval{strcmpi(optname,'solverOpts')};
% %     else
% %         % overwrite existing solverOpts fields and values
% %         newsolverOpts = optval{strcmpi(optname,'solverOpts')};
% %         newOpts = fieldnames(newsolverOpts);
% %         oldOpts = fieldnames(solverOpts);
% %
% %     end
% % %     opts = optiset(opts,'solverOpts',optval{strcmpi(optname,'solverOpts')});
% % else
% %     solverOpts = [];
% % end
% if any(strcmpi(optname,'algorithm'))
%     solverOpts.algorithm = optval{strcmpi(optname,'algorithm')};
% end
% if any(strcmpi(optname,'optTol'))
%     optTol = optval{strcmpi(optname,'optTol')};
% end
% if exist('solverOpts','var')&&~isempty(solverOpts)
%     opts = optiset(opts,'solverOpts',solverOpts);
% end
% if exist('optTol','var')&& ~isempty(optTol)
%     opts = optiset(opts,'tolrfun',optTol,'tolafun',optTol);
% end
% % printLevel
% if exist('printLevel','var') & ~setdisp & ~setwarn
%     if printLevel == 0
%         disp = 'off';
%         warnings = 'none';
%     elseif printLevel == 1
%         disp = 'off';
%         warnings = 'critical';
%     elseif printLevel == 2
%         disp = 'final';
%         warnings = 'critical';
%     elseif printLevel == 3
%         disp = 'iter';
%         warnings = 'critical';
%     elseif printLevel > 10
%         disp = 'all';
%         warnings = 'all';
%     end
%     opts = optiset(opts,'display',disp,'warnings',warnings);
% end

