% The COBRAToolbox: testDetermineFluxValuesOnBoundary.m
%
% Purpose:
%     - determineFluxValuesOnBoundary reports the fraction of the constrained reactions (and of all
%     reactions) whose flux in a solution lies on its lower or upper bound, ignoring bounds that are
%     practically infinite.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/analysis/wholeBody/PSCMToolbox/determineFluxValuesOnBoundary.m
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
fileDir = fileparts(which('testDetermineFluxValuesOnBoundary'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% tolerance for floating-point comparisons
tol = 1e-12;

% four reactions: a at its upper bound, b at its lower bound, c with practically infinite bounds,
% d with a flux inside its bounds
model.rxns = {'a'; 'b'; 'c'; 'd'};
model.lb = [0; -10; -1000001; -5];
model.ub = [10; 10; 1000001; 0];
solution.full = [10; -10; 0; 1];

%% fractions of constrained and of all reactions on the boundary

[ofConstraint, ofAll] = determineFluxValuesOnBoundary(model, solution);
% two reactions on a bound; four constraints count: lb of b, lb of d, ub of a and ub of b
assert(abs(ofConstraint - 2 / 4) < tol);
assert(abs(ofAll - 2 / 4) < tol);

%% no flux on a boundary

solution.full = [1; 1; 1; -1];
[ofConstraint, ofAll] = determineFluxValuesOnBoundary(model, solution);
assert(ofConstraint == 0 && ofAll == 0);

%% a reaction with a fixed flux zero is not counted as being on a bound

solution.full = zeros(4, 1);
[ofConstraint, ofAll] = determineFluxValuesOnBoundary(model, solution);
assert(ofConstraint == 0 && ofAll == 0);

% change the directory
cd(currentDir)
