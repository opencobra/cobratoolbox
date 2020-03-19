function [v_res, solution] = MTA_MIQP(OptimizationModel, KOrxn, varargin)
% Returns the OptimizationModel solution of a particular MTA problem and
% an specific model
%
% USAGE:
%
%    [v_res, success, unsuccess] = MTA_MIQP (OptimizationModel, KOrxn, numWorkers, timeLimit, printLevel)
%
% INPUT:
%    OptimizationModel:    Cplex Model struct
%    KOrxn:                perturbation in the model (reactions)
%    numWorkers:           number of threads used by Cplex.
%    printLevel:           1 if the process is wanted to be shown on the
%                          screen, 0 otherwise. Default: 1.
%
% OUTPUTS:
%    Vout:                 Solution flux of MIQP formulation for each case
%    solution:             Cplex solution struct
%
% .. Authors:
%       - Luis V. Valcarcel, 03/06/2015, University of Navarra, CIMA & TECNUN School of Engineering.
%       - Luis V. Valcarcel, 26/10/2018, University of Navarra, CIMA & TECNUN School of Engineering.

p = inputParser; % check the input information
% check requiered arguments
addRequired(p, 'OptimizationModel');
addRequired(p, 'KOrxn');
% Check optional arguments
addParameter(p, 'numWorkers', 0,@(x)isnumeric(x)&&isscalar(x));
addParameter(p, 'timeLimit', inf,@(x)isnumeric(x)&&isscalar(x));
addParameter(p, 'printLevel', 1,@(x)isnumeric(x)&&isscalar(x));
% extract variables from parser
parse(p, OptimizationModel, KOrxn, varargin{:});
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

% Temporal way: use ibm_cplex if installed until MIQP API for COBRA is
% implemented
global SOLVERS;
global CBT_MIQP_SOLVER
if SOLVERS.ibm_cplex.installed && isempty(CBT_MIQP_SOLVER)
    % Generate CPLEX model
    cplex = Cplex('MIQP');
    CplexModel = OptimizationModel;

    b_L(CplexModel.csense == 'E') = CplexModel.b(CplexModel.csense == 'E');
    b_U(CplexModel.csense == 'E') = CplexModel.b(CplexModel.csense == 'E');
    b_L(CplexModel.csense == 'G') = CplexModel.b(CplexModel.csense == 'G');
    b_U(CplexModel.csense == 'G') = inf;
    b_L(CplexModel.csense == 'L') = -inf;
    b_U(CplexModel.csense == 'L') = CplexModel.b(CplexModel.csense == 'L');
    CplexModel.rhs = b_U;
    CplexModel.lhs = b_L;
    CplexModel.Q = CplexModel.F;
    CplexModel.obj = CplexModel.c;
    CplexModel.ctype = CplexModel.vartype;
    CplexModel.sense = 'minimize';

    cplex.Model = CplexModel;
    % include the knock-out reactions
    cplex.Model.lb(KOrxn) = 0;
    cplex.Model.ub(KOrxn) = 0;

    % Cplex Parameter
    if numWorkers>0
        cplex.Param.threads.Cur = numWorkers;
    end
    if printLevel <=1
        cplex.Param.output.clonelog.Cur = 0;
        cplex.DisplayFunc = [];
    elseif printLevel <=2
        cplex.Param.output.clonelog.Cur = 0;
    end
    if timeLimit < 1e75
        cplex.Param.timelimit.Cur = timeLimit;
    end
    %reduce the tolerance
    cplex.Param.mip.tolerances.mipgap.Cur = 1e-5;
    % cplex.Param.mip.tolerances.absmipgap.Cur = 1e-8;
    % cplex.Param.threads.Cur = 16;

    % SOLVE the CPLEX problem if not singular
    try
        cplex.solve();
    catch
        v_res = zeros(length(v),1);
        return
    end

    if cplex.Solution.status ~= 103
        v_res = cplex.Solution.x(v);
        solution = cplex.Solution;
    else
        v_res = zeros(length(v),1);
        solution = nan;
    end

    % clear the cplex object
    delete(cplex)
    clear cplex
else
    % Generate OptimizationModel for this iteration
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
            v_res = solution.full(v);
        else
            v_res = zeros(length(v),1);
        end
    end


end
