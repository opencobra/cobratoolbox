function [output1, output2] = functionTemplate(model, arg1, optArg1, optArg2, optArg3)
% (Description of the function) Template for a main utility function for
% the COBRA toolbox. Allow passing COBRA-toolbox-wide parameters (e.g., feasTol, optTol, printLevel) 
% and solver-specific parameter structure (e.g., struct('lpmethod', 1) for Cplex, struct('Presolve', 1) for Gurobi) 
% to the function and other functions called by the function.
%
% USAGE:
%     (positional argument inputs)
%     [output1, output2] = functionTemplate(model, arg1, optArg1, optArg2, optArg3, solverParams)
%     (positional + name/value argument inputs)
%     [output1, output2] = functionTemplate(model, arg1, 'name', value, ..., solverParams)
%     (parameter structure input)
%     [output1, output2] = functionTemplate(model, ..., paramStruct)
%
% INPUT(S):
% (must be inputted as positional arguments)
%     model:               COBRA model
%     arg1:                argument 1
%
% OPTIONAL INPUT(S):
% (can be inputted as positional arguments, or name/value arguments, or a single parameter structure)
%     optArg1:            optional argument 1
%     optArg2:            optional argument 2
%     optArg3:            optional argument 3
%     ...
%
% OUTPUT(S):
%     output1:            output argument 1
%     output2:            output argument 2
%
% EXAMPLE:
%
% NOTE:
%
% Author(s):
%

% optional arguments that can be inputted as positional arguments,
% name/value arguments, or parameter structure, in the same order as
% specified in USAGE
optArgin =      {'optArg1', 'optArg2', 'optArg3'};
% defaultValues for the optional arguments above
defaultValues = {1,         'test',    {'test'}};
% validators for the optional arguments above, i.e., the inputs when passed
% to the validators must return true
validator = {...
    @(x) isscalar(x) & isnumeric(x) & x >= 0, ... % optArg1 (must be non-negative numbers)
    @ischar, ...                                  % optArg2 (must be character)
    @(x) true, ...                                % optArg3 (accept anything)
    };

% types of optimization problems to be solved in this function and the
% functions called by this function
problemTypes = {'LP', 'QP'};

% provide the optional argument name for the solver-specific parameter
% structure (to be passed to solvers like Cplex, Gurobi in e.g., solveCobraLP)
% This is intended for backward compatibility only and NOT RECOMMENDED TO USE
% because as a convention among cobra functions, solver-specific parameter 
% structure can be inputted without keyword
keyForSolverParams = '';

% treat empty inputs ([]) for positional arguments as using default values or not. 
% For example, if emptyForDefault = true, functionTemplate(model, [], 'test')
% takes arg1 as the default value 1. But if emptyForDefault = false, this
% returns error since '[]' does not pass the validator @(x) isscalar(x) & isnumeric(x) & x >= 0
emptyForDefault = true;

% run the input parser to get (1) function arguments, (2) cobra parameters
% and (3) solver-specific parameters
[funParams, cobraParams, solverVarargin] = parseCobraVarargin(varargin, ...
    optArgin, defaultValues, validator, problemTypes, keyForSolverParams, emptyForDefault);

% get all the optional function arguments
[optArg1, optArg2, optArg3] = deal(funParams{:});

%%%%% Do what you want to do with the function. For example, construct
%%%%% optimization problems and solve

LPproblem = struct();
[LPproblem.A, LPproblem.b, LPproblem.c, LPproblem.lb, LPproblem.ub, ...
    LPproblem.osense, LPproblem.csense] = deal(speye(2), [1; 1], [1; 0], ...
    [0; 0], [1; 1], -1, 'LL');

% pass the solver-specific parameters to optimization problem
% make sure to use {:}
solLP = solveCobraLP(LPproblem, solverVarargin.LP{:});
LPproblem.F = speye(2);
solQP = solveCobraQP(LPproblem, solverVarargin.QP{:});

% use the cobra parameters (e.g., manually check feasibility)
if ~(checkSolFeas(solLP) <= cobraParams.LP.feasTol)
    [output1, output2] = deal(0);
else
    [output1, output2] = deal(1);
end

help functionTemplate

end