function [cplexProblem,logFile,logToFile] = setCplexParametersForProblem(cplexProblem, problemTypeParams, solverParams, problemType)
% Set the parameters for a specific problem from the COBRA Parameter
% structure and a solver specific parameter structure (latter has
% precedence). The cobra parameters structure contains fields as specified in
% `getCobraSolverParamsOptionsForType`, while solverParams needs to
% contain a structure compatible with `setCplexParam`.
% USAGE:
%    cplexProblem = setCplexParametersForProblem(cplexProblem, problemTypeParams, solverParams, ProblemType)
%
% INPUTS:
%    cplexProblem:      the Cplex() object to set the parameters
%    problemTypeParams:  problem type parameters as defined in getCobraSolverParamsOptionsForType
%    solverParams:      the solver specific parameter structure has to be compatible with `setCplexParam`
%    problemType:       The type of Problem ('LP','MILP','QP','MIQP').
%
% see https://www.ibm.com/docs/en/icos/12.10.0?topic=cplex-list-parameters
% see  https://www.ibm.com/docs/en/icos/12.10.0

%set the default parameters so we can see what they are
cplexProblem.setDefault;

%TODO ? add these 
% valDef.DATACHECK = 1;
% valDef.DEPIND = 1;
% valDef.checkNaN = 0;
% valDef.warning = 0;

% set the printLevel to the cobra Parameters
cplexProblem.Param.output.writelevel.Cur = problemTypeParams.printLevel;
cplexProblem.Param.barrier.display.Cur = problemTypeParams.printLevel;
cplexProblem.Param.simplex.display.Cur = problemTypeParams.printLevel;
cplexProblem.Param.sifting.display.Cur = problemTypeParams.printLevel;
cplexProblem.Param.paramdisplay.Cur = double(problemTypeParams.printLevel~=0);
        
%%turn off display output if printLevel is set to 0
if problemTypeParams.printLevel == 0
    %https://www.ibm.com/support/knowledgecenter/SSSA5P_12.7.1/ilog.odms.cplex.help/refmatlabcplex/html/classCplex.html#ad15aa55e15ab198965472a5517db380b
    %DisplayFunc
    %A property of the Cplex class that is a pointer to a function which provides control of display of output.
    %The default value of this property is @disp, the function handle of the display function in MATLAB.
    %With the default, all of the log information from CPLEX will be displayed.
    %If the Cplex.DisplayFunc property is set to empty, then the log information from CPLEX will not be displayed.
    %In addition, users can write a custom DisplayFunc to control the output.
    cplexProblem.DisplayFunc = 0;
end


if isscalar(problemTypeParams.logFile)
    if problemTypeParams.logFile == 1
        % allow print to command window by setting solverParams.logFile == 1
        logFile = problemTypeParams.logFile;
        logToFile = false;
        cplexProblem.DisplayFunc = @(x) redirect(1,x);
    else
        % any other scalar will be assumed to indicate no logging
        % this also turns off cplex clonelog files.
        logFile = 0;
        logToFile = false;
        cplexProblem.Param.output.clonelog.Cur = -1;
    end
else 
    if isempty(problemTypeParams.logFile)
        % we assume that the logFile Parameter being empty indicates no
        % logging requested.
        logFile = 0;
        logToFile = false;
        cplexProblem.Param.output.clonelog.Cur = -1;
    else
        logFile = fopen(problemTypeParams.logFile,'a');
        logToFile = true;
        cplexProblem.DisplayFunc = @(x) redirect(logFile,x);
    end
end

% set tolerances

% simplex.tolerances.feasibility
% Specifies the feasibility tolerance, that is, the degree to which values of the basic variables 
% calculated by the simplex method may violate their bounds. CPLEX® does not use this tolerance to
% relax the variable bounds nor to relax right hand side values. This parameter specifies an 
% allowable violation. Feasibility influences the selection of an optimal basis and can be reset 
% to a higher value when a problem is having difficulty maintaining feasibility during optimization. 
% You can also lower this tolerance after finding an optimal solution if there is any doubt 
% that the solution is truly optimal. If the feasibility tolerance is set too low, CPLEX may falsely
% conclude that a problem is infeasible. If you encounter reports of infeasibility during Phase II of
% the optimization, a small adjustment in the feasibility tolerance may improve performance.
% Values
% Any number from 1e-9 to 1e-1; default: 1e-06.
cplexProblem.Param.simplex.tolerances.feasibility.Cur = problemTypeParams.feasTol;


