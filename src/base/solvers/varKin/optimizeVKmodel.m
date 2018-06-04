function output = optimizeVKmodel(model, solver, x0, parms)
% Function for finding a solution of the nonlinear system
% :math:`h(x) = f(x) = 0`, `x` in :math:`R^m`, (I)
% or :math:`h(x) = (f(x)^T, l(x)^T)^T = 0`, `x` in :math:`R^m`, (II)
% where :math:`f(x) = [F - R, R - F]*exp(k + [F, R]^T * x)`, :math:`l(x) = L*exp(x) - l_0`,
% using the nonlinear unconstrained minimization
% :math:`\textrm{min}\ psi(x) = 1/2 ||h(x)||^2` s.t. `x` in :math:`R^m`.
% with several solvers. For (I), one can use all the following solvers;
% however, for (II), one can only apply local solvers LLM_F, LLM_FY,
% LLM_YF, LLM and global solvers GLM_FY, GLM_YF, LevMar, LMLS, and LMTR.
% If `sonver` field is empty, the code will use LMTR as the default.
%
% USAGE:
%
%    output = optimizeVKmodel(model, solver, x0, parms)
%
% INPUT:
%    model:    stracture includes `F`, `R` and/or `L`
%
%                 * .F - forward stoichiometric matrix
%                 * .R - reverse stoichiometric matrix
%                 * .L - basis for the left null-space of `N = R - F`
%                 * .l0 - constant :math:`l_0`
%
%    solver:
%
%                 * Local `Levenberg-Marquardt` (LM) solvers:
%
%                   * LLM - LM of `Ahookhosh et al.`
%                   * LLM_F - LM of `Fischer`
%                   * LLM_FY - LM of `Fun` and `Yuan`
%                   * LLM_YF - LM of `Yamashita` and `Fukushima`
%                 * Global `Levenberg-Marquardt` (LM) solvers:
%
%                   * LM_FY - LM of `Fun` and `Yuan`
%                   * LM_YF - LM of `Yamashita` and `Fukushima`
%                   * LevMar - LM of `Kelly`
%                   * LMLS - LM line search of `Ahookhosh et al.`
%                   * LMTR - LM trust-region of `Ahookhosh et al.`
%                 * DC programming solvers:
%
%                   * DCA - DC programming algorithm
%                   * BDCA - boosted DC programming algorithm
%                 * Duplomonotone derivative-free solvers:
%
%                   * BDF - Derivative-free duplomonotone method 1
%                   * CSDF - Derivative-free duplomonotone method 2
%                   * DBDF - Derivative-free duplomonotone method 3
%
%    Parameters for LLM_F, LLM_FY, LLM_YF, LLM, GLM_FY, GLM_YF, LevMar, LMLS, LMTR
%    parms:     structure including the parameteres of schemes
%
%                 * .eta - constant for `Levenberg-Marquardt` parameter
%                 * .MaxNumIter - maximum number of iterations
%                 * .MaxNumMapEval - maximum number of function evaluations
%                 * .MaxNumGmapEval - maximum number of gradient evaluations
%                 * .TimeLimit - maximum running time
%                 * .epsilon - accuracy parameter
%                 * .x_opt - optimizer
%                 * .psi_opt - optimum
%                 * .adaptive - update lambda adaptively
%                 * .kin - kinetic parameter in :math:`R^{2n}`
%                 * .flag_x_error - 1: saves `x_error`, 0: do not saves `x_error` (default)
%                 * .flag_psi_error - 1: saves `psi_error`, 0: do not saves `psi_error` (default)
%                 * .flag_time - 1: saves `psi_error`, 0: do not saves `psi_error` (default)
%                 * .Stopping_Crit - stopping criterion
%
%                   1. stop if :math:`||grad|| \leq \epsilon`
%                   2. stop if :math:`||nhxk|| \leq \epsilon`
%                   3. stop if `MaxNumIter` is reached
%                   4. stop if `MaxNumMapEval` is reached
%                   5. stop if `MaxNumGmapEval` is reached
%                   6. stop if `TimeLimit` is reached
%                   7. stop if :math:`||grad|| \leq \textrm{max}(\epsilon, \epsilon ^2 * ngradx_0)`
%                   8. stop if :math:`||nhxk|| \leq \textrm{max}(\epsilon, \epsilon^2 * nhx_0)`
%                   9. stop if (default) :math:`||hxk|| \leq \epsilon` or `MaxNumIter` is reached
%
%    Parameters for DCA, BDCA
%    parms:     structure including the parameteres of schemes
%
%                 * mapp - function handle provides `f(x)` and gradient `f(x)`
%    x0:        initial point
%    options:   structure including the parameteres of scheme
%
%                 * .MaxNumIter - maximum number of iterations
%                 * .MaxNumMapEval - maximum number of function evaluations
%                 * .TimeLimit - maximum running time
%                 * .epsilon - accuracy parameter
%                 * .x_opt - optimizer
%                 * .psi_opt - optimum
%                 * .alpha - constant for the line search
%                 * .beta - backtarcking constant
%                 * .lambda_bar - starting step-size for the line search
%                 * .rho - strong convexity parameter
%                 * .kin - kinetic parameter in :math:`R^{2n}`
%                 * .flag_line_search - "Armijo" or "Quadratic_interpolation"
%                 * .flag_x_error - 1: saves `x_error`, 0: do not saves `x_error` (default)
%                 * .flag_psi_error - 1: saves `psi_error`, 0: do not saves `psi_error` (default)
%                 * .flag_time - 1: saves `psi_error`, 0: do not saves `psi_error` (default)
%                 * .Stopping_Crit - stopping criterion
%
%                   * 1 : stop if :math:`||nfxk|| \leq \epsilon`
%                   * 2 : stop if `MaxNumIter` is reached
%                   * 3 : stop if `MaxNumMapEval` is reached
%                   * 4 : stop if `TimeLimit` is reached
%                   * 5 : stop if (default) :math:`||hxk|| \leq \epsilon` or `MaxNumIter` is reached
%
%    Parameters for BDF, CSDF, DBDF
%    parms:     structure including the parameteres of schemes
%
%                 * mapp - function handle provides `f(x)` and gradient `f(x)`
%    x0:        initial point
%    options:   structure including the parameteres of scheme
%
%                 * .MaxNumIter - maximum number of iterations
%                 * .MaxNumMapEval - maximum number of function evaluations
%                 * .TimeLimit - maximum running time
%                 * .epsilon - accuracy parameter
%                 * .x_opt - optimizer
%                 * .psi_opt - optimum
%                 * .alpha - constant with :math:`\alpha < 2 \sigma`
%                 * .beta - is the backtarcking constant;
%                 * .lambda_min - lower bound of the step-size
%                 * .lambda_max - upper bound of the step-size
%                 * .flag_x_error - 1: saves `x_error`, 0: do not saves `x_error` (default)
%                 * .flag_psi_error - 1: saves `psi_error`, 0: do not saves `psi_error` (default)
%                 * .flag_time - 1: saves `psi_error`, 0: do not saves `psi_error` (default)
%                 * .Stopping_Crit - stopping criterion
%
%                   * 1 : stop if :math:`||nfxk|| \leq \epsilon`
%                   * 2 : stop if `MaxNumIter` is reached
%                   * 3 : stop if `MaxNumMapEval` is reached
%                   * 4 : stop if `TimeLimit` is reached
%                   * 5 : stop if (default) :math:`||hxk|| \leq \epsilon` or `MaxNumIter` is reached
%
% OUTPUT:
%    output:    structure including more output information:
%
%                 * .x_best - the best approximation of the optimizer
%                 * .psi_best - the best approximation of the optimum
%                 * .T - running time
%                 * .Niter - total number of iterations
%                 * .Nmap - total number of mapping evaluations
%                 * .Ngmap - total number of mapping gradient evaluations
%                 * .merit_func - array including all merit function  values
%                 * .x_error - relative error :math:`norm(x_k(:)-x_{opt}(:))/norm(x_{opt})`
%                 * .psi_error - relative error :math:`(psi_k-psi_{opt})/(psi_0-psi_{opt}))`
%                 * .Status - reason of termination
%                 * .Time - running time of all iterations
%
% .. Author: - Masoud Ahookhosh, Systems Biochemistry Group, LCSB, University of Luxembourg.

