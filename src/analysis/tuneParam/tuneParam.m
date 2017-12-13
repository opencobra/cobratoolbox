function optimParam = tuneParam(model,contFunctName,timelimit,nrepeat,printLevel)
% Optimizes cplex parameters to make model resolution faster.
% Particularly interetsing for large-scale MILP models and repeated runs of
% optimisation.
% While, it won't optimize memory space nor model constraints for numerical
% infeasibilities, tuneParam will provide the optimal set of solver
% parameters for feasbile models. It requires IBM ILOG cplex (for now).
%
% USAGE
%
%    cpxControl = CPLEXParamSet('ILOGcomplex');
%    load ecoli_core_model;
%    optimalParameters = tuneParam(model,cpxControl,1000,1000,0);
%
% INPUT:
%         model:         MILP as COBRA model structure
%         contFunctName: Parameters structure containing the name and value.
%                        A set of routine parameters will be added by the solver
%                        but won't be reported.
%         timelimit:     default is 10000 second
%         nrepeat:       number of row/column permutation of the original
%                        problem, reports robust results.
%                        sets the CPX_PARAM_TUNINGREPEAT parameter
%                        High values of nrepeat would require consequent
%                        memory and swap.
%         printLevel:    0/1/2/3
%
% OUTPUT:
%         optimParam: structure of optimal parameter values directly usable as
%                     contFunctName argument in solveCobraLP function
% .. Author: Marouen Ben Guebila 24/07/2017

if ~changeCobraSolver('ibm_cplex')
    error('This function requires IBM ILOG CPLEX');
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

LPProblem=buildLPproblemFromModel(model);

% Initialize the CPLEX object
try
    ILOGcplex = Cplex('fba');
catch ME
    error('CPLEX not installed or licence server not up')
end

ILOGcplex.Model.sense = 'minimize';

% Now populate the problem with the data
ILOGcplex.Model.obj   = LPProblem.c;
ILOGcplex.Model.lb    = LPProblem.lb;
ILOGcplex.Model.ub    = LPProblem.ub;
ILOGcplex.Model.A     = LPProblem.A;
ILOGcplex.Model.lhs   = LPProblem.b;
ILOGcplex.Model.rhs   = LPProblem.b;

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