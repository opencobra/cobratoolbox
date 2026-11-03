% The COBRAToolbox: testAssignQualDir.m
%
% Purpose:
%     - assignQualDir assigns a qualitative directionality to every reaction from its bounds:
%     forward for non-negative bounds, reversible for bounds of both signs.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
%     - Defect(s) fixed by feature 20261102-140321-tier1-safe-defect-fixes: Reverse reactions are
%       reported as forward.
%
% Function under test:
%     src/analysis/thermo/directionalityReport/assignQualDir.m
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
fileDir = fileparts(which('testAssignQualDir'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

%% forward and reversible reactions

model.S = zeros(2, 4);
% forward (0..5), reversible (-5..5), forward fixed at zero (0..0) and forward (2..8)
model.lb = [0; -5; 0; 2];
model.ub = [5; 5; 0; 8];
model = assignQualDir(model);
assert(isequal(size(model.qualDir), [4 1]));
assert(isequal(double(model.qualDir), [1; 0; 1; 1]));

%% reverse reactions: both bounds negative give -1

% the result is numeric, so -1 is stored and differs from the forward value 1
reverseModel.S = zeros(1, 3);
% reverse (-5..-1), forward (1..5) and reversible (-2..3)
reverseModel.lb = [-5; 1; -2];
reverseModel.ub = [-1; 5; 3];
reverseModel = assignQualDir(reverseModel);
assert(isa(reverseModel.qualDir, 'double'));
assert(isequal(reverseModel.qualDir, [-1; 1; 0]));

%% reactions with a bound of the wrong sign pair are left at zero

% lb < 0 and ub = 0 satisfies none of the three conditions
m2.S = zeros(1, 1);
m2.lb = -1;
m2.ub = 0;
m2 = assignQualDir(m2);
assert(double(m2.qualDir) == 0);

%% inconsistent bounds are an error

verifyCobraFunctionError('assignQualDir', 'inputs', {struct('S', 0, 'lb', 2, 'ub', 1)}, ...
    'testMessage', 'Model bounds are inconsistent');

% change the directory
cd(currentDir)