format longE

%% Error messages for input and output
if nargin > 4
    error('Extra inputs are asked.');
elseif nargin < 4
    error('The number of input arguments is not enough.');
end;

if nargout > 1
    error('Extra outputs are asked.');
elseif nargout == 0
    error('The number of output arguments is not enough.');
end;

if isempty(model)
    error('the structure model has to be defined.');
elseif ~isfield(model, 'F') || ~isfield(model, 'R')
    error('the fields F and R has to be filled.');
end

if isempty(solver)
    solver = 'LMTR';
elseif isfield(model, 'L') && strcmp(solver,'DCA') && ...
       strcmp(solver,'BDCA') && strcmp(solver,'BDF') && ...
       strcmp(solver,'CSDF') && strcmp(solver,'DBDF')
    error('Use a Levenberg-Marquardt solver.');
end

if isempty(parms)
     error('the structure parms should not be empty.');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%% Start of impelementations %%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% If the field model.L is filled, then a Levenberg-Marquardt method
% should be used to solve the problem; otherwise, a Levenberg-Marquardt,
% DCA, BDCA, BDF, CSDF, or DBDF can be used to solve the problem.

F = model.F;
R = model.R;
FR = [F, R];
m = size(F,1);
if isempty(x0)
    x0 = zeros(m,1);
