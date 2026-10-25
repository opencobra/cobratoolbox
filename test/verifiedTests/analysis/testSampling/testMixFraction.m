% The COBRAToolbox: testMixFraction.m
%
% Purpose:
%     - mixFraction measures how well two sets of samples agree: the fraction of sample values that
%     lie on the same side of the median of their reaction in both sets, ignoring values equal to a
%     median.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch3, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/analysis/sampling/ACHR/mixFraction.m
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
fileDir = fileparts(which('testMixFraction'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% tolerance for floating-point comparisons: a ratio of two integers
tol = 1e-12;
firstSample = [1 2 3 4 5; 5 4 3 2 1];

%% identical samples agree completely

% the value equal to the median (3) of each row is ignored
assert(abs(mixFraction(firstSample, firstSample) - 1) < tol);

%% reversed samples disagree completely

assert(abs(mixFraction(firstSample, fliplr(firstSample))) < tol);

%% partial agreement

% row 1 agrees (same order), row 2 is reversed: 4 of 8 compared values agree
secondSample = [1 2 3 4 5; 1 2 3 4 5];
assert(abs(mixFraction(firstSample, secondSample) - 0.5) < tol);

%% fixed rows are set to zero in both samples and then ignored

% with row 2 fixed only row 1 counts: identical -> 1
assert(abs(mixFraction(firstSample, fliplr(firstSample), 2) - 0) < tol);
assert(abs(mixFraction([firstSample(1, :); zeros(1, 5)], [firstSample(1, :); ones(1, 5)], 2) - 1) < tol);

%% sparse input is accepted

assert(abs(mixFraction(sparse(firstSample), sparse(firstSample)) - 1) < tol);

% change the directory
cd(currentDir)
