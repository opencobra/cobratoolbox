function [MaxNumIter, MaxNumMapEval, TimeLimit, epsilon, alpha, beta, sigma, l, tauBar, lambda_min, lambda_max, flag_x_error, flag_psi_error, flag_time, Stopping_Crit] = InitialDuplo(options)
% Function for initializing the parameters of
% `DuploBacktrack`, `DuploConStep`, and `DuploDoubBacktrack`. If some
% parameters specified by the user `InitialDuplo` uses these parameters.
% Otherwise, the default values will be used.
%
% USAGE:
%
%    [MaxNumIter, MaxNumMapEval, TimeLimit, epsilon, alpha, beta, sigma, l, tauBar, lambda_min, lambda_max, flag_x_error, flag_psi_error, flag_time, Stopping_Crit] = InitialDuplo(options)
%
% INPUTS:
%    options:           structure including the parameteres of scheme
%
%                         * .MaxNumIter - maximum number of iterations
%                         * .MaxNumMapEval - maximum number of function evaluations
%                         * .TimeLimit - maximum running time
%                         * .epsilon - accuracy parameter
%                         * .x_opt - optimizer
%                         * .psi_opt - optimum
%                         * .alpha - constant with :math:`\alpha < 2 \sigma`
%                         * .beta - reduction constant of the line search
%                         * .sigma - strong duplomonotone parameter
%                         * .l - Lipschitz continuity constant of `f`
%                         * .tauBar - a constant for determining the step-size
%                         * .lambda_min - lower bound of the step-size
%                         * .lambda_max - upper bound of the step-size
%                         * .flag_x_error - 1: saves :math:`x_{error}`, 0: do not saves :math:`x_{error}` (default)
%                         * .flag_psi_error - 1: saves :math:`\psi_{error}`, 0: do not saves :math:`\psi_{error}` (default)
%                         * .flag_time - 1: saves :math:`\psi_{error}`, 0: do not saves :math:`\psi_{error}` (default)
%                         * .Stopping_Crit - stopping criterion
%
%                           1. stop if :math:`||nfxk|| \leq \epsilon`
%                           2. stop if `MaxNumIter` is reached
%                           3. stop if `MaxNumMapEval` is reached
%                           4. stop if `TimeLimit` is reached
%                           5. stop if (default) :math:`||hxk|| \leq \epsilon` or `MaxNumIter` is reached
%
% OUTPUTS:
%    MaxNumIter:        maximum number of iterations
%    MaxNumMapEval:     maximum number of function evaluations
%    TimeLimit:         maximum running time
%    epsilon:           accuracy parameter
%    x_opt:             optimizer
%    psi_opt:           optimum
%    alpha:             a constant
%    beta:              a constant
%    flag_x_error:      1: saves :math:`x_{error}`, 0: do not saves :math:`x_{error}` (default)
%    flag_psi_error:    1: saves :math:`\psi_{error}`, 0: do not saves :math:`\psi_{error}` (default)
%    flag_time:         1: saves :math:`\psi_{error}`, 0: do not saves :math:`\psi_{error}` (default)
%    Stopping_Crit:     stopping criterion

if isfield(options,'epsilon')
    epsilon = options.epsilon;
else
    epsilon = 10^(-5);
end

if isfield(options,'MaxNumIter')
    MaxNumIter = options.MaxNumIter;
else
    MaxNumIter = 5000;
end

if isfield(options,'MaxNumMapEval')
    MaxNumMapEval = options.MaxNumMapEval;
else
    MaxNumMapEval = 10000;
end

if isfield(options,'TimeLimit')
    TimeLimit = options.TimeLimit;
else
    TimeLimit = inf;
end

if isfield(options,'alpha')
    alpha = options.alpha;
else
    alpha = 1e-1;
end

if isfield(options,'beta')
    beta = options.beta;
else
    beta = 0.5;
end

if isfield(options,'sigma')
    sigma = options.sigma;
else
    sigma = 1;
end

if isfield(options,'l')
    l = options.l;
else
    l = 10;
end

if isfield(options,'tauBar')
    tauBar = options.tauBar;
else
    tauBar = 0.6;
end

if isfield(options,'lambda_min')
    lambda_min = options.lambda_min;
else
    lambda_min = 1e-4;
end

if isfield(options,'lambda_max')
    lambda_max = options.lambda_max;
else
    lambda_max = 1;
end

if isfield(options,'flag_`x_error`')
    flag_x_error = options.flag_x_error;
else
    flag_x_error = 0;
end

if isfield(options,'flag_psi_error')
    flag_psi_error = options.flag_psi_error;
else
    flag_psi_error = 0;
end

if isfield(options,'flag_time')
    flag_time = options.flag_time;
else
    flag_time = 0;
end

if isfield(options,'Stopping_Crit')
    Stopping_Crit = options.Stopping_Crit;
else
    Stopping_Crit = 5;
end

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%% End of InitialDuplo.m %%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
