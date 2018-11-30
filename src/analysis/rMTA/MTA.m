function [TSscore, deletedGenes, Vres] = MTA(model, rxnFBS, Vref, alpha, epsilon, options)
% Calculate Metabolic Transformation Analysis (MTA) using the the
% solver CPLEX.
% Code was prepared to be able to be stopped and be launched again.
% After every run it is neccesary to eliminate the file "temp_rMTA.mat"
%
% The code here has been based on:
%   Yizhak, K., Gabay, O., Cohen, H., & Ruppin, E. (2013).
%   'Model-based identification of drug targets that revert disrupted
%   metabolism and its application to ageing'. Nature communications, 4.
%   http://www.nature.com/ncomms/2013/131024/ncomms3632/full/ncomms3632.html
%
% USAGE:
%
%    [TSscore,deletedGenes,Vout] = MTA(model, rxnFBS, Vref, alpha, epsilon, options)
%
% INPUTS:
%    model:           Metabolic model structure (COBRA Toolbox format).
%    rxnFBS:          Array that contains the desired change: Forward,
%                     Backward and Unchanged (+1;0;-1). This is calculated
%                     from the rules and differential expression analysis.
%    Vref:            Reference flux of the source state.
%
% OPTIONAL INPUT:
%    alpha:           Numeric value or array. Parameter of the quadratic
%                     problem (default = 0.66)
%    epsilon:         Numeric value or array. Minimun perturbation for each
%                     reaction (default = 0)
%    options:         Structure with fields:
%
%                       * .rxnKO - Binary variable. Calculate knock outs at
%                         reaction level instead of gene level. Default = 0
%                       * .timelimit - Time limit for the calculation of
%                         each knockout.
%                       * .separate_transcript - Character used to separate
%                         different transcripts of a gene. Default: ''.
%                         Example: separate_transcript = ''
%                                   gene 10005.1    ==>    gene 10005.1
%                                   gene 10005.2    ==>    gene 10005.2
%                                   gene 10005.3    ==>    gene 10005.3
%                                  separate_transcript = '.'
%                                   gene 10005.1
%                                   gene 10005.2    ==>    gene 10005
%                                   gene 10005.3
%                       * .numWorkers  - is the maximun number of workers
%                         used by Cplex. 0 = automatic, 1 = sequential,
%                         >1 = parallel. Default = 0;
%                       * .printLevel - 1 if the process is wanted to be
%                         shown on the screen, 0 otherwise. Default: 1.
%
% OUTPUTS:
%    Outputs are cell array for each alpha (one simulation by alpha). It
%    there is only one alpha, content of cell will be returned
%    TSscore:         Transformation score by each transformation
%    deletedGenes:    The list of genes/reactions removed in each knock-out
%    Vres:            Matrix of resulting fluxes
%
% .. Authors:
%       - Luis V. Valcarcel, 03/06/2015, University of Navarra, CIMA & TECNUN School of Engineering.
% .. Revisions:
%       - Luis V. Valcarcel, 26/10/2018, University of Navarra, CIMA & TECNUN School of Engineering.
%       - Francisco J. Planes, 26/10/2018, University of Navarra, TECNUN School of Engineering.



%% Check solver to be used
try
    Cplex('a');
catch
    error('This version MTA only works with')
end

%% Check the input information
if nargin < 3
    error('Not enough input arguments')
elseif nargin < 4
    alpha = 0.66;
    epsilon = 0;
elseif nargin < 5
    epsilon = 0;
end
if nargin < 6
    rxnKO = false;
    timelimit = inf;
    separate_transcript = '';
    numWorkers = 0;
    printLevel = 1;
else
    if isfield(options,'rxnKO') rxnKO = options.rxnKO; else rxnKO = false;   end
    if isfield(options,'timelimit') timelimit = options.timelimit; else timelimit = inf;   end
    if isfield(options,'separate_transcript') separate_transcript = options.separate_transcript; else separate_transcript = '';   end
    if isfield(options,'numWorkers') numWorkers = options.numWorkers; else numWorkers = 0;   end
    if isfield(options,'printLevel') printLevel = options.printLevel; else printLevel = 1;   end
end


fprintf('===================================\n');
fprintf('=========  MTA algorithm  =========\n');
fprintf('===================================\n');
fprintf('Step 0: preprocessing: \n');

%% Initialize variables or load previously ones
%  Check if there are any temporary files with the MTA information

num_alphas = numel(alpha);

% Calculate perturbation matrix
if rxnKO
    geneKO.genes = model.rxns;
    geneKO.rxns = model.rxns;
    geneKO.rxns = speye(numel(model.rxns));
else
    geneKO = calculateGeneKOMatrix(model,separate_transcript);
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

