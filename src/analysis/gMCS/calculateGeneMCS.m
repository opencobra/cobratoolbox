function [gmcs, gmcs_time] = calculateGeneMCS(model_name, model_struct, n_gmcs, options)
% Calculate Genetic Minimal Cut Sets (gMCSs): Calculate Minimal Cut Sets at
% the gene level (minimal gene knockout interventions), with or without
% selecting a given knockout, among all the genes included in the model or
% a given subset of them. Apaolaza et al., 2017 (Nature Communications).
% 
% USAGE:
% 
%    [gmcs, gmcs_time] = calculateGeneMCS(model_name, model_struct, n_gmcs, options)
% 
% INPUTS:
%    model_name:      Name of the metabolic model under study (in order to
%                     identify the G matrix).
%    model_struct:    Metabolic model structure (COBRA Toolbox format).
%    n_gmcs:          Number of gMCSs to calculate.
% 
% OPTIONAL INPUT:
%    options:    Structure with fields:
% 
%                  * .KO - Selected gene knockout. Default [].
%                  * .gene_set - Set of genes among which the gMCSs are 
%                    wanted to be calculated. Default [].
%                  * .timelimit - Time limit for the calculation of each
%                    gMCS in seconds. Default maximum permited by solver.
%                  * .target_b - Desired activity level of the metabolic
%                    task to be disrupted (i.e. biomass reaction). Default 1e-3.
%                  * .separate_transcript - Character used to discriminate
%                    different transcripts of a gene. Default ''.
%                    Example: separate_transcript = ''      
%                                   gene 10005.1    ==>    gene 10005.1    
%                                   gene 10005.2    ==>    gene 10005.2
%                                   gene 10005.3    ==>    gene 10005.3 
%                             separate_transcript = '.'      
%                                   gene 10005.1    
%                                   gene 10005.2    ==>    gene 10005 
%                                   gene 10005.3
%                  * .printLevel - Printing level 
%                      * 0 - Silent (Default)
%                      * 1 - Warnings and Errors
%                      * 2 - Summary information
%                      * 3 - More detailed information
%                      * > 10 - Pause statements, and maximal printing (debug mode)
% 
% OUTPUTS:
%    gmcs:         Cell array containing the calculated gMCSs.
%    gmcs_time:    Calculation times of the different processes in 
%                  the algorithm.
% 
% EXAMPLE:
%    %With optional values
%    [gmcs, gmcs_time] = calculateGeneMCS('Recon2.v04', modelR204, 100, options)
%    %Being:
%    %options.KO = '6240'
%    %options.gene_set = {'54675'; '259230'; '2987'; '60386 '; '1841'; '50484'; '6241'}
%    %options.timelimit = 300
%    %options.separate_transcript = '.'
% 
%    %Without optional values 
%    [gmcs, gmcs_time] = calculateGeneMCS('ecoli_core_model', model, 10)
% 
% .. Authors:
%       - Iñigo Apaolaza, 16/11/2017, University of Navarra, TECNUN School of Engineering.
%       - Luis V. Valcarcel, 18/11/2017, University of Navarra, TECNUN School of Engineering.
%       - Francisco J. Planes, 21/11/2017, University of Navarra, TECNUN School of Engineering.

tic
% Optional inputs
if nargin == 3
    KO = [];
    gene_set = [];
    target_b = 1e-3;
    separate_transcript = '';
    printLevel = 0;
else
    if isfield(options, 'KO')
        KO = options.KO;
    else
        KO = [];
    end
    if isfield(options, 'gene_set')
        gene_set = options.gene_set;
    else
        gene_set = [];
    end
    if isfield(options, 'timelimit')
        changeCobraSolverParams('MILP', 'timeLimit', options.timelimit);
    end
    if isfield(options, 'target_b')
        target_b = options.target_b;
    else
        target_b = 1e-3;
    end
    if isfield(options, 'separate_transcript')
        separate_transcript = options.separate_transcript;
    else
        separate_transcript = '';
    end
    if isfield(options, 'printLevel')
        printLevel = options.printLevel;
    else
        printLevel = 0;
    end
end

% Set Parameters
M = 1e5;
alpha = 1;
c = 1e-3;
b = 1e-3;
phi = 1000;

% Load or Build the G Matrix
G_file = ['G_' model_name '.mat'];
if exist(G_file) == 2
    load(G_file)
else
    [G, G_ind, related, n_genes_KO, G_time] = buildGmatrix(model_name, model_struct, separate_transcript);
