function [gmcs, gmcs_time] = calculateGeneMCS(model_name, model_struct, n_gmcs, max_len_gmcs, varargin)
% Calculate genetic Minimal Cut Sets (gMCSs) using the warm-start strategy
% available in CPLEX, namely cplex.populate(), with or without selecting a
% given knockout, among all the genes included in the model or a given
% subset of them. Apaolaza et al., 2017 (Nature Communications).
%
% USAGE:
%
%    [gmcs, gmcs_time] = calculateGeneMCS(model_name, model_struct, n_gmcs, max_len_gmcs, varargin)
%
% INPUTS:
%    model_name:      Name of the metabolic model under study (in order to
%                     identify the G matrix).
%    model_struct:    Metabolic model structure (COBRA Toolbox format).
%    n_gmcs:          Number of gMCSs to calculate.
%    max_len_gmcs:    Number of genes in the largest gMCS to be calculated.
%
% OPTIONAL INPUTS:
%    KO:                 Selected gene knockout. (default = [])
%    gene_set:           Cell array containing the set of genes among which
%                        the gMCSs are wanted to be calculated.
%                        (default = [], all genes)
%    target_b:           Desired activity level of the metabolic task to be
%                        disrupted. (default = 1e-3)
%    nutrientGMCS:       Boolean variable.  0 to calculate GeneMCS, 1 to 
%                        calculate MCS containing genes and nutrients, 
%                        known as ngMCS. (default = false)
%    exchangeRxns:       Cell array containing the set of reactions to be
%                        included as inputs of nutrients from the cell
%                        environment / culture medium. (default = [], which
%                        are all reactions with only one 1 metabolite
%                        consiedered as input for the model)
%    onlyNutrients:      Boolean variable.  1 to calculate MCS only using 
%                        selected KO and nutrients, 0 to use everything. 
%                        If there is no KO selected, it is set to false.
%                        (default = false)
%    separate_transcript:Character used to separate
%                        different transcripts of a gene. (default = '')
%                        Examples:
%                          - separate_transcript = ''
%                             - gene 10005.1    ==>    gene 10005.1
%                             - gene 10005.2    ==>    gene 10005.2
%                             - gene 10005.3    ==>    gene 10005.3
%                          - separate_transcript = '.'
%                             - gene 10005.1
%                             - gene 10005.2    ==>    gene 10005
%                             - gene 10005.3
%    forceLength:        1 if the constraint limiting the length of the 
%                        gMCSs is to be active (recommended for
%                        enumerating low order gMCSs), 0 otherwise 
%                        (default = 1)
%    timelimit:          Time limit for the calculation of gMCSs each time 
%                        the solver is called. (default = 1e75)
%    numWorkers:         Integer: is the maximun number of workers used 
%                        by Cplex and GPR2models. 0 = automatic, 
%                        1 = sequential, > 1 = parallel. (default = 0)
%    printLevel:         Integer. 1 if the process is wanted to be shown
%                        on the screen, 0 otherwise. (default = 1)
%
% OUTPUTS:
%    gmcs:         Cell array containing the calculated gMCSs.
%    gmcs_time:    Calculation times of the different processes in
%                  the algorithm.
%
% EXAMPLE:
%    %With optional values
%    [gmcs, gmcs_time] = calculateGeneMCS('Recon2.v04', modelR204, 100, 10, ...
%                                           'KO' = '6240', ...
%                                           'gene_set' = {'2987'; '6241'},  ...
%                                           'timelimit' = 300,  ...
%                                           'target_b' = 1e-4, 
%                                           'separate_transcript' = '.',  ...
%                                           'forceLength' = 0, ...
%                                           'printLevel' = 0)
%
%    %Without optional values
%    [gmcs, gmcs_time] = calculateGeneMCS('ecoli_core_model', model, 100, 10)
%
% .. Authors:
%       - Inigo Apaolaza, 30/01/2017, University of Navarra, TECNUN School of Engineering.
%       - Luis V. Valcarcel, 19/11/2017, University of Navarra, TECNUN School of Engineering.
%       - Francisco J. Planes, 20/11/2017, University of Navarra, TECNUN School of Engineering.
% .. Revisions:
%       - Inigo Apaolaza, 10/04/2018, University of Navarra, TECNUN School of Engineering.
%       - Luis V. Valcarcel, 17/04/2018, University of Navarra, TECNUN School of Engineering.
%       - Luis V. Valcarcel, 20/04/2021, University of Navarra, TECNUN School of Engineering.

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

