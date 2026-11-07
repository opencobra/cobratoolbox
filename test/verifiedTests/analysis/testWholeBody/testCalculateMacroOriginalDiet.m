% The COBRAToolbox: testCalculateMacroOriginalDiet.m
%
% Purpose:
%     - calculateMacroOriginalDiet computes the amount of each macronutrient in a diet given as food
%     names and amounts, scaling the nutrient values of a food table by the weight eaten.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
%     - Defect(s) fixed by feature 20261102-140321-tier1-safe-defect-fixes: A diet in which every
%       amount is zero stops the function with an error.
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
%     None found.
%
% Authors:
%     - Generated for feature tier1-test-batch4, 2026-10-13.
%     - Updated for feature 20261102-140321-tier1-safe-defect-fixes, 2026-11-02.

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

%% a diet in which every amount is zero has no nutrients

diet = {'bread', 0};
orgMacroDiet = calculateMacroOriginalDiet(diet, table1);
assert(isequal(orgMacroDiet.macroNames, names'));
% exact zeros: nothing is summed
assert(isequal(orgMacroDiet.values_g, zeros(10, 1)));

% change the directory
cd(currentDir)
