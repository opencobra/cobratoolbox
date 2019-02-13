function [TSscore, deletedGenes, Vres] = MTA(model, rxnFBS, Vref, varargin)
% Calculate Metabolic Transformation Analysis (MTA) using the the
% solver CPLEX.
% Code was prepared to be able to be stopped and be launched again by using
% a temporary file called 'temp_MTA.mat'.
% Outputs are cell array for each alpha (one simulation by alpha). It
% there is only one alpha, content of cell will be returned
% The code here has been based on:
%   Yizhak, K., Gabay, O., Cohen, H., & Ruppin, E. (2013).
%   'Model-based identification of drug targets that revert disrupted
%   metabolism and its application to ageing'. Nature communications, 4.
%   http://www.nature.com/ncomms/2013/131024/ncomms3632/full/ncomms3632.html
%
% USAGE:
%
%    [TSscore,deletedGenes,Vout] = MTA(model, rxnFBS, Vref, alpha, epsilon, varargin)
%
% INPUTS:
%    model:               Metabolic model structure (COBRA Toolbox format).
%    rxnFBS:              Array that contains the desired change: Forward,
%                         Backward and Unchanged (+1;0;-1). This is calculated
%                         from the rules and differential expression analysis.
%    Vref:                Reference flux of the source state.
%
% OPTIONAL INPUTS:
%    alpha:               Numeric value or array. Parameter of the quadratic
%                         problem (default = 0.66)
%    epsilon:             Numeric value or array. Minimun perturbation for each
%                         reaction (default = 0)
%    rxnKO:               Binary value. Calculate knock outs at reaction level
%                         instead of gene level. (default = false)
%    listKO:             Cell array containing the name of genes or 
%                        reactions to knockout. (default = all)
%    timelimit:           Time limit for the calculation of each knockout.
%                         (default = inf)
%    SeparateTranscript:  Character used to separate different transcripts of a gene. (default = '').
%                         Examples:
%                             - SeparateTranscript = ''
%                                   - gene 10005.1    ==>    gene 10005.1
%                                   - gene 10005.2    ==>    gene 10005.2
%                                   - gene 10005.3    ==>    gene 10005.3
%                             - SeparateTranscript = '.'
%                                   - gene 10005.1
%                                   - gene 10005.2    ==>    gene 10005
%                                   - gene 10005.3
%    numWorkers:          Integer: is the maximun number of workers
%                         used by the solver. 0 = automatic, 1 = sequential,
%                         > 1 = parallel. (default = 0)
%    printLevel:          Integer. 1 if the process is wanted to be shown
%                         on the screen, 0 otherwise. (default = 1)
%
% OUTPUTS:
%    TSscore:             Transformation score by each transformation
%    deletedGenes:        The list of genes/reactions removed in each knock-out
%    Vres:                Matrix of resulting fluxes
%
% .. Authors:
%       - Luis V. Valcarcel, 03/06/2015, University of Navarra, CIMA & TECNUN School of Engineering.
%       - Luis V. Valcarcel, 26/10/2018, University of Navarra, CIMA & TECNUN School of Engineering.
%       - Francisco J. Planes, 26/10/2018, University of Navarra, TECNUN School of Engineering.

p = inputParser; % check the input information

% check required arguments
addRequired(p, 'model');
addRequired(p, 'rxnFBS', @isnumeric);
addRequired(p, 'Vref', @isnumeric);
% Check optional arguments
addOptional(p, 'alpha', 0.66, @isnumeric);
addOptional(p, 'epsilon', 0, @isnumeric);
% Add optional name-value pair argument
addParameter(p, 'rxnKO', false);
addParameter(p, 'listKO', {}, @(x)iscell(x));
addParameter(p, 'timelimit', inf, @(x)isnumeric(x)&&isscalar(x));
addParameter(p, 'SeparateTranscript', '', @(x)ischar(x));
addParameter(p, 'numWorkers', 0, @(x)isnumeric(x)&&isscalar(x));
addParameter(p, 'printLevel', 1, @(x)isnumeric(x)&&isscalar(x));
% extract variables from parser
parse(p, model, rxnFBS, Vref, varargin{:});
alpha = p.Results.alpha;
epsilon = p.Results.epsilon;
rxnKO = p.Results.rxnKO;
listKO = p.Results.listKO;
timelimit = p.Results.timelimit;
SeparateTranscript = p.Results.SeparateTranscript;
numWorkers = p.Results.numWorkers;
printLevel = p.Results.printLevel;