p = inputParser;
% check required arguments
addRequired(p, 'model_name', @(x)ischar(x));
addRequired(p, 'model_struct');
addRequired(p, 'n_gmcs', @isnumeric);
addRequired(p, 'max_len_gmcs', @isnumeric);
% Add optional name-value pair argument
addParameter(p, 'KO', [], @(x)ischar(x)||isempty(x));
addParameter(p, 'gene_set', [], @(x)iscell(x)||isempty(x));
addParameter(p, 'target_b', 1e-3, @(x)isnumeric(x)&&isscalar(x));
addParameter(p, 'timelimit', 1e75, @(x)isnumeric(x)&&isscalar(x));
addParameter(p, 'forceLength', true, @(x)islogical(x)||(isnumeric(x)&&isscalar(x)));
addParameter(p, 'separate_transcript', '', @(x)ischar(x));
addParameter(p, 'numWorkers', 0, @(x)isnumeric(x)&&isscalar(x));
addParameter(p, 'printLevel', 1, @(x)isnumeric(x)&&isscalar(x));
addParameter(p, 'nutrientGMCS', false, @(x)islogical(x)||(isnumeric(x)&&isscalar(x)));
addParameter(p, 'exchangeRxns', [], @(x)iscell(x)||isempty(x));
addParameter(p, 'onlyNutrients', false, @(x)islogical(x)||(isnumeric(x)&&isscalar(x)));
% extract variables from parser
parse(p, model_name, model_struct, n_gmcs, max_len_gmcs, varargin{:});
model_name = p.Results.model_name;
model_struct = p.Results.model_struct;
n_gmcs = p.Results.n_gmcs;
max_len_gmcs = p.Results.max_len_gmcs;
KO = p.Results.KO;
gene_set = p.Results.gene_set;
target_b = p.Results.target_b;
timelimit = p.Results.timelimit;
forceLength = p.Results.forceLength;
separate_transcript = p.Results.separate_transcript;
numWorkers = p.Results.numWorkers;
printLevel = p.Results.printLevel;
nutrientGMCS = p.Results.nutrientGMCS;
exchangeRxns = p.Results.exchangeRxns;
onlyNutrients = p.Results.onlyNutrients;

% Define parameters for the gMCSs
integrality_tolerance = 1e-5;
M = 1e3;    % Big Value
alpha = 1;  % used to relate the lower bound of v variables with z variables
c = 1e-3;   % used to activate w variable
b = 1e-3;   % used to activate KnockOut constraint
phi = 1000; % b/c;


% Prepare model for ngMCS
if nutrientGMCS
    model_struct = prepareModelNutrientGeneMCS(model_struct, exchangeRxns);
    if onlyNutrients && ~isempty(KO)
        % select only artificial genes for nutrients
        gene_set = model_struct.genes(startsWith(model_struct.genes, 'gene_'));
    end
end

% Load or Build the G Matrix
G_file = [pwd filesep 'G_' model_name '.mat'];
if exist(G_file) == 2
    load(G_file)
else
    [G, G_ind, related, n_genes_KO, G_time] = buildGmatrix(model_name, model_struct, separate_transcript, numWorkers, printLevel);
    assert(size(G,2) == numel(model_struct.rxns));
