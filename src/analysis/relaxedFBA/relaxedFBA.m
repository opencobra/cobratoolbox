function [solution] = relaxedFBA(model, relaxOption)
%
% Finds the mimimal set of relaxations on bounds and steady state
% constraints to make the FBA problem feasible
%
% .. math::
%      min ~&~ c^T v + \lambda ||r||_0 + \alpha (||p||_0 + ||q||_0) \\
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
%    [solution] = relaxedFBA(model, relaxOption)
%
% INPUTS:
%    model:          COBRA model structure
%    relaxOption:    Structure containing the relaxation options:
%
%                      * internalRelax:
%
%                        * 0 = do not allow to relax bounds on internal reactions
%                        * 1 = do not allow to relax bounds on internal reactions with finite bounds
%                        * 2 = allow to relax bounds on all internal reactions
%
%                      * exchangeRelax:
%
%                        * 0 = do not allow to relax bounds on exchange reactions
%                        * 1 = do not allow to relax bounds on exchange reactions of the type [0,0]
%                        * 2 = allow to relax bounds on all exchange reactions
%
%                      * steadyStateRelax:
%
%                        * 0 = do not allow to relax the steady state constraint S*v = b
%                        * 1 = allow to relax the steady state constraint S*v = b
%
%                      * toBeUnblockedReactions - n x 1 vector indicating the reactions to be unblocked (optional)
%
%                        * toBeUnblockedReactions(i) = 1 : impose v(i) to be positive
%                        * toBeUnblockedReactions(i) = -1 : impose v(i) to be negative
%                        * toBeUnblockedReactions(i) = 0 : do not add any constraint
%
%                      * excludedReactions - n x 1 bool vector indicating the reactions to be excluded from relaxation (optional)
%
%                        * excludedReactions(i) = false : allow to relax bounds on reaction i
%                        * excludedReactions(i) = true : do not allow to relax bounds on reaction i
%
%                      * excludedMetabolites - m x 1 bool vector indicating the metabolites to be excluded from relaxation (optional)
%
%                        * excludedMetabolites(i) = false : allow to relax steady state constraint on metabolite i
%                        * excludedMetabolites(i) = true : do not allow to relax steady state constraint on metabolite i
%
%                      * lamda - weighting on relaxation of relaxation on steady state constraints S*v = b
%                      * alpha - weighting on relaxation of reaction bounds
%                      * gamma - weighting on zero norm of fluxes
%
% Note, excludedReactions and excludedMetabolites override all other relaxation options.
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
% .. Author: - Hoai Minh Le	15/11/2015
%

[m,n] = size(model.S); %Check inputs


if isfield(model,'SIntRxnBool')
    intRxnBool = model.SIntRxnBool;
    exRxnBool = ~intRxnBool;
else
    model_Ex = findSExRxnInd(model);
    intRxnBool = model_Ex.SIntRxnBool;
    exRxnBool = ~intRxnBool;
end



maxUB = max(model.ub); % maxUB is considered as +inf
minLB = min(model.lb); % minLB is considered as -inf

% If no relax option is given than allow to relax anything
if nargin < 2
    relaxOption.internalRelax           = 2;
    relaxOption.exchangeRelax           = 2;
    relaxOption.steadyStateRelax        = 1;
    relaxOption.toBeUnblockedReactions  = zeros(n,1);
    relaxOption.excludedReactions       = false(n,1);
    relaxOption.excludedMetabolites     = false(m,1);
end