fprintf('-------------------\n');

%% ---- STEP 1 : MTA ----

timerVal = tic;

% treat rxnFBS to remove impossible changes
rxnFBS_best = rxnFBS;
rxnFBS_best(rxnFBS_best==-1 & abs(Vref)<1e-6 & model.lb==0) = 0;
clear v_res


while i_alpha < num_alphas
    i_alpha = i_alpha + 1;
    fprintf('\tStart MTA best scenario case for alpha = %1.2f \n',alpha(i_alpha));
    
    % Create the CPLEX model
    CplexModelBest = MTA_model (model, rxnFBS_best, Vref, alpha(i_alpha), epsilon);
    fprintf('\tcplex model for MTA built\n');
    
    % perform the MIQP problem for each rxn's knock-out
    showprogress(0, '    MIQP Iterations for MTA');
    while i < length(geneKO.genes)
        for w = 1:100
            i = i+1;
            KOrxn = find(geneKO.matrix(:,i));
            v_res = MTA_MIQP (CplexModelBest, KOrxn, numWorkers, timelimit, printLevel);
            Vres{i_alpha}(:,i) = v_res;
            if ~isempty(KOrxn) && norm(v_res)>1
                TSscore(i,i_alpha) = MTA_TS(v_res,Vref,rxnFBS_best);
            else
                % if we knock off the system, invalid solution
                % remove perturbations with no effect score
                TSscore(i,i_alpha) = -Inf;
            end
            showprogress(i/length(geneKO.genes), '    MIQP Iterations for MTA');
            % Condition to exit the for loop
            if i == length(geneKO.genes)
                break;
            end
        end
        try save('temp_MTA.mat', 'i','i_alpha','TSscore','Vres'); end
    end
    clear cplex_model
    fprintf('\n\tAll MIQP problems performed\n');
    i = 0;
end


time = toc(timerVal);
fprintf('\tTime: %4.2f seconds = %4.2f minutes\n',time,time/60);
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


end








function CplexModel = MTA_model(model,rxnFBS,Vref,alpha,epsilon)
% Returns the CPLEX model needed to perform the MTA
%
% USAGE:
% 
%       CplexModel = MTA_model(model,rxnFBS,Vref,alpha,epsilon)
%
% INPUT:
%    model:            Metabolic model (COBRA format)
%    rxnFBS:           Forward, Backward and Unchanged (+1;0;-1) values
%                      corresponding to each reaction.
%    Vref:             Reference flux of the source state.
%    alpha:            parameter of the quadratic problem (default = 0.66)
%    epsilon           minimun disturbance for each reaction, (default = 0)
%
% OUTPUTS:
%    CplexModel:       CPLEX model struct that includes the stoichiometric
%                      contrains, the thermodinamic constrains and the
%                      binary variables.
%
% .. Authors:
%       - Luis V. Valcarcel, 03/06/2015, University of Navarra, CIMA & TECNUN School of Engineering.
% .. Revisions:
%       - Luis V. Valcarcel, 26/10/2018, University of Navarra, CIMA & TECNUN School of Engineering.


%% --- check the inputs ---

if nargin<3
    ME = MException('InputMTA_Model:InputData', ...
        'There are not enough input arguments.');
    throw(ME);
end

if ~exist('alpha','var')
    alpha = 0.66;
end

if ~exist('epsilon','var')
    epsilon = zeros(size(model.rxns));
end

%% --- set the CPLEX model ---

% variables
v = 1:length(model.rxns);
y_plus_F = (1:sum(rxnFBS==+1)) + v(end);             % 1 if change in rxnForward, 0 otherwise
y_minus_F = (1:sum(rxnFBS==+1)) + y_plus_F(end);     % 1 if no change in rxnForward, 0 otherwise
y_plus_B = (1:sum(rxnFBS==-1)) + y_minus_F(end);     % 1 if change in rxnBackward, 0 otherwise
y_minus_B = (1:sum(rxnFBS==-1)) + y_plus_B(end);     % 1 if no change in rxnBackward, 0 otherwise
n_var = y_minus_B(end);

% limits of the variables
lb = zeros(n_var,1);
ub = ones (n_var,1);
lb(v) = model.lb;
ub(v) = model.ub;

%type of variables
ctype(1:n_var) = 'B';
ctype(v) = 'C';

% constrains
Eq1 = 1:length(model.mets);                 % Stoichiometric matrix
Eq2 = (1:length(y_plus_F)) + Eq1(end);      % Changes in Forward
Eq3 = (1:length(y_plus_F)) + Eq2(end);      % Change or not change in Forward
Eq4 = (1:length(y_plus_B)) + Eq3(end);      % Changes in Backward
Eq5 = (1:length(y_plus_B)) + Eq4(end);      % Change or not change in Backward
n_cons = Eq5(end);

