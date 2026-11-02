% The COBRAToolbox: testCalculateFoodScore.m
%
% Purpose:
%     - calculateFoodScore compares the nutrient values of original foods with food-label and measured (metabolite) macros and returns, per food, a table with similarity scores.
%       Characterization test that PINS the current behaviour (feature
%       026-tier1-test-batch2, Constitution Principle III characterization mode);
%       it must not change the function under test.
%     - Defect(s) fixed by feature 20261102-140321-tier1-safe-defect-fixes: Default translation
%       assigned when nargin < 3.
%
% Function under test:
%     src/analysis/wholeBody/Nutrition_Modelling_Toolbox/calculateFoodScore.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 026-tier1-test-batch2, 2026-10-11.
%     - Updated for feature 20261102-140321-tier1-safe-defect-fixes, 2026-11-02.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testCalculateFoodScore'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% tolerance for the similarity scores (Euclidean distances of small integers)
tol = 1e-12;

% original foods: name, 5 filler columns that the function ignores, then the nutrients
variableNames = {'OriginalFoodName', 'c2', 'c3', 'c4', 'c5', 'c6', 'Protein', 'Fat'};
originalFood = table({'apple pie'; 'banana'}, [0; 0], [0; 0], [0; 0], [0; 0], [0; 0], [10; 4], [5; NaN], ...
                     'VariableNames', variableNames);

% food-label and measured macros per food (two entries each); the columns Other,
% Vitamins/Minerals/Elements and Carbohydrates are dropped by the function
makeMacros = @(items, values) table(items, values(:, 1), values(:, 2), [0; 0], [0; 0], [0; 0], ...
    'VariableNames', {'FoodItem', 'Protein', 'Fat', 'Other', 'Vitamins/Minerals/Elements', 'Carbohydrates'});
labelMacros.shadowA = makeMacros({'labelA'; 'labelB'}, [10 5; 13 9]);
labelMacros.shadowB = makeMacros({'labelC'; 'labelD'}, [4 1; 7 2]);
measuredMacros.shadowA = makeMacros({'metA'; 'metB'}, [5 2.5; 13 3]);
measuredMacros.shadowB = makeMacros({'metC'; 'metD'}, [2 0.5; 7 1]);

% translation: original food name -> name of the food in the macro structures
translation = {'apple pie', 'shadowA'; 'banana', 'shadowB'};

%% scores with a translation array

output = calculateFoodScore(originalFood, labelMacros, measuredMacros, translation);
assert(isequal(fieldnames(output), {'shadowA'; 'shadowB'}));

% food A: first row is the original food (as strings), then the measured values as a
% percentage of the label values; the score is the distance between the original food
% and each label entry: 0 for the original row, sqrt(0^2+0^2)=0 for labelA and
% sqrt(3^2+4^2)=5 for labelB
foodA = output.shadowA;
assert(isequal(foodA.Properties.VariableNames, {'FoodItem', 'Protein', 'Fat', 'similarityScore'}));
assert(isequal(foodA.FoodItem, {'apple pie'; 'metA'; 'metB'}));
assert(isequal(foodA.Protein, ["10"; "50%"; "100%"]));
assert(isequal(foodA.Fat, ["5"; "50%"; "33.3333%"]));
assert(norm(foodA.similarityScore - [0; 0; 5]) < tol);

% food B: the nutrient with a NaN original value (Fat) is left out of the distance, so
% the score only uses Protein: |4-4| = 0 and |4-7| = 3
foodB = output.shadowB;
assert(isequal(foodB.FoodItem, {'banana'; 'metC'; 'metD'}));
assert(isequal(foodB.Protein, ["4"; "50%"; "100%"]));
assert(ismissing(foodB.Fat(1)));
assert(isequal(foodB.Fat(2:3), ["50%"; "50%"]));
assert(norm(foodB.similarityScore - [0; 0; 3]) < tol);

%% empty translation: food rows are found by row name; a warning is issued

originalFoodRowNames = originalFood;
originalFoodRowNames.Properties.RowNames = {'shadowA', 'shadowB'};
lastwarn('');
outputNoTranslation = calculateFoodScore(originalFoodRowNames, labelMacros, measuredMacros, []);
assert(contains(lastwarn, 'No translation array is given'));
% same numbers as with the translation array
assert(isequal(outputNoTranslation.shadowA.Protein, ["10"; "50%"; "100%"]));
assert(norm(outputNoTranslation.shadowB.similarityScore - [0; 0; 3]) < tol);

%% no translation argument: the default (empty) translation finds the food rows by row name

% three inputs give the same result and the same warning as an empty translation
originalFoodRowNames = originalFood;
originalFoodRowNames.Properties.RowNames = {'shadowA', 'shadowB'};
outputNoTranslation = calculateFoodScore(originalFoodRowNames, labelMacros, measuredMacros, []);
lastwarn('');
outputDefaultTranslation = calculateFoodScore(originalFoodRowNames, labelMacros, measuredMacros);
assert(contains(lastwarn, 'No translation array is given'));
% isequaln: the original Fat value of food B is a missing string, which isequal never matches
assert(isequaln(outputDefaultTranslation, outputNoTranslation));

% change the directory
cd(currentDir)
