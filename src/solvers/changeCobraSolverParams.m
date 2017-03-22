function changeOK = changeCobraSolverParams(solverType,paramName,paramValue)
%changeCobraSolverParams Changes parameters for the Cobra Toolbox optimization solver(s)
%
% changeOK = changeCobraSolverParams(solverType,paramName,paramValue)
%
% INPUT
% solverType    Solver type, 'LP' or 'MILP' (opt, default
%               'LP')
% paramName     Parameter name
% paramValue    Parameter value
%
% Allowed LP parameter names:
% optTol        Optimal objective accuracy tolerance
% teasTol       Constraint feasibilty tolerance
%
% minNorm       {(0), scalar , n x 1 vector}, where [m,n]=size(S);
%               If not zero then, minimise the Euclidean length
%               of the solution to the LP problem. minNorm ~1e-6 should be
%               high enough for regularisation yet maintain the same value for
%               the linear part of the objective. However, this should be
%               checked on a case by case basis, by optimization with and
%               without regularisation.
%
% printLevel    Printing level
%               = 0    Silent
%               = 1    Warnings and Errors
%               = 2    Summary information (Default)
%               = 3    More detailed information
%               > 10   Pause statements, and maximal printing (debug mode)
%
% primalOnly    {(0),1} 1=only return the primal vector (lindo solvers)
%
% Allowed MILP parameter names:
%  timeLimit     Global time limit
%  intTol        Integer tolerance
%  relMipGapTol  Relative MIP gap tolerance
%  logFile       Internal log file for solver
%  printLevel    Print level for solver
%
% OUTPUT
% changeOK      Logical inicator that supplied parameter is allowed (=1)
%

% Markus Herrgard       5/3/07
% Jan Schellenberger    09/28/09
% Ronan Fleming         12/07/09 commenting of input/output

changeOK = false;

if strcmp(paramName,'objTol')
    warning('objTol being depreciated for the more standard optTol')
    paramName='optTol';
end

allowedLPparams = {'optTol', 'primalOnly', 'minNorm', 'printLevel','feasTol'};
allowedQPparams = {'minNorm', 'printLevel'};
allowedMILPparams = {'intTol','relMipGapTol','timeLimit','logFile','printLevel'};

% Only LP, QP and MILP are currently included
switch solverType
    case 'LP'
        if (ismember(paramName,allowedLPparams))
            global CBT_LP_PARAMS;
            CBT_LP_PARAMS.(paramName) = paramValue;
            changeOK = true;
        else
            error(['Parameter name ' paramName ' not allowed for LP solvers']);
        end
    case 'QP'
         if (ismember(paramName,allowedQPparams))
            global CBT_QP_PARAMS;
            CBT_QP_PARAMS.(paramName) = paramValue;
            changeOK = true;
        else
            error(['Parameter name ' paramName ' not allowed for QP solvers']);
        end
    case 'MILP'
        if (ismember(paramName,allowedMILPparams))
            global CBT_MILP_PARAMS;
            CBT_MILP_PARAMS.(paramName) = paramValue;
            changeOK = true;
        else
            error(['Parameter name ' paramName ' not allowed for MILP solvers']);
        end
    otherwise
        error(['solver type ' solverType ' not valid']);
end
