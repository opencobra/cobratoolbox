function [ constraintModel ] = eFlux( model, expression, minSum)
% Implementation of the EFlux algorthm by Coljin et al.
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

if ~isfield(expression,'preprocessed')
    expression.preprocessed = 0;
end

if ~exist('minSum','var')
    minSum = false;
end

if ~expression.preprocessed
    reactionExpression = mapExpressionToReactions(model,struct('gene',expression.target,'value',expression.value));
else
    reactionExpression = -ones(size(model.rxns));
    [pres,pos] = ismember(model.rxns,expression.target);
    reactionExpression(pres) = expression.target(pos(pres));    
end

unconstraintReactions = expression == -1;
maxFlux = max(expression(~unconstraintReactions));
expression(unconstraintReactions) = 1;
expression = expressionFunction(expression/maxFlux);

model.lb(model.lb < 0) = -expression(model.lb<0);
model.ub(model.ub > 0) = expression(model.ub);

constraintModel = model;

end

