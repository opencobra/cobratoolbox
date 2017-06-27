function [ constraintModel ] = eFlux( model, expression, expressionFunction, excludedReactions)
% EFLUX implementation of the EFlux algorthm byy Coljin et al.
%
% USAGE:
%
%    constraintModel = eFlux(model,expression)
%
%

if ~exist('expressionFunction','var')
    expressionFunction = @(x) x;
end

unconstraintReactions = expression == -1;
maxFlux = max(expression(~unconstraintReactions));
expression(unconstraintReactions) = 1;
expression = expressionFunction(expression/maxFlux);

model.lb(model.lb < 0) = -expression(model.lb<0);
model.ub(model.ub > 0) = expression(model.ub);

constraintModel = model;

end

