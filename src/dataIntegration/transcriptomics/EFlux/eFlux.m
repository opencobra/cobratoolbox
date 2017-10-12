function [ constraintModel ] = eFlux( model, expression, minSum)
% Implementation of the EFlux algorithm as described in:
% Interpreting Expression Data with Metabolic Flux Models: Predicting Mycobacterium tuberculosis Mycolic Acid Production
% Colijn C, Brandes A, Zucker J, Lun DS, Weiner B, et al. (2009)
% PLOS Computational Biology 5(8): e1000489. https://doi.org/10.1371/journal.pcbi.1000489
%
% USAGE:
%
%    constraintModel = eFlux(model,expression)
%
% INPUTS:
%    model:         The model to Constrain.
%    expression:    struct with two fields required and one optional field:
%                   * .target       - the names of the target (rxns or genes)
%                   * .value        - the value for the target. Positive values
%                                     for all constraint reactions, negative
%                                     values for unconstraint reactions.
%                   * .preprocessed - Indicator whether the provided
%                                     targets are genes (false), or reactions (true)
%                                     Default: false
%
% OPTIONAL INPUTS:
%
%    minSum:       Switch for the processing of Genetic data. If false
%                  (default), ORs in the GPR will be treated as min. If
%                  true, ORs will be treated as addition.
%
% NOTE:
%
%    All Flux bounds will be reset by this function, i.e. any enforced
%    fluxes (like ATP Maintenance) will be removed!
%
% ..Authors
%     - Thomas Pfau
if ~isfield(expression,'preprocessed')
    expression.preprocessed = 0;
end

if ~exist('minSum','var')
    minSum = false;
end

if ~expression.preprocessed
    %This leads to -1 for unassociated genes
    reactionExpression = mapExpressionToReactions(model,struct('gene',expression.target,'value',expression.value));
else
    %Default : unconstraint.
    reactionExpression = -ones(size(model.rxns));
    [pres,pos] = ismember(model.rxns,expression.target);
    reactionExpression(pres) = expression.target(pos(pres));    
end

unconstraintReactions = reactionExpression == -1;
maxFlux = max(reactionExpression(~unconstraintReactions));
expression(unconstraintReactions) = 1;

expression(~unconstraintReactions) = reactionExpression(~unconstraintReactions)/maxFlux;
%Warning if Flux enforcing bounds are removed.
if(any(model.lb > 0 | model.ub < 0))
    warning('Enforcing bounds for the following fluxes have been removed:\n%s', strjoin(model.rxns((model.lb > 0 | model.ub < 0)),'\n'));
end

model.lb(model.lb < 0) = -expression(model.lb<0);
model.ub(model.ub > 0) = expression(model.ub);

constraintModel = model;

end

