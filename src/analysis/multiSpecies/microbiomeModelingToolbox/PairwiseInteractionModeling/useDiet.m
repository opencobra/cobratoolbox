function [modelOut] = useDiet(modelIn, dietConstraints)
% Implements diet constraints in a COBRA model structure.
% USAGE:
%
%    [modelOut] = useDiet(modelIn, dietConstraints)
%
% INPUTS:
%    modelIn:     original model
%    dietConstraints:        cell array of three columns containing 
% exchanges, lower bounds, and  upper bounds respectively
%
% OUTPUT:
%    modelOut:    model with applied constraints

% .. Authors:
%       - Almut Heinken 16.03.2017
%       - Laurent Heirendt March 2017
%       - Almut Heinken 02/2018: Generalized script for any dietary
%       constraints as input.

model = modelIn;
model = changeRxnBounds(model, model.rxns(strmatch('EX_', model.rxns)), 0, 'l');

for i = 1:length(dietConstraints)
    model = changeRxnBounds(model, dietConstraints{i, 1}, dietConstraints{i, 2}, 'l');
    model = changeRxnBounds(model, dietConstraints{i, 1}, dietConstraints{i, 3}, 'u');
end

modelOut = model;

end
