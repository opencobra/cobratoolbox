function changeOK = changeCobraSolverParams(solverType, paramName, paramValue)
% Changes parameters for the Cobra Toolbox optimization solver(s)
%
% USAGE:
%
%    changeOK = changeCobraSolverParams(solverType, paramName, paramValue)
%
% INPUTS:
%    solverType:        Solver type, 'LP' or 'MILP' (opt, default, 'LP')
%    paramName:         Parameter name
%    paramValue:        Parameter value
%
% OUTPUT:
%    changeOK:          Logical inicator that supplied parameter is allowed (= 1)
%
%
% Explanation on parameters:
%
%  * printLevel:        Printing level
%
%    * 0 - Silent
%    * 1 - Warnings and Errors
%    * 2 - Summary information (Default)
%    * 3 - More detailed information
%    * > 10 - Pause statements, and maximal printing (debug mode)
%
%  * primalOnly:        {(0), 1}; 1 = only return the primal vector (lindo solvers)
%
%  * saveInput:         Saves LPproblem to filename specified in field.
%                       i.e. parameters.saveInput = 'LPproblem.mat';
%
%  * minNorm:           {(0), scalar , `n x 1` vector}, where `[m, n] = size(S)`;
%                       If not zero then, minimise the Euclidean length
%                       of the solution to the LP problem. minNorm ~1e-6 should be
%                       high enough for regularisation yet maintain the same value for
%                       the linear part of the objective. However, this should be
%                       checked on a case by case basis, by optimization with and
%                       without regularisation.
%
%  * optTol             Optimality tolerance
%
%  * feasTol            Feasibility tolerance
%
%  * timeLimit:         Global solver time limit
%
%  * intTol:            Integrality tolerance
%
%  * relMipGapTol:      Relative MIP gap tolerance
%
%  * logFile:           Log file (for CPLEX)
%
% NOTE:
%
%    The available solver Parameters can be obtained by calling
%    getSolverParamsOptionsForType().
%    If input argument `minNorm` is not zero, then minimise the Euclidean length
%    of the solution to the LP problem. `minNorm ~1e-6` should be
%    high enough for regularisation yet maintain the same value for
%    the linear part of the objective. However, this should be
%    checked on a case by case basis, by optimization with and
%    without regularisation.
%
% .. Authors:
%       - Markus Herrgard, 5/3/07
%       - Jan Schellenberger, 09/28/09
%       - Ronan Fleming, 12/07/09 commenting of input/output
%       - Thomas Pfau 2018 - Update to allow all solver Types 


global CBT_LP_PARAMS;
global CBT_MILP_PARAMS;
global CBT_QP_PARAMS;
global CBT_MIQP_PARAMS;
global CBT_NLP_PARAMS;
% get the parameter structs
changeOK = false;

if strcmp(paramName,'objTol')
    warning('objTol being depreciated for the more standard optTol')
    paramName='optTol';
end

allowedParameters = getCobraSolverParamsOptionsForType(solverType);
if (ismember(paramName,allowedParameters))   
    eval(['CBT_' solverType '_PARAMS.(paramName) = paramValue;']);
    changeOK = true;
else
    error(['Parameter name ' paramName ' not allowed for LP solvers']);
end
end
