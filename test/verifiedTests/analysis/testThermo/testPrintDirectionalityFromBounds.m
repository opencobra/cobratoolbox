% The COBRAToolbox: testPrintDirectionalityFromBounds.m
%
% Purpose:
%     - printDirectionalityFromBounds returns a label (reversible, reverse, forward only or closed)
%     for every reaction from its lower and upper bounds, taken from the model or given explicitly.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/analysis/thermo/thermoFBA/printDirectionalityFromBounds.m
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
fileDir = fileparts(which('testPrintDirectionalityFromBounds'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

model.S = zeros(1, 5);
% reversible, reverse only, forward only, closed with both zero, closed with a negative upper bound at zero
model.lb = [-1; -1; 0; 0; 0];
model.ub = [1; 0; 1; 0; 0];

%% bounds taken from the model

directionality = printDirectionalityFromBounds(model);
assert(isequal(directionality, {'reversible'; 'reverse'; 'forward only'; 'closed'; 'closed'}));

%% bounds given explicitly replace the model bounds

directionality = printDirectionalityFromBounds(model, zeros(1, 5), ones(1, 5));
assert(all(strcmp(directionality, 'forward only')));
directionality = printDirectionalityFromBounds(model, -ones(1, 5), -ones(1, 5));
assert(all(strcmp(directionality, 'reverse')));

%% only the lower bound is given

directionality = printDirectionalityFromBounds(model, 5 * ones(1, 5));
assert(isequal(directionality, {'forward only'; 'closed'; 'forward only'; 'closed'; 'closed'}));

% change the directory
cd(currentDir)
