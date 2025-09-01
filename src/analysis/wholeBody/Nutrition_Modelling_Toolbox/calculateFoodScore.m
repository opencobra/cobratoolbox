function [outputMacros] = calculateFoodScore(originalFood, vmhLabelMacros, vmhMetaboliteMacros, translation)
% Calculates a score based on how similar the macros of the original food
% are with its VMH alternative. The score is added to the vmhFood
% structure. The user can add on weights in the template file to prioritise
% or deprioritise certain macros. It is suggested to have the weight for
% fiber, starch and minerals always set to 0.
% Usage:
%   [vmhFood] = calculateFoodScore(originalFood, vmhFood, translation)
% Inputs:
%   originalFood:   The filled in template file with the original food items
%   vmhFoodMacros:  A structure with each field a food item that contain a
%                   table with their macros
% Optional input:
%   translation:    A cell with a translation of food items to a alias. The
%                   alias is the name of the fields in vmhFoodMacros. Used
%                   to obtain the correct original food item values
% Output:
%  vmhFoodMacros:   An updated vmhFoodMacro structure where the original
%                   food item macros and the calculated scores are added to
%                   each fields macro table
% Example:
%   [vmhFood] = calculateFoodScore(originalFood, vmhFood, translation)
% Note:
%   It is important that the template file is used as otherwise issues could
%   arise with finding the values (starting in the 6th column), the weights
%   (the 2nd row) and calculating the differences between the original and
%   VMH macros.
% .. Author - Bram Nap, 05-2024

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
