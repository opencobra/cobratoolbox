function [cplexProblem,logFile,logToFile] = setCplexParametersForProblem(cplexProblem, cobraParams, solverParams, problemType)
% Set the parameters for a specific problem from the COBRA Parameter
% structure and a solver specific parameter structre (latter has
% precedence)
% USAGE:
%    cplexProblem = setCplexParametersForProblem(cplexProblem, cobraParams, solverParams, ProblemType)
%
% INPUTS:
%    cplexProblem:      the Cplex() object to set the parameters
%    cobraParams:       the COBRA parameter structure
%    solverParams:      the solver specific parameter structure (must be a
%                       valid input to `setCplexParam`;
%    problemType:       The type of Problem ('LP','MILP','QP','MIQP').
%

% set the printLevel to the cobra Parameters
cplexProblem.Param.output.writelevel.Cur = cobraParams.printLevel;
cplexProblem.Param.barrier.display.Cur = cobraParams.printLevel;
cplexProblem.Param.simplex.display.Cur = cobraParams.printLevel;
cplexProblem.Param.sifting.display.Cur = cobraParams.printLevel;

if isscalar(cobraParams.logFile) && cobraParams.logFile == 1
    % allow print to command window by setting solverParams.logFile == 1
    logFile = 1;
    logToFile = false;
else
    logFile = fopen(cobraParams.logFile,'a');
    logToFile = true;
end


cplexProblem.DisplayFunc = @(x) redirect(outputfile);
% set tolerances
cplexProblem.Param.simplex.tolerances.optimality.Cur = cobraParams.optTol;
cplexProblem.Param.simplex.tolerances.feasibility.Cur = cobraParams.feasTol;
if strcmp(problemType,'MILP') || strcmp(problemType,'MIQP')
    % Set Integer specific parameters.
    cplexProblem.Param.mip.tolerances.mipgap.Cur =  cobraParams.relMipGapTol;
    cplexProblem.Param.mip.tolerances.integrality.Cur =  cobraParams.intTol;
    cplexProblem.Param.mip.tolerances.absmipgap.Cur =  cobraParams.absMipGapTol;
    cplexProblem.Param.timelimit.Cur = cobraParams.timeLimit;
end

% Set IBM-Cplex-specific parameters. Will overide Cobra solver parameters
cplexProblem = setCplexParam(cplexProblem, solverParams);
end

function redirect(l)
% Write the line of log output
fprintf(outputfile, '%s\n', l);
end