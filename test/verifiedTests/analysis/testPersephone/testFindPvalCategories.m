% The COBRAToolbox: testFindPvalCategories.m
%
% Purpose:
%     - findPvalCategories sorts p-values into three groups (FDR below 0.05, p below 0.05 and p of
%     0.05 or more) and returns a logical table of group membership and a colour for each non-empty
%     group.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/analysis/persephone/findPvalCategories.m
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
fileDir = fileparts(which('testFindPvalCategories'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% colours of the three groups: red, blue and grey
red = [0.89 0.145 0.157];
grey = [0.804 0.808 0.808];

%% groups that are present are returned, empty groups are removed

% the three smallest p-values stay below 0.05 after the false discovery rate adjustment;
% the two large ones are above 0.05
[groups, colours] = findPvalCategories([0.001; 0.01; 0.03; 0.2; 0.9]);
assert(isequal(groups.Properties.VariableNames, {'FDR < 0.05', 'P > 0.05'}));
assert(isequal(groups.('FDR < 0.05'), [true; true; true; false; false]));
assert(isequal(groups.('P > 0.05'), [false; false; false; true; true]));
% the blue group is empty, so the colours are red and grey
assert(numel(colours) == 2 && isequal(colours{1}, red) && isequal(colours{2}, grey));

%% only large p-values

[groups, colours] = findPvalCategories([0.5; 0.6]);
assert(isequal(groups.Properties.VariableNames, {'P > 0.05'}));
assert(all(groups.('P > 0.05')));
assert(numel(colours) == 1 && isequal(colours{1}, grey));

%% p-values below 0.05 that do not survive the adjustment

% the adjusted value of 0.04 among six p-values is 0.24, so it only counts as P < 0.05
[groups, colours] = findPvalCategories([0.04; 0.5; 0.6; 0.7; 0.8; 0.9]);
assert(isequal(groups.Properties.VariableNames, {'P < 0.05', 'P > 0.05'}));
assert(isequal(groups.('P < 0.05'), [true; false; false; false; false; false]));
assert(isequal(colours{1}, [0 0.4470 0.7410]) && isequal(colours{2}, grey));

% change the directory
cd(currentDir)
