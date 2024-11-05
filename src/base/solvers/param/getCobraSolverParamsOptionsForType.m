function paramNames = getCobraSolverParamsOptionsForType(problemType)
% This function returns the parameters that are supported for each specified
% problem type.
%
% USAGE:
%    paramNames = getCobraSolverParamsOptionsForType(problemType)
%
% INPUT:
%    problemType :      One of the problem types available in the COBRA
%                       Toolbox ('LP','QP','EP','CLP','MILP','MIQP','NLP')
%
% OUPTUT:
%    paramNames:        Cell array of names of parameters that can be set
%                       for each problem type, independent of the specific
%                       solver being used.

if iscell(problemType)
    paramNames = {};
    for j = 1:numel(problemType)
        paramNames = [paramNames, getCobraSolverParamsOptionsForType(problemType{j})];
    end
    paramNames = unique(paramNames);
    return
end
switch problemType 
    case 'LP'
        paramNames = {'multiscale'...       % true if problem is multiscale
                      'problemType'...      % problem type
                      'verify',...          % verify that it is a suitable  LP problem
                      'minNorm', ...        % type of normalization used.
                      'printLevel', ...     % print Level
                      'primalOnly', ...     % only solve for primal
                      'saveInput', ...      % save the input to a file (specified)
                      'feasTol', ...        % feasibility tolerance
                      'optTol', ...         % optimality tolerance
                      'solver', ...         % solver to use (overriding set solver)
                      'debug', ...          % run debgugging code
                      'logFile', ...        % file (location) to write logs to
                              };            % 
   case 'QP'
        paramNames = {'multiscale'...       % true if problem is multiscale
                      'problemType'...      % problem type
                      'verify',...          % verify that it is a suitable  QP problem
                      'printLevel', ...     % print level
                      'saveInput', ...      % save the input to a file (specified)
                      'debug', ...          % run debgugging code
                      'feasTol',...         % feasibility tolerance
                      'optTol',...          % optimality tolerance
                      'logFile', ...        % file (location) to write logs to
                      'solver'};            % the solver to use

   case 'EP'
        paramNames = {'multiscale'...       % true if problem is multiscale
                      'problemType'...      % problem type
                      'verify',...          % verify that it is a suitable  EP problem
                      'printLevel', ...     % print level
                      'debug', ...          % run debgugging code
                      'feasTol',...         % feasibility tolerance
                      'optTol',...          % optimality tolerance
                      'solver'};            % the solver to use
   case 'CLP'
        paramNames = {'multiscale'...       % true if problem is multiscale
                      'problemType'...      % problem type
                      'verify',...          % verify that it is a suitable  CLP problem
                      'printLevel', ...     % print level
                      'debug', ...          % run debgugging code
                      'feasTol',...         % feasibility tolerance
                      'optTol',...          % optimality tolerance
                      'solver',...          % the solver to use
                      };            
                                 
    case 'MILP'
        paramNames = {'problemType'...      % problem type
                      'intTol', ...         % integer tolerance (accepted derivation from integer numbers)
                      'relMipGapTol', ...   % relative MIP Gap tolerance
                      'absMipGapTol', ...   % absolute MIP Gap tolerance
                      'timeLimit', ...      % maximum time before stopping computation (if supported by the solver)
                      'logFile', ...        % file (location) to write logs to
                      'printLevel', ...     % print level
                      'saveInput', ...      % save the input to a file (specified)
                      'feasTol', ...        % feasibility tolerance
                      'optTol', ...         % optimality tolerance
                      'solver', ...         % solver to use (overriding set solver)
                      'debug'};             % run debgugging code

    case 'MIQP'
        paramNames = {'problemType'...      % problem type
                      'timeLimit', ...      % maximum time before stopping computation (if supported by the solver)
                      'method', ...         % solver method: -1 = automatic, 0 = primal simplex, 1 = dual simplex, 2 = barrier, 3 = concurrent, 4 = deterministic concurrent, 5 = Network Solver(if supported by the solver)
                      'feasTol',...         % feasibility tolerance
                      'optTol',...          % optimality tolerance
                      'intTol', ...         % integer tolerance (accepted derivation from integer numbers)
                      'relMipGapTol', ...   % relative MIP Gap tolerance
                      'absMipGapTol', ...   % absolute MIP Gap tolerance
                      'printLevel', ...     % print level
                      'saveInput',...       % save the input to a file (specified)
                      'logFile', ...        % file (location) to write logs to
                      'solver'};            % the solver to use

    case 'NLP'
        paramNames = {'problemType'...      % problem type
                      'warning', ...        % whether to display warnings
                      'checkNaN', ...       % check for NaN solutions
                      'PbName', ...         % name of the problem
                      'iterationLimit', ... % maximum number of iterations before stopping computation (if supported by the solver)
                      'timeLimit', ...      % time limit for the calculation
                      'logFile', ...        % file (location) to write logs to
                      'printLevel',...      % print level
                      'saveInput', ...      % save the input to a file (specified)
                      'solver'};            % the solver to use
    otherwise
        error(['Solver type ' problemType ' is not supported by the COBRA Toolbox']);
end