end
len_KO = cellfun(@length, G_ind);
n_poss_KO = length(G_ind);
n_relations = size(related, 1);
tmp_gMCS_time = toc;
gmcs_time{1, 1} = 'G - Step 1';
gmcs_time{2, 1} = 'G - Step 2';
gmcs_time{3, 1} = 'G - Step 3';
gmcs_time{4, 1} = 'G - Step 4';
gmcs_time{5, 1} = 'Total Build G Matrix';
gmcs_time(1:4, 2) = mat2cell(G_time, ones(4, 1), 1);
gmcs_time{5, 2} = tmp_gMCS_time;

% Permit only some KOs in G_ind
if ~isempty(gene_set)
    if ~isempty(KO)
        gene_set = [gene_set; {KO}];
    end
    gene_set = unique(gene_set);
    tmp_set = cellfun(@ismember, G_ind, repmat({gene_set}, n_poss_KO, 1), 'UniformOutput', false);
    tmp_set = cellfun(@sum, tmp_set);
    pos_set = find(tmp_set == len_KO);
    G = G(pos_set, :);
    G_ind = G_ind(pos_set);
    n_genes_KO = n_genes_KO(pos_set);
    n_poss_KO = length(G_ind);    
    cell_related_1 = mat2cell(related(:, 1), ones(size(related, 1), 1), 1);
    cell_pos_set = mat2cell(pos_set, ones(n_poss_KO, 1), 1);
    cell_related_1 = cellfun(@num2str, cell_related_1, 'UniformOutput', false);    
    cell_pos_set = cellfun(@num2str, cell_pos_set, 'UniformOutput', false);
    tmp_related_1 = cellfun(@ismember, cell_related_1, repmat({cell_pos_set}, size(related, 1), 1), 'UniformOutput', false);
    tmp_related_1 = logical(cell2mat(tmp_related_1));
    related = related(tmp_related_1, :);
    n_relations = size(related, 1);    
    pos_set(:, 2) = 1:length(pos_set);
    tmp_related = related(:);
    n_tmp_related = length(tmp_related);
    for i = 1:n_tmp_related
        pos = find(pos_set(:, 1) == tmp_related(i));
        tmp_related(i) = pos_set(pos, 2);
    end
    related = tmp_related(1:n_tmp_related/2);
    related(:, 2) = tmp_related(n_tmp_related/2+1:end);
end

% Splitting
S = [model_struct.S -model_struct.S(:, model_struct.lb<0)];
G = [G G(:, model_struct.lb<0)];
[n_mets, n_rxns] = size(S);
nbio = find(model_struct.c);
t = zeros(n_rxns, 1);
t(nbio) = 1;

if isempty(KO)
% ENUMERATE gMCSs
% Define variables
    var.u = 1:n_mets;
    var.vp = var.u(end)+1:var.u(end)+n_poss_KO;
    var.w = var.vp(end)+1:var.vp(end)+1;
    var.zp = var.w(end)+1:var.w(end)+n_poss_KO;
    var.zw = var.zp(end)+1:var.zp(end)+1;
    n_vars = var.zw(end);
    var_group.v = [var.vp var.w];
    var_group.z = [var.zp var.zw];

% Define constraints
    cons.Ndual = 1:size(S, 2);
    cons.forceBioCons = cons.Ndual(end)+1:cons.Ndual(end)+1;
    cons.linkAlpha = cons.forceBioCons(end)+1:cons.forceBioCons(end)+length(var.zp)+length(var.zw);
    cons.linkM = cons.linkAlpha(end)+1:cons.linkAlpha(end)+length(var.zp)+length(var.zw);
    if n_relations > 0
        cons.relations = cons.linkM(end)+1:cons.linkM(end)+n_relations;    
        n_cons = cons.relations(end);
    else
        n_cons = cons.linkM(end);
    end

% A matrix
    A = sparse(zeros(n_cons, n_vars));
    A(cons.Ndual, var.u) = S';
    A(cons.Ndual, var.vp) = G';
    A(cons.Ndual, var.w) = -t;
    A(cons.forceBioCons, var.w) = -target_b;
    A(cons.linkAlpha, [var.vp var.w]) = speye(length(var.vp)+length(var.w));
    A(cons.linkAlpha, [var.zp var.zw]) = -alpha*speye(length(var.zp)+length(var.zw));
    A(cons.linkM, [var.vp var.w]) = speye(length(var.vp)+length(var.w));
    A(cons.linkM, [var.zp var.zw]) = -M*speye(length(var.zp)+length(var.zw));
    if n_relations > 0
        for i = 1:n_relations
            A(cons.relations(i), var.zp(related(i, 1))) = -1;
            A(cons.relations(i), var.zp(related(i, 2))) = 1;
        end
    end

