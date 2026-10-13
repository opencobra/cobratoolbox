% The COBRAToolbox: testExtractDietFromModel.m
%
% Purpose:
%     - extractDietFromModel lists the food and diet exchange reactions of a whole-body model that
%     have a negative lower bound, together with the uptake flux (minus the lower bound).
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/analysis/wholeBody/Nutrition_Modelling_Toolbox/extractDietFromModel.m
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

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testExtractDietFromModel'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

model.rxns = {'Food_EX_apple'; 'Diet_EX_glc'; 'Food_EX_milk'; 'other'};

%% food and diet reactions with an open uptake

model.lb = [-5; -3; 0; -1];
foodMenu = extractDietFromModel(model);
% food reactions first, then diet reactions; milk is closed and 'other' is not a diet reaction
assert(isequal(foodMenu, {'Food_EX_apple', 5; 'Diet_EX_glc', 3}));

%% only diet reactions

model.lb = [0; -3; 0; 0];
foodMenu = extractDietFromModel(model);
assert(isequal(foodMenu, {'Diet_EX_glc', 3}));

%% only food reactions

model.lb = [-2; 0; -4; 0];
foodMenu = extractDietFromModel(model);
assert(isequal(foodMenu, {'Food_EX_apple', 2; 'Food_EX_milk', 4}));

%% nothing open

model.lb = zeros(4, 1);
foodMenu = extractDietFromModel(model);
assert(isempty(foodMenu));

% change the directory
cd(currentDir)
