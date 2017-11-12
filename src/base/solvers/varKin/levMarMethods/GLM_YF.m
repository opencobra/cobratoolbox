function [x_best, psi_best, out] = GLM_YF(mapp, lin_sym_solver, x0, options)
% GLM_YF is a Levenberg-Marquardt algorithm for solving systems of
% nonlinear equations :math:`h(x) = 0`, `x` in :math:`R^m`
% using the nonlinear unconstrained minimization :math:`\textrm{min} \psi(x) = 1/2 ||h(x)||^2`
% s.t. `x` in :math:`R^m`.
%
% USAGE:
%
%    [x_best, psi_best, out]=GLM_YF(mapp, lin_sym_solver, x0, options)
%
% INPUTS:
%    mapp:              function handle provides `h(x)` and gradient `h(x)`
%    lin_sym_solver:    function handle for solving the linear system
%    x0:                initial point
%    options:           structure including the parameteres of scheme
%
%                         * .eta - parameter of the scheme
%                         * .MaxNumIter - maximum number of iterations
%                         * .MaxNumMapEval - maximum number of function evaluations
%                         * .MaxNumGmapEval - maximum number of subgradient evaluations
%                         * .TimeLimit - maximum running time
%                         * .epsilon - accuracy parameter
%                         * .x_opt - optimizer
%                         * .psi_opt - optimum
%                         * .adaptive - update lambda adaptively
%                         * .flag_x_error - 1: saves :math:`x_{error}`, 0: do not saves :math:`x_{error}` (default)
%                         * .flag_psi_error - 1: saves :math:`\psi_{error}`, 0: do not saves :math:`\psi_{error}` (default)
%                         * .flag_time - 1: saves :math:`\psi_{error}`, 0: do not saves :math:`\psi_{error}` (default)
%                         * .Stopping_Crit - stopping criterion
%
%                           1. stop if :math:`||grad|| \leq \epsilon`
%                           2. stop if :math:`||nhxk|| \leq \epsilon`
%                           3. stop if `MaxNumIter` is reached
%                           4. stop if `MaxNumMapEval` is reached
%                           5. stop if `MaxNumGmapEval` is reached
%                           6. stop if `TimeLimit` is reached
%                           7. stop if :math:`||grad|| \leq \textrm{max}(\epsilon, \epsilon^2 * ngradx0)`
%                           8. stop if :math:`||nhxk|| \leq \textrm{max}(\epsilon, \epsilon^2 * nhx0)`
%                           9. stop if (default) :math:`||hxk|| \leq \epsilon` or `MaxNumIter` is reached
%
% OUTPUT:
%    x_best:            the best approximation of the optimizer
%    psi_best:          the best approximation of the optimum
%    out:               structure including more output information
%
%                         * .T - running time
%                         * .Niter - total number of iterations
%                         * .Nmap - total number of mapping evaluations
%                         * .Ngmap - total number of mapping gradient evaluations
%                         * .merit_func - array including all merit function values
%                         * .x_error - relative error :math:`\textrm{norm}(x_k(:)-x_{opt}(:))/\textrm{norm}(x_{opt})`
%                         * .psi_error - relative error :math:`(\psi_k-\psi_{opt})/(\psi_0-\psi_{opt}))`
%                         * .Status - reason of termination
%
% .. REFERENCE:
% .. N. Yamashita, M., Fukushima, On  the  rate  of  convergence  of the Levenberg-Marquardt  method, In: G. Alefeld, X. Chen  (eds.) Topics  in  Numerical  Analysis,  vol.  15,  pp.  239-249. Springer  Vienna,  Vienna, (2001)
% .. Author: - Masoud Ahookhosh, System Biochemistry Group, Luxembourg Center for System Biomedicine, University of Luxembourg, Luxembourg
%            - Update: July 2017, M. Ahookhosh

format longG ;

% ================ Error messages for input and output =================
if nargin > 4
    error('The number of input arguments is more than what is needed');
elseif nargin < 4
    error('The number of input arguments is not enough');
end;

if isempty(mapp)
    error('the function handle mapp has to be defined');
elseif ~isa(mapp,'function_handle')
    error('mapp should be a function handle');
end

if isempty(lin_sym_solver)
    error('the function handle lin_sym_solver has to be defined');
elseif ~isa(lin_sym_solver,'function_handle')
    error('lin_sym_solver should be a function handle');
end

if isempty(x0)
    error('The starting point x0 has to be defined');