% network.tolerances.feasibility
% Specifies feasibility tolerance for network primal optimization. The feasibility tolerance specifies
% the degree to which the flow value of a model may violate its bounds. This tolerance influences
% the selection of an optimal basis and can be reset to a higher value when a problem is having 
% difficulty maintaining feasibility during optimization. You may also wish to lower this tolerance
% after finding an optimal solution if there is any doubt that the solution is truly optimal. 
% If the feasibility tolerance is set too low, CPLEX may falsely conclude that a problem is infeasible.
% If you encounter reports of infeasibility during Phase II of the optimization, a small adjustment
% in the feasibility tolerance may improve performance.
% Values
% Any number from 1e-11 to 1e-1; default: 1e-6.
cplexProblem.Param.network.tolerances.feasibility.Cur = problemTypeParams.feasTol;

% Influences the reduced-cost tolerance for optimality. This parameter governs 
% how closely CPLEX must approach the theoretically optimal solution.
% The simplex algorithm halts when it has found a basic feasible solution with
% all reduced costs nonnegative. CPLEX uses this optimality tolerance to make 
% the decision of whether or not a given reduced cost should be considered nonnegative.
% CPLEX considers "nonnegative" a negative reduced cost having absolute value less
% than the optimality tolerance. For example, if your optimality tolerance is set
% to 1e-6, then CPLEX considers a reduced cost of -1e-9 as nonnegative for 
% the purpose of deciding whether the solution is optimal.
% Values
% Any number from 1e-9 to 1e-1; default: 1e-06.
cplexProblem.Param.simplex.tolerances.optimality.Cur = problemTypeParams.optTol;

% network.tolerances.optimality
% Specifies the optimality tolerance for network optimization; that is, 
% the amount a reduced cost may violate the criterion for an optimal solution.
% Values
% Any number from 1e-11 to 1e-1; default: 1e-6.
cplexProblem.Param.network.tolerances.optimality.Cur = problemTypeParams.optTol;


%https://www.ibm.com/support/knowledgecenter/SSSA5P_12.7.0/ilog.odms.cplex.help/CPLEX/Parameters/topics/BarEpComp.html
%Sets the tolerance on complementarity for convergence. The barrier algorithm terminates with an optimal solution if the relative complementarity is smaller than this value.
%Changing this tolerance to a smaller value may result in greater numerical precision of the solution, but also increases the chance of failure to converge in the algorithm and consequently may result in no solution at all. Therefore, caution is advised in deviating from the default setting.
% cplexProblem.Param.barrier.convergetol.Cur = problemTypeParams.feasTol;

if strcmp(problemType,'MILP') || strcmp(problemType,'MIQP')
    % Set Integer specific parameters.
    cplexProblem.Param.mip.tolerances.mipgap.Cur =  problemTypeParams.relMipGapTol;
    cplexProblem.Param.mip.tolerances.integrality.Cur =  problemTypeParams.intTol;
    cplexProblem.Param.mip.tolerances.absmipgap.Cur =  problemTypeParams.absMipGapTol;
    cplexProblem.Param.timelimit.Cur = problemTypeParams.timeLimit;
end


