function solution = solveCobraNLP(NLPproblem, varargin)
% Solves a COBRA non-linear (objective and/or constraints) problem.
% Solves a problem of the following form:
% optimize `objFunction(x)` or `c'*x`
% st. :math:`A*x  <=> b   or b_L < A*x < b_U`
% and  :math:`d_L < d(x) < d_U`
% where `A` is a matrix, `d(x)` is an optional function and the objective
% is either a general function or a linear function.
%
% USAGE:
%
%    solution = solveCobraNLP(NLPproblem, varargin)
%

% INPUT:
%    NLPproblem:    Non-linear optimization problem (fields up to 'c' are mandatory, below `c` are optional)
%
%                     * .A - LHS matrix
%                     * .b - RHS vector
%                     * .lb - Lower bound vector
%                     * .ub - Upper bound vector
%                     * .osense - Objective sense (-1 for maximisation, 1 for minimisation)
%                     * .csense - Constraint senses ('L','E','G')
%                     * .objFunction - Function to evaluate as the objective (The function
%                       will receive two inputs, First the flux vector to
%                       evaluate and second the NLPproblem struct. The function
%                       should be provided as a string (or `c`)
%                     * .c - linear objective such that `c*x` is optimized.
%                     * .x0 - Initial solution
%                     * .gradFunction - Name of the function that computes the `n x 1` gradient
%                       vector (ignored if 'd' is set).
%                     * .H - Name of the function that computes the `n` x `n` Hessian matrix
%                     * .fLowBnd - A lower bound on the function value at optimum.
%                     * .d - Name of function that computes the mN nonlinear constraints
%                     * .dd - Name of function that computes the constraint Jacobian `mN x n`
%                     * .d2d - Name of function that computes the second part of the
%                       Lagrangian function (only needed for some solvers)
%                     * .d_L - Lower bound vector in nonlinear constraints
%                     * .d_U - Upper bound vector in nonlinear constraints
%                     * .user - Solver specific user parameters structure
%
% Note that 'b_L' and 'b_U' can be used in place of 'b' and 'csense'
%
% Optional parameters can be entered using parameters structure or as
% parameter followed by parameter value: i.e. ,'printLevel', 3)
% Setting `parameters` = 'default' uses default setting set in
% `getCobraSolverParameters`.
%
% OPTIONAL INPUTS:
%    varargin:      Additional parameters either as parameter struct, or as
%                   parameter/value pairs. A combination is possible, if
%                   the parameter struct is either at the beginning or the
%                   end of the optional input.
%                   All fields of the struct which are not COBRA parameters
%                   (see `getCobraSolverParamsOptionsForType`) for this
%                   problem type will be passed on to the solver in a
%                   solver specific manner.
% OUTPUT:
%    solution:      Structure containing the following fields describing a NLP solution:
%
%                     * .full:            Full NLP solution vector
%                     * .obj:             Objective value
%                     * .rcost:           Reduced costs
%                     * .dual:            Dual solution
%                     * .solver:          Solver used to solve NLP problem
%                     * .stat:            Solver status in standardized form
%
%                       * 1 - Optimal solution
%                       * 2 - Unbounded solution
%                       * 0 - Infeasible
%                       * -1 - No solution reported (timelimit, numerical problem etc)
%                     * .origStat:        Original status returned by the specific solver
%                     * .time:            Solve time in seconds
%                     * .origSolStruct    Original solution structure%
%
% .. Author:
%       - Markus Herrgard 12/7/07
%       - Richard Que 02/10/10 Added tomlab_snopt support.

[cobraParams,solverParams] = parseSolverParameters('NLP',varargin{:});% get the solver parameters

% set the solver
solver = cobraParams.solver;

% save input if selected
if ~isempty(cobraParams.saveInput)
    fileName = cobraParams.saveInput;
    if ~find(regexp(fileName, '.mat'))
        fileName = [fileName '.mat'];
    end
    disp(['Saving LPproblem in ' fileName]);
    save(fileName, 'LPproblem')
end

currentDir = pwd;

cleanupobj = onCleanup(@() cd(currentDir));

optParamNames = {'printLevel','warning','checkNaN','PbName', ...
                 'iterationLimit', 'logFile'};
