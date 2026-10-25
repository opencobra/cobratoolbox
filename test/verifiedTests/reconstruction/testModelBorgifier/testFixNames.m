% The COBRAToolbox: testFixNames.m
%
% Purpose:
%     - fixNames converts names to lower case and replaces blanks, hyphens, commas, colons, brackets
%     and parentheses by single underscores, keeping a final compartment tag in brackets.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/reconstruction/comparison/modelBorgifier/fixNames.m
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
fileDir = fileparts(which('testFixNames'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

%% lower case and separators

names = fixNames({'Glucose 6-phosphate', 'A,B:C(D)'});
assert(isequal(names, {'glucose_6_phosphate', 'a_b_c_d'}));

%% compartment tags at the end are kept

names = fixNames({'x[c]', 'x_[c]', 'Glc-D[e]'});
assert(isequal(names, {'x[c]', 'x[c]', 'glc_d[e]'}));

%% repeated and leading or trailing underscores

names = fixNames({'a__b___c', '_a_', 'a_____b'});
assert(isequal(names, {'a_b_c', 'a', 'a_b'}));

%% the pipe separator and brackets inside a name

names = fixNames({'Name|ID', 'abc]def[g]'});
assert(isequal(names, {'name|id', 'abc_def[g]'}));

% change the directory
cd(currentDir)
