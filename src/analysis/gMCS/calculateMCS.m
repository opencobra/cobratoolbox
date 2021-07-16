function [mcs, mcs_time] = calculateMCS(model_struct, n_mcs, max_len_mcs, varargin)
% Calculate Minimal Cut Sets (MCSs) using the warm-start strategy available
% in CPLEX, namely cplex.populate(), with or without selecting a given
% knockout, among all the reactions included in the model or a given subset
% of them. Tobalina et al., 2016 (Bioinformatics); von Kamp and Klamt, 2014
% (PLoS Computational Biology).
%
% USAGE:
%
%    [mcs, mcs_time] = populateMCS(model_struct, n_mcs, max_len_mcs, options)
%
% INPUTS:
%    model_struct:    Metabolic model structure (COBRA Toolbox format).
%    n_mcs:           Number of MCSs to calculate.
%    max_len_mcs:     Number of reactions in the largest MCS to be calculated.
%
% OPTIONAL INPUT:
%    options:         Structure with fields:
%
%                       * .KO - Selected reaction knockout. Default: [].
%                       * .rxn_set - Cell array containing the set of
%                         reactions ('rxns') among which the MCSs are
%                         wanted to be calculated. Default: [] (all reactions
%                         are included).
%                       * .timelimit - Time limit for the calculation of MCSs
%                         each time the solver is called. Default: 1e75.
%                       * .target_b - Desired activity level of the metabolic
%                         task to be disrupted. Default: 1e-3;
%                       * .forceLength - 1 if the constraint limiting the
%                         length of the MCSs is to be active (recommended for
%                         enumerating low order MCSs), 0 otherwise.
%                         Default: 1.
%                       * .numWorkers  - is the maximun number of workers
%                       used by Cplex and GPR2models. 0 = automatic, 1 =
%                       sequential, >1 = parallel. Default = 0;
%                       * .printLevel - 1 if the process is wanted to be
%                         shown on the screen, 0 otherwise. Default: 1.
%
% OUTPUTS:
%    mcs:         Cell array containing the calculated MCSs.
%    mcs_time:    Calculation times of the different processes in
%                 the algorithm.
%
% EXAMPLE:
%    %With optional values
%    [mcs, mcs_time] = calculateMCS(modelR204, 100, 10, options)
%    %Being:
%    %options.KO = 'r1651'
%    %options.rxn_set = {'r1652'; 'r1653'; 'r1654'}
%    %options.timelimit = 300
%    %options.target_b = 1e-4
%    %options.forceLength = 0
%    %options.printLevel = 0
%
%    %Without optional values
%    [mcs, mcs_time] = calculateMCS(model, 100, 10)
%
% .. Authors:
%       - Inigo Apaolaza, 30/01/2017, University of Navarra, TECNUN School of Engineering.
%       - Luis V. Valcarcel, 19/11/2017, University of Navarra, TECNUN School of Engineering.
%       - Francisco J. Planes, 20/11/2017, University of Navarra, TECNUN School of Engineering.
% .. Revisions:
%       - Inigo Apaolaza, 10/04/2018, University of Navarra, TECNUN School of Engineering.
%       - Luis V. Valcarcel, 17/04/2018, University of Navarra, TECNUN School of Engineering.
%       - Luis V. Valcarcel, 30/06/2021, University of Navarra, TECNUN School of Engineering.

% Check the installation of cplex
global SOLVERS;
global CBT_MILP_SOLVER;
if SOLVERS.ibm_cplex.installed && SOLVERS.ibm_cplex.working
    if ~strcmp(CBT_MILP_SOLVER,'ibm_cplex')
        warning('calculateMCS will use IBM CPLEX although it is not selected for MILP')
    end
else
    error('This version calculateMCS only works with IBM CPLEX. Newer versions will include more solvers included in COBRA Toolbox')
end

