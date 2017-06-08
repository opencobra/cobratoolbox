function [maxGrowthRate, minTarget, maxTarget] = testOptForceSol(model, targetRxn, solution, relax, tol)
%% DESCRIPTION
% This function will calculate the minimum and maximum rates for target
% production when applying a set of interventions (upregulations,
% downregulations, knockouts) in the model. Flux for each intervened 
% reaction in the mutant must be specified in the structure solution (third
% input). 

%% INPUTS
% model (obligatory):       Type: structure (COBRA model)
%                           Description: a metabolic model with at least
%                           the following fields:
%                           rxns            Reaction IDs in the model
%                           mets            Metabolite IDs in the model
%                           S               Stoichiometric matrix (sparse)
%                           b               RHS of Sv = b (usually zeros)
%                           c               Objective coefficients
%                           lb              Lower bounds for fluxes
%                           ub              Upper bounds for fluxes
%                           rev             Reversibility flag
%
% targetRxn(obligatory):    Type: string. 
%                           Description: reaction identifier for target
%                           reaction
%                           Example: targetRxn='EX_suc' 
%
% solution (obligatory):    Type: structure. 
%                           Description: structure containing information
%                           Only two fields are needed:
%                                   reactions: identifiers for reactions
%                                   that will be intervened
%                                   flux: flux achieved in the intervened
%                                   reactions. 
%                           Example;
%                           solution=struct('reactions',{{'R21';'R24'}},'flux',[10;0])
%                           In this example, the reaction R21 will be
%                           regulated at 10 (mmol/gDW h) (upregulation or
%                           downregulation depending on the value for the
%                           wild-type strain) and R21 will be regulated at
%                           0 (mmol/gDW h) (knockout)
%
%% OUTPUTS
% maxGrowthRate    Type: double
%                  Description: Maximim growth rate of mutant strain
%                  (applying the inverventions)
%
% minTarget        Type: double.
%                  Description: Minimum production rate of target at max
%                  growth rate
%
% maxTarget        Type: double.
%                  Description: Maximum production rate of target at max
%                  growth rate
%
%% CODE
%input handling
if nargin <1
    error('OptForce: model must be specified when running testOptForceSol');
else
    if ~isfield(model,'S'), error('OptForce: Missing field S in model');  end
    if ~isfield(model,'rxns'), error('OptForce: Missing field rxns in model');  end
    if ~isfield(model,'mets'), error('OptForce: Missing field mets in model');  end
    if ~isfield(model,'lb'), error('OptForce: Missing field lb in model');  end
    if ~isfield(model,'ub'), error('OptForce: Missing field ub in model');  end
    if ~isfield(model,'c'), error('OptForce: Missing field c in model'); end
    if ~isfield(model,'b'), error('OptForce: Missing field b in model'); end
end
if nargin <2
    error('OptForce: target reaction must be specified when running testOptForceSol');
else
    if ~ischar(targetRxn)
        error('OptForce: input targetRxn must be an string');
    end
end
if nargin <3
    error('OptForce: intervened reactions must be specified when running testOptForceSol');
else
    if ~isfield(solution,'reactions'), error('OptForce: Missing field reactions in solution');  end
    if ~isfield(solution,'flux'), error('OptForce: Missing field flux in solution');  end
end
if nargin<4; relax = 1; end;
% tolerance for growh rate
if nargin<5; tol = 1e-7; end;

% Number of interventions
nInt = length(solution.reactions);

% Apply interventions to model
modelForce = model;
for i = 1:nInt
    modelForce = changeRxnBounds(modelForce, solution.reactions(i), solution.flux(i), 'b');
end

% Calculate optimal growth rate in the mutant strain
solForce = optimizeCbModel(modelForce);
maxGrowthRate = solForce.f;

if solForce.stat == 1
    % find minimum and maximum production rate for target at optimal growth rate
    if relax
        grRounded = floor(solForce.f/tol)*tol; 
    else
        grRounded = solForce.f; 
    end
    modelForce = changeRxnBounds(modelForce, modelForce.rxns(modelForce.c==1), grRounded,'l');
    modelForce = changeObjective(modelForce, targetRxn);
    solMax = optimizeCbModel(modelForce, 'max');
    solMin = optimizeCbModel(modelForce, 'min');
    maxTarget = solMax.f;
    minTarget = solMin.f;
else
    warning('OptForce: infeasible model for mutant strain, according to function testOptForceSol')
    maxTarget = 0;
    minTarget = 0;
end
end