if nargin < 3
    if isfield(relaxOption,'internalRelax') == 0
        relaxOption.internalRelax = 2;
    else
        if relaxOption.internalRelax < 0 || relaxOption.internalRelax > 2
                solution.status = -1;
                error('Incorrect input : internalRelax')
        end
    end

    if isfield(relaxOption,'exchangeRelax') == 0
        relaxOption.exchangeRelax = 2;
    else
        if relaxOption.exchangeRelax < 0 || relaxOption.exchangeRelax > 2
                solution.status = -1;
                error('Incorrect input : exchangeRelax')
        end
    end

    if isfield(relaxOption,'steadyStateRelax') == 0
        relaxOption.exchangeRelax = 1;
    else
        if relaxOption.steadyStateRelax < 0 || relaxOption.steadyStateRelax > 1
                solution.status = -1;
                error('Incorrect input : steadyStateRelax')
        end
    end

    if isfield(relaxOption,'toBeUnblockedReactions') == 0
        relaxOption.toBeUnblockedReactions = zeros(n,1);
    end

    if isfield(relaxOption,'excludedReactions') == 0
        relaxOption.excludedReactions = false(n,1);
    end
    %use this to override any other assignment
    excludedReactionsTmp=relaxOption.excludedReactions;

    if isfield(relaxOption,'excludedMetabolites') == 0
        relaxOption.excludedMetabolites = false(m,1);
    end
    %use this to override any other assignment
    excludedMetabolitesTmp=relaxOption.excludedMetabolites;
end

%set global parameters on zero norm if they do not exist
if ~isfield(relaxOption,'alpha')
    relaxOption.alpha = 10; 
end
if ~isfield(relaxOption,'lambda')
    relaxOption.lambda = 10;    
end
if ~isfield(relaxOption,'gamma')
    relaxOption.gamma = 10;   
end

%set local paramters on zero norm for capped L1
if ~isfield(relaxOption,'alpha0')
    relaxOption.alpha0 = relaxOption.alpha; 
end
if ~isfield(relaxOption,'lambda0')
    relaxOption.lambda0 = relaxOption.lambda;    
end
if ~isfield(relaxOption,'gamma0')
    relaxOption.gamma0 = relaxOption.gamma;   
end

%set local paramters on one norm for capped L1
if ~isfield(relaxOption,'alpha1')
    relaxOption.alpha1 = relaxOption.alpha0/10; 
end
if ~isfield(relaxOption,'lambda1')
    relaxOption.lambda1 = relaxOption.lambda0/10;    
end
if ~isfield(relaxOption,'gamma1')
    relaxOption.gamma1 = relaxOption.gamma0/10;   
end

%Combine excludedReactions with internalRelax and exchangeRelax
if relaxOption.internalRelax == 0 %Exclude all internal reactions
    relaxOption.excludedReactions(intRxnBool) = true;
elseif relaxOption.internalRelax == 1 % Exclude internal reactions with finite bounds
    index_IntRxnFiniteBound = find(((model.ub < maxUB) & (model.lb > minLB)) & intRxnBool);
    relaxOption.excludedReactions(index_IntRxnFiniteBound) = true;
end

if relaxOption.exchangeRelax == 0 %Exclude all exchange reactions
    relaxOption.excludedReactions(exRxnBool) = true;
elseif relaxOption.exchangeRelax == 1 % Exclude exchange reactions of the type [0,0]
    index_ExRxn00 = find(((model.ub == 0) & (model.lb == 0)) & exRxnBool);
    relaxOption.excludedReactions(index_ExRxn00) = true;
end

%override
relaxOption.excludedReactions = relaxOption.excludedReactions | excludedReactionsTmp;

%Combine excludedMetabolites with steadyStateRelax
if relaxOption.steadyStateRelax == 0 %Exclude all metabolites
    relaxOption.excludedMetabolites = true(m,1);
end

%override
relaxOption.excludedMetabolites = relaxOption.excludedMetabolites | excludedMetabolitesTmp;

% Call the solver
solution = relaxFBA_cappedL1(model,relaxOption);

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
% relaxOption.epsilon = feasTol;
% solution.p(solution.p<feasTol) = 0;%lower bound relaxation
% solution.q(solution.q<feasTol) = 0;%upper bound relaxation
% solution.r(solution.r<feasTol) = 0;%steady state constraint relaxation

end
