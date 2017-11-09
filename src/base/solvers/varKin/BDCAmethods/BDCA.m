function [x_best,psi_best,out] = BDCA(mapp, x0, options)
% BDCA is a derivative-free algorithm for solving systems of nonlinear
% equations :math:`f(x) = 0`, `x` in :math:`R^m` using the nonlinear unconstrained minimization
% :math:`\textrm{min}\ \psi(x) = 1/2 ||f(x)||^2` s.t. `x` in :math:`R^m`.
%
% USAGE:
%
%    [x_best,psi_best,out] = BDCA(mapp, x0, options)
%
% INPUTS:
%    mapp:        function handle provides `f(x)` and gradient `f(x)`
%    x0:          initial point
%    options:     structure including the parameteres of scheme
%
%                   * .MaxNumIter - maximum number of iterations
%                   * .MaxNumMapEval - maximum number of function evaluations
%                   * .TimeLimit - maximum running time
%                   * .epsilon - accuracy parameter
%                   * .x_opt - optimizer
%                   * .psi_opt - optimum
%                   * .alpha - constant for the line searche
%                   * .beta - backtarcking constant
%                   * .lambda_bar - starting step-size for the line search
%                   * .rho - strong convexity parameter
%                   * .kin - kinetic parameter in `R^(2n)`
%                   * .flag_line_search - "Armijo" or "Quadratic_interpolation"
%                   * .flag_x_error - 1: saves :math:`x_{error}`, 0: do not saves :math:`x_{error}` (default)
%                   * .flag_psi_error - 1:saves :math:`\psi_{error}`, 0: do not saves :math:`\psi_{error}` (default)
%                   * .flag_time - 1: saves :math:`\psi_{error}`, 0: do not saves :math:`\psi_{error}` (default)
%                   * .Stopping_Crit - stopping criterion:
%
%                     1. stop if :math:`||nfxk|| \leq \epsilon`
%                     2. stop if `MaxNumIter` is reached
%                     3. stop if `MaxNumMapEval` is reached
%                     4. stop if `TimeLimit` is reached
%                     5. stop if (default) :math:`||hxk|| \leq \epsilon` or `MaxNumIter` is reached
%
% OUTPUTS:
%    x_best:      the best approximation of the optimizer
%    psi_best:    the best approximation of the optimum
%    out:         structure including more output information
%
%                   * .T - running time
%                   * .Niter - total number of iterations
%                   * .Nmap - total number of mapping evaluations
%                   * .merit_func - array including all merit function values
%                   * .x_error - relative error :math:`\textrm{norm}(x_k(:)-x_{opt}(:))/\textrm{norm}(x_{opt})`
%                   * .psi_error - relative error :math:`(\psi_k-\psi_{opt})/(\psi_0-\psi_{opt}))`
%                   * .Status - reason of termination
%
% .. REFERENCE:
% .. Algorithm 2 and 3 of [1]: F.J. Aragon Artacho, R.M.T. Fleming, V.T. Phan, Accelerating the DC algorithm for smooth functions, Submitted (2015)
%
% .. Authors:
%       - Francisco J. Aragón Artacho, Department of Mathematics, University of Alicante, Spain
%       - Vuong T. Phan, Masoud Ahookhosh, System Biochemistry Group, Luxembourg Center for System Biomedicine, University of Luxembourg, Luxembourg
%       - Update July 2017, M. Ahookhosh

format longG ;

% ================ Error messages for input and output =================
if nargin > 3
    error('The number of input arguments is more than what is needed');
elseif nargin < 3
    error('The number of input arguments is not enough');
end;

if isempty(mapp)
    error('the function handle mapp has to be defined');
elseif ~isa(mapp,'function_handle')
    error('mapp should be a function handle');
end

if isempty(x0)
    error('The starting point x0 has to be defined');
elseif ~isa(x0,'numeric')
    error('x0 should be a numeric vector');
end

% =================== initializing the parameters ======================
% ===== user has requested viewing the default values of "options" =====
[MaxNumIter,MaxNumMapEval,TimeLimit,epsilon,alpha,beta,lambda_bar, ...
             rho,kin,flag_line_search,flag_x_error,flag_psi_error, ...
                        flag_time,Stopping_Crit] = InitialBDCA(options);

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

F = options.F;
R = options.R;
FR = [F,R];
RF = [R,F];
FR_RF = FR-RF;
df=@(x) FR*diag(exp(p+FR'*x))*FR_RF';

eps = 1e-8;
options_fmin = optimoptions('fminunc','Algorithm', 'trust-region', ...
'GradObj', 'on','Hessian','on','Display','off','TolFun',eps,'TolX',eps);

xk         = x0;
Xk         = xk;
Niter      = 1;
fxk        = mapp(x0);
Nmap       = 1;
nfx0       = norm(fxk);
nfxk2      = nfx0^2;
merit_func = 0.5*nfxk2;
max_inner  = 5;
StopFlag   = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%% Main body of BDCA.m %%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
T0 = tic;

% ======================= start of the main loop =======================
while ~StopFlag

    yk = fminunc(@(x)FuncGradHessSub(x,xk,F,R,kin,rho),xk,options_fmin);

    fyk  = mapp(yk);
    Nmap = Nmap+1;
    dk   = yk-xk;

    switch lower(flag_line_search)
        case 'armijo'
            lambdak = lambda_bar;

        case 'quadratic_interpolation'
            lambdak      = lambda_bar;
            nfyk_lambda0 = norm(f(yk+lambda*dk))^2;
            dfyk         = df(yk);
            slope0       = 2*fyk'*dfyk'*dk;
            lambda1      = -slope0*lambda^2/(2*(nfyk_lambda0-nfyk ...
                                                       -slope0*lambda));
            nfyk_lambda1 = norm(mapp(yk+lambda1*dk))^2;
            if nfyk_lambda1<nfyk_lambda0 && lambda1>0
                lambdak = lambda1;
            end
    end

    xkb         = yk+lambdak*dk;
    fxkb        = mapp(xkb);
    nfxkb2      = norm(fxkb)^2;
    ndk2        = norm(dk)^2;
    inner_count = 0;
    while (nfxkb2>=nfxk2-alpha*lambdak*ndk2 && inner_count<=max_inner)
        lambdak     = beta*lambdak;
        xkb         = yk+lambdak*dk;
        fxkb        = mapp(xkb);
        Nmap        = Nmap+1;
        nfxkb2      = norm(fxkb)^2;
        inner_count = inner_count+1;
    end

    % ================= Gathering output information ===================
    xk                = xkb;
    Niter             = Niter+1;
    Xk(:,Niter)       = xk;
    nfxk              = sqrt(nfxkb2);
    nfxk2             = nfxkb2;
    psik              = 0.5*nfxk2;
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

    [StopFlag,Status] = StopCritBDCA(nfxk,Niter,Nmap,T,MaxNumIter, ...
                         MaxNumMapEval,TimeLimit,epsilon,Stopping_Crit);

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Outputs %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Status
x_best         = xk;
psi_best       = psik;
out.Xk         = Xk;
out.T          = T;
out.nhx        = nfxk;
out.merit_func = merit_func';
out.Niter      = Niter;
out.Nmap       = Nmap;
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%% End of BDCA.m %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
