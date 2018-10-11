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
%    model:          COBRA model structure
%    model.S
%    model.SIntRxnBool
%
% OPTIONAL INPUTS:
%    model:          COBRA model structure
%    model.SIntRxnBool
%
%
%    param:    Structure optionally containing the relaxation parameters:
%
%                      * internalRelax:
%
%                        * 0 = do not allow to relax bounds on internal reactions
%                        * 1 = do not allow to relax bounds on internal reactions with finite bounds
%                        * {2} = allow to relax bounds on all internal reactions
%
%                      * exchangeRelax:
%
%                        * 0 = do not allow to relax bounds on exchange reactions
%                        * 1 = do not allow to relax bounds on exchange reactions of the type [0,0]
%                        * {2} = allow to relax bounds on all exchange reactions
%
%                      * steadyStateRelax:
%
%                        *    0 = do not allow to relax the steady state constraint S*v = b
%                        *  {1} = allow to relax the steady state constraint S*v = b
%
%                      * toBeUnblockedReactions - nRxns x 1 vector indicating the reactions to be unblocked
%
%                        * toBeUnblockedReactions(i) = 1 : impose v(i) to be positive
%                        * toBeUnblockedReactions(i) = -1 : impose v(i) to be negative
%                        * toBeUnblockedReactions(i) = 0 : do not add any constraint (default)
%
%                      * excludedReactions - nRxns x 1 bool vector indicating the reactions to be excluded from relaxation
%
%                        * excludedReactions(i) = false : allow to relax bounds on reaction i (default)
%                        * excludedReactions(i) = true : do not allow to relax bounds on reaction i 
%
%                      * excludedReactionLB - nRxns x 1 bool vector indicating
%                      the reactions with lower bounds to be excluded from
%                      relaxation (overridden by excludedReactions)
%
%                        * excludedReactionLB(i) = false : allow to relax lower bounds on reaction i (default)
%                        * excludedReactionLB(i) = true : do not allow to relax lower bounds on reaction i 
%
%                      * excludedReactionUB - nRxns x 1 bool vector indicating
%                      the reactions with upper bounds to be excluded from relaxation (overridden by excludedReactions)
%
%                        * excludedReactionUB(i) = false : allow to relax upper bounds on reaction i (default)
%                        * excludedReactionUB(i) = true : do not allow to relax upper bounds on reaction i 
%
%                      * excludedMetabolites - nMets x 1 bool vector indicating the metabolites to be excluded from relaxation
%
%                        * excludedMetabolites(i) = false : allow to relax steady state constraint on metabolite i (default)
%                        * excludedMetabolites(i) = true : do not allow to relax steady state constraint on metabolite i
%
%                      * lamda - weighting on relaxation of relaxation on steady state constraints S*v = b
%                      * alpha - weighting on relaxation of reaction bounds
%                      * gamma - weighting on zero norm of fluxes
%
%                     * .nbMaxIteration - stopping criteria - number maximal of iteration (Default value = 100)
%                     * .epsilon - stopping criteria - (Default value = 1e-6)
%                     * .theta0 - initial parameter of the approximation (Default value = 0.5)
%                                 Theoretically, the greater the value of step parameter, the better the approximation of a step function.
%                                 However, practically, a greater inital value, will tend to optimise toward a local minima of the approximate 
%                                 cardinality optimisation problem.
%                     * .printLevel (Default = 0) Printing the progress of
%                     the algorithm is useful when trying different values
%                     of theta0 to start with the appropriate parameter
%                     giving the lowest cardinality solution.
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
%
% relaxedModel       model structure that admits a flux balance solution
%
% .. Authors: - Hoai Minh Le, Ronan Fleming
%              

if isfield(model,'E')
    issueConfirmationWarning('relaxedFBA ignores additional variables defined in the model (model field .E)!')
end


[nMets,nRxns] = size(model.S); %Check inputs

if ~isfield(param,'maxUB')
    param.maxUB = max(max(model.ub),-min(model.lb));
end
if ~isfield(param,'maxLB')
    param.minLB = min(-max(model.ub),min(model.lb));
end
if ~isfield(param,'maxRelaxR')
    param.maxRelaxR = 1000; %TODO - check this for multiscale models
