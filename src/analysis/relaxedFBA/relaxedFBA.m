function [solution, relaxedModel] = relaxedFBA(model, param)
%
% Finds the mimimal set of relaxations on bounds and steady state
% constraints to make the FBA problem feasible. The optional parameters,
% excludedReactions and excludedMetabolites override all other relaxation options.
%
% .. math::
%      min ~&~ c^T v + \gamma ||v||_0 + \lambda ||r||_0 + \alpha (||p||_0 + ||q||_0) \\
%      s.t ~&~ S v + r \leq, =, \geq  b \\
%          ~&~ l - p \leq v \leq u + q \\
%          ~&~ r \in R^nMets \\
%          ~&~ p,q \in R_+^nRxns
%
% `nMets` - number of metabolites,
% `nRxns` - number of reactions
%
% USAGE:
%
%    [solution] = relaxedFBA(model, param)
%
% INPUTS:
%    model:          COBRA model structure with the fields:
%                      * .S
%                      * .b
%                      * .ub
%                      * .ub
%                      * .mets  (required if model.SIntRxnBool absent)
%                      * .rxns  (required if model.SIntRxnBool absent)
%
% OPTIONAL INPUTS:
%    model:          COBRA model structure with the fields
%                      * .csense
%                      * .C
%                      * .d
%                      * .dsense
%                      * .SIntRxnBool
%
%
%    param:    Structure optionally containing the relaxation parameters:
%
%                      * .internalRelax:
%                        * 0 = do not allow to relax bounds on internal reactions
%                        * 1 = do not allow to relax bounds on internal reactions with finite bounds
%                        * {2} = allow to relax bounds on all internal reactions
%
%                      * .exchangeRelax:
%                        * 0 = do not allow to relax bounds on exchange reactions
%                        * 1 = do not allow to relax bounds on exchange reactions of the type [0,0]
%                        * {2} = allow to relax bounds on all exchange reactions
%
%                      * .steadyStateRelax:
%                        *  0 = do not allow to relax the steady state constraint S*v = b
%                        *  {1} = allow to relax the steady state constraint S*v = b
%
%                      * .extraVarRelax:
%                        * 0 = do not allow to relax bounds on extra variables
%                        * 1 = do not allow to relax bounds on extra variables with finite bounds
%                        * {2} = allow to relax bounds on all extra variables
%
%                      * .extraConstraintRelax:
%                        * 0 = do not allow to relax extra constraints
%                        * {1} = allow to relax extra constraints
%
%                      * .toBeUnblockedReactions - nRxns x 1 vector indicating the reactions to be unblocked
%                        * toBeUnblockedReactions(i) = 1 : impose v(i) to be positive
%                        * toBeUnblockedReactions(i) = -1 : impose v(i) to be negative
%                        * toBeUnblockedReactions(i) = 0 : do not add any constraint (default)
%
%                      * .excludedReactions - nRxns x 1 bool vector indicating the reactions to be excluded from relaxation
%                        * excludedReactions(i) = false : allow to relax bounds on reaction i (default)
%                        * excludedReactions(i) = true : do not allow to relax bounds on reaction i 
%
%                      * .excludedReactionLB - nRxns x 1 bool vector indicating
%                      the reactions with lower bounds to be excluded from
%                      relaxation (overridden by excludedReactions)
%                        * excludedReactionLB(i) = false : allow to relax lower bounds on reaction i (default)
%                        * excludedReactionLB(i) = true : do not allow to relax lower bounds on reaction i 
%
%                      * .excludedReactionUB - nRxns x 1 bool vector indicating
%                      the reactions with upper bounds to be excluded from relaxation (overridden by excludedReactions)
%                        * excludedReactionUB(i) = false : allow to relax upper bounds on reaction i (default)
%                        * excludedReactionUB(i) = true : do not allow to relax upper bounds on reaction i 
%
%                      * .excludedMetabolites - nMets x 1 bool vector indicating the metabolites to be excluded from relaxation
%                        * excludedMetabolites(i) = false : allow to relax steady state constraint on metabolite i (default)
%                        * excludedMetabolites(i) = true : do not allow to relax steady state constraint on metabolite i
%
%                      * .toBeUnblockedEvars - nEvars x 1 vector indicating the extra variables to be unblocked
%                        * toBeUnblockedEvars(i) = 1 : impose vEvar(i) to be positive
%                        * toBeUnblockedEvars(i) = -1 : impose vEvar(i) to be negative
%                        * toBeUnblockedEvars(i) = 0 : do not add any constraint (default)
%
%                      * .excludedEvars - nEvars x 1 bool vector indicating the extra variables to be excluded from relaxation
%                        * excludedEvars(i) = false : allow to relax bounds on extra variable i (default)
%                        * excludedEvars(i) = true : do not allow to relax bounds on extra variable i 
%
%                      * .excludedEvarLB - nEvars x 1 bool vector indicating
%                      the extra variables with lower bounds to be excluded from
%                      relaxation (overridden by excludedEvars)
%                        * excludedEvarLB(i) = false : allow to relax lower bounds on extra variablen i (default)
%                        * excludedEvarLB(i) = true : do not allow to relax lower bounds on extra variable i 
%
%                      * .excludedEvarUB - nEvars x 1 bool vector indicating
%                      the extra variables with upper bounds to be excluded from relaxation (overridden by excludedEvars)
%                        * excludedEvarUB(i) = false : allow to relax upper bounds on extra variable i (default)
%                        * excludedEvarUB(i) = true : do not allow to relax upper bounds on extra variable i 
%
%                      * .excludedCtrs - nCtrs x 1 bool vector indicating the extra constraints to be excluded from relaxation
%                        * excludedCtrs(i) = false : allow to relax steady state constraint on extra constraints i (default)
%                        * excludedCtrs(i) = true : do not allow to relax steady state constraint on extra constraints i
%
%                      * .lamda - weighting on relaxation of relaxation on steady state constraints S*v = b
%                      * .alpha - weighting on relaxation of reaction bounds
%                      * .gamma - weighting on zero norm of fluxes
%
%                     * .nbMaxIteration - stopping criteria - number maximal of iteration (Default value = 100)
%                     * .epsilon - stopping criteria - (Default value = 1e-6)
%                     * .theta - initial parameter of the approximation (Default value = 0.5)
%                                 Theoretically, the greater the value of step parameter, the better the approximation of a step function.
%                                 However, practically, a greater inital value, will tend to optimise toward a local minima of the approximate 
%                                 cardinality optimisation problem.
%
%                     * .printLevel (Default = 0) Printing the progress of
%                     the algorithm is useful when trying different values
%                     of theta to start with the appropriate parameter
%                     giving the lowest cardinality solution.
%                     * .relaxedPrintLevel (Default = 0) Printing information on relaxed reaction bounds and steady state constraints
%                     * .maxRelaxR (Default = 1e4), maximum relaxation of any bound or equality constraint permitted
%
% OUTPUT:
%    solution:       Structure containing the following fields:
%
%                      * stat - status
%
%                        * 1  = Solution found
%                        * 0  = Infeasible
%                        * -1 = Invalid input
%                      * r - relaxation on steady state constraints S*v = b
%                      * p - relaxation on lower bound of reactions
%                      * q - relaxation on upper bound of reactions
%                      * v - reaction rate
%                      * vEvar - extra variable value
%                      * pEvar - relaxation on lower bound of extra
%                      variables
%                      * qEvar - relaxation on upper bound of extra
%                      variables
%                      * rCtrs - relaxation on steady state of extra constraints
%
% relaxedModel       model structure that admits a flux balance solution
%
% Authors: - Hoai Minh Le, Ronan Fleming
% .. Please cite:
% Fleming RMT, Haraldsdottir HS, Le HM, Vuong PT, Hankemeier T, Thiele I. 
% Cardinality optimisation in constraint-based modelling: Application to human metabolism, 2022 (submitted).  
%
% - April 2026: expanded to deal with extra variables and constraints (model.C,
% model.D, model.E) - Tania Barata