% rhs vector
    rhs = zeros(n_cons, 1);
    rhs(cons.Ndual, 1) = 0;
    rhs(cons.forceBioCons) = -c;
    rhs(cons.linkAlpha) = 0;
    rhs(cons.linkM) = 0;
    rhs(cons.relations) = 0;

% csense vector
    csense(cons.Ndual) = 'G';
    csense(cons.forceBioCons) = 'L';
    csense(cons.linkAlpha) = 'G';
    csense(cons.linkM) = 'L';
    csense(cons.relations) = 'G';

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
    obj(var.zp) = n_genes_KO;
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
    showprogress(0, ['Calculating ' num2str(n_gmcs) ' gMCSs...']);
    for i = 1:n_gmcs
        showprogress(i/n_gmcs);
        ini_gmcs_time = toc;
        tmp_sol_gmcs = solveCobraMILP(MILPproblem, 'printLevel', printLevel);
        if tmp_sol_gmcs.stat == 1
            tmp_gmcs = G_ind((tmp_sol_gmcs.full(var.zp))>0.9);
            tmp_gmcs = [tmp_gmcs{:}];
            gmcs{i, 1} = unique(tmp_gmcs)';
            gmcsi_time = toc-ini_gmcs_time;
            n_time = size(gmcs_time, 1);
            gmcs_time{n_time+1, 1} = ['gMCS_' num2str(i)];
            gmcs_time{n_time+1, 2} = gmcsi_time;
        else
            gmcs{i, 1} = NaN;
            gmcsi_time = toc-ini_gmcs_time;
            n_time = size(gmcs_time, 1);
            gmcs_time{n_time+1, 1} = ['gMCS_' num2str(i)];
            gmcs_time{n_time+1, 2} = gmcsi_time;
            n_time = size(gmcs_time, 1);
            gmcs_time{n_time+1, 1} = 'Total Time gMCS';
            gmcs_time{n_time+1, 2} = toc;
            fprintf('\nAll existing gMCSs have been calculated.\n');
            return
        end        
        sol = tmp_sol_gmcs.full(var.zp)>0.9;
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
% Select the Row in G_ind related to the KO under study
    dp = double(cellfun(@sum, cellfun(@ismember, G_ind, repmat({KO}, n_poss_KO, 1), 'UniformOutput', false))>0);
    dp = dp*10; % To improve the solving process. It doesn't affect to the solution.

% Define variables
    var.u = 1:n_mets;
    var.vp = var.u(end)+1:var.u(end)+n_poss_KO;
    var.w = var.vp(end)+1:var.vp(end)+1;
    var.zp = var.w(end)+1:var.w(end)+n_poss_KO;
    var.zw = var.zp(end)+1:var.zp(end)+1;
    var.epsp = var.zw(end)+1:var.zw(end)+n_poss_KO;
    var.epsw = var.epsp(end)+1:var.epsp(end)+1;
    var.delp = var.epsw(end)+1:var.epsw(end)+n_poss_KO;
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
    cons.linearComb = cons.linkM(end)+1:cons.linkM(end)+size(S, 1)+size(G, 1)+size(t, 2);
    cons.link_z_eps_del = cons.linearComb(end)+1:cons.linearComb(end)+length(var.zp)+length(var.zw);
    if n_relations > 0
        cons.relations = cons.link_z_eps_del(end)+1:cons.link_z_eps_del(end)+n_relations;    
        n_cons = cons.relations(end);
    else
        n_cons = cons.link_z_eps_del(end);
    end

