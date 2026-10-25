% The COBRAToolbox: testNaturallabel.m
%
% Purpose:
%     - naturallabel returns the natural-abundance probability (98.9 % 12C, 1.1 % 13C) of every
%     labelling pattern of n carbon atoms, in binary order.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch3, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/dataIntegration/fluxomics/naturallabel.m
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
fileDir = fileparts(which('testNaturallabel'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% tolerance for floating-point comparisons: products of the constants 0.989 and 0.011
tol = 1e-15;

%% one and two carbon atoms: the patterns 0..2^n-1 in binary order (1 = 13C)

assert(norm(naturallabel(1) - [0.989; 0.011]) < tol);
assert(norm(naturallabel(2) - [0.989^2; 0.989 * 0.011; 0.989 * 0.011; 0.011^2]) < tol);

%% the probabilities of all patterns add up to 1

assert(abs(sum(naturallabel(3)) - 1) < 1e-12);
assert(numel(naturallabel(3)) == 8);

%% no atoms (or a negative number): the scalar 1

assert(naturallabel(0) == 1);
assert(naturallabel(-2) == 1);

% change the directory
cd(currentDir)