feasTol = getCobraSolverParams('LP', 'feasTol');

if ~isfield(model,'S')
    %relax generic LP problem
    % if no stoichiometric matrix is available, use matrix A as matrix S
    model.S = model.A;
    % when 'SIntRxnBool' is missing, do not get it from model.d, because 
    % model.d may be the RHS of coupling constraints, instead default it
    % to 'true' in all reactions
    if ~isfield(model,'SIntRxnBool')
            model.SIntRxnBool = true(size(model.S,2),1);
    end
    model = rmfield(model,'A');
end

[nMetsOrig,nRxnsOrig] = size(model.S);

% % default params and check inputs
if ~exist('param','var')
    param = struct();
end

if ~isfield(param,'printLevel')
    param.printLevel = 0; %TODO - check this for multiscale models
end

if ~isfield(param,'relaxedPrintLevel')
    param.relaxedPrintLevel = 0;
end

if isfield(param,'internalRelax') == 0
    param.internalRelax = 2; %allow all internal reaction bounds to be relaxed
elseif param.internalRelax < 0 || param.internalRelax > 2
        solution.status = -1;
        error('Incorrect input : internalRelax')
end

if isfield(param,'exchangeRelax') == 0
    param.exchangeRelax = 2; %allow all exchange reaction bounds to be relaxed
