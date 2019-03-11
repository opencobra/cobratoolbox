function [TSscore, deletedGenes, Vres] = rMTA(model, rxnFBS, Vref, varargin)
% Calculate robust Metabolic Transformation Analysis (rMTA) using the
% solver CPLEX.
% Code was prepared to be able to be stopped and be launched again by using
% a temporally file called 'temp_rMTA.mat'.
% Outputs are cell array for each alpha (one simulation by alpha). It
% there is only one alpha, content of cell will be returned
%
% USAGE:
%
%    [TSscore,deletedGenes,Vout] = rMTA(model, rxnFBS, Vref, alpha, epsilon, varargin)
%
% INPUTS:
%    model:              Metabolic model structure (COBRA Toolbox format).
%    rxnFBS:             Array that contains the desired change: Forward,
%                        Backward and Unchanged (+1;0;-1). This is calculated
%                        from the rules and differential expression analysis.
%    Vref:               Reference flux of the source state.
%
% OPTIONAL INPUTS:
%    alpha:              Numeric value or array. Parameter of the quadratic
%                        problem (default = 0.66)
%    epsilon:            Numeric value or array. Minimun perturbation for each
%                        reaction (default = 0)
%    parameterK:         Numeric value value. Parameter to calculate rTS 
%                        score. (default = 100)
%    rxnKO:              Binary value. Calculate knock outs at reaction level
%                        instead of gene level. (default = false)
%    listKO:             Cell array containing the name of genes or 
%                        reactions to knockout. (default = all)
%    timelimit:          Time limit for the calculation of each knockout. (default = inf)
%    SeparateTranscript: Character used to separate
%                        different transcripts of a gene. (default = '')
%                        Examples:
%                          - SeparateTranscript = ''
%                             - gene 10005.1    ==>    gene 10005.1
%                             - gene 10005.2    ==>    gene 10005.2
%                             - gene 10005.3    ==>    gene 10005.3
%                          - SeparateTranscript = '.'
%                             - gene 10005.1
%                             - gene 10005.2    ==>    gene 10005
%                             - gene 10005.3
%    numWorkers:         Integer: is the maximun number of workers
%                        used by the solver. 0 = automatic, 1 = sequential,
%                        > 1 = parallel. (default = 0)
%    printLevel:         Integer. 1 if the process is wanted to be shown
%                        on the screen, 0 otherwise. (default = 1)
%
% OUTPUTS:
%    TSscore:            Transformation score by each transformation
%    deletedGenes:       The list of genes/reactions removed in each knock-out
%    Vref:               Matrix of resulting fluxes
%
% .. Authors:
%       - Luis V. Valcarcel, 03/06/2015, University of Navarra, CIMA & TECNUN School of Engineering.
%       - Luis V. Valcarcel, 26/10/2018, University of Navarra, CIMA & TECNUN School of Engineering.
%       - Francisco J. Planes, 26/10/2018, University of Navarra, TECNUN School of Engineering.

p = inputParser;
% check required arguments
addRequired(p, 'model');
addRequired(p, 'rxnFBS',@isnumeric);
addRequired(p, 'Vref',@isnumeric);
% Check optional arguments
addOptional(p, 'alpha', 0.66, @isnumeric);
addOptional(p, 'epsilon', 0, @isnumeric);
% Add optional name-value pair argument
addParameter(p, 'parameterK', 100, @(x)isnumeric(x)&&isscalar(x));
addParameter(p, 'rxnKO', false);
addParameter(p, 'listKO', {}, @(x)iscell(x));
addParameter(p, 'timelimit', inf, @(x)isnumeric(x)&&isscalar(x));
addParameter(p, 'SeparateTranscript', '', @(x)ischar(x));
addParameter(p, 'numWorkers', 0, @(x)isnumeric(x)&&isscalar(x));
addParameter(p, 'printLevel', 1, @(x)isnumeric(x)&&isscalar(x));
addParameter(p, 'deprecated_rTS', 0, @(x)islogical(x)||isscalar(x));
% extract variables from parser
parse(p, model, rxnFBS, Vref, varargin{:});
alpha = p.Results.alpha;
epsilon = p.Results.epsilon;
parameterK = p.Results.parameterK;
rxnKO = p.Results.rxnKO;
listKO = p.Results.listKO;
timelimit = p.Results.timelimit;
SeparateTranscript = p.Results.SeparateTranscript;
numWorkers = p.Results.numWorkers;
printLevel = p.Results.printLevel;
deprecated_rTS = p.Results.deprecated_rTS;

