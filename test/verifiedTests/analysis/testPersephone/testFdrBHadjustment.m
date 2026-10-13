% The COBRAToolbox: testFdrBHadjustment.m
%
% Purpose:
%     - fdrBHadjustment adjusts p-values for multiple testing with the Benjamini-Hochberg false-
%     discovery-rate procedure.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch3, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/analysis/persephone/fdrBHadjustment.m
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
%     - Generated for feature tier1-test-batch3, 2026-10-12.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testFdrBHadjustment'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% tolerance for floating-point comparisons: a product and a division of small numbers, so
% rounding is far below 1e-12
tol = 1e-12;

%% four p-values

% sorted: 0.005 0.01 0.03 0.04 -> times m/rank: 0.02 0.02 0.04 0.04 -> running minimum from the
% largest rank: 0.02 0.02 0.04 0.04; mapped back to the input order
q = fdrBHadjustment([0.01 0.04 0.03 0.005]);
assert(isequal(size(q), [4 1]));                       % always a column
assert(norm(q - [0.02; 0.04; 0.04; 0.02]) < tol);

%% two p-values: the adjusted values never decrease with the rank

% sorted 0.5 0.9 -> 1.0 0.9 -> running minimum 0.9 0.9
assert(norm(fdrBHadjustment([0.5; 0.9]) - [0.9; 0.9]) < tol);

%% a single p-value is unchanged

assert(abs(fdrBHadjustment(0.2) - 0.2) < tol);

%% values are mapped back to the input order

% sorted 0.7 0.8 0.9 -> 2.1 1.2 0.9 -> running minimum 0.9 0.9 0.9
assert(norm(fdrBHadjustment([0.9 0.8 0.7]) - [0.9; 0.9; 0.9]) < tol);

%% adjusted values above 1 are limited to 1

% p-values above 1 are not valid, but the function limits the result to 1:
% sorted 1.5 2 -> times m/rank: 3 2 -> running minimum 2 2 -> limited to 1 1
assert(norm(fdrBHadjustment([1.5 2]) - [1; 1]) < tol);

% change the directory
cd(currentDir)
