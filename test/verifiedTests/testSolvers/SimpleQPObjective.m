function [ function_value] = SimpleQPObjective( values, Problem)
%SimpleQPObjective Calculates obj.*sum(x.^2)
%   Where obj is provided as objArguments{1} of the Problem struct.

obj = Problem.objArguments{1};

function_value = sum(obj.*values.^2);
end

