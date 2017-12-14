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
%         contFunctName: Parameters structure containing the name and value.
%                        A set of routine parameters will be added by the solver
%                        but won't be reported.
%         timelimit:     default is 10000 second
%         nrepeat:       number of row/column permutation of the original
%                        problem, reports robust results.
%                        sets the CPX_PARAM_TUNINGREPEAT parameter
%                        High values of nrepeat would require consequent
%                        memory and swap.
%         printLevel:    0/(1)/2/3
%
% OUTPUT:
%         optimParam: structure of optimal parameter values directly usable as
%                     contFunctName argument in solveCobraLP function
%
% .. Author: Marouen Ben Guebila 24/07/2017

if ~changeCobraSolver('ibm_cplex')
    error('This function requires IBM ILOG CPLEX');
end

if ~exist('printLevel','var')
    printLevel = 1;
end

if exist('timelimit','var')
    contFunctName.tune.timelimit = timelimit;
end
if exist('nrepeat','var')
    contFunctName.tune.repeat = nrepeat;
end
if exist('printLevel','var')
    contFunctName.tune.display = printLevel;
end


%read parameters
if isstruct(contFunctName)
    cpxControl=contFunctName;
else
    if ~isempty(contFunctName)
        %calls a user specified function to create a CPLEX control structure
        %specific to the users problem. A TEMPLATE for one such function is
        %CPLEXParamSet
        cpxControl=eval(contFunctName);
    else
        cpxControl=[];
    end
end

if ~isfield(LPProblem,'A')
    if ~isfield(LPProblem,'S')
            error('Equality constraint matrix must either be a field denoted A or S.')
    end
    LPProblem.A=LPProblem.S;
end

if ~isfield(LPProblem,'csense')
    nMet=size(LPProblem.A);
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
    error('CPLEX not installed or licence server not up')
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
optimParam=cpxControl;

%Call parameter tuner
if ~ILOGcplex.tuneParam()
    fprintf('Optimal parameters found. \n');
    [paramList, paramPath] = getParamList(cpxControl, 1);
     for i=1:length(paramPath)
         try
             eval(['optimParam.' paramPath{i} '=ILOGcplex.Param.' paramPath{i} '.Cur;']);
         catch ME
             fprintf(['Parameter ' paramPath{i} ' was not found. \n']);
         end
     end
else
    fprintf('Optimisation failed. \n')
end

end