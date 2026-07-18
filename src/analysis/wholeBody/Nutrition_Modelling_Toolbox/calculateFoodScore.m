function [outputMacros] = calculateFoodScore(originalFood, vmhLabelMacros, vmhMetaboliteMacros, translation)
% Calculate a similarity score between the macros of each original food item
% and its VMH alternative and add the score to the food macro structure
%
% A cosine-style distance is computed between the reported macros of the
% original food and the macros of the matched VMH food. Weights supplied in
% the template file let the user prioritise or deprioritise certain macros;
% it is suggested to keep the weight for fiber, starch and minerals set to 0.
%
% USAGE:
%
%    [outputMacros] = calculateFoodScore(originalFood, vmhLabelMacros, vmhMetaboliteMacros, translation)
%
% INPUTS:
%    originalFood:            The filled-in template table with the original
%                             food items; food names are in the first column
%                             and macro values from the seventh column onward
%    vmhLabelMacros:          Structure with one field per VMH food item, each
%                             holding a table of reported (label) macros
%    vmhMetaboliteMacros:     Structure with one field per VMH food item, each
%                             holding a table of macros computed from measured
%                             metabolite levels
%
% OPTIONAL INPUTS:
%    translation:             Cell array translating original food names to
%                             their alias (the field names in vmhLabelMacros),
%                             used to match the correct original food values.
%                             Defaults to NaN when not provided
%
% OUTPUT:
%    outputMacros:            Updated structure where, for each food item, the
%                             original food macros, the percentage of reported
%                             macros captured by measured metabolites and the
%                             similarity score are added to the macro table
%
% NOTE:
%    It is important that the template file is used, as otherwise issues could
%    arise with finding the values (starting in the 6th column), the weights
%    (the 2nd row) and calculating the differences between the original and
%    VMH macros.
%
% .. Author: - Bram Nap, 05-2024

% If translation table is not given set it to NaN
if nargin<3
    translation = NaN;
end

% Obtain the macro values and food nameas for original food items.
orgVals = [originalFood(:,1), originalFood(:, 7:end)];
orgNames = orgVals.OriginalFoodName;

% Obtain the field names of the VMH food macro structure
structNames = fieldnames(vmhLabelMacros);

for i = 1:size(structNames,1)
    % Obtain the VMH macro table
    labelMacros = vmhLabelMacros.(structNames{i});
    % Remove the column "Other" and vitamins
    labelMacros.Other = [];
    labelMacros.("Vitamins/Minerals/Elements") = [];
    labelMacros.Carbohydrates = [];
    if ~isempty(translation)
        % If translation array is given change the name of the original item in
        % the original food table to its alias
        shadow2food = translation(strcmp(translation(:,2), structNames(i)),1);
        orgSpefVals = orgVals(strcmp(orgNames,shadow2food),:);
    else
        % If translation is not given we assume the field names and the
        % original food names are the same.
        orgSpefVals = orgVals(structNames(i),:);
        warning("No translation array is given and could lead to errors in finding to correct entries")
    end
    
    % Obtain the macros of the original food
    orgNumbers = orgSpefVals{1, 2:end}';
    
    % Obtain the label macros for the VMH food
    labelMacrosValues = labelMacros{:,2:end};

    % Find any NaN in the original data and remove it from analysis
    labelMacrosValues(:,isnan(orgNumbers)) = [];
    orgNumbers(isnan(orgNumbers)) = [];
    orgNumbers = orgNumbers';
    
    % Obtain the similarity score through cosine method
    similarityScore = zeros(size(labelMacrosValues,1),1);
    for j = 1:size(labelMacrosValues,1)
        similarityScore(j,1) = sqrt(bsxfun(@plus, sum(orgNumbers.^2,2), sum(labelMacrosValues(j,:).^2,2)')- 2*(orgNumbers*labelMacrosValues(j,:)'));
    end
    
    similarityScore = [0;similarityScore];
    % set the headers so for smooth merging later
    orgSpefVals.Properties.VariableNames = labelMacros.Properties.VariableNames;
    
    % Extract the macronutrients calculated from measured metabolite levels
    metMacros = vmhMetaboliteMacros.(structNames{i});
    metMacros.("Vitamins/Minerals/Elements") = [];
    metMacros.Other = [];
    metMacros.Carbohydrates = [];
    
    % Calculate the percentage of the calculated metabolite macros /
    % reported macros.
    percentageMeasured = metMacros{:, 2:end}./labelMacros{:,2:end} * 100;
    percentageMeasured(isnan(percentageMeasured)) = 0;
    percentageMeasured = array2table(strcat(string(percentageMeasured), '%'));
    
    % Set as table and merge with the original values
    percentageMeasured = [metMacros.FoodItem, percentageMeasured];
    percentageMeasured.Properties.VariableNames = metMacros.Properties.VariableNames;

    orgSpefVals{1,2:end} = string(orgSpefVals{1,2:end});

    comparedMacros = [orgSpefVals;percentageMeasured];
    % Set the similarity score and store in the structure
    comparedMacros.similarityScore = similarityScore;
    outputMacros.(structNames{i}) = comparedMacros;
end
end