time_aa = tic;
% Set Parameters
p = inputParser;
% check required arguments
addRequired(p, 'model_struct');
addRequired(p, 'n_mcs', @isnumeric);
addRequired(p, 'max_len_mcs', @isnumeric);
% Add optional name-value pair argument
addParameter(p, 'KO', [], @(x)ischar(x)||isempty(x));
addParameter(p, 'rxn_set', [], @(x)iscell(x)||isempty(x));
addParameter(p, 'target_b', 1e-3, @(x)isnumeric(x)&&isscalar(x));
addParameter(p, 'timelimit', 1e75, @(x)isnumeric(x)&&isscalar(x));
addParameter(p, 'forceLength', true, @(x)islogical(x)||(isnumeric(x)&&isscalar(x)));
addParameter(p, 'numWorkers', 0, @(x)isnumeric(x)&&isscalar(x));
addParameter(p, 'printLevel', 1, @(x)isnumeric(x)&&isscalar(x));
% extract variables from parser
parse(p, model_struct, n_mcs, max_len_mcs, varargin{:});
model_struct = p.Results.model_struct;
n_mcs = p.Results.n_mcs;
max_len_mcs = p.Results.max_len_gmcs;
KO = p.Results.KO;
rxn_set = p.Results.rxn_set;
target_b = p.Results.target_b;
timelimit = p.Results.timelimit;
forceLength = p.Results.forceLength;
numWorkers = p.Results.numWorkers;
printLevel = p.Results.printLevel;


integrality_tolerance = 1e-5;
M = 1e3;    % Big Value
alpha = 1;  % used to relate the lower bound of v variables with z variables
c = 1e-3;   % used to activate w variable
b = 1e-3;   % used to activate KnockOut constraint
phi = 1000; % b/c;

% Build the K Matrix
[~, n_ini_rxns] = size(model_struct.S);
K = speye(n_ini_rxns);

% Splitting
S = [model_struct.S -model_struct.S(:, model_struct.lb<0)];
K = [K K(:, model_struct.lb<0)];
K_ind = model_struct.rxns;
n_K_ind = length(K_ind);
[n_mets, n_rxns] = size(S);
nbio = find(model_struct.c);
t = zeros(n_rxns, 1);
t(nbio) = 1;

% Permit only KOs in rxn_set
if ~isempty(rxn_set)
    if ~isempty(KO)
        rxn_set = [rxn_set; {KO}];
    end
    rxn_set = unique(rxn_set);
    tmp_set = cellfun(@ismember, model_struct.rxns, repmat({rxn_set}, n_ini_rxns, 1), 'UniformOutput', false);
    pos_set = find(cell2mat(tmp_set));
    K = K(pos_set, :);
    K_ind = model_struct.rxns(pos_set);
    n_K_ind = length(K_ind);
end

if isempty(KO)
% ENUMERATE MCSs
% Define variables
    var.u = 1:n_mets;
    var.vp = var.u(end)+1:var.u(end)+n_K_ind;
    var.w = var.vp(end)+1:var.vp(end)+1;
    var.zp = var.w(end)+1:var.w(end)+n_K_ind;
    var.zw = var.zp(end)+1:var.zp(end)+1;
    n_vars = var.zw(end);
    var_group.v = [var.vp var.w];
    var_group.z = [var.zp var.zw];

% Define constraints
    cons.Ndual = 1:size(S, 2);
    cons.forceBioCons = cons.Ndual(end)+1:cons.Ndual(end)+1;
    cons.forceLength = cons.forceBioCons(end)+1:cons.forceBioCons(end)+1;
    n_cons = cons.forceLength(end);

% Cplex - A matrix
    A = sparse(zeros(n_cons, n_vars));
    A(cons.Ndual, var.u) = S';
    A(cons.Ndual, var.vp) = K';
    A(cons.Ndual, var.w) = -t;
    A(cons.forceBioCons, var.w) = -target_b;
    if forceLength == 1
        A(cons.forceLength, var.zp) = 1;
    end

% Cplex - rhs and lhs vectors
    rhs = zeros(n_cons, 1);
    rhs(cons.Ndual, 1) = inf;
    rhs(cons.forceBioCons) = -c;
    if forceLength == 1
        rhs(cons.forceLength) = 1;
    end
    lhs = zeros(n_cons, 1);
    lhs(cons.Ndual, 1) = 0;
    lhs(cons.forceBioCons) = -1000;
    if forceLength == 1
        lhs(cons.forceLength) = 1;
    end

