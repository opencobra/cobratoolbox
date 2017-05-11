function solution = solveCobraNLP(NLPproblem,varargin)
%solveCobraNLP Solves a COBRA non-linear (objective and/or constraints)
%problem.
%
% solution = solveCobraNLP(NLPproblem,varargin)

% Solves a problem of the following form:
%     optimize objFunction(x) or c'*x
%     st.       A*x  <=> b   or b_L < A*x < b_U
%        and    d_L < d(x) < d_U
%     where A is a matrix, d(x) is an optional function and the objective
%     is either a general function or a linear function.
%
%INPUT
% NLPproblem  Non-linear optimization problem
%  Required Fields
%   A               LHS matrix
%   b               RHS vector
%   lb              Lower bounds
%   ub              Upper bounds
%   csense          Constraint senses ('L','E','G')
%   osense          Objective sense (-1 for maximisation, 1 for minimisation)
%   objFunction     Function to evaluate as the objective (The function
%                   will receive two inputs, First the flux vector to
%                   evaluate and second the NLPproblem struct. The function
%                   should be provided as a string
%       or
%   c               linear objective such that c*x is optimized.
%  Note: 'b_L' and 'b_U' can be used in place of 'b' and 'csense'
%
%  Optional Fields
%   x0              Initial solution
%   gradFunction    Name of the function that computes the n x 1 gradient
%                   vector (ignored if 'd' is set).
%   H               Name of the function that computes the n x n Hessian
%                   matrix
%   fLowBnd         A lower bound on the function value at optimum.
%   d               Name of function that computes the mN nonlinear
%                   constraints
%   dd              Name of function that computes the constraint Jacobian
%                   mN x n
%   d2d             Name of function that computes the second part of the
%                   Lagrangian function (only needed for some solvers)
%   d_L             Lower bound vector in nonlinear constraints
%   d_U             Upper bound vector in nonlinear constraints
%   user            Solver specific user parameters structure
%
%OPTIONAL INPUTS
% Optional parameters for the solver can be entered using parameters structure or as
% parameter followed by parameter value: e.g. ,'printLevel',3)
%
% parameters    Structure containing optional parameters as fields.
%               Setting parameters = 'default' uses default setting set in
%               getCobraSolverParameters.
%
%OUTPUT
% solution Structure containing the following fields describing an NLP
% solution
%  full             Full LP solution vector
%  obj              Objective value
%  rcost            Reduced costs
%  dual             Dual solution
%  solver           Solver used to solve LP problem
%
%  stat             Solver status in standardized form
%                   1   Optimal solution
%                   2   Unbounded solution
%                   0   Infeasible
%                   -1  No solution reported (timelimit, numerical
%                       problem etc)
%
%  origStat         Original status returned by the specific solver
%  time             Solve time in seconds
%  origSolStruct    Original solution structure
%
% Markus Herrgard 12/7/07
% Richard Que (02/10/10) Added tomlab_snopt support.

global CBT_NLP_SOLVER

if ~isempty(CBT_NLP_SOLVER)
    solver = CBT_NLP_SOLVER;
else
    error('No solver found.  call changeCobraSolver(solverName)');
end

optParamNames = {'printLevel','warning','checkNaN','PbName', ...
                 'iterationLimit', 'logFile'};
parameters = '';

[printLevel ~] = getCobraSolverParams('NLP',{'printLevel','warning'},parameters);

