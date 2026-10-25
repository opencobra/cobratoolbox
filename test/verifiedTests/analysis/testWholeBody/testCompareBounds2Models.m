% The COBRAToolbox: testCompareBounds2Models.m
%
% Purpose:
%     - compareBounds2Models compares the bounds of two models: it lists the reactions missing from
%     each model and, for the shared reactions, which bounds are identical and which differ.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/analysis/wholeBody/PSCMToolbox/compareBounds2Models.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Reactions missing from a model are collected in a character matrix, which fails for
%         names of different lengths
%       SEVERITY: error
%       TRIGGER: two or more reactions missing from the same model whose identifiers have different
%         lengths
%       OBSERVED: the names are appended as rows of a character array, so unequal lengths stop the
%         function with "Dimensions of arrays being concatenated are not consistent"
%       EXPECTED: the missing reactions returned in a cell array
%       LINES: 48-50
%     - DEFECT: The numbers of mismatched bounds are displayed instead of returned
%       SEVERITY: cosmetic
%       TRIGGER: any call
%       OBSERVED: the last two statements show mismatch_lb and mismatch_ub in the command window;
%         they are not outputs
%       EXPECTED: the counts returned or not displayed
%       LINES: 84-85
%
% Authors:
%     - Generated for feature tier1-test-batch4, 2026-10-13.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testCompareBounds2Models'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% models share the reactions b and c; a is only in model 1 and d only in model 2
model1.rxns = {'a'; 'b'; 'c'};
model1.lb = [0; -1; 0];
model1.ub = [1; 1; 5];
model2.rxns = {'b'; 'c'; 'd'};
model2.lb = [-1; 0; 0];
model2.ub = [2; 5; 1];

%% missing reactions and bound comparison

text = evalc('[R1_missing, R2_missing, R12_bounds, R12_bounds_mismatch] = compareBounds2Models(model1, model2);');
% reaction d is not in model 1 and reaction a is not in model 2
assert(strcmp(R1_missing, 'd') && strcmp(R2_missing, 'a'));
% identical bounds: both bounds of c and the lower bound of b
assert(isequal(R12_bounds, {'b', 'identical lower bound', -1, -1; ...
                            'c', 'identical lower bound', 0, 0; ...
                            'c', 'identical upper bound', 5, 5}));
% the upper bound of b differs (1 against 2)
assert(isequal(R12_bounds_mismatch, {'b', 'NOT identical upper bound', 1, 2}));
% the mismatch counts are displayed
assert(contains(text, 'mismatch_lb') && contains(text, 'mismatch_ub'));

%% different lower bounds are reported as well

model2.lb(2) = -3;
[~, ~, ~, R12_bounds_mismatch] = compareBounds2Modelsquietly(model1, model2);
assert(isequal(R12_bounds_mismatch, {'b', 'NOT identical upper bound', 1, 2; 'c', 'NOT identical lower bound', 0, -3}));


function [R1_missing, R2_missing, R12_bounds, R12_bounds_mismatch] = compareBounds2Modelsquietly(model1, model2)
% Call compareBounds2Models and discard the text it displays.
evalc('[R1_missing, R2_missing, R12_bounds, R12_bounds_mismatch] = compareBounds2Models(model1, model2);');
end

% change the directory
cd(currentDir)
