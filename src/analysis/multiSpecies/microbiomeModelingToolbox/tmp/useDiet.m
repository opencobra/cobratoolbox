function [modelOut] = useDiet(modelIn, dietConstraints)
% Implements diet constraints in a COBRA model structure.
%
% USAGE:
%
%    [modelOut] = useDiet(modelIn, dietConstraints)
%
% INPUTS:
%    modelIn:                original model
%    dietConstraints:        cell array of three columns containing
%                            exchanges, lower bounds, and  upper bounds respectively
%
% OUTPUT:
%    modelOut:    model with applied constraints

% .. Authors:
%       - Almut Heinken 16.03.2017
%       - Laurent Heirendt March 2017
%       - Almut Heinken 02/2018: Generalized script for any dietary constraints as input.

if isempty(dietConstraints) || size(dietConstraints, 2) < 2
    error('No dietary constraints entered.')
end
model = modelIn;
model = changeRxnBounds(model, model.rxns(strmatch('EX_', model.rxns)), 0, 'l');

for i = 1:length(dietConstraints)
    model = changeRxnBounds(model, char(dietConstraints{i, 1}), str2double(dietConstraints{i, 2}), 'l');
    if size(dietConstraints, 2) > 2
    model = changeRxnBounds(model, char(dietConstraints{i, 1}), str2double(dietConstraints{i, 3}), 'u');
    end
end

modelOut = model;

end
