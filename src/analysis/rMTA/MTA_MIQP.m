function [v_res, solution] = MTA_MIQP (OptimizationModel, KOrxn, varargin)
% Returns the OptimizationModel solution of a particular MTA problem and
% an specific model
%
% USAGE:
%
%    [v_res, success, unsuccess] = MTA_MIQP (OptimizationModel, KOrxn, numWorkers, timeLimit, printLevel)
%
% INPUT:
%    OptimizationModel:       Cplex Model struct
%    KOrxn:            perturbation in the model (reactions)
%    numWorkers:       number of threads used by Cplex.
%    printLevel:       1 if the process is wanted to be shown on the
%                      screen, 0 otherwise. Default: 1.
%
% OUTPUTS:
%    Vout:             Solution flux of MIQP formulation for each case
%    solution:         Cplex solution struct
%
% .. Authors:
%       - Luis V. Valcarcel, 03/06/2015, University of Navarra, CIMA & TECNUN School of Engineering.
% .. Revisions:
%       - Luis V. Valcarcel, 26/10/2018, University of Navarra, CIMA & TECNUN School of Engineering.

% Check the input information
p = inputParser;
% check requiered arguments
addRequired(p, 'OptimizationModel');
addRequired(p, 'KOrxn');
% Check optional arguments
addOptional(p, 'numWorkers', 0);
addOptional(p, 'timeLimit', inf);
addOptional(p, 'printLevel', 1);
% extract variables from parser
parse(p);
numWorkers = p.Results.numWorkers;
timeLimit = p.Results.timeLimit;
printLevel = p.Results.printLevel;


%Indexation of variables
v = OptimizationModel.idx_variables.v;
y_plus_F = OptimizationModel.idx_variables.y_plus_F;
y_minus_F = OptimizationModel.idx_variables.y_minus_F;
y_plus_B = OptimizationModel.idx_variables.y_plus_B;
y_minus_B = OptimizationModel.idx_variables.y_minus_B;
OptimizationModel = rmfield(OptimizationModel,'idx_variables');

% Generate OptimizationModel for this iteration
cplex = Cplex('MIQP');
MIQPproblem = OptimizationModel;
% include the knock-out reactions
MIQPproblem.lb(KOrxn) = 0;
MIQPproblem.ub(KOrxn) = 0;

% Solver Parameter
if printLevel <=1
    logFile = 0;
if timeLimit > 1e75
    timeLimit = 1e75;
end

% SOLVE the MIQP problem 
solution = solveCobraMIQP(MIQPproblem, ...
    'timeLimit',timeLimit, 'relMipGapTol',  1e-5, ...
    'printLevel', 1, 'logFile', logFile,...
    'threads',numWorkers);

if solution.stat ~= 0 
    v_res = cplex.Solution.x(v);
else
    v_res = zeros(length(v),1);
end

end