end
gmcs_time{1, 1} = '------ TIMING ------';
gmcs_time{1, 2} = '--- G MATRIX ---';
gmcs_time{2, 1} = 'G - Step 1';
gmcs_time{3, 1} = 'G - Step 2';
gmcs_time{4, 1} = 'G - Step 3';
gmcs_time{5, 1} = 'G - Step 4';
gmcs_time{6, 1} = 'G - Others';
gmcs_time{7, 1} = 'TOTAL G MATRIX';
gmcs_time(2:6, 2) = mat2cell(G_time, ones(5, 1), 1);
gmcs_time{7, 2} = sum(G_time);
gmcs_time{9, 1} = '------ TIMING ------';
gmcs_time{9, 2} = '---- gMCSs ----';
time_aa = tic;
len_KO = cellfun(@length, G_ind);
n_poss_KO = length(G_ind);
if isnan(related)
    n_relations = 0;
else
    n_relations = size(related, 1);
end

% Permit only KOs in gene_set
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
    if n_relations > 0
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
    if n_relations > 0
        cons.relations = cons.forceBioCons(end)+1:cons.forceBioCons(end)+n_relations;
        cons.forceLength = cons.relations(end)+1:cons.relations(end)+1;
    else
        cons.forceLength = cons.forceBioCons(end)+1:cons.forceBioCons(end)+1;
    end
    n_cons = cons.forceLength(end);

% Cplex - A matrix
    A = sparse(zeros(n_cons, n_vars));
    A(cons.Ndual, var.u) = S';
    A(cons.Ndual, var.vp) = G';
    A(cons.Ndual, var.w) = -t;
    A(cons.forceBioCons, var.w) = -target_b;
    if n_relations > 0
        for i = 1:n_relations
            A(cons.relations(i), var.zp(related(i, 1))) = -1;
            A(cons.relations(i), var.zp(related(i, 2))) = 1;
        end
    end
    if forceLength == 1
        A(cons.forceLength, var.zp) = n_genes_KO;
    end

% Cplex - rhs and lhs vectors
    rhs = zeros(n_cons, 1);
    rhs(cons.Ndual, 1) = inf;
    rhs(cons.forceBioCons) = -c;
    try rhs(cons.relations) = inf; end
    if forceLength == 1
        rhs(cons.forceLength) = 1;
    end
    lhs = zeros(n_cons, 1);
    lhs(cons.Ndual, 1) = 0;
    lhs(cons.forceBioCons) = -1000;
    try lhs(cons.relations) = 0; end
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
    obj(var.zp) = n_genes_KO;
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
    cplex = Cplex('geneMCS');
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

% Calculation of gMCSs
    i = 0;
    k = 0;
    n_time = size(gmcs_time, 1);
    gmcs_time{n_time+1, 1} = 'Preparation';
    gmcs_time{n_time+1, 2} = toc(time_aa);
    gmcs = [];
    largest_gmcs = 0;
    while largest_gmcs <= max_len_gmcs && cplex.Model.rhs(cons.forceLength) <= max_len_gmcs && k < n_gmcs
        ini_gmcs_time = toc(time_aa);
        cplex.Param.mip.limits.populate.Cur = 40;
        cplex.Param.mip.pool.relgap.Cur = 0.1;
        cplex.populate();
        n_pool = size(cplex.Solution.pool.solution, 1);
        if n_pool ~= 0
            solution = cplex.Solution.pool.solution;
            for j = 1:n_pool
                k = k+1;
                tmp_gmcs = G_ind((solution(j).x(var.zp))>0.9);
                tmp_gmcs = [tmp_gmcs{:}];
                gmcs{k, 1} = unique(tmp_gmcs)';
                n_cons = n_cons+1;
                sol = solution(j).x(var.zp)>0.9;
                cplex.Model.A(n_cons, var.zp) = sparse(double(sol));
                cplex.Model.rhs(n_cons) = sum(sol)-1;
                cplex.Model.lhs(n_cons) = 0;
            end
            i = i+1;
            gmcsi_time = toc(time_aa)-ini_gmcs_time;
            n_time = size(gmcs_time, 1);
            gmcs_time{n_time+1, 1} = ['POPULATE_ORDER_' num2str(cplex.Model.rhs(cons.forceLength))];
            gmcs_time{n_time+1, 2} = gmcsi_time;
        else
            gmcsi_time = toc(time_aa)-ini_gmcs_time;
            n_time = size(gmcs_time, 1);
            gmcs_time{n_time+1, 1} = ['POPULATE_ORDER_' num2str(cplex.Model.rhs(cons.forceLength)) 'NF'];
            gmcs_time{n_time+1, 2} = gmcsi_time;
            if forceLength == 1
                cplex.Model.rhs(cons.forceLength) = cplex.Model.rhs(cons.forceLength)+1;
                cplex.Model.lhs(cons.forceLength) = cplex.Model.lhs(cons.forceLength)+1;
            else
                n_time = size(gmcs_time, 1);
                gmcs_time{n_time+1, 1} = 'TOTAL gMCSs';
                gmcs_time{n_time+1, 2} = toc(time_aa);
                return;
            end
        end
        try disp(['Number of gMCS saved: ' num2str(length(gmcs))]); end
        try save('tmp.mat', 'gmcs', 'gmcs_time'); end
        try largest_gmcs = max(cellfun(@length, gmcs)); end
    end