if nargin ~=1
    if mod(length(varargin),2)==0
        for i=1:2:length(varargin)-1
            if ismember(varargin{i},optParamNames)
                parameters.(varargin{i}) = varargin{i+1};
            else
                %Changed to highlight non COBRA parameters (which might be used for e.g. fmincon.
                parameters.(varargin{i}) = varargin{i+1};
                if printLevel > 0
                    warning([varargin{i} ' is not a COBRA parameter']);
                end
            end
        end
    elseif strcmp(varargin{1},'default')
        parameters = 'default';
    elseif isstruct(varargin{1})
        parameters = varargin{1};
    else
        error('Invalid number of parameters/values')
        solution=[];
        return;
    end
end


%deal variables
[A,lb,ub] = deal(NLPproblem.A,NLPproblem.lb,NLPproblem.ub);

% Assume constraint S*v = b if csense not provided
if ~isfield(NLPproblem, 'csense')
    % If csense is not declared in the model, assume that all
    % constraints are equalities.
    NLPproblem.csense(1:size(A,1), 1) = 'E';
end

% Assume constraint S*v = 0 if b not provided
if ~isfield(NLPproblem, 'b')
    NLPproblem.b = zeros(size(A, 1), 1);
end

if isfield(NLPproblem,'csense')
    [b, csense] = deal(NLPproblem.b, NLPproblem.csense);
elseif isfield(NLPproblem,'b_U')
    [b_L,b_U] = deal(NLPproblem.b_L,NLPproblem.b_U);
else
    display('either .b_U, .b_L or .b, .csense must be defined')
end

if isfield(NLPproblem, 'objFunction')
    objFunction = NLPproblem.objFunction;
elseif isfield(NLPproblem, 'c')
    c = NLPproblem.c;
else
    display('either .objFunction or .c must be defined')
end
if isfield(NLPproblem,'x0')
    x0 = NLPproblem.x0;
else
    x0 = [];
end


t_start = clock;
% Solvers
switch solver
    case 'matlab'
        %% fmincon
        A1 = [A(csense == 'L',:);-A(csense == 'G',:)];
        b1 = [b(csense == 'L'),-b(csense == 'G')];

        A2 = A(csense == 'E',:);
        b2 = b(csense == 'E');

        %Get fminCon Options, and set the options supplied by the user.
        [iterationLimit,timeLimit] = getCobraSolverParams('NLP',{'iterationLimit','timeLimit'},parameters);
        options = optimoptions('fmincon','maxIter',iterationLimit,'maxFunEvals',iterationLimit);

        if isstruct(parameters)
            paramFields = fieldnames(parameters);
            for field = 1:numel(paramFields)
                if any(ismember(fieldnames(options),paramFields{field}))
                    options.(paramFields{field}) = parameters.(paramFields{field});
                end
            end
        end

        % define the objective function with 2 input arguments
        if exist('objFunction','var')
            func = eval(['@(x) ', num2str(NLPproblem.osense), '*' , objFunction, '(x, NLPproblem)']);
        else
            func = @(x) NLPproblem.osense*sum(c.*x);
        end
        %Now, define the maximum timer
        options.OutputFcn = @stopTimer;
        %and start it.
        stopTimer(timeLimit,1);

        [x, f, origStat, output, lambda] = fmincon(func, x0, A1, b1, A2, b2, lb, ub, [], options);

        %Assign Results
        if (origStat > 0)
            stat = 1; % Optimal solution found
            y = lambda.eqlin;
            w = zeros(length(lb), 1); % set zero Lagrangian multipliers (N/A)
        elseif (origStat < 0)
            %We supply empty fields, but we need to assign them as
            %otherwise
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
        Prob.Warning = warning;
        Prob.SOL.optPar(35) = iterationLimit; %This is major iteration limit.
        Prob.SOL.optPar(30) = 1e9; %this is the minor iteration limit.  Essentially unlimited
        Prob.CheckNaN = checkNaN;

        Prob.SOL.PrintFile = strcat(logFile, '_iterations.txt');
        Prob.SOL.SummFile = strcat(logFile, '_summary.txt');

        if printLevel >= 1
            Prob.optParam.IterPrint = 1;
        end
        if printLevel >=3
            Prob.PriLevOpt = 1;

        end

        %Call Solver
        Result = tomRun('snopt', Prob, printLevel);

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
        save ttt
    otherwise
        error(['Unknown solver: ' solver]);
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
