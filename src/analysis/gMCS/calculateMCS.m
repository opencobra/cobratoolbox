function [mcs, mcs_time] = calculateMCS(model_struct, n_mcs, options)
% Calculate Minimal Cut Sets (MCSs): Calculate Minimal Cut Sets at the
% reaction level (minimal reaction knockout interventions), with or without
% selecting a given knockout, among all the reactions included in the model
% or a given subset of them. Tobalina et al., 2016 (Bioinformatics);
% von Kamp and Klamt, 2014 (PLoS Computational Biology).
% 
% USAGE:
% 
%    [mcs, mcs_time] = calculateMCS(model_struct, n_mcs, options)
% 
% INPUTS:
%    model_struct:    Metabolic model structure (COBRA Toolbox format).
%    n_mcs:           Number of MCSs to calculate.
% 
% OPTIONAL INPUT:
%    options:         Structure with fields:
% 
%                       * .KO - Selected reaction knockout. Default [].
%                       * .rxn_set - Cell array containing the set of 
%                         reactions ('rxns') among which the MCSs are 
%                         wanted to be calculated. Default [].
%                       * .timelimit - Time limit for the calculation of each
%                         MCS in seconds. Default: maximum permited by solver.
%                       * .target_b - Desired activity level of the metabolic
%                         task to be disrupted. Default 1e-3;
%                       * .printLevel - Printing level 
%                           * 0 - Silent (Default)
%                           * 1 - Warnings and Errors
%                           * 2 - Summary information
%                           * 3 - More detailed information
%                           * > 10 - Pause statements, and maximal printing (debug mode)
% 
% OUTPUTS:
%    mcs:         Structure containing the calculated MCSs.
%    mcs_time:    Calculation times of the different processes in 
%                 the algorithm.
% 
% EXAMPLE:
%    %With optional values
%    [mcs, mcs_time] = calculateMCS(modelR204, 100, options)
%    %Being:
%    %options.KO = 'r1651'
%    %options.rxn_set = {'r1652'; 'r1653'; 'r1654'}
%    %options.timelimit = 300
%    %options.target_b = 1e-4
% 
%    %Without optional values 
%    [mcs, mcs_time] = calculateMCS(model, 10)
% 
% .. Authors:
%       - Iñigo Apaolaza, 16/11/2017, University of Navarra, TECNUN School of Engineering.
%       - Luis V. Valcarcel, 18/11/2017, University of Navarra, TECNUN School of Engineering.
%       - Francisco J. Planes, 20/11/2017, University of Navarra, TECNUN School of Engineering.

tic
% Optional inputs
if nargin == 2
    KO = [];
    rxn_set = [];
    target_b = 1e-3;
    printLevel = 0;
else
    if isfield(options, 'KO')
        KO = options.KO;
    else
        KO = [];
    end
    if isfield(options, 'rxn_set')
        rxn_set = options.rxn_set;
    else
        rxn_set = [];
    end
    if isfield(options, 'timelimit')
        changeCobraSolverParams('MILP', 'timeLimit', options.timelimit);
    end
    if isfield(options, 'target_b')
        target_b = options.target_b;
    else
        target_b = 1e-3;
    end
    if isfield(options, 'printLevel')
        printLevel = options.printLevel;
    else
        printLevel = 0;
    end
end

% Set Parameters
M = 1e5;    % Big Value
alpha = 1;  % used to relate the lower bound of v variables with z variables
c = 1e-3;   % used to activate w variable
b = 1e-3;   % used to activate KnockOut constraint
phi = 1000; % b/c;

% Build the K Matrix
[~, n_ini_rxns] = size(model_struct.S);
K = eye(n_ini_rxns);

% Splitting
S = [model_struct.S -model_struct.S(:, model_struct.lb<0)];
K = [K K(:, model_struct.lb<0)];
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
else
    K_ind = model_struct.rxns;
    n_K_ind = length(K_ind);
end

if isempty(KO)
% ENUMERATE gMCSs
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
    cons.linkAlpha = cons.forceBioCons(end)+1:cons.forceBioCons(end)+length(var.zp)+length(var.zw);
    cons.linkM = cons.linkAlpha(end)+1:cons.linkAlpha(end)+length(var.zp)+length(var.zw);
    n_cons = cons.linkM(end);