if printLevel >0
    fprintf('===================================\n');
    fprintf('========  rMTA algorithm  =========\n');
    fprintf('===================================\n');
    fprintf('Step 0: preprocessing: \n');
end


%% Initialize variables or load previously ones
%  Check if there are any temporary files with the rMTA information

num_alphas = numel(alpha);

% Calculate perturbation matrix
if rxnKO
    geneKO.genes = model.rxns;
    geneKO.rxns = model.rxns;
    geneKO.matrix = speye(numel(model.rxns));
else
    geneKO = calculateGeneKOMatrix(model, SeparateTranscript, printLevel);
end

% Reduce the to the number of requiered KOs
if ~isempty(listKO)
    if  rxnKO
        listKO = unique(listKO);
        assert(all(ismember(listKO,geneKO.genes)), 'Reactions in listKO are not in the model');
    elseif isempty(SeparateTranscript)
        listKO = unique(listKO);
        assert(all(ismember(listKO,geneKO.genes)), 'Genes in listKO are not in the model');
    else
        listKO = unique(strtok(listKO,SeparateTranscript));
        assert(all(ismember(listKO,geneKO.genes)), 'Genes in listKO are not in the model');
    end
    idx = ismember(geneKO.genes,listKO);
    geneKO.genes = geneKO.genes(idx);
    geneKO.matrix = geneKO.matrix(:,idx);
end