if isfield(solverParams,'qpmethod') && strcmp(problemType,'QP')
    % https://www.ibm.com/docs/en/icos/12.10.0?topic=parameters-algorithm-continuous-quadratic-optimization
    % 0	CPX_ALG_AUTOMATIC	Automatic: let CPLEX choose; default
    % 1	CPX_ALG_PRIMAL	Use the primal simplex optimizer.
    % 2	CPX_ALG_DUAL	Use the dual simplex optimizer.
    % 3	CPX_ALG_NET	Use the network optimizer.
    % 4	CPX_ALG_BARRIER	Use the barrier optimizer.
    % 6	CPX_ALG_CONCURRENT	Use the concurrent optimizer.
    if isnumeric(solverParams.qpmethod)
        cplexProblem.Param.qpmethod.Cur=solverParams.qpmethod; %backward compatibility
    else
        switch solverParams.qpmethod
            case 'AUTOMATIC'
                cplexProblem.Param.qpmethod.Cur=0;
            case 'PRIMAL'
                cplexProblem.Param.qpmethod.Cur=1;
            case 'DUAL'
                cplexProblem.Param.qpmethod.Cur=2;
            case 'NETWORK'
                cplexProblem.Param.qpmethod.Cur=3;
            case 'BARRIER'
                cplexProblem.Param.qpmethod.Cur=4;
            case 'CONCURRENT'
                cplexProblem.Param.qpmethod.Cur=6;
            otherwise
                error('unrecognised option for solverParams.qpmethod')
        end
    end
    %this is how it was, it seems wrong - Ronan
    % switch problemTypeParams.method
    %     case -1 % automatic
    %         cplexProblem.Param.qpmethod.Cur = -1;
    %     case 0
    %         cplexProblem.Param.qpmethod.Cur = 1;
    %     case 1
    %         cplexProblem.Param.qpmethod.Cur = 2;
    %     case 2
    %         cplexProblem.Param.qpmethod.Cur = 4;
    %     case 3
    %         cplexProblem.Param.qpmethod.Cur = 6;
    %     case 5
    %         cplexProblem.Param.qpmethod.Cur = 3;
    %     otherwise
    %         cplexProblem.Param.qpmethod.Cur = 0;
    % end
end

if strcmp(problemType,'MIQP')
    %this is how it was, it seems wrong - Ronan
    warning('check the problemTypeParams.method mapping to algorithm numbers is correct')
    if isnumeric(problemTypeParams.method)
        %backward compatiblity
        switch problemTypeParams.method
            case -1 % automatic
                cplexProblem.Param.qpmethod.Cur = -1;
            case 0
                cplexProblem.Param.qpmethod.Cur = 1;
            case 1
                cplexProblem.Param.qpmethod.Cur = 2;
            case 2
                cplexProblem.Param.qpmethod.Cur = 4;
            case 3
                cplexProblem.Param.qpmethod.Cur = 6;
            case 5
                cplexProblem.Param.qpmethod.Cur = 3;
            otherwise
                cplexProblem.Param.qpmethod.Cur = 0;
        end
    else
        switch problemTypeParams.method
            case 'AUTOMATIC'
                cplexProblem.Param.lpmethod.Cur=0;
            case 'PRIMAL'
                cplexProblem.Param.lpmethod.Cur=1;
            case 'DUAL'
                cplexProblem.Param.lpmethod.Cur=2;
            case 'NETWORK'
                cplexProblem.Param.lpmethod.Cur=3;
            case 'BARRIER'
                cplexProblem.Param.lpmethod.Cur=4;
            case 'SIFTING'
                cplexProblem.Param.lpmethod.Cur=5;
            case 'CONCURRENT'
                cplexProblem.Param.lpmethod.Cur=6;
            otherwise
                error('unrecognised option for solverParams.lpmethod')
        end
    end
end


if isfield(solverParams,'lpmethod') && strcmp(problemType,'LP')
    %https://www.ibm.com/docs/en/icos/12.10.0?topic=parameters-algorithm-continuous-linear-problems
    % Value Symbol Meaning
    % 0	CPX_ALG_AUTOMATIC 	Automatic: let CPLEX choose; default
    % 1	CPX_ALG_PRIMAL 	Primal simplex
    % 2	CPX_ALG_DUAL 	Dual simplex
    % 3	CPX_ALG_NET 	Network simplex
    % 4	CPX_ALG_BARRIER 	Barrier
    % 5	CPX_ALG_SIFTING 	Sifting
    % 6	CPX_ALG_CONCURRENT 	Concurrent (Dual, Barrier, and Primal in opportunistic parallel mode; Dual and Barrier in deterministic parallel mode)

    if isnumeric(solverParams.lpmethod)
        cplexProblem.Param.lpmethod.Cur=solverParams.lpmethod; %backward compatibility
    else
        switch solverParams.lpmethod
            case 'AUTOMATIC'
                cplexProblem.Param.lpmethod.Cur=0;
            case 'PRIMAL'
                cplexProblem.Param.lpmethod.Cur=1;
            case 'DUAL'
                cplexProblem.Param.lpmethod.Cur=2;
            case 'NETWORK'
                cplexProblem.Param.lpmethod.Cur=3;
            case 'BARRIER'
                cplexProblem.Param.lpmethod.Cur=4;
            case 'SIFTING'
                cplexProblem.Param.lpmethod.Cur=5;
            case 'CONCURRENT'
                cplexProblem.Param.lpmethod.Cur=6;
            otherwise
                error('unrecognised option for solverParams.lpmethod')
        end
    end
