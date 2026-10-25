% The COBRAToolbox: testGPRrulesMapper.m
%
% Purpose:
%     - GPRrulesMapper evaluates an association rule written in terms of the expression matrix x and
%     returns the resulting values, or 0 for an empty rule.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/dataIntegration/transcriptomics/rFASTCORMICS/GPRrulesMapper.m
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
fileDir = fileparts(which('testGPRrulesMapper'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

x = [1 0; 1 1];

%% and-rule takes the smaller value, or-rule the larger value (with the Boolean operators)

assert(isequal(GPRrulesMapper('x(1,:) & x(2,:)', x), [1 0]));
assert(isequal(GPRrulesMapper('x(1,:) | x(2,:)', [1 0; 0 0]), [1 0]));

%% arithmetic rules are evaluated as written

assert(isequal(GPRrulesMapper('x(1,:) + x(2,:)', [1 2; 3 4]), [4 6]));

%% an empty rule gives zero

assert(GPRrulesMapper('', x) == 0);
assert(GPRrulesMapper([], x) == 0);

% change the directory
cd(currentDir)