% generate constrain matrix
A = spalloc(n_cons, n_var, nnz(model.S) + 5*length(Eq2) + 5*length(Eq4));

posF = find(rxnFBS == +1);
posB = find(rxnFBS == -1);
posS = find(rxnFBS == 0);

% First contraint, stoichiometric
A(Eq1,v) = model.S;
lhs(Eq1) = 0;
rhs(Eq1) = 0;

% Second contraint, Change or not change in Forward
A(Eq2,v(posF)) = eye(length(posF));
A(Eq2,y_plus_F) = - ( Vref(posF) + epsilon(posF) ) .* eye(length(posF));
A(Eq2,y_minus_F) = - model.lb(posF) .* eye(length(posF));
lhs(Eq2) = 0;
rhs(Eq2) = inf;

% Third contraint, Change or not change in Forward
A(Eq3,y_plus_F) = eye(length(Eq3));
A(Eq3,y_minus_F) = eye(length(Eq3));
lhs(Eq3) = 1;
rhs(Eq3) = 1;

% Fourth contraint, Backward changes
A(Eq4,posB) = eye(length(posB));
A(Eq4,y_plus_B) = - ( Vref(posB) - epsilon(posB) ) .* eye(length(posB));
A(Eq4,y_minus_B) = - model.ub(posB) .* eye(length(posB));
lhs(Eq4) = -inf;
rhs(Eq4) = 0;

% Fiveth contraint, Change or not change in Backward
A(Eq5,y_plus_B) = eye(length(Eq5));
A(Eq5,y_minus_B) = eye(length(Eq5));
lhs(Eq5) = 1;
rhs(Eq5) = 1;

% Objective fuction
% linear part
c = zeros(n_var,1);
c(y_minus_F) = alpha/2;
c(y_minus_B) = alpha/2;
c(v(posS)) = -2 * Vref(posS) * (1-alpha);
% quadratic part
Q = spalloc(n_var,n_var,length(posS));
Q(v(posS),v(posS)) =  2 * (1-alpha) .* eye(length(posS));

% save the resultant model
CplexModel = struct();
[CplexModel.A, CplexModel.lb, CplexModel.ub] = deal(A, lb, ub);
[CplexModel.lhs, CplexModel.rhs] = deal(lhs, rhs);
[CplexModel.obj, CplexModel.Q] = deal(c, Q);
[CplexModel.sense, CplexModel.ctype] = deal('minimize', ctype);

%save the index of the variables
CplexModel.idx_variables.v = v;
CplexModel.idx_variables.y_plus_F = y_plus_F;
CplexModel.idx_variables.y_minus_F = y_minus_F;
CplexModel.idx_variables.y_plus_B = y_plus_B;
CplexModel.idx_variables.y_minus_B = y_minus_B;

end


function [geneKO] = calculateGeneKOMatrix(model, separate_transcript)
% Build a rxn-gene matrix such that the i-th column indicates what
% reactions become inactive because of the i-th gene's knock-out.
%
% USAGE:
%
%    geneKO = calculateGeneKOMatrix(model)
%
% INPUT:
%    model:             The COBRA Model structure
%
% OUTPUT:
%    geneKO:            Struct which contains matrix with blocked 
%                       reactions for each gene in the metabolic model,
%                       name of reactions and name of genes.
%
% .. Authors: - Luis V. Valcarcel, Oct 2017

% define gene set
genes = unique(strtok(model.genes, separate_transcript));
% genes = genes(1:10); % test
% genes = {'115584'}; % test
% genes = {'160728'; '6526'; '115584'; '9497'; '30833'; '132';...
% '124935';'10257'; '64841';'7084'}; % test
ngenes = numel(genes);

% generate output matrix
ko_rxn_gene = zeros(numel(model.rxns),ngenes);

% affected reactions
showprogress(0, 'Calculate Gene Knock-out matrix');
for gen = 1:ngenes
    showprogress(gen/ngenes, 'Calculate Gene Knock-out matrix');
    
    transcripts = model.genes(startsWith(model.genes,[genes{gen} separate_transcript]));
    [~, hasEffect, constrRxnNames] = deleteModelGenes(model, transcripts);
    
    if hasEffect
        % search index of bloced reactions
        [~,idx] = ismember(constrRxnNames,model.rxns);
        ko_rxn_gene(idx,gen) = 1;
    end
end
% fprintf('\n');
fprintf('\n\tGeneKOMatrix calculated\n');

