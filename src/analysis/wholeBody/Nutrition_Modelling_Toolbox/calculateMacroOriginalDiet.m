function orgMacroDiet = calculateMacroOriginalDiet(diet, originalMacroTable)
%  Calucalte the macro composition of the diet based on the original macros
%  given in the template file used to choose VMH food item alternatives.
%
% Usage:
%   macroDiet = calculateMacroOriginalDiet(diet, originalMacroTable)
%
% Inputs:
%   diet:               A nx2 cell array. Column one has to original food 
%                       names, column 2 has the respective amounts eaten
%   originalMacroTable: A table. The filled in template file
% 
% Output:
%   macroDiet:  A cell array with the total macro composition of the the
%               given diet based on the original food item macros
% Example:
%   macroDiet = calculateMacroOriginalDiet(diet, originalMacroTable)
% 
% Note:
%   It is important that the template file base structure is not altered as
%   we assume the basic structure here to perform calculations
% 
% Authors
%   .. Bram Nap, 09-2024

% Remove all food items that have a weight eaten of 0
diet(cell2mat(diet(:,2))==0,:)=[];

% Obtain the macro values from the original items and normalise them to per
% 1 g eaten
values = originalMacroTable{2:end, 6:15};
valuesNorm = values./originalMacroTable.("WeightEaten (g)")(2:end);

% Obtain indexes of items in the diet in the original food items table
[~,~,idx] = intersect(diet(:,1), originalMacroTable.OriginalFoodName(2:end), 'stable');

% Calculate the normalised original food macros with the amount eaten in
% the diet
valuesDiet = valuesNorm(idx,:) .* cell2mat(diet(:,2));

% Sum all macros of the diet
macroDiet = sum(valuesDiet,1)';

macroDiet(isnan(macroDiet)) = 0;
% Add names of macros
orgMacroDiet = table();
orgMacroDiet.macroNames = originalMacroTable.Properties.VariableNames(6:15)';
orgMacroDiet.values_g = macroDiet;

end