% A matrix
    A = sparse(zeros(n_cons, n_vars));
    A(cons.Ndual, var.u) = S';
    A(cons.Ndual, var.vp) = K';
    A(cons.Ndual, var.w) = -t;
    A(cons.forceBioCons, var.w) = -target_b;
    A(cons.linkAlpha, [var.vp var.w]) = speye(length(var.vp)+length(var.w));
    A(cons.linkAlpha, [var.zp var.zw]) = -alpha*speye(length(var.zp)+length(var.zw));
    A(cons.linkM, [var.vp var.w]) = speye(length(var.vp)+length(var.w));
    A(cons.linkM, [var.zp var.zw]) = -M*speye(length(var.zp)+length(var.zw));

% rhs vector
    rhs = zeros(n_cons, 1);
    rhs(cons.Ndual, 1) = 0;
    rhs(cons.forceBioCons) = -c;
    rhs(cons.linkAlpha) = 0;
    rhs(cons.linkM) = 0;

% csense vector
    csense(cons.Ndual, 1) = 'G';
    csense(cons.forceBioCons) = 'L';
    csense(cons.linkAlpha) = 'G';
    csense(cons.linkM) = 'L';

% ub and lb vectors
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

% obj vector
    obj(var.u, 1) = 0;
    obj(var.vp) = 0;
    obj(var.w) = 0;
    obj(var.zp) = 1;
    obj(var.zw) = 0;

% ctype vector
    ctype(var.u) = 'C';
    ctype(var.vp) = 'C';
    ctype(var.w) = 'C';
    ctype(var.zp) = 'B';
    ctype(var.zw) = 'B';

% Introduce all data in a structure
    MILPproblem.A = A;
    MILPproblem.b = rhs;
    MILPproblem.c = obj;
    MILPproblem.lb = lb;
    MILPproblem.ub = ub;
    MILPproblem.csense = csense;
    MILPproblem.vartype = ctype;
    MILPproblem.osense = 1;
    MILPproblem.x0 = [];

% Solve the problem
    mcs_time = [];
    showprogress(0, ['Calculating ' num2str(n_mcs) ' MCSs...']);
    for i = 1:n_mcs
        showprogress(i/n_mcs);
        ini_mcs_time = toc;
        tmp_sol_mcs = solveCobraMILP(MILPproblem, 'printLevel', printLevel);
        if tmp_sol_mcs.stat == 1
            mcs{i, 1} = K_ind((tmp_sol_mcs.full(var.zp))>0.9);
            mcsi_time = toc-ini_mcs_time;
            n_time = size(mcs_time, 1);
            mcs_time{n_time+1, 1} = ['MCS_' num2str(i)];
            mcs_time{n_time+1, 2} = mcsi_time;
        else
            mcs{i, 1} = NaN;
            mcsi_time = toc-ini_mcs_time;
            n_time = size(mcs_time, 1);
            mcs_time{n_time+1, 1} = ['MCS_' num2str(i)];
            mcs_time{n_time+1, 2} = mcsi_time;
            n_time = size(mcs_time, 1);
            mcs_time{n_time+1, 1} = 'Total Time MCS';
            mcs_time{n_time+1, 2} = toc;
            fprintf('\nAll existing MCSs have been calculated.\n');
            return
        end        
        sol = tmp_sol_mcs.full(var.zp)>0.9;
        n_cons = n_cons+1;
        A(n_cons, var.zp) = sparse(double(sol));
        rhs(n_cons) = sum(sol)-1;
        csense(n_cons) = 'L';
        MILPproblem.A = A;
        MILPproblem.b = rhs;
        MILPproblem.csense = csense;
    end
else
% CALCULATE gMCSs WITH A GIVEN KNOCK-OUT
% Select the Row in K_ind related to the KO under study
    tmp = repmat({KO}, n_K_ind, 1);
    dp = cellfun(@isequal, K_ind, tmp);
    dp = dp*10; % To improve the solving process. It doesn't affect to the solution.

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
    cons.linkAlpha = cons.forceKO(end)+1:cons.forceKO(end)+length(var.zp)+length(var.zw);
    cons.linkM = cons.linkAlpha(end)+1:cons.linkAlpha(end)+length(var.zp)+length(var.zw);
    cons.linearComb = cons.linkM(end)+1:cons.linkM(end)+size(S, 1)+size(K, 1)+size(t, 2);
    cons.link_z_eps_del = cons.linearComb(end)+1:cons.linearComb(end)+length(var.zp)+length(var.zw);
    n_cons = cons.link_z_eps_del(end);