elseif param.exchangeRelax < 0 || param.exchangeRelax > 2
        solution.status = -1;
        error('Incorrect input : exchangeRelax')
end

if isfield(param,'steadyStateRelax') == 0
    param.steadyStateRelax = 1; %allow steady state constraint to be relaxed
else
    if param.steadyStateRelax < 0 || param.steadyStateRelax > 1
        solution.status = -1;
        error('Incorrect input : steadyStateRelax')
    end
end

if isfield(param, 'extraVarRelax') == 0
    param.extraVarRelax = 2; % by default allow relaxation of extra variables' bounds
else
    if param.extraVarRelax < 0 || param.extraVarRelax > 2
        solution.status = -1;
        error('Incorrect input : extraVarRelax')
    end
end

if isfield(param, 'extraConstraintRelax') == 0
    param.extraConstraintRelax = 1; % by default allow relaxation of extra constraints
else
    if param.extraConstraintRelax < 0 || param.extraConstraintRelax > 1
        solution.status = -1;
        error('Incorrect input : extraConstraintRelax')
    end
end

if isfield(param,'nbMaxIteration') == 0
    param.nbMaxIteration = 20;
end

if isfield(param,'epsilon') == 0
    param.epsilon=feasTol;
end

if isfield(param,'theta') == 0
    param.theta   = 0.1;
end

if ~isfield(param,'maxRelaxR')
    param.maxRelaxR = 1/feasTol; %TODO - check this for multiscale models
end

% % model defaults and checks
if ~isfield(model, 'b') || isempty(model.b)
    model.b = zeros(nMetsOrig, 1);
end

if isfield(model,'C') && ~isfield(model,'d')
    error('For the constraints C*v <= d, both must be present')
end

% check dimensions for C and d
if isfield(model,'C') 
    [nIneq,nltC]=size(model.C);
    [nIneq2,nltd]=size(model.d);
    if nltC~=nRxnsOrig
        error('For the constraints C*v <= d the number of columns of S and C are inconsisent')
    end
    if nIneq~=nIneq2
        error('For the constraints C*v <= d, the number of rows of C and d are inconsisent')
    end
    if nltd~=1
        error('For the constraints C*v <= d, d must have only one column')
    end
else
    nIneq=0;
end

%check the csense and dsense and make sure it is consistent
if isfield(model,'C')
    if ~isfield(model,'csense')
        if param.printLevel>1
            fprintf('%s\nRxns','No defined csense.')
            fprintf('%s\nRxns','We assume that all mass balance constraints are equalities, i.e., S*v = 0')
        end
        model.csense(1:nMetsOrig,1) = 'E';
    else
        if length(model.csense)==nMetsOrig
            model.csense = columnVector(model.csense);
        else
            if length(model.csense)==nMetsOrig+nIneq
                %this is a workaround, a model should not be like this
                model.dsense=model.csense(nMetsOrig+1:nMetsOrig+nIneq,1);
                model.csense=model.csense(1:nMetsOrig,1);
            else
                error('Length of csense is invalid!')
            end
        end
    end
    
    if ~isfield(model,'dsense')
        if param.printLevel>1
            fprintf('%s\nRxns','No defined dsense.')
            fprintf('%s\nRxns','We assume that all constraints C & d constraints are C*v <= d')
        end
        model.dsense(1:nIneq,1) = 'L';
    else
        if length(model.dsense)~=nIneq
            error('Length of dsense is invalid! Defaulting to equality constraints.')
        else
            model.dsense = columnVector(model.dsense);
        end
    end