parameters = '';

% deal variables
[A,lb,ub] = deal(NLPproblem.A,NLPproblem.lb,NLPproblem.ub);

% assume constraint A*x = b if csense not provided
if ~isfield(NLPproblem, 'csense')
    % If csense is not declared in the Problem, assume that all
    % constraints are equalities.
    NLPproblem.csense(1:size(A,1), 1) = 'E';
end
csense = NLPproblem.csense;

% assume constraint A*x = 0 if b not provided
if ~isfield(NLPproblem, 'b')
    NLPproblem.b = zeros(size(A, 1), 1);
end
b = NLPproblem.b;

if isfield(NLPproblem, 'objFunction')
    objFunction = NLPproblem.objFunction;
elseif isfield(NLPproblem, 'c')
    c = NLPproblem.c;
else
    error('either .objFunction or .c must be defined')
end

if isfield(NLPproblem,'x0')
    x0 = NLPproblem.x0;
else
    x0 = [];
end


t_start = clock;
% solvers
switch solver
    case 'matlab'
        %% fmincon
        A1 = [A(csense == 'L',:);-A(csense == 'G',:)];
        b1 = [b(csense == 'L'),-b(csense == 'G')];

        A2 = A(csense == 'E',:);
        b2 = b(csense == 'E');

        % get fminCon Options, and set the options supplied by the user.
        switch cobraParams.printLevel
            case 0
                fminconPrintLevel = 'off';
            case 1
                fminconPrintLevel = 'final';
            case 2
                fminconPrintLevel = 'iter-detailed';
            otherwise
                fminconPrintLevel = 'off';
        end
        options = optimoptions('fmincon','maxIter',cobraParams.iterationLimit,'maxFunEvals',cobraParams.iterationLimit, 'Display',fminconPrintLevel);

        options = updateStructData(options,solverParams);

        % define the objective function with 2 input arguments
        if exist('objFunction','var')
            func = eval(['@(x) ', num2str(NLPproblem.osense), '*' , objFunction, '(x, NLPproblem)']);
        else
            func = @(x) NLPproblem.osense*sum(c.*x);
        end

        %Now, define the maximum timer

        options.OutputFcn = @stopTimer;

        %and start it.
        stopTimer(cobraParams.timeLimit,1);

        % save current directory
        currentDir = pwd;

        % change to temporary directory
        % NOTE: this change to the matlabroot is necessary, as other solvers may shade the fmincon function
        cd([matlabroot filesep 'toolbox' filesep 'shared' filesep 'optimlib']);

        % call fmincon
        [x, f, origStat, output, lambda] = fmincon(func, x0, A1, b1, A2, b2, lb, ub, [], options);

        % change back to currentDir
        cd(currentDir);

        % assign Results
        if (origStat > 0)
            stat = 1; % Optimal solution found
            y = lambda.eqlin;
            w = zeros(length(lb), 1); % set zero Lagrangian multipliers (N/A)
        elseif (origStat < 0)
            % we supply empty fields, but we need to assign them as otherwise
            y = [];
            w = [];
            stat = 0; % Infeasible
        else
            y = [];
            w = [];
            stat = -1; % Solution did not converge
        end
    case 'tomlab_snopt'
        %% tomlab_snopt

        %get settings
        [checkNaN, PbName, iterationLimit, logFile] =  ...
            getCobraSolverParams('NLP',{'checkNaN','PbName', 'iterationLimit', 'logFile'},parameters);
        if isfield(NLPproblem,'gradFunction')
            gradFunction = NLPproblem.gradFunction;
        else
            gradFunction = [];
        end
        if isfield(NLPproblem,'H')
            H = NLPproblem.H;
        else
            H = [];
        end
        if isfield(NLPproblem,'fLowBnd')
            fLowBnd = NLPproblem.fLowBnd;
        else
            fLowBnd = [];
        end
        if isfield(NLPproblem,'d')
            d = NLPproblem.d;
        else
            d = [];
        end
        if isfield(NLPproblem,'dd')
            dd = NLPproblem.dd;
        else
            dd = [];
        end
        if isfield(NLPproblem,'d2d')
            d2d = NLPproblem.d2c;
        else
            d2d = [];
        end
        if isfield(NLPproblem,'d_L')
            d_L = NLPproblem.d_L;
        else
            d_L = [];
        end
        if isfield(NLPproblem,'d_U')
            d_U = NLPproblem.d_U;
        else
            d_U = [];
        end
        if isfield(NLPproblem,'user')
            userParams = NLPproblem.user;
        else
            userParams = [];
        end
        if isfield(NLPproblem,'SOL'), Prob.SOL = NLPproblem.SOL; end

        x_L = lb;
        x_U = ub;
        if ~exist('b_L','var')
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
        end

        %settings
        HessPattern = [];
        pSepFunc = [];
        ConsPattern = [];
        x_min = []; x_max = [];
        f_opt = [];  x_opt = [];

        if exist('c', 'var') % linear objective function
            Prob  = lpconAssign(c, x_L, x_U, PbName, x0,...
               A, b_L, b_U,...
               d, dd, d2d, ConsPattern, d_L, d_U,...
               fLowBnd, x_min, x_max, f_opt, x_opt);
        else % general objective function
            f = objFunction;
            g = gradFunction;
            Prob = conAssign(f, g, H, HessPattern, x_L, x_U, PbName, x0, ...
                pSepFunc, fLowBnd, ...
                A, b_L, b_U, d, dd, d2d, ConsPattern, d_L, d_U, ...
                x_min, x_max, f_opt, x_opt);
        end
        Prob.user = userParams;
        Prob.Warning = cobraParams.warning;
        Prob.SOL.optPar(35) = cobraParams.iterationLimit; %This is major iteration limit.
        Prob.SOL.optPar(30) = 1e9; %this is the minor iteration limit.  Essentially unlimited
        Prob.CheckNaN = cobraParams.checkNaN;

        Prob.SOL.PrintFile = strcat(cobraParams.logFile, '_iterations.txt');
        Prob.SOL.SummFile = strcat(cobraParams.logFile, '_summary.txt');

        if cobraParams.printLevel >= 1
            Prob.optParam.IterPrint = 1;
        end
        if cobraParams.printLevel >=3
            Prob.PriLevOpt = 1;
        end
        %Now, update the Problem struct with solver Params....
        Prob = updateStructData(Prob,solverParams);

        %Call Solver
        Result = tomRun('snopt', Prob, cobraParams.printLevel);

        % Assign results
        x = Result.x_k;
        f = Result.f_k;

        origStat = Result.Inform;
        w = Result.v_k(1:length(lb));
        y = Result.v_k((length(lb)+1):end);
        if (origStat >= 1) && (origStat <= 3)
            stat = 1;
        elseif (origStat >= 11) && (origStat <= 14)
            stat = 0;
        elseif (origStat == 21 || origStat == 22)
            stat = 2;
        else
            stat = -1;
        end
    otherwise
        if isempty(solver)
            error('There is no solver for LP problems available');
        else
            error(['Unknown solver: ' solver]);
        end
end

%% Assign Solution
t = etime(clock, t_start);
[solution.full,solution.obj,solution.rcost,solution.dual, ...
    solution.solver,solution.stat,solution.origStat,solution.time] = ...
    deal(x,f,w,y,solver,stat,origStat,t);
if strcmp(solver,'tomlab_snopt')
    solution.origSolStruct = Result;
end
end

function overtimelimit = stopTimer(maxtime,init, varargin)
persistent STARTTIME;
persistent MAXTIME;
%OutputFunction will be called with 3 arguments during fmincon, so we can
%savely set this up with 2 arguments.
if nargin < 3
    if isempty(STARTTIME)
        %If the STARTTIME is not set, we can definitely set the new time.
        STARTTIME = clock;
        MAXTIME = maxtime;
    else
        if init
            %if we call for an initialisation, also reset the timer
            STARTTIME = clock;
            MAXTIME = maxtime;
        end
    end
else
    if etime(clock,STARTTIME) > MAXTIME
        disp('Time limit reached, stopping optimization')
        overtimelimit = 1;
    else
        overtimelimit = 0;
    end
end
end