end

if isfield(model, 'L')

    if  ~strcmp(solver,'LLM_F')  && ~strcmp(solver,'LLM_FY') && ...
        ~strcmp(solver,'LLM_YF') && ~strcmp(solver,'LLM')    && ...
        ~strcmp(solver,'GLM_FY') && ~strcmp(solver,'GLM_YF') && ...
        ~strcmp(solver,'LevMar') && ~strcmp(solver,'LMLS')   && ...
        ~strcmp(solver,'LMTR')
        error('Wrong solver is used.');
    end

    % Full row-rank nonlinear system
    % Remove rows of [F-R] that the resulted matrix is full row rank
    % where tol is a rank estimation tolerance (default=1e-10). The
    % output are the full row-rank matrix (A-B), idx (he indices
    % (into X=(F-R)') of the extracted columns), and Xsub (the extracted
    % colums of X).

    if isfield(model, 'L')
        L  = model.L;
        l0 = model.l0;
    end

    X  = (F-R)';
    % X has no non-zeros and hence no independent columns
    if ~nnz(X)
        Xsub = [];
        idx  = [];
        return
    end
    [Q,S,E] = qr(X, 0);
    if ~isvector(S)
        diagr = abs(diag(S));
    else
        diagr = S(1);
    end
    tol = 1e-10;
    % Rank estimation
    r   = find(diagr >= tol*diagr(1), 1, 'last');
    idx = sort(E(1:r));

    % Xsub=X(:,idx);
    A     = F(idx, :);
    B     = R(idx, :);
    AB_BA = [A-B, B-A];

    opt.FR = FR;
    opt.AB_BA = AB_BA;
    opt.L = L;
    opt.l0 = l0;
    if isfield(parms, 'kin')
        opt.k = parms.kin;
    end

    mapp = @ (varargin) Extended_rate_function(opt, varargin{:});
    lin_sym_solver = @ (varargin) lin_sym_solver_mldivide(varargin{:});

    if isfield(parms, 'MaxNumIter')
        options.MaxNumIter = parms.MaxNumIter;
    end
    if isfield(parms, 'MaxNumMapEval')
        options.MaxNumMapEval = parms.MaxNumMapEval;
    end
    if isfield(parms, 'MaxNumGmapEval')
        options.MaxNumGmapEval = parms.MaxNumGmapEval;
    end
    if isfield(parms, 'TimeLimit')
        options.TimeLimit = parms.TimeLimit;
    end
    if isfield(parms, 'epsilon')
        options.epsilon = parms.epsilon;
    end
    if isfield(parms, 'x_opt')
        options.x_opt = parms.x_opt;
    end
    if isfield(parms, 'psi_opt')
        options.psi_opt = parms.psi_opt;
    end
    if isfield(parms, 'eta')
        options.eta = parms.eta;
    end
    if isfield(parms, 'adaptive')
        options.adaptive = parms.adaptive;
    end
    if isfield(parms, 'kin')
        options.kin = parms.kin;
    end
    if isfield(parms, 'flag_x_error')
        options.flag_x_error = parms.flag_x_error;
        flag_x_error = parms.flag_x_error;
    else
        flag_x_error = 0;
    end
    if isfield(parms, 'flag_psi_error')
        options.flag_psi_error = parms.flag_psi_error;
        flag_psi_error = parms.flag_psi_error;
    else
        flag_psi_error = 0;
    end
    if isfield(parms, 'flag_time')
        options.flag_time = parms.flag_time;
        flag_time = parms.flag_time;
    else
        flag_time = 0;
    end
    if isfield(parms, 'Stopping_Crit')
        options.Stopping_Crit = parms.Stopping_Crit;
    end

    switch solver

        case 'LLM_YF'
            fprintf('Running LLM_YF ...\n')
            options.lambda = 1;
            options.eta = 2;
            options.adaptive = 0;
            options.Stopping_Crit = 9;
            [x_best,psi_best,out] = ...
                                LLM(mapp, lin_sym_solver, x0, options);

        case 'LLM_FY'
            fprintf('Running LLM_FY ...\n')
            options.lambda = 1;
            options.eta = 1;
            options.adaptive = 0;
            options.Stopping_Crit = 9;
            [x_best,psi_best,out] = ...
                                LLM(mapp, lin_sym_solver, x0, options);

        case 'LLM_F'
            fprintf('Running LLM_F ...\n')
            options.lambda = 0;
            options.eta = 1;
            options.adaptive = 0;
            options.Stopping_Crit = 9;
            [x_best,psi_best,out] = ...
                                LLM(mapp, lin_sym_solver, x0, options);

        case 'LLM'
            fprintf('Running LLM ...\n')
            options.eta = 1.2;
            options.adaptive = 1;
            options.Stopping_Crit = 9;
            [x_best,psi_best,out] = ...
                                LLM(mapp, lin_sym_solver, x0, options);

        case 'GLM_YF'
            fprintf('Running GLM_YF ...\n')
            options.Stopping_Crit = 9;
            [x_best,psi_best,out] = ...
                             GLM_YF(mapp, lin_sym_solver, x0, options);

        case 'GLM_FY'
            fprintf('Running GLM_FY ...\n')
            options.Stopping_Crit = 9;
            [x_best,psi_best,out] = ...
                             GLM_FY(mapp, lin_sym_solver, x0, options);

        case 'LevMar'
            fprintf('Running LevMar ...\n')
            options.Stopping_Crit = 9;
            [x_best,psi_best,out] = ...
                             LevMar(mapp, lin_sym_solver, x0, options);

        case 'LMLS'
            fprintf('Running LMLS ...\n')
            options.eta = 1.2;
            options.adaptive = 1;
            options.Stopping_Crit = 9;
            [x_best,psi_best,out] = ...
                               LMLS(mapp, lin_sym_solver, x0, options);

        case 'LMTR'
            fprintf('Running LMTR ...\n')
            options.eta = 1.2;
            options.adaptive = 1;
            options.Stopping_Crit = 9;
            [x_best,psi_best,out] = ...
                               LMTR(mapp, lin_sym_solver, x0, options);
    end

else

    FR_RF = [F-R, R-F];
    opt.FR = FR;
    opt.FR_RF = FR_RF;
    if isfield(parms, 'kin')
        opt.k = parms.kin;
    end
    mapp = @ (varargin) Rate_function(opt, varargin{:});

    if isfield(parms, 'MaxNumIter')
        options.MaxNumIter = parms.MaxNumIter;
    end
    if isfield(parms, 'MaxNumMapEval')
        options.MaxNumMapEval = parms.MaxNumMapEval;
    end
    if isfield(parms, 'MaxNumGmapEval')
        options.MaxNumGmapEval = parms.MaxNumGmapEval;
    end
    if isfield(parms, 'TimeLimit')
        options.TimeLimit = parms.TimeLimit;
    end
    if isfield(parms, 'epsilon')
        options.epsilon = parms.epsilon;
    end
    if isfield(parms, 'x_opt')
        options.x_opt = parms.x_opt;
    end
    if isfield(parms, 'psi_opt')
        options.psi_opt = parms.psi_opt;
    end
    if isfield(parms, 'alpha')
        options.alpha = parms.alpha;
    end
    if isfield(parms, 'beta')
        options.beta = parms.beta;
    end
    if isfield(parms, 'rho')
        options.rho = parms.rho;
    end
    if isfield(parms, 'kin')
        options.kin = parms.kin;
    end
    if isfield(parms, 'lambda_bar')
        options.lambda_bar = parms.lambda_bar;
    end
    if isfield(parms, 'lambda_min')
        options.lambda_min = parms.lambda_min;
    end
    if isfield(parms, 'lambda_max')
        options.lambda_max = parms.lambda_max;
    end
    if isfield(parms, 'flag_line_search')
        options.flag_line_search = parms.flag_line_search;
    end
    if isfield(parms, 'flag_x_error')
        options.flag_x_error = parms.flag_x_error;
        flag_x_error = parms.flag_x_error;
    else
        flag_x_error = 0;
    end
    if isfield(parms, 'flag_psi_error')
        options.flag_psi_error = parms.flag_psi_error;
        flag_psi_error = parms.flag_psi_error;
    else
        flag_psi_error = 0;
    end
    if isfield(parms, 'flag_time')
        options.flag_time = parms.flag_time;
        flag_time = parms.flag_time;
    else
        flag_time = 0;
    end
    if isfield(parms, 'Stopping_Crit')
        options.Stopping_Crit = parms.Stopping_Crit;
    end

    if strcmp(solver,'LLM_F') || strcmp(solver,'LLM_FY') || ...
       strcmp(solver,'LLM_YF') || strcmp(solver,'LLM') || ...
       strcmp(solver,'GLM_FY') ||strcmp(solver,'GLM_YF') || ...
       strcmp(solver,'LevMar') || strcmp(solver,'LMLS') || ...
       strcmp(solver,'LMTR')

        lin_sym_solver = ...
                      @ (varargin) lin_sym_solver_mldivide(varargin{:});
        mapp = @ (varargin) Rate_function1(opt, varargin{:});
    end

    switch solver

        case 'LLM_YF'
            fprintf('Running LLM_YF ...\n')
            options.lambda = 1;
            options.eta = 2;
            options.adaptive = 0;
            [x_best,psi_best,out] = ...
                                LLM(mapp, lin_sym_solver, x0, options);

        case 'LLM_FY'
            fprintf('Running LLM_FY ...\n')
            options.lambda = 1;
            options.eta = 1;
            options.adaptive = 0;
            [x_best,psi_best,out] = ...
                                LLM(mapp, lin_sym_solver, x0, options);

        case 'LLM_F'
            fprintf('Running LLM_F ...\n')
            options.lambda = 0;
            options.eta = 1;
            options.adaptive = 0;
            [x_best,psi_best,out] = ...
                                LLM(mapp, lin_sym_solver, x0, options);

        case 'LLM'
            fprintf('Running LLM ...\n')
            options.eta = 1.2;
            options.adaptive = 1;
            [x_best,psi_best,out] = ...
                                LLM(mapp, lin_sym_solver, x0, options);

        case 'GLM_YF'
            fprintf('Running GLM_YF ...\n')
            [x_best,psi_best,out] = ...
                             GLM_YF(mapp, lin_sym_solver, x0, options);

        case 'GLM_FY'
            fprintf('Running GLM_FY ...\n')
            [x_best,psi_best,out] = ...
                             GLM_FY(mapp, lin_sym_solver, x0, options);

        case 'LevMar'
            fprintf('Running LevMar ...\n')
            [x_best,psi_best,out] = ...
                             LevMar(mapp, lin_sym_solver, x0, options);

        case 'LMLS'
            fprintf('Running LMLS ...\n')
            options.eta = 1.2;
            options.adaptive = 1;
            [x_best,psi_best,out] = ...
                               LMLS(mapp, lin_sym_solver, x0, options);

        case 'LMTR'
            fprintf('Running LMTR ...\n')
            options.eta = 1.2;
            options.adaptive = 1;
            options.Stopping_Crit = 9;
            [x_best,psi_best,out] = ...
                               LMTR(mapp, lin_sym_solver, x0, options);

        case 'DCA'
            fprintf('Running DCA ...\n')
            options.F = F;
            options.R = R;
            options.rho = 100;
            [x_best,psi_best,out] = DCA(mapp, x0, options);

        case 'BDCA'
            fprintf('Running BDCA ...\n')
            options.F = F;
            options.R = R;
            [x_best,psi_best,out] = BDCA(mapp, x0, options);

        case 'BDF'
            fprintf('Running BDF ...\n')
            [x_best,psi_best,out] = BDF(mapp, x0, options);


        case 'CSDF'
            fprintf('Running CSDF ...\n')
            options.sigma = 1;
            options.l = 10;
            options.tauBar = 0.5;
            [x_best,psi_best,out] = CSDF(mapp, x0, options);


        case 'DBDF'
            fprintf('Running DBDF ...\n')
            [x_best,psi_best,out] = DBDF(mapp, x0, options);


    end

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Output %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

output.x_best = x_best;
output.psi_best = psi_best;
output.T = out.T;
output.merit_func = out.merit_func;
output.Niter = out.Niter;
output.Nmap = out.Nmap;
if isfield(out,'Ngmap')
    output.Ngmap = out.Ngmap;
end
output.Status = out.Status;
output.x_best = x_best;
output.x_best = x_best;

if flag_x_error == 1
    output.x_error = out.x_error;
end
if flag_psi_error == 1
    output.psi_error = out.psi_error;
end
if flag_time == 1
    output.Time = out.Time;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%% optimizeVKmodel.m %%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
