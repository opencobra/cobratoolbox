function paramNames = getCobraSolverParamsOptionsForType(solverType)
% This function returns the available optional parameters for the specified
% solver type.
%
% USAGE:
%    paramnames = getCobraSolverParamsOptionsForType(solverType)
%
% INPUT:
%    solverType:        One of the solver types available in the cobra
%                       Toolbox ('LP','QP','MILP','MIQP','NLP')
% OUPTUT:
%    paramNames:        The possible parameters that can be set for the
%                       given solver Type (depends on the solver Type

switch solverType
    case 'LP'
        paramNames = {'minNorm', ...        % type of normalization used.
                      'printLevel', ...     % print Level
                      'primalOnly', ...     % only solve for primal
                      'saveInput', ...      % save the input to a file (specified)
                      'feasTol', ...        % feasibility tolerance
                      'optTol', ...         % optimality tolerance
                      'solver', ...         % solver to use (overriding set solver)
                      'debug', ...          % run debgugging code
                      'logFile', ...        % file (location) to write logs to
                      'lifting'};           % whether to lift a problem

    case 'QP'
        paramNames = {'method', ...         % solver method: -1 = automatic, 0 = primal simplex, 1 = dual simplex, 2 = barrier, 3 = concurrent, 4 = deterministic concurrent, 5 = Network Solver(if supported by the solver)
                      'printLevel', ...     % print level
                      'saveInput', ...      % save the input to a file (specified)
                      'feasTol',...         % feasibility tolerance
                      'optTol',...          % optimality tolerance
                      'logFile', ...        % file (location) to write logs to
                      'solver'};            % the solver to use


    case 'MILP'
        paramNames = {'intTol', ...         % integer tolerance (accepted derivation from integer numbers)
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
        paramNames = {'timeLimit', ...      % maximum time before stopping computation (if supported by the solver)
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
        paramNames = {'warning', ...        % whether to display warnings
                      'checkNaN', ...       % check for NaN solutions
                      'PbName', ...         % name of the problem
                      'iterationLimit', ... % maximum number of iterations before stopping computation (if supported by the solver)
                      'timeLimit', ...      % time limit for the calculation
                      'logFile', ...        % file (location) to write logs to
                      'printLevel',...      % print level
                      'saveInput', ...      % save the input to a file (specified)
                      'solver'};            % the solver to use
    otherwise
        error('Solver type %s is not supported by the Toolbox');
end