elseif ~isa(x0,'numeric')
    error('x0 should be a numeric vector');
end

% =================== initializing the parameters ======================
% ===== user has requested viewing the default values of "options" =====
[eta,epsilon,MaxNumIter,MaxNumMapEval,MaxNumGmapEval, adaptive, ...
    TimeLimit,flag_x_error,flag_psi_error,flag_time,Stopping_Crit] ...
    = Initialization(options);

if ~isa(eta,'numeric') || (eta <= 0)
    error('eta should be numeric and eta in (0,4*delta)');
end

if isfield(options,'x_opt')
    x_opt=options.x_opt;
elseif flag_x_error==1
    error('x_error requires to x_opt be specified');
end

if flag_x_error == 1
    Nxopt      = sqrt(sum(x_opt(:).^2));
    x_error(1) = sqrt(sum((x0(:)-x_opt(:)).^2))/Nxopt;
end

if flag_psi_error == 1
    psi_error(1) = 1;
end

if flag_time == 1
    Time(1) = 0;
end

xk         = x0;
Niter      = 1;
[hxk,ghxk] = mapp(x0);
Nmap       = 1;
Ngmap      = 1;
grad       = ghxk*hxk;
nhxk       = sqrt(sum(hxk.^2));
nhx0       = nhxk;
ngradx0    = sqrt(sum(grad.^2));
I          = eye(length(xk));
psik       = 0.5*nhxk^2;
merit_func = psik;
sigma      = 1e-2;
rho        = 0.2;
gamma      = 0.5; % ???
max_inner  = 5;
StopFlag   = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%% Main body of GLM_YF.m %%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
T0 = tic;

% ======================= start of the main loop =======================
while ~StopFlag

    muk   = nhxk^2;
    Hk    = ghxk*ghxk'+muk*I;
    dk    = lin_sym_solver(Hk,grad);
    xk1   = xk+dk;
    hxk1  = mapp(xk1);
    Nmap  = Nmap+1;
    nhxk1 = norm(hxk1);
    if nhxk1 <= gamma*nhxk
        xk    = xk1;
        Niter = Niter+1;
        hxk   = mapp(xk);
        Nmap  = Nmap+1;
        nhxk  = norm(hxk);
        psik  = 0.5*nhxk^2;
    else
        psik1       = 0.5*nhxk1^2;
        alphak      = 1;
        inner_count = 0;
        while ((psik1-psik)>=sigma*alphak*(grad'*dk)&& ...
                inner_count<= max_inner)
            alphak      = rho*alphak;
            xk1         = xk+alphak*dk;
            hxk1        = mapp(xk1);
            Nmap        = Nmap+1;
            nhxk1       = norm(hxk1);
            psik1       = 0.5*nhxk1^2;
            inner_count = inner_count+1;
        end
        xk    = xk1;
        Niter = Niter+1
        nhxk  = nhxk1;
        psik  = psik1;
    end
    [hxk,ghxk] = mapp(xk);
    Nmap       = Nmap+1;
    Ngmap      = Ngmap+1;
    grad       = ghxk*hxk;

    % ================= Gathering output information ===================
    merit_func(Niter) = psik;
    if flag_time == 1
        Time(Niter+1) = toc(T0);
    end

    if flag_x_error == 1
        Nx_opt = norm(x_opt);
        x_error(Niter+1) = sqrt(sum((xk(:)-x_opt(:)).^2))/Nx_opt;
    end

    if flag_psi_error == 1
        psi_error(Niter+1) = (psik-psi_opt)/(psi0-psi_opt);
    end

    % ================== checking stopping criteria ====================
    T = toc(T0);

    [StopFlag,Status] = StopCriterion(grad,nhxk,Niter,Nmap, ...
    Ngmap,MaxNumIter,MaxNumMapEval,MaxNumGmapEval,T,TimeLimit, ...
    epsilon,nhx0,ngradx0,Stopping_Crit);

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Outputs %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Status
x_best         = xk;
psi_best       = psik;
out.T          = T;
out.nhx        = nhxk;
out.merit_func = merit_func';
out.Niter      = Niter;
out.Nmap       = Nmap;
out.Ngmap      = Ngmap;
out.Status     = Status;

if flag_x_error == 1
    out.x_error = x_error;
end
if flag_psi_error == 1
    out.psi_error = psi_error;
end
if flag_time == 1
    out.Time = Time;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%% End of GLM_YF.m %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