% Reduce the size of the problem;
geneKO2 = geneKO;
[geneKO.matrix,geneKO.IA,geneKO.IC ] = unique(geneKO.matrix','rows');
geneKO.matrix = geneKO.matrix';
geneKO.genes = num2cell((1:length(geneKO.IA))');


if ~exist('temp_rMTA.mat','file')
    % Boolean variable for each case
    best = false;
    moma = false;
    worst = false;
    % counters
    i = 0;          % counter for best scenario
    i_alpha = 0;    % counter for best scenario alphas
    j = 0;          % counter for moma scenario
    k = 0;          % counter for worst scenario
    k_alpha = 0;    % counter for worst scenario alphas
    % scores
    score_best = zeros(numel(geneKO.genes),num_alphas);
    score_moma = zeros(numel(geneKO.genes),1);
    score_worst = zeros(numel(geneKO.genes),num_alphas);
    % fluxes
    Vres = struct();
    Vres.bMTA = cell(num_alphas,1);
    Vres.bMTA(:) = {zeros(numel(model.rxns),numel(geneKO.genes))};
    Vres.mMTA = zeros(numel(model.rxns),numel(geneKO.genes));
    Vres.wMTA = cell(num_alphas,1);
    Vres.wMTA(:) = {zeros(numel(model.rxns),numel(geneKO.genes))};
else
    load('temp_rMTA.mat');
    i_alpha = max(i_alpha-1,0);
    i = max(i-100,0);
    k_alpha = max(k_alpha-1,0);
    k = max(k-100,0);
end

if printLevel >0
    fprintf('-------------------\n');
end

%% ---- STEP 1 : The best scenario: bMTA ----

if printLevel >0
    fprintf('Step 1 in progress: the best scenario \n');
end
timerVal = tic;

% treat rxnFBS to remove impossible changes
rxnFBS_best = rxnFBS;
rxnFBS_best(rxnFBS_best==-1 & abs(Vref)<1e-6 & model.lb==0) = 0;
clear v_res

if best
    if printLevel >0
        fprintf('\tAll MIQP for all alphas performed\n');
    end
else
    while i_alpha < num_alphas
        i_alpha = i_alpha + 1;
        if printLevel >0
            fprintf('\tStart rMTA best scenario case for alpha = %1.2f \n',alpha(i_alpha));
        end

        % Create the CPLEX model
        CplexModelBest = buildMTAproblemFromModel(model, rxnFBS_best, Vref, alpha(i_alpha), epsilon);
        if printLevel >0
            fprintf('\tcplex model for MTA built\n');
        end

        % perform the MIQP problem for each rxn's knock-out
        if printLevel >0
            showprogress(0, '    MIQP Iterations for bMTA');
        end
        while i < length(geneKO.genes)
            for w = 1:100
                i = i+1;
                KOrxn = find(geneKO.matrix(:,i));
                v_res = MTA_MIQP (CplexModelBest, KOrxn, 'numWorkers', numWorkers, 'timelimit', timelimit, 'printLevel', printLevel);
                Vres.bMTA{i_alpha}(:,i) = v_res;
                if ~isempty(KOrxn) && norm(v_res)>1
                    score_best(i,i_alpha) = MTA_TS(v_res,Vref,rxnFBS_best);
                else
                    % if we knock off the system, invalid solution
                    % remove perturbations with no effect score
                    score_best(i,i_alpha) = -Inf;
                end
                if printLevel >0
                    showprogress(i/length(geneKO.genes), '    MIQP Iterations for bMTA');
                end
                % Condition to exit the for loop
                if i == length(geneKO.genes)
                    break;
                end
            end
            try save('temp_rMTA.mat', 'i','j','k','i_alpha','k_alpha','best','moma','worst','score_best','score_moma','score_worst','Vres'); end
        end
        clear cplex_model
        if printLevel >0
            fprintf('\tAll MIQP problems performed\n');
        end
        i = 0;
    end
    best = true;
end

time_best = toc(timerVal);
if printLevel >0
    fprintf('\tStep 1 time: %4.2f seconds = %4.2f minutes\n',time_best,time_best/60);
end
try save('temp_rMTA.mat', 'i','j','k','i_alpha','k_alpha','best','moma','worst','score_best','score_moma','score_worst','Vres'); end
fprintf('-------------------\n');


%% ---- STEP 2 : MOMA ----
% MOMA is the most robust result

fprintf('Step 2 in progress: MOMA\n');
timerVal = tic;

QPproblem = buildLPproblemFromModel(model);
[~,nRxns] = size(model.S);
[~,nVars] = size(QPproblem.A);
QPproblem.c(1:nRxns) = -2*Vref;
QPproblem.F = sparse(nVars,nVars);
QPproblem.F(1:nRxns,1:nRxns) = 2*speye(nRxns);
QPproblem.osense = +1; %'minimize'
fprintf('\tQPproblem model for MOMA built\n');

% perform the MOMA problem for each rxn's knock-out
clear v_res success unsuccess

if moma
    if printLevel >0
        fprintf('\tAll MOMA problems performed\n');
    end
else
    if printLevel >0
        showprogress(0, '    QP Iterations for MTA');
    end
    while j < length(geneKO.genes)
        for w = 1:100
            j = j+1;
            KOrxn = find(geneKO.matrix(:,j));
            clear QPproblem_aux
            QPproblem_aux = QPproblem;
            QPproblem_aux.ub(KOrxn) = 0;
            QPproblem_aux.lb(KOrxn) = 0;
            MOMAsolution = solveCobraQP(QPproblem_aux, 'printLevel', 0);
            % if we knock off the system, invalid solution
            if MOMAsolution.stat==(+1) || MOMAsolution.stat==(-1)
                v_res = MOMAsolution.full;
                Vres.mMTA(:,j) = v_res;
                if ~isempty(KOrxn) && norm(v_res)<1    % the norm(Vref) ~= 1e4
                    score_moma(j) = -Inf;
                else
                    % remove inactive reactions score
                    score_moma(j) = MTA_TS(v_res,Vref,rxnFBS_best);
                end
            else
                Vres.mMTA(:,j) = 0;
                score_moma(j) = -Inf;
            end
            clear v_aux success
            if printLevel >0
                showprogress(j/length(geneKO.genes), '    QP Iterations for MTA');
            end
            % Condition to exit the for loop
            if j == length(geneKO.genes)
                break;
            end
        end
        try save('temp_rMTA.mat', 'i','j','k','i_alpha','k_alpha','best','moma','worst','score_best','score_moma','score_worst','Vres'); end
    end
    clear cplex_model cplex_moma
    if printLevel >0
        fprintf('\tAll MOMA problems performed\n');
    end
    moma = true;
end

time_moma = toc(timerVal);
if printLevel >0
    fprintf('\tStep 2 time: %4.2f seconds = %4.2f minutes\n',time_moma,time_moma/60);
end
try save('temp_rMTA.mat', 'i','j','k','best','moma','worst','score_best','score_moma','score_worst','Vres'); end
fprintf('-------------------\n');


%% ---- STEP 3 : The worst scenario ----
% Worst scenario is MTA but maximizing the changes in the wrong
% sense

if printLevel >0
    fprintf('Step 3 in progress: the worst scenario \n');
end
timerVal = tic;

%generate the worst rxnFBS
rxnFBS_worst = -rxnFBS;
rxnFBS_worst(rxnFBS_worst==-1 & abs(Vref)<1e-6 & model.lb==0) = 0;
clear v_res

if worst
    if printLevel >0
        fprintf('\tAll MIQP problems performed\n');
    end
else
    while k_alpha < num_alphas
        k_alpha = k_alpha + 1;
        if printLevel >0
            fprintf('\tStart rMTA worst scenario case for alpha = %1.2f \n',alpha(k_alpha));
        end

        CplexModelWorst = buildMTAproblemFromModel(model, rxnFBS_worst, Vref,  alpha(k_alpha), epsilon);
        if printLevel >0
            fprintf('\tcplex model for MTA built\n');
        end

        if printLevel >0
            showprogress(0, '    MIQP Iterations for wMTA');
        end
        while k < length(geneKO.genes)
            for w = 1:100
                k = k+1;
                KOrxn = find(geneKO.matrix(:,k));
                v_res = MTA_MIQP (CplexModelWorst, KOrxn, 'numWorkers', numWorkers, 'timelimit', timelimit, 'printLevel', printLevel);
                Vres.wMTA{k_alpha}(:,k) = v_res;
                if ~isempty(KOrxn) && norm(v_res)>1
                    score_worst(k,k_alpha) = MTA_TS(v_res,Vref,rxnFBS_worst);
                else
                    % if we knock off the system, invalid solution
                    % remove perturbations with no effect score
                    score_worst(k, k_alpha) = -Inf;
                end
                if printLevel >0
                    showprogress(k/length(geneKO.genes), '    MIQP Iterations for wMTA');
                end
                % Condition to exit the for loop
                if k == length(geneKO.genes)
                    break;
                end
            end
            try save('temp_rMTA.mat', 'i','j','k','i_alpha','k_alpha','best','moma','worst','score_best','score_moma','score_worst','Vres'); end
        end
        clear cplex_model
        fprintf('\tAll MIQP problems performed\n');
        k = 0;
    end
    worst = true;
end

time_worst = toc(timerVal);
if printLevel >0
    fprintf('\tStep 3 time: %4.2f seconds = %4.2f minutes\n',time_worst,time_worst/60);
end
try save('temp_rMTA.mat', 'i','j','k','i_alpha','k_alpha','best','moma','worst','score_best','score_moma','score_worst','Vres'); end
fprintf('-------------------\n');


%% ---- STEP 4 : Return to gene size ----

aux = geneKO;
geneKO = geneKO2;

% scores
score_best = score_best(aux.IC,:);
score_moma = score_moma(aux.IC,:);
score_worst = score_worst(aux.IC,:);
% fluxes
for i = 1:num_alphas
    Vres.bMTA{i} = Vres.bMTA{i}(:,aux.IC);
    Vres.wMTA{i} = Vres.wMTA{i}(:,aux.IC);
end
Vres.mMTA = Vres.mMTA(:,aux.IC);

% Define one of the outputs
deletedGenes = geneKO.genes;

%% ---- STEP 5 : Calculate the rMTA TS score ----

score_rMTA = zeros(numel(geneKO.genes),num_alphas);
score_rMTA_old = zeros(numel(geneKO.genes),num_alphas);

for i = 1:num_alphas
    T = table(geneKO.genes, score_best(:,i), score_moma, score_worst(:,i));
    T.Properties.VariableNames = {'gene_ID','bTS','mTS','wTS'};

    % if wTS or bTS are infinite, delete the solution
    T.mTS(T.bTS<-1e30) = -inf;
    T.mTS(T.wTS<-1e30) = -inf;   
    
    % rMTA
    aux1 = T.bTS-T.wTS;
    aux1 = aux1*parameterK;
    aux2 = zeros(size(aux1));
    aux2(T.wTS<0 & T.bTS>0 & T.mTS>0) = 1;
    score_rMTA(:,i) = T.mTS .* (aux1.^aux2);
    
    % old rMTA
    aux1 = abs(T.bTS-T.wTS).*abs(T.mTS);
    aux_idx = T.bTS<T.wTS | T.mTS<0 | T.bTS<0;
    aux1(aux_idx)= -abs(aux1(aux_idx));
    score_rMTA_old(:,i) = T.mTS .* (aux1.^aux2);
    clear aux1 aux2 aux_idx
    
end

% save results
TSscore = struct();
TSscore.bTS = score_best;
TSscore.mTS = score_moma;
TSscore.wTS = score_worst;
TSscore.rTS = score_rMTA;
if deprecated_rTS
    TSscore.old_rTS = score_rMTA_old;
end

% remove temporal file
delete('temp_rMTA.mat')
end

