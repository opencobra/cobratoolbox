function [diet] = makeDietFormatConsistant(model, diet)
% Check a diet input for formatting consistency for use with
% setFoodConstraints and return it in a consistent format
%
% USAGE:
%
%    [diet] = makeDietFormatConsistant(model, diet)
%
% INPUTS:
%    model:           A COBRA model, with fields:
%
%                       * .rxns - reaction identifiers
%    diet:            An n x 2 cell array of n dietary components and their
%                     corresponding flux
%
% OUTPUT:
%    diet:            The diet in a format consistent with setFoodConstraints
%
% .. Author: - Bronson R. Weston, 2022

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