% geneKO
geneKO.genes = genes;
geneKO.rxns = model.rxns;
geneKO.matrix = (ko_rxn_gene~=0);
end


function [v_res, solution] = MTA_MIQP (CplexModel, KOrxn, numWorkers, timelimit, printLevel)
% Returns the CPLEX solution of a particular MTA problem and an specific
% model
% 
% USAGE:
%
%    [v_res, success, unsuccess] = MTA_MIQP (Model, KOrxn, numWorkers, printLevel)
%
% INPUT:
%    CplexModel:       Cplex Model struct
%    KOrxn:            perturbation in the model (reactions)
%    numWorkers:       number of threads used by Cplex.
%    printLevel:       1 if the process is wanted to be shown on the
%                      screen, 0 otherwise. Default: 1.
%
% OUTPUTS:
%    Vout:             Solution flux of MIQP formulation for each case
%    solution:         Cplex solution struct
%
% .. Authors:
%       - Luis V. Valcarcel, 03/06/2015, University of Navarra, CIMA & TECNUN School of Engineering.
% .. Revisions:
%       - Luis V. Valcarcel, 26/10/2018, University of Navarra, CIMA & TECNUN School of Engineering.

%Indexation of variables
v = CplexModel.idx_variables.v;
y_plus_F = CplexModel.idx_variables.y_plus_F;
y_minus_F = CplexModel.idx_variables.y_minus_F;
y_plus_B = CplexModel.idx_variables.y_plus_B;
y_minus_B = CplexModel.idx_variables.y_minus_B;
CplexModel = rmfield(CplexModel,'idx_variables');

% Generate CPLEX model
cplex = Cplex('MIQP');
cplex.Model = CplexModel;
% include the knock-out reactions
cplex.Model.lb(KOrxn) = 0;
cplex.Model.ub(KOrxn) = 0;

% Cplex Parameter
if numWorkers>0
    cplex.Param.threads.Cur = numWorkers;
end
if printLevel <=1
    cplex.Param.output.clonelog.Cur = 0;
    cplex.DisplayFunc = [];
elseif printLevel <=2
    cplex.Param.output.clonelog.Cur = 0;
end
if timelimit < 1e75
    cplex.Param.timelimit.Cur = timelimit;
end
%reduce the tolerance
cplex.Param.mip.tolerances.mipgap.Cur = 1e-5;
% cplex.Param.mip.tolerances.absmipgap.Cur = 1e-8;
% cplex.Param.threads.Cur = 16;

% SOLVE the CPLEX problem if not singular
try
    cplex.solve();
catch
    v_res = zeros(length(v),1);
    return
end

if cplex.Solution.status ~= 103
    v_res = cplex.Solution.x(v);
    solution = cplex.Solution;
else
    v_res = zeros(length(v),1);
    solution = nan;
end

% clear the cplex object
delete(cplex)
clear cplex

end


function score = MTA_TS(Vout,Vref,rxnFBS)
% Returns the TS score of a particular solution of the MTA perturbation
% algorithm.
%
% USAGE:
% 
%       score = MTA_TS(v_res,vref,Model,success,unsuccess)
% 
% INPUT:
%    Vout:             Solution flux of MIQP formulation for each case
%    Vref:             Reference flux of source state
%    rxnFBS:           Array that contains the desired change: Forward,
%                      Backward and Unchanged (+1;0;-1).
%
% OUTPUTS:
%    score:            TS score for each case
%
% .. Authors:
%       - Luis V. Valcarcel, 03/06/2015, University of Navarra, CIMA & TECNUN School of Engineering.
% .. Revisions:
%       - Luis V. Valcarcel, 26/10/2018, University of Navarra, CIMA & TECNUN School of Engineering.


%Indexation of variables
v_rF = find(rxnFBS==+1);
v_rB = find(rxnFBS==-1);
v_r = [v_rF; v_rB];     % the order is neccesary, as the success array has been defined in that order
v_s = find(rxnFBS==0);

% Compute the successful reactions, without thershold
% We will consider a reaction successful if this reaction moves in the
% right direction
success = false (size(Vout));
success( rxnFBS==+1 & Vout>Vref ) = 1;
success( rxnFBS==-1 & Vout<Vref ) = 1;
% reduce the size of succes and respect the order
% indexation is defined as v_r = [v_rF; v_rB]
success = success(v_r);
unsuccess = ~success;

aux_Rs = sum(abs(Vout(v_r(success)) - Vref(v_r(success))));
aux_Ru = sum(abs(Vout(v_r(unsuccess)) - Vref(v_r(unsuccess))));
aux_S = sum(abs(Vout(v_s) - Vref(v_s)));

%score
score = (aux_Rs-aux_Ru)/(aux_S);

end