% Cplex - ub and lb vectors
    ub(var.u, 1) = inf;
    ub(var.vp) = inf;
    ub(var.w) = inf;
    ub(var.zp) = 1;
    ub(var.zw) = 1;
    lb(var.u, 1) = -inf;
    lb(var.vp) = 0;
    lb(var.w) = 0;
    lb(var.zp) = 0;
    lb(var.zw) = 0;

% Cplex - obj vector
    obj(var.u, 1) = 0;
    obj(var.vp) = 0;
    obj(var.w) = 0;
    obj(var.zp) = 1;
    obj(var.zw) = 0;

% Cplex - ctype vector
    ctype(var.u) = 'C';
    ctype(var.vp) = 'C';
    ctype(var.w) = 'C';
    ctype(var.zp) = 'B';
    ctype(var.zw) = 'B';

% Cplex - sense of the optimization
    sense = 'minimize';

% Cplex - Introduce all data in a Cplex structure
    cplex = Cplex('MCS');
    Model = struct();
    [Model.A, Model.rhs, Model.lhs, Model.ub, Model.lb, Model.obj, Model.ctype, Model.sense] = deal(A, rhs, lhs, ub, lb, obj, ctype, sense);
    cplex.Model = Model;

% Cplex Indicators
    % z = 1  -->  v >= alpha
    for ivar = 1:length(var_group.z)
        a = zeros(n_vars, 1);
        a(var_group.v(ivar)) = 1;
        cplex.addIndicators(var_group.z(ivar), 0, a, 'G', alpha);
    end

% Cplex Indicators
    % z = 0  -->  v <= 0
    for ivar = 1:length(var_group.z)
        a = zeros(n_vars, 1);
        a(var_group.v(ivar)) = 1;
        cplex.addIndicators(var_group.z(ivar), 1, a, 'L', 0);
    end

% Cplex Parameters
    sP = struct();
    [sP.mip.tolerances.integrality, sP.mip.strategy.heuristicfreq, sP.mip.strategy.rinsheur] = deal(integrality_tolerance, 1000, 50);
    [sP.emphasis.mip, sP.output.clonelog, sP.timelimit, sP.threads] = deal(4, -1, max(10, timelimit), numWorkers);
    [sP.preprocessing.aggregator, sP.preprocessing.boundstrength, ...
        sP.preprocessing.coeffreduce, sP.preprocessing.dependency, ...
        sP.preprocessing.dual, sP.preprocessing.fill,...
        sP.preprocessing.linear, sP.preprocessing.numpass, ...
        sP.preprocessing.presolve, sP.preprocessing.reduce,..., ...
        sP.preprocessing.relax, sP.preprocessing.symmetry] = deal(50, 1, 2, 1, 1, 50, 1, 50, 1, 3, 1, 1);
    cplex = setCplexParam(cplex, sP);

    if printLevel == 0
        cplex.DisplayFunc = [];
    end

