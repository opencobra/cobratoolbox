function optimParam = tuneParam(LPProblem,contFunctName,timelimit,nrepeat,printLevel)
% Optimizes cplex parameters to make model resolution faster.
% Particularly interetsing for large-scale MILP models and repeated runs of
% optimisation.
% While, it won't optimize memory space nor model constraints for numerical
% infeasibilities, tuneParam will provide the optimal set of solver
% parameters for feasbile models. It requires IBM ILOG cplex (for now).
%
% USAGE:
%
%    optimalParameters = tuneParam(LPProblem,contFunctName,timelimit,nrepeat,printLevel);
%
% INPUT:
%         LPProblem:     MILP as COBRA LP problem structure
%         contFunctName: Parameters structure containing the name and value,
%                        OR the name of a function that returns such a
%                        structure (e.g. 'CPLEXParamSet'), OR [] for
%                        defaults. A set of routine parameters will be added
%                        by the solver but won't be reported.
%
% OPTIONAL INPUTS:
%         timelimit:     CPX_PARAM_TUNINGTILIM in seconds (default: 10000)
%         nrepeat:       CPX_PARAM_TUNINGREPEAT, number of row/column
%                        permutations of the original problem (default: 1).
%                        High values require consequent memory and swap.
%         printLevel:    0/(1)/2/3
%
% OUTPUT:
%         optimParam: structure of optimal parameter values directly usable as
%                     contFunctName argument in solveCobraLP function
%
% .. Author: Marouen Ben Guebila 24/07/2017

% Validate that ibm_cplex is available without permanently changing the
% user's configured LP solver.
global CBT_LP_SOLVER
prevLPSolver = CBT_LP_SOLVER;
cplexAvailable = changeCobraSolver('ibm_cplex', 'LP', 0);
if ~isempty(prevLPSolver) && ~strcmp(prevLPSolver, 'ibm_cplex')
    changeCobraSolver(prevLPSolver, 'LP', 0);
end
if ~cplexAvailable
    error('tuneParam:noCplex', 'This function requires IBM ILOG CPLEX');
end

if ~exist('printLevel','var') || isempty(printLevel)
    printLevel = 1;
end

% Resolve contFunctName into a struct BEFORE attempting to assign tune.* fields.
if nargin < 2 || isempty(contFunctName)
    cpxControl = struct();
elseif isstruct(contFunctName)
    cpxControl = contFunctName;
elseif ischar(contFunctName) || isstring(contFunctName)
    %calls a user specified function to create a CPLEX control structure
    %specific to the users problem. A TEMPLATE for one such function is
    %CPLEXParamSet
    cpxControl = eval(char(contFunctName));
    if ~isstruct(cpxControl)
        error('tuneParam:badControl', ...
              '%s did not return a parameter struct.', char(contFunctName));
    end
else
    error('tuneParam:badControl', ...
          'contFunctName must be a struct, function name, or empty.');
end

% Apply tuning overrides on the resolved struct.
if exist('timelimit','var') && ~isempty(timelimit)
    cpxControl.tune.timelimit = timelimit;
end
if exist('nrepeat','var') && ~isempty(nrepeat)
    cpxControl.tune.repeat = nrepeat;
end
cpxControl.tune.display = printLevel;

if ~isfield(LPProblem,'A')
    if ~isfield(LPProblem,'S')
            error('Equality constraint matrix must either be a field denoted A or S.')
    end
    LPProblem.A=LPProblem.S;
end

if ~isfield(LPProblem,'csense')
    nMet = size(LPProblem.A, 1);
    if printLevel>0
        fprintf('%s\n','Assuming equality constraints, i.e. S*v=b');
    end
    %assuming equality constraints
    LPProblem.csense(1:nMet,1)='E';
end

if ~isfield(LPProblem,'osense')
    %assuming maximisation
    LPProblem.osense=-1;
    if printLevel>0
        fprintf('%s\n','Assuming maximisation of objective');
    end
end

if size(LPProblem.A,2)~=length(LPProblem.c)
    error('dimensions of A & c are inconsistent');
end

if size(LPProblem.A,2)~=length(LPProblem.lb) || size(LPProblem.A,2)~=length(LPProblem.ub)
    error('dimensions of A & bounds are inconsistent');
end

%get data
[c,x_L,x_U,b,csense,osense] = deal(LPProblem.c,LPProblem.lb,LPProblem.ub,...
    LPProblem.b,LPProblem.csense,LPProblem.osense);
%modify objective to correspond to osense
c=full(c*osense);

%cplex expects it dense
b=full(b);

%complex ibm ilog cplex interface
nRows = size(LPProblem.A, 1);
b_L = -inf(nRows, 1);
b_U =  inf(nRows, 1);
if ~isempty(csense)
    %set up constant vectors for CPLEX
    b_L(csense == 'E',1) = b(csense == 'E');
    b_U(csense == 'E',1) = b(csense == 'E');
    b_L(csense == 'G',1) = b(csense == 'G');
    b_U(csense == 'G',1) = Inf;
    b_L(csense == 'L',1) = -Inf;
    b_U(csense == 'L',1) = b(csense == 'L');
end

% Initialize the CPLEX object
try
    ILOGcplex = Cplex('fba');
catch ME
    err = MException('tuneParam:cplexInit', ...
                    'CPLEX not installed or licence server not up');
    err = addCause(err, ME);
    throw(err);
end

ILOGcplex.Model.sense = 'minimize';

% Now populate the problem with the data
ILOGcplex.Model.obj   = c;
ILOGcplex.Model.lb    = x_L;
ILOGcplex.Model.ub    = x_U;
ILOGcplex.Model.A     = LPProblem.A;
ILOGcplex.Model.lhs   = b_L;
ILOGcplex.Model.rhs   = b_U;

%loop through parameters
ILOGcplex = setCplexParam(ILOGcplex, cpxControl, 1);
optimParam = cpxControl;

%Call parameter tuner
if ~ILOGcplex.tuneParam()
    if printLevel > 0
        fprintf('Optimal parameters found. \n');
    end
    [~, paramPath] = getParamList(cpxControl, 1);
    for i = 1:length(paramPath)
        try
            optimParam = setfield_path(optimParam, paramPath{i}, ...
                getfield_path(ILOGcplex.Param, [paramPath{i} '.Cur']));
        catch
            if printLevel > 0
                fprintf(['Parameter ' paramPath{i} ' was not found. \n']);
            end
        end
    end
else
    warning('tuneParam:tuneFailed', 'CPLEX parameter tuning failed.');
end

end

function s = setfield_path(s, dotted, value)
% Assign value into a nested struct using a dotted path (no eval).
parts = strsplit(dotted, '.');
s = setfield(s, parts{:}, value);
end

function v = getfield_path(s, dotted)
% Read a value from a nested struct using a dotted path (no eval).
parts = strsplit(dotted, '.');
v = getfield(s, parts{:});
end