function [v_res, solution] = MTA_MIQP(OptimizationModel, KOrxn, varargin)
% Returns the OptimizationModel solution of a particular MTA problem and
% an specific model
%
% USAGE:
%
%    [v_res, success, unsuccess] = MTA_MIQP (OptimizationModel, KOrxn, numWorkers, timeLimit, printLevel)
%
% INPUT:
%    OptimizationModel:    Cplex Model struct with fields:
%
%                            * .idx_variables - indices of the problem variables (v, y_plus_F, y_minus_F, y_plus_B, y_minus_B)
%    KOrxn:                perturbation in the model (reactions)
%    numWorkers:           number of threads used by Cplex.
%    FORCE_CPLEX:          1 to force CPLEX solver, 0 (default) for COBRA
%                          solver.
%    printLevel:           1 if the process is wanted to be shown on the
%                          screen, 0 otherwise. Default: 1.
%
% OUTPUTS:
%    v_res:                Solution flux of MIQP formulation for each case
%    solution:             Cplex solution struct
%
% .. Authors:
%       - Luis V. Valcarcel, 03/06/2015, University of Navarra, CIMA & TECNUN School of Engineering.
%       - Luis V. Valcarcel, 26/10/2018, University of Navarra, CIMA & TECNUN School of Engineering.
%       - Luis V. Valcarcel, 09/03/2021, University of Navarra, CIMA & TECNUN School of Engineering.

p = inputParser; % check the input information
% check requiered arguments
addRequired(p, 'OptimizationModel');
addRequired(p, 'KOrxn');
% Check optional arguments
addParameter(p, 'numWorkers', 0,@(x)isnumeric(x)&&isscalar(x));
addParameter(p, 'timeLimit', inf,@(x)isnumeric(x)&&isscalar(x));
addParameter(p, 'printLevel', 1,@(x)isnumeric(x)&&isscalar(x));
addParameter(p, 'FORCE_CPLEX', 0,@(x)isnumeric(x)&&isscalar(x));
% extract variables from parser
parse(p, OptimizationModel, KOrxn, varargin{:});
numWorkers = p.Results.numWorkers;
timeLimit = p.Results.timeLimit;
printLevel = max(p.Results.printLevel, 0);

%Indexation of variables
v = OptimizationModel.idx_variables.v;
y_plus_F = OptimizationModel.idx_variables.y_plus_F;
y_minus_F = OptimizationModel.idx_variables.y_minus_F;
y_plus_B = OptimizationModel.idx_variables.y_plus_B;
y_minus_B = OptimizationModel.idx_variables.y_minus_B;
OptimizationModel = rmfield(OptimizationModel,'idx_variables');

% Route the MIQP through the COBRA solver abstraction so rMTA honours
% changeCobraSolver (feature 015-solver-spine-hardening). The former raw
% ibm_cplex fast path is now reached through the abstraction itself via
% changeCobraSolver('MIQP', 'ibm_cplex'); the FORCE_CPLEX input is retained
% for backward compatibility but no longer bypasses solveCobraMIQP.

% Generate OptimizationModel for this iteration
MIQPproblem = OptimizationModel;
% include the knock-out reactions
MIQPproblem.lb(KOrxn) = 0;
MIQPproblem.ub(KOrxn) = 0;

% Solver Parameter
if timeLimit > 1e75
    timeLimit = 1e75;
end

% SOLVE the MIQP problem
solution = solveCobraMIQP(MIQPproblem, ...
    'timeLimit',timeLimit, 'relMipGapTol',  1e-5, ...
    'printLevel', max(printLevel-1,0), 'logFile', 0,...
    'threads',numWorkers);

if isnumeric(solution.stat) && solution.stat == 1
    v_res = solution.full(v);
elseif ischar(solution.stat) && strcmp(solution.stat, 'OPTIMAL')
    v_res = solution.full(v);
else
    % Use of try for different outputs of COBRA MIQP solver
    try
        v_res = solution.full(v);
    catch
        v_res = zeros(length(v),1);
    end
end
