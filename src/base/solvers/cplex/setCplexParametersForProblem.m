function [cplexProblem,logFile,logToFile] = setCplexParametersForProblem(cplexProblem, cobraParams, solverParams, problemType)
% Set the parameters for a specific problem from the COBRA Parameter
% structure and a solver specific parameter structre (latter has
% precedence). The cobra parameters structure contains fields as specified in
% `getCobraSolverParamsOptionsForType`, while solverParams needs to
% contain a structure compatible with `setCplexParam`.
% USAGE:
%    cplexProblem = setCplexParametersForProblem(cplexProblem, cobraParams, solverParams, ProblemType)
%
% INPUTS:
%    cplexProblem:      the Cplex() object to set the parameters
%    cobraParams:       the COBRA parameter structure, with parameters as defined in
%                       `getCobraSolverParamsOptionsForType`
%    solverParams:      the solver specific parameter structure has to be compatible with `setCplexParam`
%    problemType:       The type of Problem ('LP','MILP','QP','MIQP').
%

%set the default parameters so we can see what they are
cplexProblem.setDefault;

% set the printLevel to the cobra Parameters
cplexProblem.Param.output.writelevel.Cur = cobraParams.printLevel;
cplexProblem.Param.barrier.display.Cur = cobraParams.printLevel;
cplexProblem.Param.simplex.display.Cur = cobraParams.printLevel;
cplexProblem.Param.sifting.display.Cur = cobraParams.printLevel;
cplexProblem.Param.paramdisplay.Cur = double(cobraParams.printLevel~=0);
        
%%turn off display output if printLevel is set to 0
if cobraParams.printLevel == 0
    %https://www.ibm.com/support/knowledgecenter/SSSA5P_12.7.1/ilog.odms.cplex.help/refmatlabcplex/html/classCplex.html#ad15aa55e15ab198965472a5517db380b
    %DisplayFunc
    %A property of the Cplex class that is a pointer to a function which provides control of display of output.
    %The default value of this property is @disp, the function handle of the display function in MATLAB.
    %With the default, all of the log information from CPLEX will be displayed.
    %If the Cplex.DisplayFunc property is set to empty, then the log information from CPLEX will not be displayed.
    %In addition, users can write a custom DisplayFunc to control the output.
    cplexProblem.DisplayFunc = [];
end

if isscalar(cobraParams.logFile)
    if cobraParams.logFile == 1
        % allow print to command window by setting solverParams.logFile == 1
        logFile = cobraParams.logFile;
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
    if isempty(cobraParams.logFile)
        % we assume that the logFile Parameter being empty indicates no
        % logging requested.
        logFile = 0;
        logToFile = false;
        cplexProblem.Param.output.clonelog.Cur = -1;
    else
        logFile = fopen(cobraParams.logFile,'a');
        logToFile = true;
        cplexProblem.DisplayFunc = @(x) redirect(logFile,x);
    end
end

% set tolerances
cplexProblem.Param.simplex.tolerances.feasibility.Cur = cobraParams.feasTol;
cplexProblem.Param.simplex.tolerances.optimality.Cur = cobraParams.optTol;

cplexProblem.Param.network.tolerances.feasibility.Cur = cobraParams.feasTol;
cplexProblem.Param.network.tolerances.optimality.Cur = cobraParams.optTol;

%https://www.ibm.com/support/knowledgecenter/SSSA5P_12.7.0/ilog.odms.cplex.help/CPLEX/Parameters/topics/BarEpComp.html
%Sets the tolerance on complementarity for convergence. The barrier algorithm terminates with an optimal solution if the relative complementarity is smaller than this value.
%Changing this tolerance to a smaller value may result in greater numerical precision of the solution, but also increases the chance of failure to converge in the algorithm and consequently may result in no solution at all. Therefore, caution is advised in deviating from the default setting.
% cplexProblem.Param.barrier.convergetol.Cur = cobraParams.feasTol;

if strcmp(problemType,'MILP') || strcmp(problemType,'MIQP')
    % Set Integer specific parameters.
    cplexProblem.Param.mip.tolerances.mipgap.Cur =  cobraParams.relMipGapTol;
    cplexProblem.Param.mip.tolerances.integrality.Cur =  cobraParams.intTol;
    cplexProblem.Param.mip.tolerances.absmipgap.Cur =  cobraParams.absMipGapTol;
    cplexProblem.Param.timelimit.Cur = cobraParams.timeLimit;
end

if strcmp(problemType,'QP') || strcmp(problemType,'MIQP')
    switch cobraParams.method
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
end

% Set IBM-Cplex-specific parameters. Will overide Cobra solver parameters
cplexProblem = setCplexParam(cplexProblem, solverParams);
end

function redirect(outFile,l)
% Write the line of log output
fprintf(outFile, '%s\n', l);
end
