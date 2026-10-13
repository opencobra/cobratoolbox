% The COBRAToolbox: testCalculateMacroOriginalDiet.m
%
% Purpose:
%     - calculateMacroOriginalDiet computes the amount of each macronutrient in a diet given as food
%     names and amounts, scaling the nutrient values of a food table by the weight eaten.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/analysis/wholeBody/Nutrition_Modelling_Toolbox/calculateMacroOriginalDiet.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: A diet in which every amount is zero stops the function with an error
%       SEVERITY: error
%       TRIGGER: a diet whose amounts are all zero, for example {bread, 0}
%       OBSERVED: the rows with a zero amount are removed first, which leaves an empty diet, and
%         multiplying the empty list of amounts with the nutrient table fails with "Arrays have
%         incompatible sizes for this operation"
%       EXPECTED: zero amounts for all nutrients
%       LINES: 33-37
%
% Authors:
%     - Generated for feature tier1-test-batch4, 2026-10-13.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testCalculateMacroOriginalDiet'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% tolerance for floating-point comparisons
tol = 1e-12;

% food table: the first row is a header row; columns 6 to 15 hold ten macronutrient columns
% (1 to 10 g per portion for apple, twice as much for bread)
names = {'Carb', 'Fat', 'Prot', 'Fib', 'Sug', 'Sat', 'Mono', 'Poly', 'Chol', 'Sod'};
table1 = table();
table1.OriginalFoodName = {''; 'apple'; 'bread'};
table1.Group = {''; 'fruit'; 'grain'};
table1.Code = [0; 1; 2];
table1.Note = {''; ''; ''};
table1.("WeightEaten (g)") = [0; 100; 200];
for i = 1:10
    table1.(names{i}) = [0; i; 2 * i];
end

%% nutrient amounts of a diet

% 50 g of apple (half a portion) and 100 g of bread (half a portion)
diet = {'apple', 50; 'bread', 100};
orgMacroDiet = calculateMacroOriginalDiet(diet, table1);
assert(isequal(orgMacroDiet.macroNames, names'));
% nutrient i: 0.5 * i + 0.5 * 2 * i = 1.5 i
assert(norm(orgMacroDiet.values_g - 1.5 * (1:10)') < tol);

%% foods with a zero amount are ignored

diet = {'apple', 100; 'bread', 0};
orgMacroDiet = calculateMacroOriginalDiet(diet, table1);
assert(norm(orgMacroDiet.values_g - (1:10)') < tol);

% change the directory
cd(currentDir)
