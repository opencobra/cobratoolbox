%not ready
function [eta, epsilon, MaxNumIter, MaxNumMapEval, MaxNumGmapEval, adaptive, TimeLimit, flag_x_error, flag_psi_error, flag_time, Stopping_Crit] = Initialization(options)
% Initialization is a function for initializing the parameters of LLM
% and GLM. If some parameters specified by the user Initialization uses
% these parameters. Otherwise, the default values will be employed.
%
% USAGE:
%
%    [eta, epsilon, MaxNumIter, MaxNumMapEval, MaxNumGmapEval, adaptive, TimeLimit, flag_x_error, flag_psi_error, flag_time, Stopping_Crit] = Initialization(options)
%
% INPUTS:
%
% options              % structure including the parameteres of schemes
%
%   .eta               % parameter of the scheme
%   .MaxNumIter        % maximum number of iterations
%   .MaxNumMapEval     % maximum number of function evaluations
%   .MaxNumGmapEval    % maximum number of subgradient evaluations
%   .TimeLimit         % maximum running time
%   .epsilon           % accuracy parameter
%   .x_opt             % optimizer
%   .psi_opt           % optimum
%   .adaptive          % update lambda adaptively
%   .flag_x_error      % 1 : saves x_error
%                      % 0 : do not saves x_error (default)
%   .flag_psi_error    % 1 : saves psi_error
%                      % 0 : do not saves psi_error (default)
%   .flag_time         % 1 : saves psi_error
%                      % 0 : do not saves psi_error (default)
%   .Stopping_Crit     % stopping criterion
%
%                      % 1 : stop if ||grad|| <= epsilon
%                      % 2 : stop if ||nhxk|| <= epsilon
%                      % 3 : stop if MaxNumIter is reached
%                      % 4 : stop if MaxNumMapEval is reached
%                      % 5 : stop if MaxNumGmapEval is reached
%                      % 6 : stop if TimeLimit is reached
%                      % 7 : stop if
%                               ||grad||<=max(epsilon,epsilon^2*ngradx0)
%                      % 8 : stop if
%                               ||nhxk||<=max(epsilon,epsilon^2*nhx0)
%                      % 9 : stop if                         (default)
%                            ||hxk||<=epsilon or MaxNumIter is reached
%
% OUTPUT:
%
% x_best               % the best approximation of the optimizer
% psi_best             % the best approximation of the optimum
% out                  % structure including more output information
%
%   .T                 % running time
%   .Niter             % total number of iterations
%   .Nmap              % total number of mapping evaluations
%   .Ngmap             % total number of mapping gradient evaluations
%   .merit_func        % array including all merit function values
%   .x_error           % relative error norm(xk(:)-x_opt(:))/norm(x_opt)
%   .psi_error         % relative error (psik-psi_opt)/(psi0-psi_opt))
%   .status            % reason of termination
%

if isfield(options,'eta')
    eta = options.eta;
else
    eta = 1;
end

if isfield(options,'epsilon')
    epsilon = options.epsilon;
else
    epsilon = 10^(-5);
end

if isfield(options,'MaxNumIter')
    MaxNumIter = options.MaxNumIter;
else
    MaxNumIter = 500;
end

if isfield(options,'MaxNumMapEval')
    MaxNumMapEval = options.MaxNumMapEval;
else
    MaxNumMapEval = 1000;
end

if isfield(options,'MaxNumGmapEval')
    MaxNumGmapEval = options.MaxNumGmapEval;
else
    MaxNumGmapEval = 500;
end

if isfield(options,'adaptive')
    adaptive = options.adaptive;
else
    adaptive = 1;
end

if isfield(options,'TimeLimit')
    TimeLimit = options.TimeLimit;
else
    TimeLimit = inf;
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
    Stopping_Crit = 9;
end

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%% End of Initialization.m %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
