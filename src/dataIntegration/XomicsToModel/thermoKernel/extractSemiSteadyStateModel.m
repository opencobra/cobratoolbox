function [thermoModel, thermoModelMetBool, thermoModelRxnBool] = extractSemiSteadyStateModel(model,rxnWeights, metWeights, param)

if ~exist('param','var')
    param = struct();
end

metBool = ~isnan(metWeights) & metWeights~=0;
metWeights = metWeights(metBool);

if ~isfield(model,'csense')
    model.csense(1:size(model.S,1),1)='E';
end
model.csense=model.csense(metBool);

model.S = model.S(metBool,:);
if ~isfield(model,'csense')
    model.b = model.b(metBool,:);
else
    model.b = zeros(nnz(metBool),1);
end

model.mets=model.mets(metBool);

if isfield(model,'SConsistentMetBool')
    model.SConsistentMetBool = model.SConsistentMetBool(metBool);
end
if isfield(model,'fluxConsistentMetBool')
    model.fluxConsistentMetBool = model.fluxConsistentMetBool(metBool);
end

activeInactiveRxn=[];
presentAbsentMet=[];
[thermoModel, thermoModelMetBool, thermoModelRxnBool] = ...
    thermoKernel(model, activeInactiveRxn, rxnWeights, presentAbsentMet, metWeights, param);

% function [thermoModel, thermoModelMetBool, thermoModelRxnBool] = thermoKernel(model, activeInactiveRxn, rxnWeights, presentAbsentMet, metWeights, param)
% From a cobra model, extract a thermodynamically flux consistent submodel
% (thermoModel), of minimal size, optionally given:
% a set of active and inactive reactions (activeInactiveRxn), 
% a set of penalties on activity/inactivity of reactions (rxnWeights),
% a set of present and absent metabolites (presentAbsentMet), and
% a set of penalties on presence/absence of metabolites (metWeights).
%
% INPUT:
%    model:             (the following fields are required - others can be supplied)
%
%                         * S  - `m x n` Stoichiometric matrix
%                         * c  - `n x 1` Linear objective coefficients
%                         * lb - `n x 1` Lower bounds
%                         * ub - `n x 1` Upper bounds
%
% OPTIONAL INPUTS:
%    model:             (optional fields)
%          * b - `m x 1` change in concentration with time
%          * csense - `m x 1` character array with entries in {L,E,G}
%          * osenseStr: Maximize ('max')/minimize ('min') (opt, default = 'max') linear part of the objective.
%          * C - `k x n` Left hand side of C*v <= d
%          * d - `k x n` Right hand side of C*v <= d
%          * dsense - `k x 1` character array with entries in {L,E,G}
%          * beta - scalar  trade-off parameter on minimisation of one-norm of internal fluxes. Increase to incentivise thermodynamic feasibility in optCardThermo
%
%    activeInactiveRxn: - `n x 1` with entries {1,-1, 0} depending on whether a reaction must be active, inactive, or unspecified respectively.
%    rxnWeights:        - `n x 1` real valued penalties on zero norm of reaction flux, negative to promote a reaction to be active, positive 
%                                 to promote a reaction to be inactive and zero to be indifferent to activity or inactivity  
%    presentAbsentMet:  - `m x 1` with entries {1,-1, 0} depending on whether a metabolite must be present, absent, or unspecified respectively.
%    metWeights:        - `m x 1` real valued penalties on zero norm of metabolite "activity", negative to promote a metabolite to be present, positive 
%                                 to promote a metabolite to be absent and zero to be indifferent to presence or absence 
%
%    param:      Parameters structure:
%                   * .printLevel - greater than zero to recieve more output
%                   * .bigNum - definition of a large positive number (Default value = 1e6)
%                   * .nbMaxIteration -  maximal number of outer iterations (Default value = 30)
%                   * .epsilon - smallest non-zero flux - (Default value = feasTol = 1e-6)
%                   * .theta - parameter of the approximation (Default value = 2)
%                              For a sufficiently large parameter , the Capped-L1 approximate problem
%                              and the original cardinality optimisation problem are have the same set of optimal solutions
%                   * .normalizeZeroNormWeights - {(0),1}, normalises zero norm weights
%                                                 rxnWeights  = rxnWeights./sum(abs(rxnWeights));
%                                                 metWeights  = metWeights./sum(abs(metWeights));
%                   * .param.removeOrphanGenes - {(1),0}, removes orphan genes from thermoModel
%                   * .formulation - mathematical formulation of thermoKernel algorithm (use default unless expert user)
% 
% OUTPUTS:
%   thermoModel:           thermodynamically consistent model extracted from input model
%   thermoModelMetBool:   `m` x 1 boolean vector of thermodynamically consistent `mets` in input model
%   thermoModelRxnBool:   `n` x 1 boolean vector of thermodynamically consistent `rxns` in input model