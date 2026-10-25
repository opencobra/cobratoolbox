% The COBRAToolbox: testGetRandGlc.m
%
% Purpose:
%     - getRandGlc returns a random distribution over eight labelling patterns of glucose, as a
%     vector of the 64 isotopomer fractions.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/dataIntegration/fluxomics/getRandGlc.m
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
fileDir = fileparts(which('testGetRandGlc'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% fix the random generator for repeatable runs and restore it afterwards
previous = rng;
cleanup = onCleanup(@() rng(previous));
rng(1);

%% a distribution over 64 isotopomers

xGlc = getRandGlc();
assert(isequal(size(xGlc), [64 1]));
% fractions add up to one
assert(abs(sum(xGlc) - 1) < 1e-12);
assert(all(xGlc >= 0));

%% only eight isotopomers carry label

xGlc = getRandGlc();
% positions of the eight patterns: unlabelled (1), single labels 2, 3, 5, 9, 17, 33 and the pattern 49
expectedSupport = [1 2 3 5 9 17 33 49];
assert(isequal(find(xGlc > 0)', expectedSupport));

%% every call gives a different distribution

assert(~isequal(getRandGlc(), getRandGlc()));

% change the directory
cd(currentDir)