else
    if ~isfield(model,'csense')
        % If csense is not declared in the model, assume that all constraints are equalities.
        if param.printLevel>1
            fprintf('%s\nRxns','We assume that all mass balance constraints are equalities, i.e., S*v = dxdt = 0')
        end
        model.csense(1:nMetsOrig,1) = 'E';
    else % if csense is in the model, move it to the lp problem structure
        if length(model.csense)~=nMetsOrig
            error('The length of csense does not match the number of rows of model.S.')
            model.csense(1:nMetsOrig,1) = 'E';
        else
            model.csense = columnVector(model.csense);
        end
    end
end

% % defaults for model.C/.D/.E, extra variables and constraints
hasE = isfield(model, 'E') && ~isempty(model.E);
hasC = isfield(model, 'C') && ~isempty(model.C);
hasD = isfield(model, 'D') && ~isempty(model.D);

if hasE && hasC && (~hasD)
    warning(sprintf(['model.E and model.C are present but model.D is missing.\n' ...
        'model.D will be filled with 0s']))
    model.D = sparse(size(model.C, 1), size(model.E, 2));
    hasD = true;
end

if hasD && hasE && (~hasC)
    warning(sprintf(['model.E and model.D are present but model.C is missing.\n' ...
        'model.C will be filled with 0s']))
    model.C = sparse(size(model.D, 1), size(model.S, 2));
    hasC = true;
end

if hasC && hasD && (~hasE)
    warning(sprintf(['model.C and model.D are present but model.E is missing.\n' ...
        'model.E will be filled with 0s']))
    model.E = sparse(size(model.S, 1), size(model.D, 2));
    hasE = true;
end

if hasD
    nEvars = size(model.D, 2);
elseif hasE
    nEvars = size(model.E, 2);
else
    nEvars = 0;
end

if hasC
    nCtrs = size(model.C, 1);
elseif hasD
    nCtrs = size(model.D, 1);
else
    nCtrs = 0;
end