% Calculation of MCSs
    mcs_time{1, 1} = '------ TIMING ------';
    mcs_time{1, 2} = '--- MCSs ---';
    i = 0;
    k = 0;
    n_time = size(mcs_time, 1);
    mcs_time{n_time+1, 1} = 'Preparation';
    mcs_time{n_time+1, 2} = toc(time_aa);
    mcs = [];
    largest_mcs = 0;
    while largest_mcs <= max_len_mcs && k < n_mcs && cplex.Model.rhs(cons.forceLength) <= max_len_mcs
        ini_mcs_time = toc(time_aa);
        cplex.Param.mip.limits.populate.Cur = 40;
        cplex.Param.mip.pool.relgap.Cur = 0.1;
        cplex.populate();
        n_pool = size(cplex.Solution.pool.solution, 1);
        if n_pool ~= 0
            solution = cplex.Solution.pool.solution;
            for j = 1:n_pool
                k = k+1;
                mcs{k, 1} = K_ind((solution(j).x(var.zp))>0.9);
                n_cons = n_cons+1;
                sol = solution(j).x(var.zp)>0.9;
                cplex.Model.A(n_cons, var.zp) = sparse(double(sol));
                cplex.Model.rhs(n_cons) = sum(sol)-1;
                cplex.Model.lhs(n_cons) = 0;
            end
            i = i+1;
            mcsi_time = toc(time_aa)-ini_mcs_time;
            n_time = size(mcs_time, 1);
            mcs_time{n_time+1, 1} = ['POPULATE_ORDER_' num2str(cplex.Model.rhs(cons.forceLength))];
            mcs_time{n_time+1, 2} = mcsi_time;
        else
            mcsi_time = toc(time_aa)-ini_mcs_time;
            n_time = size(mcs_time, 1);
            mcs_time{n_time+1, 1} = ['POPULATE_ORDER_' num2str(cplex.Model.rhs(cons.forceLength)) 'NF'];
            mcs_time{n_time+1, 2} = mcsi_time;
            if forceLength == 1
                cplex.Model.rhs(cons.forceLength) = cplex.Model.rhs(cons.forceLength)+1;
                cplex.Model.lhs(cons.forceLength) = cplex.Model.lhs(cons.forceLength)+1;
            else
                n_time = size(mcs_time, 1);
                mcs_time{n_time+1, 1} = 'TOTAL MCSs';
                mcs_time{n_time+1, 2} = toc(time_aa);
                return;
            end
        end
        try save('tmp.mat', 'mcs', 'mcs_time'); end
        try largest_mcs = max(cellfun(@length, mcs)); end
    end
else
% CALCULATE MCSs WITH A GIVEN KNOCKOUT
% Select the row(s) in K_ind related to the KO under study
    tmp = repmat({KO}, n_K_ind, 1);
    dp = cellfun(@isequal, K_ind, tmp);

% Define variables
    var.u = 1:n_mets;
    var.vp = var.u(end)+1:var.u(end)+n_K_ind;
    var.w = var.vp(end)+1:var.vp(end)+1;
    var.zp = var.w(end)+1:var.w(end)+n_K_ind;
    var.zw = var.zp(end)+1:var.zp(end)+1;
    var.epsp = var.zw(end)+1:var.zw(end)+n_K_ind;
    var.epsw = var.epsp(end)+1:var.epsp(end)+1;
    var.delp = var.epsw(end)+1:var.epsw(end)+n_K_ind;
    var.delw = var.delp(end)+1:var.delp(end)+1;
    var.x = var.delw(end)+1:var.delw(end)+n_rxns+1;
    n_vars = var.x(end);
    var_group.v = [var.vp var.w];
    var_group.z = [var.zp var.zw];
    var_group.eps = [var.epsp var.epsw];
    var_group.del = [var.delp var.delw];

% Define constraints
    cons.Ndual = 1:size(S, 2);
    cons.forceBioCons = cons.Ndual(end)+1:cons.Ndual(end)+1;
    cons.forceKO = cons.forceBioCons(end)+1:cons.forceBioCons(end)+1;
    cons.linearComb = cons.forceKO(end)+1:cons.forceKO(end)+size(S, 1)+size(K, 1)+size(t, 2);
    cons.forceLength = cons.linearComb(end)+1:cons.linearComb(end)+1;
    n_cons = cons.forceLength(end);

