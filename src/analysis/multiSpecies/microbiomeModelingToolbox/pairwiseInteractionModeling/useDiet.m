function [modelOut] = useDiet(modelIn, dietConstraints, printLevel)
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
%    printLevel:             Verbose level (default: printLevel = 1)
%
% OUTPUT:
%    modelOut:    model with applied constraints

% .. Authors:
%       - Almut Heinken 16.03.2017
%       - Laurent Heirendt March 2017
%       - Almut Heinken 02/2018: Generalized script for any dietary constraints as input.
%       - Federico Baldini 08/2018: adding printLevel option.

if ~exist('printLevel', 'var')
    printLevel = 1;
end

if isempty(dietConstraints) || size(dietConstraints, 2) < 2
    error('No dietary constraints entered.')
end
model = modelIn;

% Adapt constraints in dietary and fecal compartments- only for microbiota models
if any(strncmp(dietConstraints(:,1),'Diet_EX_',8))
    if  printLevel > 0
        model = changeRxnBounds(model, model.rxns(strmatch('Diet_EX_', model.rxns)), 0, 'l');
    else
        warning('off','all')
        model = changeRxnBounds(model, model.rxns(strmatch('Diet_EX_', model.rxns)), 0, 'l');
        warning('on','all')
    end        
else
    % for AGORA or pairwise model
    if  printLevel > 0
        model = changeRxnBounds(model, model.rxns(strmatch('EX_', model.rxns)), 0, 'l');
    else
        warning('off','all')
        model = changeRxnBounds(model, model.rxns(strmatch('EX_', model.rxns)), 0, 'l');
        warning('on','all')
    end      
end

for i = 1:length(dietConstraints)
        if  printLevel > 0
            model = changeRxnBounds(model, char(dietConstraints{i, 1}), str2double(dietConstraints{i, 2}), 'l');
        else
            warning('off','all')
            model = changeRxnBounds(model, char(dietConstraints{i, 1}), str2double(dietConstraints{i, 2}), 'l');
            warning('on','all')
        end    
    if size(dietConstraints, 2) > 2
        if  printLevel > 0
            model = changeRxnBounds(model, char(dietConstraints{i, 1}), str2double(dietConstraints{i, 3}), 'u');
        else
            warning('off','all')
            model = changeRxnBounds(model, char(dietConstraints{i, 1}), str2double(dietConstraints{i, 3}), 'u');
            warning('on','all')
        end        
    end
end

modelOut = model;

end
