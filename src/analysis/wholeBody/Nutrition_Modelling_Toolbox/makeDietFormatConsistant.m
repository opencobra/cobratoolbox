function [diet] = makeDietFormatConsistant(model,diet)
% This function takes a diet input and checks it for formatting consisteny 
% for input into setFoodConstraints
%
% USAGE:
%
%   [diet] = makeDietFormatConsistant(model,diet)
%
% INPUTS
%   model:             A COBRA model
%
%   diet:            A nx2 cell array containing n dietary components and
%                    the corresponding flux
% OUTPUT
%   diet:           A diet of consistent format for setFoodConstraints
%
% Authors:
%   Bronson R. Weston 2022

load fdTable.mat
load fdCategoriesTable.mat
foods=[fdTable.Properties.VariableNames(2:end),fdCategoriesTable.Properties.VariableNames(2:end)];
for i=1:length(diet(:,1))
    if ~isempty(find(strcmp(foods,diet{i,1})))
        diet{i,1}=['Food_EX_',diet{i,1},'[d]'];
    elseif ~isempty(find(strcmp(model.rxns,['Diet_EX_' diet{i,1} '[d]'])))
                disp('C')
        diet{i,1}=['Diet_EX_',diet{i,1},'[d]'];
    end
end
end