% A matrix
    A = sparse(zeros(cons.link_z_eps_del(end), var.x(end)));
    A(cons.Ndual, var.u) = S';
    A(cons.Ndual, var.vp) = K';
    A(cons.Ndual, var.w) = -t;
    A(cons.forceBioCons, var.w) = -target_b;
    A(cons.linkAlpha, [var.vp var.w]) = speye(length(var.vp)+length(var.w));
    A(cons.linkAlpha, [var.zp var.zw]) = -alpha*speye(length(var.zp)+length(var.zw));
    A(cons.linkM, [var.vp var.w]) = speye(length(var.vp)+length(var.w));
    A(cons.linkM, [var.zp var.zw]) = -M*speye(length(var.zp)+length(var.zw));
    A(cons.forceKO, var.vp) = dp';
    A(cons.linearComb, var.x) = [S sparse(zeros(n_mets, 1)); K sparse(zeros(n_K_ind, 1)); -t' target_b];
    A(cons.linearComb, [var.epsp var.epsw]) = [sparse(zeros(n_mets, length(var.vp)+length(var.w))); -speye(length(var.vp)+length(var.w))];
    A(cons.linearComb, [var.delp var.delw]) = -[sparse(zeros(n_mets, length(var.vp)+length(var.w))); -speye(length(var.vp)+length(var.w))];
    A(cons.link_z_eps_del, [var.zp var.zw]) = M*speye(length(var.zp)+length(var.zw));
    A(cons.link_z_eps_del, [var.epsp var.epsw]) = speye(length(var.vp)+length(var.w));
    A(cons.link_z_eps_del, [var.delp var.delw]) = speye(length(var.vp)+length(var.w));

% rhs vector
    rhs(cons.Ndual, 1) = 0;
    rhs(cons.forceBioCons) = -c;
    rhs(cons.forceKO) = b*10;
    rhs(cons.linkAlpha) = 0;
    rhs(cons.linkM) = 0;
    rhs(cons.linearComb) = [sparse(zeros(n_mets, 1)); dp; zeros(size(t, 2), 1)];
    rhs(cons.link_z_eps_del) = M;
    
% csense vector
    csense(cons.Ndual, 1) = 'G';
    csense(cons.forceBioCons) = 'L';
    csense(cons.forceKO) = 'G';
    csense(cons.linkAlpha) = 'G';
    csense(cons.linkM) = 'L';
    csense(cons.linearComb) = 'E';
    csense(cons.link_z_eps_del) = 'L';

% ub and lb vectors
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

% obj vector
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

% ctype vector
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

% Introduce all data in a structure
    MILPproblem.A = A;
    MILPproblem.b = rhs;
    MILPproblem.c = obj;
    MILPproblem.lb = lb;
    MILPproblem.ub = ub;
    MILPproblem.csense = csense;
    MILPproblem.vartype = ctype;
    MILPproblem.osense = 1;
    MILPproblem.x0 = [];

% Solve the problem
    mcs_time = [];
    showprogress(0, ['Calculating ' num2str(n_mcs) ' MCSs...']);
    for i = 1:n_mcs
        showprogress(i/n_mcs);
        ini_mcs_time = toc;
        tmp_sol_mcs = solveCobraMILP(MILPproblem, 'printLevel', printLevel);
        if tmp_sol_mcs.stat == 1
            mcs{i, 1} = K_ind((tmp_sol_mcs.full(var.zp))>0.9);
            mcsi_time = toc-ini_mcs_time;
            n_time = size(mcs_time, 1);
            mcs_time{n_time+1, 1} = ['MCS_' num2str(i)];
            mcs_time{n_time+1, 2} = mcsi_time;
        else
            mcs{i, 1} = NaN;
            mcsi_time = toc-ini_mcs_time;
            n_time = size(mcs_time, 1);
            mcs_time{n_time+1, 1} = ['MCS_' num2str(i)];
            mcs_time{n_time+1, 2} = mcsi_time;
            n_time = size(mcs_time, 1);
            mcs_time{n_time+1, 1} = 'Total Time MCS';
            mcs_time{n_time+1, 2} = toc;
            fprintf('\nAll existing MCSs have been calculated.\n');
            return
        end        
        sol = tmp_sol_mcs.full(var.zp)>0.9;
        n_cons = n_cons+1;
        A(n_cons, var.zp) = sparse(double(sol));
        rhs(n_cons) = sum(sol)-1;
        csense(n_cons) = 'L';
        MILPproblem.A = A;
        MILPproblem.b = rhs;
        MILPproblem.csense = csense;
    end
end
n_time = size(mcs_time, 1);
mcs_time{n_time+1, 1} = 'Total Time MCS';
mcs_time{n_time+1, 2} = toc;
end