else
% CALCULATE gMCSs WITH A GIVEN KNOCKOUT
% Select the row(s) in G_ind related to the KO under study
    n_G_ind = length(G_ind);
    tmp = repmat({KO}, n_G_ind, 1);
    dp = cellfun(@ismember, tmp, G_ind);

% Define variables
    var.u = 1:n_mets;
    var.vp = var.u(end)+1:var.u(end)+n_G_ind;
    var.w = var.vp(end)+1:var.vp(end)+1;
    var.zp = var.w(end)+1:var.w(end)+n_G_ind;
    var.zw = var.zp(end)+1:var.zp(end)+1;
    var.epsp = var.zw(end)+1:var.zw(end)+n_G_ind;
    var.epsw = var.epsp(end)+1:var.epsp(end)+1;
    var.delp = var.epsw(end)+1:var.epsw(end)+n_G_ind;
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
    cons.linearComb = cons.forceKO(end)+1:cons.forceKO(end)+size(S, 1)+size(G, 1)+size(t, 2);
    if n_relations > 0
        cons.relations = cons.linearComb(end)+1:cons.linearComb(end)+n_relations;
        cons.forceLength = cons.relations(end)+1:cons.relations(end)+1;
    else
        cons.forceLength = cons.linearComb(end)+1:cons.linearComb(end)+1;
    end
    n_cons = cons.forceLength(end);

