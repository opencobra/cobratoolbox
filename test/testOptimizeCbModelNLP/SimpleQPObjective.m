function [ function_value] = SimpleQPObjective( values, Problem)
%SIMPLELPOBJECTIVE Optimizes a simple QP objective for an input.
%   Detailed explanation goes here

obj = Problem.objArguments{1};

function_value = -sum(obj.*values.^2);
end

