function solution = relaxedFBA(model, param)
%
% Finds the mimimal set of relaxations on bounds and steady state
% constraints to make the FBA problem feasible. The optional parameters,
% excludedReactions and excludedMetabolites override all other relaxation options.
%
% .. math::
%      min ~&~ c^T v + \gamma ||v||_0 + \lambda ||r||_0 + \alpha (||p||_0 + ||q||_0) \\
%      s.t ~&~ S v + r \leq, =, \geq  b \\
%          ~&~ l - p \leq v \leq u + q \\
%          ~&~ r \in R^m \\
%          ~&~ p,q \in R_+^n
%
% `m` - number of metabolites,
% `n` - number of reactions
%
% USAGE:
%
%    [solution] = relaxedFBA(model, param)
%
% INPUTS:
%    model:          COBRA model structure
%
% OPTIONAL INPUTS:
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
%                        * {0} = do not allow to relax the steady state constraint S*v = b
%                        *   1 = allow to relax the steady state constraint S*v = b
%
%                      * toBeUnblockedReactions - n x 1 vector indicating the reactions to be unblocked
%
%                        * toBeUnblockedReactions(i) = 1 : impose v(i) to be positive
%                        * toBeUnblockedReactions(i) = -1 : impose v(i) to be negative
%                        * toBeUnblockedReactions(i) = 0 : do not add any constraint (default)
%
%                      * excludedReactions - n x 1 bool vector indicating the reactions to be excluded from relaxation
%
%                        * excludedReactions(i) = false : allow to relax bounds on reaction i (default)
%                        * excludedReactions(i) = true : do not allow to relax bounds on reaction i 
%
%                      * excludedMetabolites - m x 1 bool vector indicating the metabolites to be excluded from relaxation
%
%                        * excludedMetabolites(i) = false : allow to relax steady state constraint on metabolite i (default)
%                        * excludedMetabolites(i) = true : do not allow to relax steady state constraint on metabolite i
%
%                      * lamda - weighting on relaxation of relaxation on steady state constraints S*v = b
%                      * alpha - weighting on relaxation of reaction bounds
%                      * gamma - weighting on zero norm of fluxes
%
%                     * .nbMaxIteration - stopping criteria - number maximal of iteration (Defaut value = 1000)
%                     * .epsilon - stopping criteria - (Defaut value = 10e-6)
%                     * .theta - parameter of the approximation (Defaut value = 0.5)
%
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
% .. Authors: - Hoai Minh Le, Ronan Fleming	15/11/2015
%

[m,n] = size(model.S); %Check inputs


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
    param.steadyStateRelax = 0; %do not allow steady state constraint to be relaxed
else
    if param.steadyStateRelax < 0 || param.steadyStateRelax > 1
        solution.status = -1;
        error('Incorrect input : steadyStateRelax')
    end
end

if isfield(param,'toBeUnblockedReactions') == 0
    param.toBeUnblockedReactions = zeros(n,1);
end

if isfield(param,'excludedReactions') == 0
    param.excludedReactions = false(n,1);
end
%use this to override any other assignment
excludedReactionsTmp=param.excludedReactions;

if isfield(param,'excludedMetabolites') == 0
    param.excludedMetabolites = false(m,1);
end

%use this to override any other assignment
excludedMetabolitesTmp=param.excludedMetabolites;

if isfield(param,'nbMaxIteration') == 0
    param.nbMaxIteration = 1000;
end

if isfield(param,'epsilon') == 0
    param.epsilon = 10e-6;
end

if isfield(param,'theta') == 0
    param.theta   = 0.5;
end
    
%      min  ~&~ c^T v - \gamma_1 ||v||_1 - \gamma_0 ||v||_0 + \lambda_1 ||r||_1 + \lambda_0 ||r||_0 \\
%           ~&~   + \alpha_1 (||p||_1 + ||q||_1) + \alpha_0 (||p||_0 + ||q||_0) \\
%      s.t. ~&~ S v + r = b \\
%           ~&~ l - p \leq v \leq u + q \\
%           ~&~ r \in R^m \\
%           ~&~ p,q \in R_+^n
%                      * r - relaxation on steady state constraints :math:`S*v = b`
%                      * p - relaxation on lower bound of reactions
%                      * q - relaxation on upper bound of reactions
%                      * v - reaction rate

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
    param.gamma1 = 1e-6 + param.gamma0/10;   
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
param.excludedReactions = param.excludedReactions | excludedReactionsTmp;

%Combine excludedMetabolites with steadyStateRelax
if param.steadyStateRelax == 0 %Exclude all metabolites
    param.excludedMetabolites = true(m,1);
end

%override
param.excludedMetabolites = param.excludedMetabolites | excludedMetabolitesTmp;

% Call the solver
if 1
    param
end
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
% feasTol = getCobraSolverParams('LP', 'feasTol');
% param.epsilon = feasTol;
% solution.p(solution.p<feasTol) = 0;%lower bound relaxation
% solution.q(solution.q<feasTol) = 0;%upper bound relaxation
% solution.r(solution.r<feasTol) = 0;%steady state constraint relaxation

end
