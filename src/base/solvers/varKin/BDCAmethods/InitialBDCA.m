function [MaxNumIter, MaxNumMapEval, TimeLimit, epsilon, alpha, beta, lambda_bar, rho,kin, flag_line_search, flag_x_error, flag_psi_error, flag_time, Stopping_Crit] = InitialBDCA(options)
% `InitialBDCA` is a function for initializing the parameters of BDCA and
% DCA. If some parameters specified by the user `InitialDuplo` uses these
% parameters. Otherwise, the default values will be used.
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
%                         * .alpha - constant for the line searche
%                         * .beta - backtarcking constant
%                         * .lambda_bar - starting step-size for the line search
%                         * .rho - strong convexity parameter
%                         * .kin - kinetic parameter in :math:`R^{2n}`
%                         * .flag_line_search - "Armijo" or "Quadratic_interpolation"
%                         * .flag_x_error - 1: saves :math:`x_{error}`, 0: do not saves :math:`x_{error}` (default)
%                         * .flag_psi_error - 1:saves :math:`\psi_{error}`, 0: do not saves :math:`\psi_{error}` (default)
%                         * .flag_time - 1: saves :math:`\psi_{error}`, 0: do not saves :math:`\psi_{error}` (default)
%                         * .Stopping_Crit - stopping criterion:
%
%                           1. stop if :math:`||nfxk|| \leq \epsilon`
%                           2. stop if MaxNumIter is reached
%                           3. stop if MaxNumMapEval is reached
%                           4. stop if TimeLimit is reached
%                           5. stop if (default) :math:`||hxk|| \leq \epsilon` or `MaxNumIter` is reached
%
% OUTPUTS:
%    MaxNumIter:        maximum number of iterations
%    MaxNumMapEval:     maximum number of function evaluations
%    TimeLimit:         maximum running time
%    epsilon:           accuracy parameter
%    x_opt:             optimizer
%    psi_opt:           optimum
%    alpha:             constant for the line search
%    beta:              backtracking constant
%    lambda_bar:        starting step-size for the line search
%    flag_x_error:      1: saves :math:`x_{error}`, 0: do not saves :math:`x_{error}` (default)
%    flag_psi_error:    1: saves :math:`\psi_{error}`, 0: do not saves :math:`\psi_{error}` (default)
%    flag_time:         1: saves :math:`\psi_{error}`, 0: do not saves :math:`\psi_{error}` (default)
%    Stopping_Crit:     stopping criterion
%
%
% .. REFERENCE:
% .. Algorithm 2 and 3 of [1]: F.J. Aragon Artacho, R.M.T. Fleming, V.T. Phan, Accelerating the DC algorithm for smooth functions, Submitted (2015)
%
% .. Authors:
%       - Francisco J. Aragón Artacho, Department of Mathematics, University of Alicante, Spain
%       - Vuong T. Phan, Masoud Ahookhosh, System Biochemistry Group, Luxembourg Center for System Biomedicine, University of Luxembourg, Luxembourg
%       - Update July 2017, M. Ahookhosh

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
    alpha = 0.4;
end

if isfield(options,'beta')
    beta = options.beta;
else
    beta = 0.5;
end

if isfield(options,'lambda_bar')
    lambda_bar = options.lambda_bar;
else
    lambda_bar = 50;
end

if isfield(options,'rho')
    rho = options.rho;
else
    rho = 100;
end

if isfield(options,'kin')
    kin = options.kin;
else
    error('The kinetic parameter should be provides.')
end

if isfield(options,'flag_line_search')
    flag_line_search = options.flag_line_search;
else
    flag_line_search = 'Armijo';
end

if isfield(options,'flag_x_error')
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
%%%%%%%%%%%%%%%%%%%%%%% End of InitialBDCA.m %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