end
if ~isfield(param,'printLevel')
    param.printLevel = 0; %TODO - check this for multiscale models
else
    printLevel=param.printLevel;
end
if isfield(model,'SIntRxnBool')
    SIntRxnBool = model.SIntRxnBool;
else
    model_Ex = findSExRxnInd(model);
    SIntRxnBool = model_Ex.SIntRxnBool;
end

maxUB = max(model.ub); % maxUB is considered as +inf
minLB = min(model.lb); % minLB is considered as -inf

if isfield(param,'internalRelax') == 0
    param.internalRelax = 2; %allow all internal reaction bounds to be relaxed
else
    if param.internalRelax < 0 || param.internalRelax > 2
        solution.status = -1;
        error('Incorrect input : internalRelax')
    end
end

if isfield(param,'exchangeRelax') == 0
    param.exchangeRelax = 2; %allow all exchange reaction bounds to be relaxed
else
    if param.exchangeRelax < 0 || param.exchangeRelax > 2
        solution.status = -1;
        error('Incorrect input : exchangeRelax')
    end
end

if isfield(param,'steadyStateRelax') == 0
    param.steadyStateRelax = 1; %do not allow steady state constraint to be relaxed
else
    if param.steadyStateRelax < 0 || param.steadyStateRelax > 1
        solution.status = -1;
        error('Incorrect input : steadyStateRelax')
    end
end

if isfield(param,'toBeUnblockedReactions') == 0
    param.toBeUnblockedReactions = zeros(nRxns,1);
end

if isfield(param,'excludedReactionLB') == 0
    param.excludedReactionLB = false(nRxns,1);
end
%use this to override some other assignment
excludedReactionLBTmp=param.excludedReactionLB;

if isfield(param,'excludedReactionUB') == 0
    param.excludedReactionUB = false(nRxns,1);
end
%use this to override some other assignment
excludedReactionUBTmp=param.excludedReactionUB;

if isfield(param,'excludedReactions') == 0
    param.excludedReactions = false(nRxns,1);
end
%use this to override all other assignment
excludedReactionsTmp=param.excludedReactions;

if isfield(param,'excludedMetabolites') == 0
    param.excludedMetabolites = false(nMets,1);
end

%use this to override any other assignment
excludedMetabolitesTmp=param.excludedMetabolites;

if isfield(param,'nbMaxIteration') == 0
    param.nbMaxIteration = 100;
end

if isfield(param,'epsilon') == 0
    param.epsilon = 1e-6;
end

if isfield(param,'theta0') == 0
    param.theta0   = 0.5;
end

%make sure C is present if d is present
if ~isfield(model,'C') && isfield(model,'d')
    error('For the constraints C*v <= d, both must be present')
end

if isfield(model,'C')
    [nIneq,nltC]=size(model.C);
    [nIneq2,nltd]=size(model.d);
    if nltC~=nRxns
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
        if printLevel>1
            fprintf('%s\nRxns','No defined csense.')
            fprintf('%s\nRxns','We assume that all mass balance constraints are equalities, i.e., S*v = 0')
        end
        model.csense(1:nMets,1) = 'E';
    else
        if length(model.csense)==nMets
            model.csense = columnVector(model.csense);
        else
            if length(model.csense)==nMets+nIneq
                %this is a workaround, a model should not be like this
                model.dsense=model.csense(nMets+1:nMets+nIneq,1);
                model.csense=model.csense(1:nMets,1);
            else
                error('Length of csense is invalid!')
            end
        end
    end
    
    if ~isfield(model,'dsense')
        if printLevel>1
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
        if printLevel>1
            fprintf('%s\nRxns','We assume that all mass balance constraints are equalities, i.e., S*v = dxdt = 0')
        end
        model.csense(1:nMets,1) = 'E';
    else % if csense is in the model, move it to the lp problem structure
        if length(model.csense)~=nMets
            error('The length of csense does not match the number of rows of model.S.')
            model.csense(1:nMets,1) = 'E';
        else
            model.csense = columnVector(model.csense);
        end
    end
end

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