% A matrix
    A = sparse(zeros(cons.link_z_eps_del(end), var.x(end)));
    A(cons.Ndual, var.u) = S';
    A(cons.Ndual, var.vp) = G';
    A(cons.Ndual, var.w) = -t;
    A(cons.forceBioCons, var.w) = -target_b;
    A(cons.linkAlpha, [var.vp var.w]) = speye(length(var.vp)+length(var.w));
    A(cons.linkAlpha, [var.zp var.zw]) = -alpha*speye(length(var.zp)+length(var.zw));
    A(cons.linkM, [var.vp var.w]) = speye(length(var.vp)+length(var.w));
    A(cons.linkM, [var.zp var.zw]) = -M*speye(length(var.zp)+length(var.zw));
    A(cons.forceKO, var.vp) = dp';
    A(cons.linearComb, var.x) = [S sparse(zeros(n_mets, 1)); G sparse(zeros(n_poss_KO, 1)); -t' target_b];
    A(cons.linearComb, [var.epsp var.epsw]) = [sparse(zeros(n_mets, length(var.vp)+length(var.w))); -speye(length(var.vp)+length(var.w))];
    A(cons.linearComb, [var.delp var.delw]) = -[sparse(zeros(n_mets, length(var.vp)+length(var.w))); -speye(length(var.vp)+length(var.w))];
    A(cons.link_z_eps_del, [var.zp var.zw]) = M*speye(length(var.zp)+length(var.zw));
    A(cons.link_z_eps_del, [var.epsp var.epsw]) = speye(length(var.vp)+length(var.w));
    A(cons.link_z_eps_del, [var.delp var.delw]) = speye(length(var.vp)+length(var.w));
    if n_relations > 0
        for i = 1:n_relations
            A(cons.relations(i), var.zp(related(i, 1))) = -1;
            A(cons.relations(i), var.zp(related(i, 2))) = 1;
        end
    end

% rhs vector
    rhs(cons.Ndual, 1) = 0;
    rhs(cons.forceBioCons) = -c;
    rhs(cons.forceKO) = b*10;
    rhs(cons.linkAlpha) = 0;
    rhs(cons.linkM) = 0;
    rhs(cons.linearComb) = [sparse(zeros(n_mets, 1)); dp; zeros(size(t, 2), 1)];
    rhs(cons.link_z_eps_del) = M;
    rhs(cons.relations) = 0;
    
% csense vector
    csense(cons.Ndual, 1) = 'G';
    csense(cons.forceBioCons) = 'L';
    csense(cons.forceKO) = 'G';
    csense(cons.linkAlpha) = 'G';
    csense(cons.linkM) = 'L';
    csense(cons.linearComb) = 'E';
    csense(cons.link_z_eps_del) = 'L';
    csense(cons.relations) = 'G';

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

% Cplex - obj vector
    obj(var.u, 1) = 0;
    obj(var.vp) = 0;
    obj(var.w) = 0;
    obj(var.zp) = n_genes_KO;
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
    showprogress(0, ['Calculating ' num2str(n_gmcs) ' gMCSs...']);
    for i = 1:n_gmcs
        showprogress(i/n_gmcs);
        ini_gmcs_time = toc;
        tmp_sol_gmcs = solveCobraMILP(MILPproblem, 'printLevel', printLevel);
        if tmp_sol_gmcs.stat == 1
            tmp_gmcs = G_ind((tmp_sol_gmcs.full(var.zp))>0.9);
            tmp_gmcs = [tmp_gmcs{:}];
            gmcs{i, 1} = unique(tmp_gmcs)';
            gmcsi_time = toc-ini_gmcs_time;
            n_time = size(gmcs_time, 1);
            gmcs_time{n_time+1, 1} = ['gMCS_' num2str(i)];
            gmcs_time{n_time+1, 2} = gmcsi_time;
        else
            gmcs{i, 1} = NaN;
            gmcsi_time = toc-ini_gmcs_time;
            n_time = size(gmcs_time, 1);
            gmcs_time{n_time+1, 1} = ['gMCS_' num2str(i)];
            gmcs_time{n_time+1, 2} = gmcsi_time;
            n_time = size(gmcs_time, 1);
            gmcs_time{n_time+1, 1} = 'Total Time gMCS';
            gmcs_time{n_time+1, 2} = toc;
            fprintf('\nAll existing gMCSs have been calculated.\n');
            return
        end        
        sol = tmp_sol_gmcs.full(var.zp)>0.9;
        n_cons = n_cons+1;
        A(n_cons, var.zp) = sparse(double(sol));
        rhs(n_cons) = sum(sol)-1;
        csense(n_cons) = 'L';
        MILPproblem.A = A;
        MILPproblem.b = rhs;
        MILPproblem.csense = csense;
    end
end
n_time = size(gmcs_time, 1);
gmcs_time{n_time+1, 1} = 'Total Time gMCS';
gmcs_time{n_time+1, 2} = toc;
end