if printLevel >0
    fprintf('===================================\n');
    fprintf('=========  MTA algorithm  =========\n');
    fprintf('===================================\n');
    fprintf('Step 0: preprocessing: \n');
end

%% Initialize variables or load previously ones
%  Check if there are any temporary files with the MTA information

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
        assert(all(ismember(listKO,geneKO.genes)),'Reactions in listKO are not in the model');
    elseif isempty(SeparateTranscript)
        listKO = unique(listKO);
        assert(all(ismember(listKO,geneKO.genes)),'Genes in listKO are not in the model');
    else
        listKO = unique(strtok(listKO,SeparateTranscript));
        assert(all(ismember(listKO,geneKO.genes)),'Genes in listKO are not in the model');
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

if ~exist('temp_MTA.mat','file')
    % counters
    i = 0;          % counter
    i_alpha = 0;    % counter for lphas
    % scores
    TSscore = zeros(numel(geneKO.genes),num_alphas);
    Vres = cell(num_alphas,1);
    Vres(:) = {zeros(numel(model.rxns),numel(geneKO.genes))};
else
    load('temp_MTA.mat');
    i_alpha = max(i_alpha-1,0);
    i = max(i-100,0);
end

if printLevel >0
    fprintf('-------------------\n');
end

%% ---- STEP 1 : MTA ----

timerVal = tic;

% treat rxnFBS to remove impossible changes
rxnFBS_best = rxnFBS;
rxnFBS_best(rxnFBS_best==-1 & abs(Vref)<1e-6 & model.lb==0) = 0;
clear v_res


while i_alpha < num_alphas
    i_alpha = i_alpha + 1;
    if printLevel >0
        fprintf('\tStart MTA best scenario case for alpha = %1.2f \n',alpha(i_alpha));
    end

    % Create the CPLEX model
    CplexModelBest = buildMTAproblemFromModel(model, rxnFBS_best, Vref, alpha(i_alpha), epsilon);
    if printLevel >0
        fprintf('\tcplex model for MTA built\n');
    end

    % perform the MIQP problem for each rxn's knock-out
    if printLevel >0
        showprogress(0, '    MIQP Iterations for MTA');
    end
    while i < length(geneKO.genes)
        for w = 1:100
            i = i+1;
            KOrxn = find(geneKO.matrix(:,i));
            v_res = MTA_MIQP (CplexModelBest, KOrxn, 'numWorkers', numWorkers, 'timelimit', timelimit, 'printLevel', printLevel);
            Vres{i_alpha}(:,i) = v_res;
            if ~isempty(KOrxn) && norm(v_res)>1
                TSscore(i,i_alpha) = MTA_TS(v_res,Vref,rxnFBS_best);
            else
                % if we knock off the system, invalid solution
                % remove perturbations with no effect score
                TSscore(i,i_alpha) = -Inf;
            end
            if printLevel >0
                showprogress(i/length(geneKO.genes), '    MIQP Iterations for MTA');
            end
            % Condition to exit the for loop
            if i == length(geneKO.genes)
                break;
            end
        end
        try save('temp_MTA.mat', 'i','i_alpha','TSscore','Vres'); end
    end
    clear cplex_model
    if printLevel >0
        fprintf('\tAll MIQP problems performed\n');
    end
    i = 0;
end


time = toc(timerVal);
if printLevel >0
    fprintf('\tTime: %4.2f seconds = %4.2f minutes\n',time,time/60);
end
try save('temp_MTA.mat', 'i','i_alpha','TSscore','Vres'); end
fprintf('-------------------\n');

%% ---- STEP 2 : Return to gene size ----

aux = geneKO;
geneKO = geneKO2;

% scores
TSscore = TSscore(aux.IC,:);
% fluxes
for i=1:num_alphas
    Vres{i} = Vres{i}(:,aux.IC);
end

% Define one of the outputs
deletedGenes = geneKO.genes;


delete('temp_MTA.mat')

end