% default of extra variables
if nEvars > 0
    if ~isfield(model, 'evarlb')
        model.evarlb = -inf*ones(nEvars, 1);
    end
    if ~isfield(model, 'evarub')
        model.evarub = inf*ones(nEvars, 1);
    end
    if ~isfield(model, 'evarc')
        model.evarc = zeros(nEvars, 1);
    end
    if ~isfield(model, 'evars')
        model.evars = cellstr(char("evar_" + string(1:nEvars)'));
    end
end

% default for extra constraints
if nCtrs > 0
    if ~isfield(model, 'd')
        model.d = zeros(nCtrs, 1);
    end
    if ~isfield(model,'dsense') % if dsense does not exist defaults to 'L'
        model.dsense = repmat('L', nCtrs, 1);
    end
    if ~isfield(model, 'ctrs')
        model.ctrs = cellstr(char("ctrs_"+string(1:nCtrs)'));
    end
end

% % split between internal and external reactions
if isfield(model,'SIntRxnBool') && length(model.SIntRxnBool)==nRxnsOrig
    SIntRxnBool = model.SIntRxnBool;
else
    if isfield(model,'SConsistentRxnBool') && length(model.SConsistentRxnBool)==nRxnsOrig
        SIntRxnBool = model.SConsistentRxnBool;
    else
        if param.printLevel>0
            fprintf('%s\n','Computing model.SIntRxnBool heuristically from stoichiometric matrix')
        end
        model_Ex = findSExRxnInd(model,nMetsOrig);
        SIntRxnBool = model_Ex.SIntRxnBool;
    end
end
%it is possible to define external reactions separately, in case this is different from ~SIntRxnBool
if isfield(model,'SExtRxnBool') && length(model.SExtRxnBool)==nRxnsOrig
    SExtRxnBool = model.SExtRxnBool;
else
    SExtRxnBool = ~SIntRxnBool; 
end

% expand model - join matrices
modelOrig = model; % save original model
if hasE
    model.S = [modelOrig.S, modelOrig.E];
end

if hasD
    model.C = [modelOrig.C, modelOrig.D];
end

if hasC || hasD
    model.S = [model.S; model.C];
end

if hasE || hasD
    model.lb = [modelOrig.lb; modelOrig.evarlb];
    model.ub = [modelOrig.ub; modelOrig.evarub];
    model.c = [modelOrig.c; modelOrig.evarc];
    model.rxns = [modelOrig.rxns; modelOrig.evars];
    if isfield(modelOrig, 'rxnNames') && ~isempty(modelOrig.rxnNames)...
            &&  isfield(modelOrig, 'evarNames') && ~isempty(modelOrig.evarNames)
        model.rxnNames = [modelOrig.rxnNames; modelOrig.evarNames];
        model = rmfield(model, {'evarNames'});
    end
    model = rmfield(model, {'evars', 'evarlb', 'evarub', 'evarc', 'E'});
end
if hasC || hasD
    model.mets = [modelOrig.mets; modelOrig.ctrs];
    model.csense = [modelOrig.csense; modelOrig.dsense];
    model.b = [modelOrig.b; modelOrig.d];
    if isfield(modelOrig, 'metNames') && ~isempty(modelOrig.metNames)...
            &&  isfield(modelOrig, 'ctrNames') && ~isempty(modelOrig.ctrNames)
        model.metNames = [modelOrig.metNames; modelOrig.ctrNames];
        model = rmfield(model, {'ctrNames'});
    end
    model = rmfield(model, {'ctrs', 'dsense', 'd', 'C', 'D'});
end

% % bounds, .toBeUunblockedReactions default
[nMets,nRxns] = size(model.S);

if ~isfield(param,'maxUB')
    param.maxUB = max(max(model.ub),-min(model.lb));
end
if ~isfield(param,'minLB')
    param.minLB = min(-max(model.ub),min(model.lb));
end

if isfield(param,'toBeUnblockedReactions') == 0
    %this constraint is handled directly within relaxFBA_cappedL1
    param.toBeUnblockedReactions = zeros(nRxnsOrig,1);
end

if nEvars > 0 % when model was expanded to include extra variables
    if ~isfield(param,'toBeUnblockedEvars') || isempty(param.toBeUnblockedEvars)
        param.toBeUnblockedEvars = zeros(nEvars, 1);
    end
    param.toBeUnblockedReactions = [param.toBeUnblockedReactions; param.toBeUnblockedEvars];
end

% % exclude relaxations
% reaction and metabolites exclusion defaults
if isfield(param,'excludedReactionLB') == 0
    param.excludedReactionLB = false(nRxnsOrig,1);
end

if isfield(param,'excludedReactionUB') == 0
    param.excludedReactionUB = false(nRxnsOrig,1);
end

if isfield(param,'excludedReactions') == 0
    param.excludedReactions = false(nRxnsOrig,1);
end

if isfield(param,'excludedMetabolites') == 0
    param.excludedMetabolites = false(nMetsOrig,1);
end

% extra variable and constraints exclusion defaults
if nEvars > 0 % when model was expanded to include extra variables
    if ~isfield(param,'excludedEvarLB') || isempty(param.excludedEvarLB)
        param.excludedEvarLB = false(nEvars, 1);
    end
    if ~isfield(param,'excludedEvarUB') || isempty(param.excludedEvarUB)
        param.excludedEvarUB = false(nEvars, 1);
    end
    if isfield(param, 'excludedEvars') == 0
        param.excludedEvars = false(nEvars, 1);
    end
else
    param.excludedEvarLB = false(0, 1);
    param.excludedEvarUB = false(0, 1);
    param.excludedEvars = false(0, 1);
end

if nCtrs > 0
    if isfield(param,'excludedCtrs') == 0
        param.excludedCtrs = false(nCtrs, 1); % by default allow all extra constraints to be relaxed
    end
else
    param.excludedCtrs = false(0, 1);
end

% overwrite excludedReactions with internalRelax and exchangeRelax
if param.internalRelax == 0 %Exclude all internal reactions from relaxation
    param.excludedReactions(SIntRxnBool) = true;
elseif param.internalRelax == 1 % Exclude internal reactions with finite bounds
    isFin = ((model.ub(1:nRxnsOrig) < param.maxUB) & (model.lb(1:nRxnsOrig) > param.minLB)) & SIntRxnBool;
    param.excludedReactions(isFin) = true;
end

if param.exchangeRelax == 0 %Exclude all exchange reactions from relaxation
    param.excludedReactions(SExtRxnBool) = true;
elseif param.exchangeRelax == 1 % Exclude exchange reactions of the type [0,0]
    is00 = ((model.ub(1:nRxnsOrig) == 0) & (model.lb(1:nRxnsOrig) == 0)) & SExtRxnBool;
    param.excludedReactions(is00) = true;
end

% overwrite .excludedMetabolites with .steadyStateRelax
if param.steadyStateRelax == 0 %Exclude all metabolites
    param.excludedMetabolites = true(nMetsOrig,1);
end

% overwrite .excludedEvars with .extraVarRelax
if nEvars > 0
    if param.extraVarRelax == 0
        param.excludedEvars = true(nEvars, 1); % exclude all extra variables from relaxation
    elseif param.extraVarRelax == 1 % exclude extra variables with finite bounds
        isFin = (modelOrig.evarub < param.maxUB) & (modelOrig.evarlb > param.minLB);
        param.excludedEvars(isFin) = true;
    end
end
if nCtrs > 0
    if param.extraConstraintRelax == 0
            param.excludedCtrs = true(nCtrs, 1); % do not allow extra constraints
            % relaxation if .extraConstraintRelax = 0, irrespectively of
            % .excludedCtrs value
    end
end

% add relaxations from .excludedReactions/Evars to .excluded*Lb/UB
param.excludedReactionLB = param.excludedReactionLB | param.excludedReactions;
param.excludedReactionUB = param.excludedReactionUB | param.excludedReactions;

if nEvars > 0
    param.excludedEvarLB = param.excludedEvarLB | param.excludedEvars;
    param.excludedEvarUB = param.excludedEvarUB | param.excludedEvars;
end

% adapt .excluded* to expanded model
param.excludedReactionLB = [param.excludedReactionLB; param.excludedEvarLB];
param.excludedReactionUB = [param.excludedReactionUB; param.excludedEvarUB];
param.excludedReactions = [param.excludedReactions; param.excludedEvars];
param.excludedMetabolites = [param.excludedMetabolites; param.excludedCtrs];

% deal with infinite bounds
%TODO properly incorporate inf bounds
if any(model.lb==inf)
    error('Infinite lower bounds causing infeasibility.')
end
if any(model.ub==-inf)
    error('Negative infinite upper bounds causing infeasibility.')
end

infLB = (model.lb == -inf);
infUB = (model.ub ==  inf);

%add a large finite lower bound here
model.lb(infLB) = -1/feasTol;
%add a large finite upper bound here
model.ub(infUB) = 1/feasTol;

% user-defined excludedReactions/Evars in expanded model
excludedReactionsTmp = param.excludedReactions;
%use this to override some other assignment
excludedReactionLBTmp=param.excludedReactionLB | infLB;
%use this to override some other assignment
excludedReactionUBTmp=param.excludedReactionUB | infUB;
%use this to override any other assignment
excludedMetabolitesTmp=param.excludedMetabolites;

%Old - was maximising the number of active reactions, removed as this
%interfered with the relaxation unless parameters chosen sensitively
%enough
%      min  ~&~ c^T v - \gamma_1 ||v||_1 - \gamma_0 ||v||_0 + \lambda_1 ||r||_1 + \lambda_0 ||r||_0 \\

%New
%      min  ~&~ c^T v + \gamma_1 ||v||_1 + \gamma_0 ||v||_0 + \lambda_1 ||r||_1 + \lambda_0 ||r||_0 \\
%           ~&~   + \alpha_1 (||p||_1 + ||q||_1) + \alpha_0 (||p||_0 + ||q||_0) \\
%
%      s.t. ~&~ S v + r = b \\
%           ~&~ l - p \leq v \leq u + q \\
%           ~&~ r \in R^nMets \\
%           ~&~ p,q \in R_+^nRxns
%
%                      * v - reaction rate
%                      * r - relaxation on steady state constraints :math:`S*v = b`
%                      * p - relaxation on lower bound of reactions
%                      * q - relaxation on upper bound of reactions

% % weights for capped-L1
%set global parameters on zero norm if they do not exist
if ~isfield(param,'alpha') && ~isfield(param,'alpha0')
    param.alpha = 1; %weight on relaxation of bounds of reactions
end
if ~isfield(param,'lambda') && ~isfield(param,'lambda0')
    param.lambda = 1;  %weight on relaxation of steady state constraints
end
if ~isfield(param,'gamma') && ~isfield(param,'gamma0')
    %default should not be to aim for zero norm flux vector if the problem is infeasible at the begining 
    param.gamma = 0;  %weight on zero norm of reaction rate  
end

%set local paramters on zero norm for capped L1
if ~isfield(param,'alpha0')
    param.alpha0 = param.alpha; 
end
if ~isfield(param,'lambda0')
    param.lambda0 = param.lambda;    
end
if ~isfield(param,'gamma0')
    param.gamma0 = param.gamma;       
end

%set local paramters on one norm for capped L1
if ~isfield(param,'alpha1')
    param.alpha1 = feasTol; 
end
if ~isfield(param,'lambda1')
    param.lambda1 = feasTol;    
end
if ~isfield(param,'gamma1')
    %some regularisation on the flux rates to keep it well behaved
    param.gamma1 = feasTol;   
end

%override
%param.excludedReactions = param.excludedReactions |
%excludedReactionsTmp;%Minh

%rank order
param.excludedReactionLB = param.excludedReactions;
param.excludedReactionLB(~param.excludedReactionLB & excludedReactionLBTmp)=1;
param.excludedReactionLB(~param.excludedReactionLB & excludedReactionsTmp)=1;
param.excludedReactionLB(param.toBeUnblockedReactions~=0)=1;

param.excludedReactionUB = param.excludedReactions;
param.excludedReactionUB(~param.excludedReactionUB & excludedReactionUBTmp)=1;
param.excludedReactionUB(~param.excludedReactionUB & excludedReactionsTmp)=1;
param.excludedReactionUB(param.toBeUnblockedReactions~=0)=1;
param=rmfield(param,'excludedReactions');

%override
param.excludedMetabolites = param.excludedMetabolites | excludedMetabolitesTmp;

if param.printLevel>1
    disp(param)
end

%test if the problem is feasible or not
FBAsolution = optimizeCbModel(model); % optimizeCbModel can be used at
% this point because the model is expanded to include
% extra variables and constraints as additional columns and rows in S,
% otherwise optimizeCbModel would disregard extra variables
if FBAsolution.stat == 1 && ~any(param.toBeUnblockedReactions)
    disp('Model is already feasible, no relaxation is necessary. Exiting.')
    solution.stat=1;
    solution.r=zeros(nMetsOrig,1);
    solution.p=zeros(nRxnsOrig,1);
    solution.q=zeros(nRxnsOrig,1);
    solution.v=NaN*ones(nRxnsOrig,1);
    if nEvars > 0
        solution.vEvar = NaN*ones(nEvars, 1);
        solution.pEvar = zeros(nEvars, 1);
        solution.qEvar = zeros(nEvars, 1);
    end
    if nCtrs > 0
        solution.rCtrs = zeros(nCtrs, 1);
    end
    relaxedModel=modelOrig;
    return
else
    
    %too time consuming
    if isMATLABReleaseOlderThan('R2022a')
        if size(model.S,1)*size(model.S,2)<=1e4
            if any(~isfinite(model.S),'all')
                [I,J]=find(~isfinite(model.S))
                error('model.S has non-finite entries')
            end
            if any(~isfinite(model.b))
                [I,J]=find(~isfinite(model.b))
                error('model.b has non-finite entries')
            end
            if any(~isfinite(model.c))
                [I,J]=find(~isfinite(model.c))
                error('model.c has non-finite entries')
            end
        end
    else
        if ~allfinite(model.S)
            [I,J]=find(~isfinite(model.S))
            error('model.S has non-finite entries')
        end
        if ~allfinite(model.b)
            [I,J]=find(~isfinite(model.b))
            error('model.b has non-finite entries')
        end
        if ~allfinite(model.c)
            [I,J]=find(~isfinite(model.c))
            error('model.c has non-finite entries')
        end
    end

    solutionTmp = relaxFBA_cappedL1(model,param);
    
    % Attempt to handle numerical issues with small perturbations, less than
    % feasibility tolerance, that cause relaxed problem to be slightly
    % inconsistent, e.g., lb>ub can be true if one is sligly perturbed
    % solution.p(1052)
    % ans =
    %         1000
    % solution.q(1052)
    % ans =
    %   -1.7053e-13
    if isfield(solutionTmp, 'stat') && (solutionTmp.stat==1 || solutionTmp.stat==3)
        feasTol = getCobraSolverParams('LP', 'feasTol');
        solutionTmp.p(solutionTmp.p<feasTol) = 0;%lower bound relaxation
        solutionTmp.q(solutionTmp.q<feasTol) = 0;%upper bound relaxation
        solutionTmp.r(abs(solutionTmp.r)<feasTol) = 0;%steady state constraint relaxation
        
        solution.stat = solutionTmp.stat;
        solution.v = solutionTmp.v(1:nRxnsOrig);
        solution.p = solutionTmp.p(1:nRxnsOrig);
        solution.q = solutionTmp.q(1:nRxnsOrig);
        solution.r = solutionTmp.r(1:nMetsOrig);

        % split solution for expanded model with extra variables and
        % constraints
        if nEvars > 0
            solution.vEvar = solutionTmp.v(nRxnsOrig+1:nRxns);
            solution.pEvar = solutionTmp.p(nRxnsOrig+1:nRxns);
            solution.qEvar = solutionTmp.q(nRxnsOrig+1:nRxns);
        end

        if nCtrs > 0
            solution.rCtrs = solutionTmp.r(nMetsOrig+1:nMets);
        end

        %check the relaxed problem is feasible
        relaxedModel=modelOrig; % build relaxed model from the unexpanded model
        relaxedModel.lb=modelOrig.lb-solution.p;
        relaxedModel.ub=modelOrig.ub+solution.q;
        relaxedModel.b=modelOrig.b-solution.r;

        if nEvars > 0
            relaxedModel.evarlb = modelOrig.evarlb - solution.pEvar;
            relaxedModel.evarub = modelOrig.evarub + solution.qEvar;
        end

        if nCtrs > 0
            relaxedModel.d = modelOrig.d - solution.rCtrs;
        end
        
        LP = buildOptProblemFromModel(relaxedModel, true, struct());
        LPsol = solveCobraLP(LP); % do not use optimizeCbModel as it does not consider extra variables
        if LPsol.stat==1 || solution.stat==3
            if param.relaxedPrintLevel>0
                fprintf('%s\n%s\n','Relaxed model is feasible.','Statistics:')
                fprintf('%u%s\n', nnz(solution.p>=feasTol), ' lower bound relaxation(s)');
                fprintf('%u%s\n', nnz(solution.q>=feasTol), ' upper bound relaxation(s)');
                fprintf('%u%s\n', nnz(abs(solution.r)>=feasTol), ' steady state relaxation(s)');
                
                if isfield(relaxedModel,'rxns')
                    if param.relaxedPrintLevel>0 && any(solution.p>=feasTol)
                        fprintf('%s\n','The lower bound of these reactions had to be relaxed:')
                        printConstraints(relaxedModel,-inf,inf, solution.p>=feasTol,relaxedModel,0);
                    end
                    if param.relaxedPrintLevel>0 && any(solution.q>=feasTol)
                        fprintf('%s\n','The upper bound of these reactions had to be relaxed:')
                        printConstraints(relaxedModel,-inf,inf, solution.q>=feasTol,relaxedModel, 0);
                    end
                end
                if isfield(relaxedModel,'mets')
                    if param.relaxedPrintLevel>0 && any(abs(solution.r)>=feasTol)
                        fprintf('%s\n','The  steady state constraints on these metabolites had to be relaxed:')
                        T = table(relaxedModel.mets(abs(solution.r)>=feasTol),solution.r(abs(solution.r)>=feasTol),'VariableNames',{'rxns','r'});
                        disp(T);
                    end
                end
                fprintf('%s\n','... done.')
            end
            
        else
            disp(LPsol)
            error('Relaxed model may not admit a steady state. relaxedFBA failed')
        end
    else
        solution.stat = 0;
        relaxedModel=[];
    end
end
