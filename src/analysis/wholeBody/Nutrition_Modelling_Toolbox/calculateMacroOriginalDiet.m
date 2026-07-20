function orgMacroDiet = calculateMacroOriginalDiet(diet, originalMacroTable)
% Calculate the macro composition of a diet from the original macros given
% in the template file used to choose VMH food item alternatives
%
% USAGE:
%
%    orgMacroDiet = calculateMacroOriginalDiet(diet, originalMacroTable)
%
% INPUTS:
%    diet:                 An n x 2 cell array; column one holds the original
%                          food names and column two the respective amounts
%                          eaten (in grams)
%    originalMacroTable:     The filled-in template table. Macro values are read
%                          from columns 6-15 and normalised per gram using the
%                          "WeightEaten (g)" column, food items are matched on
%                          the OriginalFoodName column, and the table
%                          `.Properties.VariableNames` provide the macro names
%
% OUTPUT:
%    orgMacroDiet:         Table with the total macro composition of the given
%                          diet based on the original food item macros:
%
%                            * .macroNames - names of the macronutrients
%                            * .values_g - total amount of each macro (grams)
%
% NOTE:
%    It is important that the template file base structure is not altered as
%    the basic structure is assumed here to perform the calculations.
%
% .. Author: - Bram Nap, 09-2024

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