else
    cplexProblem.Param.lpmethod.Cur=4;%BARRIER provided best benchmark performance on Harvetta
end

if isfield(solverParams,'multiscale') && solverParams.multiscale==1 && 0
    % Decides how to scale the problem matrix.
    % Value  Meaning
    % -1	No scaling
    % 0	Equilibration scaling; default
    % 1	More aggressive scaling
    % https://www.ibm.com/docs/en/icos/12.10.0?topic=parameters-scale-parameter
    cplexProblem.Param.read.scale.Cur = -1;

    % Emphasizes precision in numerically unstable or difficult problems.
    % This parameter lets you specify to CPLEX that it should emphasize precision in
    % numerically difficult or unstable problems, with consequent performance trade-offs in time and memory.
    % Value Meaning
    % 0   Do not emphasize numerical precision; default
    % 1	Exercise extreme caution in computation
    % https://www.ibm.com/docs/en/icos/12.10.0?topic=parameters-numerical-precision-emphasis
    cplexProblem.Param.emphasis.numerical.Cur = 1;
end

if isfield(solverParams,'scaind')
    % Decides how to scale the problem matrix.
    % Value  Meaning
    % -1	No scaling
    % 0	Equilibration scaling; default
    % 1	More aggressive scaling
    % https://www.ibm.com/docs/en/icos/12.10.0?topic=parameters-scale-parameter
    cplexProblem.Param.read.scale.Cur = solverParams.scaind;
end

if isfield(solverParams,'timelimit')
    % https://www.ibm.com/docs/en/icos/12.10.0?topic=parameters-optimizer-time-limit-in-seconds
    cplexProblem.Param.timelimit.Cur = solverParams.timelimit;
end
if isfield(solverParams,'secondsTimeLimit')
    % https://www.ibm.com/docs/en/icos/12.10.0?topic=parameters-optimizer-time-limit-in-seconds
    cplexProblem.Param.timelimit.Cur = solverParams.secondsTimeLimit;
end

if isfield(solverParams,'emphasis_numerical')
    % https://www.ibm.com/docs/en/icos/12.10.0?topic=parameters-numerical-precision-emphasis
    cplexProblem.Param.emphasis.numerical.Cur = solverParams.emphasis_numerical;
end

if isfield(solverParams,'markowitz')
    %     Influences pivot selection during basis factoring. Increasing the Markowitz threshold may improve the numerical properties of the solution.
    % Any number from 0.0001 to 0.99999; default: 0.01
    % https://www.ibm.com/docs/en/icos/12.10.0?topic=parameters-markowitz-tolerance
    cplexProblem.Param.simplex.tolerances.markowitz.Cur = solverParams.markowitz;
end

if isfield(cplexProblem,'Start')
    %https://www.ibm.com/docs/en/icos/12.8.0.0?topic=parameters-advanced-start-switch
    cplexProblem.Param.advance.Cur = 1;
end


if 0
    % not clear what setCplexParam function does, skipping it 
    if isfield(solverParams,'qpmethod')
        solverParams=rmfield(solverParams,'qpmethod');
    end

    if isfield(solverParams,'lpmethod')
        solverParams=rmfield(solverParams,'lpmethod');
    end

    if isfield(solverParams,'printLevel')
        solverParams=rmfield(solverParams,'printLevel');
    end

    % Set IBM-Cplex-specific parameters. Will overide Cobra solver parameters
    cplexProblem = setCplexParam(cplexProblem, solverParams);
end

end

function redirect(outFile,l)
% Write the line of log output
fprintf(outFile, '%s\n', l);
end