% Cplex - A matrix
    A = sparse(zeros(n_cons, n_vars));
    A(cons.Ndual, var.u) = S';
    A(cons.Ndual, var.vp) = K';
    A(cons.Ndual, var.w) = -t;
    A(cons.forceBioCons, var.w) = -target_b;
    A(cons.forceKO, var.vp) = dp';
    A(cons.linearComb, var.x) = [S sparse(zeros(n_mets, 1)); K sparse(zeros(n_K_ind, 1)); -t' target_b];
    A(cons.linearComb, [var.epsp var.epsw]) = [sparse(zeros(n_mets, length(var.vp)+length(var.w))); -speye(length(var.vp)+length(var.w))];
    A(cons.linearComb, [var.delp var.delw]) = -[sparse(zeros(n_mets, length(var.vp)+length(var.w))); -speye(length(var.vp)+length(var.w))];
    if forceLength == 1
        A(cons.forceLength, var.zp) = 1;
    end

% Cplex - rhs and lhs vectors
    rhs = zeros(n_cons, 1);
    rhs(cons.Ndual, 1) = inf;
    rhs(cons.forceBioCons) = -c;
    rhs(cons.forceKO) = 10000;
    rhs(cons.linearComb) = [sparse(zeros(n_mets, 1)); dp; zeros(size(t, 2), 1)];
    if forceLength == 1
        rhs(cons.forceLength) = 1;
    end
    lhs = zeros(n_cons, 1);
    lhs(cons.Ndual, 1) = 0;
    lhs(cons.forceBioCons) = -1000;
    lhs(cons.forceKO) = b*10;
    lhs(cons.linearComb) = [sparse(zeros(n_mets, 1)); dp; zeros(size(t, 2), 1)];
    if forceLength == 1
        lhs(cons.forceLength) = 1;
    end

% Cplex - ub and lb vectors
    ub(var.u, 1) = inf;
    ub(var.vp) = inf;
    ub(var.w) = inf;
    ub(var.zp) = 1;
    ub(var.zw) = 1;
    ub(var.epsp) = inf;
    ub(var.epsw) = 0;
    ub(var.delp) = inf;
    ub(var.delw) = 0;
    ub(var.x) = inf;
    lb(var.u, 1) = -inf;
    lb(var.vp) = 0;
    lb(var.w) = 0;
    lb(var.zp) = 0;
    lb(var.zw) = 0;
    lb(var.epsp) = 0;
    lb(var.epsw) = 0;
    lb(var.delp) = 0;
    lb(var.delw) = 0;
    lb(var.x) = 0;
    lb(var.x(end)) = phi;

% Cplex - obj vector
    obj(var.u, 1) = 0;
    obj(var.vp) = 0;
    obj(var.w) = 0;
    obj(var.zp) = 1;
    obj(var.zw) = 0;
    obj(var.epsp) = 0;
    obj(var.epsw) = 0;
    obj(var.delp) = 0;
    obj(var.delw) = 0;
    obj(var.x) = 0;

% Cplex - ctype vector
    ctype(var.u) = 'C';
    ctype(var.vp) = 'C';
    ctype(var.w) = 'C';
    ctype(var.zp) = 'B';
    ctype(var.zw) = 'B';
    ctype(var.epsp) = 'C';
    ctype(var.epsw) = 'C';
    ctype(var.delp) = 'C';
    ctype(var.delw) = 'C';
    ctype(var.x) = 'C';

% Cplex - sense of the optimization
    sense = 'minimize';

% Cplex - Introduce all data in a Cplex structure
    cplex = Cplex('MCS');
    Model = struct();
    [Model.A, Model.rhs, Model.lhs, Model.ub, Model.lb, Model.obj, Model.ctype, Model.sense] = deal(A, rhs, lhs, ub, lb, obj, ctype, sense);
    cplex.Model = Model;

% Cplex Indicators
    % z = 1  -->  v >= alpha
    for ivar = 1:length(var_group.z)
        a = zeros(var.x(end), 1);
        a(var_group.v(ivar)) = 1;
        cplex.addIndicators(var_group.z(ivar), 0, a, 'G', alpha);
    end

% Cplex Indicators
    % z = 0  -->  v <= 0
    for ivar = 1:length(var_group.z)
        a = zeros(var.x(end), 1);
        a(var_group.v(ivar)) = 1;
        cplex.addIndicators(var_group.z(ivar), 1, a, 'L', 0);
    end

% Cplex Indicators
    % z = 1  -->  epsilon <= 0
    for ivar = 1:length(var_group.z)
        a = zeros(var.x(end), 1);
        a(var_group.eps(ivar)) = 1;
        cplex.addIndicators(var_group.z(ivar), 0, a, 'L', 0);
    end

% Cplex Indicators
    % z = 0  -->  epsilon <= M
    for ivar = 1:length(var_group.z)
        a = zeros(var.x(end), 1);
        a(var_group.eps(ivar)) = 1;
        cplex.addIndicators(var_group.z(ivar), 1, a, 'L', M);
    end

% Cplex Parameters
    sP = struct();
    [sP.mip.tolerances.integrality, sP.mip.strategy.heuristicfreq, sP.mip.strategy.rinsheur] = deal(integrality_tolerance, 1000, 50);
    [sP.emphasis.mip, sP.output.clonelog, sP.timelimit, sP.threads] = deal(4, -1, max(10, timelimit), numWorkers);
    [sP.preprocessing.aggregator, sP.preprocessing.boundstrength, ...
        sP.preprocessing.coeffreduce, sP.preprocessing.dependency, ...
        sP.preprocessing.dual, sP.preprocessing.fill,...
        sP.preprocessing.linear, sP.preprocessing.numpass, ...
        sP.preprocessing.presolve, sP.preprocessing.reduce,..., ...
        sP.preprocessing.relax, sP.preprocessing.symmetry] = deal(50, 1, 2, 1, 1, 50, 1, 50, 1, 3, 1, 1);
    cplex = setCplexParam(cplex, sP);
    if printLevel == 0
        cplex.DisplayFunc = [];
    end

% Calculation of MCSs
    mcs_time{1, 1} = '------ TIMING ------';
    mcs_time{1, 2} = '--- MCSs ---';
    i = 0;
    k = 0;
    n_time = size(mcs_time, 1);
    mcs_time{n_time+1, 1} = 'Preparation';
    mcs_time{n_time+1, 2} = toc(time_aa);
    mcs = [];
    largest_mcs = 0;
    while largest_mcs <= max_len_mcs && k < n_mcs && cplex.Model.rhs(cons.forceLength) <= max_len_mcs
        ini_mcs_time = toc(time_aa);
        cplex.Param.mip.limits.populate.Cur = 40;
        cplex.Param.mip.pool.relgap.Cur = 0.1;
        cplex.populate();
        n_pool = size(cplex.Solution.pool.solution, 1);
        if n_pool ~= 0
            solution = cplex.Solution.pool.solution;
            for j = 1:n_pool
                k = k+1;
                mcs{k, 1} = K_ind((solution(j).x(var.zp))>0.9);
                n_cons = n_cons+1;
                sol = solution(j).x(var.zp)>0.9;
                cplex.Model.A(n_cons, var.zp) = sparse(double(sol));
                cplex.Model.rhs(n_cons) = sum(sol)-1;
                cplex.Model.lhs(n_cons) = 0;
            end
            i = i+1;
            mcsi_time = toc(time_aa)-ini_mcs_time;
            n_time = size(mcs_time, 1);
            mcs_time{n_time+1, 1} = ['POPULATE_ORDER_' num2str(cplex.Model.rhs(cons.forceLength))];
            mcs_time{n_time+1, 2} = mcsi_time;
        else
            mcsi_time = toc(time_aa)-ini_mcs_time;
            n_time = size(mcs_time, 1);
            mcs_time{n_time+1, 1} = ['POPULATE_ORDER_' num2str(cplex.Model.rhs(cons.forceLength)) 'NF'];
            mcs_time{n_time+1, 2} = mcsi_time;
            if forceLength == 1
                cplex.Model.rhs(cons.forceLength) = cplex.Model.rhs(cons.forceLength)+1;
                cplex.Model.lhs(cons.forceLength) = cplex.Model.lhs(cons.forceLength)+1;
            else
                n_time = size(mcs_time, 1);
                mcs_time{n_time+1, 1} = 'TOTAL MCSs';
                mcs_time{n_time+1, 2} = toc(time_aa);
                return;
            end
        end
        try save('tmp.mat', 'mcs', 'mcs_time'); end
        try largest_mcs = max(cellfun(@length, mcs)); end
    end
end
n_time = size(mcs_time, 1);
mcs_time{n_time+1, 1} = 'TOTAL MCSs';
mcs_time{n_time+1, 2} = toc(time_aa);
end
