function [modelOut] = useDiet_AGORA_pairedModels(modelIn, diet)
% assigns a diet for the 773 AGORA microbes
% Please cite "Magnusdottir, Heinken et al., Nat Biotechnol. 2017 35(1):81-89"
% if you use this script for your own analysis.
%
% INPUT
% modelIn   original model
% diet      string that specifies the diet to be used ('Western' or 'HighFiber')
%
% OUTPUT
% modelOut  model with applied constraints
%
% Almut Heinken 16.03.2017
% Laurent Heirendt March 2017

model = modelIn;
model = changeRxnBounds(model, model.rxns(strmatch('EX_', model.rxns)), 0, 'l');

% load the diet constraints
load('dietConstraints.mat');

if strcmp(diet, 'Western')
    DietConstraints = DietConstraints_Western;
elseif strcmp(diet, 'HighFiber')
    DietConstraints = DietConstraints_HighFiber;
else
    error('The diet constraints are not available.');
end

for i = 1:length(DietConstraints)
    model = changeRxnBounds(model, DietConstraints{i, 1}, DietConstraints{i, 2}, 'l');
end

modelOut = model;

end