%set global parameters on zero norm if they do not exist
if ~isfield(param,'alpha') && ~isfield(param,'alpha0')
    param.alpha = 10; %weight on relaxation of bounds of reactions
end
if ~isfield(param,'lambda') && ~isfield(param,'lambda0')
    param.lambda = 10;  %weight on relaxation of steady state constraints
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
    param.alpha1 = param.alpha0/10; 
end
if ~isfield(param,'lambda1')
    param.lambda1 = param.lambda0/10;    
end
if ~isfield(param,'gamma1')
    %always include some regularisation on the flux rates to keep it well
    %behaved
    param.gamma1 = 0*1e-6 + param.gamma0/10;   
end

%Combine excludedReactions with internalRelax and exchangeRelax
if param.internalRelax == 0 %Exclude all internal reactions
    param.excludedReactions(SIntRxnBool) = true;
elseif param.internalRelax == 1 % Exclude internal reactions with finite bounds
    index_IntRxnFiniteBound_Bool = ((model.ub < maxUB) & (model.lb > minLB)) & SIntRxnBool;
    param.excludedReactions(index_IntRxnFiniteBound_Bool) = true;
end

if param.exchangeRelax == 0 %Exclude all exchange reactions
    param.excludedReactions(~SIntRxnBool) = true;
elseif param.exchangeRelax == 1 % Exclude exchange reactions of the type [0,0]
    index_ExRxn00_Bool = ((model.ub == 0) & (model.lb == 0)) & ~SIntRxnBool;
    param.excludedReactions(index_ExRxn00_Bool) = true;
end

%override
%param.excludedReactions = param.excludedReactions |
%excludedReactionsTmp;%Minh

%rank order
param.excludedReactionLB = param.excludedReactions;
param.excludedReactionLB(~param.excludedReactionLB & excludedReactionLBTmp)=1;
param.excludedReactionLB(~param.excludedReactionLB & excludedReactionsTmp)=1;

param.excludedReactionUB = param.excludedReactions;
param.excludedReactionUB(~param.excludedReactionUB & excludedReactionUBTmp)=1;
param.excludedReactionUB(~param.excludedReactionUB & excludedReactionsTmp)=1;
param=rmfield(param,'excludedReactions');

%Combine excludedMetabolites with steadyStateRelax
if param.steadyStateRelax == 0 %Exclude all metabolites
    param.excludedMetabolites = true(nMets,1);
end

%override
param.excludedMetabolites = param.excludedMetabolites | excludedMetabolitesTmp;


%test if the problem is feasible or not
FBAsolution = optimizeCbModel(model);
if FBAsolution.stat == 1
    disp('Model is already feasible, no relaxation is necessary. Exiting.')
    solution.stat=1;
    solution.r=zeros(nMets,1);
    solution.p=zeros(nRxns,1);
    solution.q=zeros(nRxns,1);
    solution.v=NaN*ones(nRxns,1);
    relaxedModel=model;
    return
else
    solution = relaxFBA_cappedL1(model,param);
    
    % Attempt to handle numerical issues with small perturbations, less than
    % feasibility tolerance, that cause relaxed problem to be slightly
    % inconsistent, e.g., lb>ub can be true if one is sligly perturbed
    % solution.p(1052)
    % ans =
    %         1000
    % solution.q(1052)
    % ans =
    %   -1.7053e-13
    if solution.stat==1
        feasTol = getCobraSolverParams('LP', 'feasTol');
        solution.p(solution.p<feasTol) = 0;%lower bound relaxation
        solution.q(solution.q<feasTol) = 0;%upper bound relaxation
        solution.r(abs(solution.r)<feasTol) = 0;%steady state constraint relaxation
        
        %check the relaxed problem is feasible
        relaxedModel=model;
        relaxedModel.lb=model.lb-solution.p;
        relaxedModel.ub=model.ub+solution.q;
        relaxedModel.b=relaxedModel.b-solution.r;
        
        LPsol = solveCobraLP(relaxedModel, 'printLevel',0);%,'feasTol', 1e-5,'optTol', 1e-5);
        if LPsol.stat~=1
            disp(LPsol)
            error('Relaxed model does not admit a steady state. relaxedFBA failed')
        end
    else
        relaxedModel=[];
    end
end