% Cplex - A matrix
    A = sparse(zeros(n_cons, n_vars));
    A(cons.Ndual, var.u) = S';
    A(cons.Ndual, var.vp) = G';
    A(cons.Ndual, var.w) = -t;
    A(cons.forceBioCons, var.w) = -target_b;
    A(cons.forceKO, var.vp) = dp';
    A(cons.linearComb, var.x) = [S sparse(zeros(n_mets, 1)); G sparse(zeros(n_G_ind, 1)); -t' target_b];
    A(cons.linearComb, [var.epsp var.epsw]) = [sparse(zeros(n_mets, length(var.vp)+length(var.w))); -speye(length(var.vp)+length(var.w))];
    A(cons.linearComb, [var.delp var.delw]) = -[sparse(zeros(n_mets, length(var.vp)+length(var.w))); -speye(length(var.vp)+length(var.w))];
    if n_relations > 0
        for i = 1:n_relations
            A(cons.relations(i), var.zp(related(i, 1))) = -1;
            A(cons.relations(i), var.zp(related(i, 2))) = 1;
        end
    end
    if forceLength == 1
        A(cons.forceLength, var.zp) = 1;
    end

% Cplex - rhs and lhs vectors
    rhs = zeros(n_cons, 1);
    rhs(cons.Ndual, 1) = inf;
    rhs(cons.forceBioCons) = -c;
    rhs(cons.forceKO) = 10000;
    rhs(cons.linearComb) = [sparse(zeros(n_mets, 1)); dp; zeros(size(t, 2), 1)];
    try rhs(cons.relations) = inf; end
    if forceLength == 1
        rhs(cons.forceLength) = 1;
    end
    lhs = zeros(n_cons, 1);
    lhs(cons.Ndual, 1) = 0;
    lhs(cons.forceBioCons) = -1000;
    lhs(cons.forceKO) = b*10;
    lhs(cons.linearComb) = [sparse(zeros(n_mets, 1)); dp; zeros(size(t, 2), 1)];
    try lhs(cons.relations) = 0; end
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

% Cplex - sense of the optimization
    sense = 'minimize';

% Cplex - Introduce all data in a Cplex structure
    cplex = Cplex('geneMCS');
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

% Calculation of gMCSs
    i = 0;
    k = 0;
    n_time = size(gmcs_time, 1);
    gmcs_time{n_time+1, 1} = 'Preparation';
    gmcs_time{n_time+1, 2} = toc(time_aa);
    gmcs = [];
    largest_gmcs = 0;
    while largest_gmcs <= max_len_gmcs && cplex.Model.rhs(cons.forceLength) <= max_len_gmcs && k < n_gmcs
        ini_gmcs_time = toc(time_aa);
        cplex.Param.mip.limits.populate.Cur = 40;
        cplex.Param.mip.pool.relgap.Cur = 0.1;
        cplex.populate();
        n_pool = size(cplex.Solution.pool.solution, 1);
        if n_pool ~= 0
            solution = cplex.Solution.pool.solution;
            for j = 1:n_pool
                k = k+1;
                tmp_gmcs = G_ind((solution(j).x(var.zp))>0.9);
                tmp_gmcs = [tmp_gmcs{:}];
                gmcs{k, 1} = unique(tmp_gmcs)';
                n_cons = n_cons+1;
                sol = solution(j).x(var.zp)>0.9;
                cplex.Model.A(n_cons, var.zp) = sparse(double(sol));
                cplex.Model.rhs(n_cons) = sum(sol)-1;
                cplex.Model.lhs(n_cons) = 0;
            end
            i = i+1;
            gmcsi_time = toc(time_aa)-ini_gmcs_time;
            n_time = size(gmcs_time, 1);
            gmcs_time{n_time+1, 1} = ['POPULATE_ORDER_' num2str(cplex.Model.rhs(cons.forceLength))];
            gmcs_time{n_time+1, 2} = gmcsi_time;
        else
            gmcsi_time = toc(time_aa)-ini_gmcs_time;
            n_time = size(gmcs_time, 1);
            gmcs_time{n_time+1, 1} = ['POPULATE_ORDER_' num2str(cplex.Model.rhs(cons.forceLength)) 'NF'];
            gmcs_time{n_time+1, 2} = gmcsi_time;
            if forceLength == 1
                cplex.Model.rhs(cons.forceLength) = cplex.Model.rhs(cons.forceLength)+1;
                cplex.Model.lhs(cons.forceLength) = cplex.Model.lhs(cons.forceLength)+1;
            else
                n_time = size(gmcs_time, 1);
                gmcs_time{n_time+1, 1} = 'TOTAL gMCSs';
                gmcs_time{n_time+1, 2} = toc(time_aa);
                return;
            end
        end
        try disp(['Number of gMCS saved: ' num2str(length(gmcs))]); end
        try save('tmp.mat', 'gmcs', 'gmcs_time'); end
        try largest_gmcs = max(cellfun(@length, gmcs)); end
    end
end
n_time = size(gmcs_time, 1);
gmcs_time{n_time+1, 1} = 'TOTAL gMCSs';
gmcs_time{n_time+1, 2} = toc(time_aa);
end
