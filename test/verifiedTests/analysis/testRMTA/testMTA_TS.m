% The COBRAToolbox: testMTA_TS.m
%
% Purpose:
%     - MTA_TS computes the transformation score of the metabolic transformation algorithm: the
%     change of the reactions that should increase or decrease, successful minus unsuccessful,
%     divided by the change of the unchanged reactions.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/analysis/rMTA/MTA_TS.m
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
fileDir = fileparts(which('testMTA_TS'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% tolerance for floating-point comparisons
tol = 1e-12;

%% all changing reactions move in the wanted direction

% r1 should increase (2 > 1) and r2 should decrease (1 < 2): successful changes 1 + 1;
% unchanged reactions r3 and r4 move by |5 - 4| + |3 - 1| = 3
score = MTA_TS([2; 1; 5; 3], [1; 2; 4; 1], [1; -1; 0; 0]);
assert(abs(score - 2/3) < tol);

%% a change in the wrong direction is subtracted

% r1 should increase but decreases by 1 (unsuccessful), r2 decreases by 1 (successful):
% (1 - 1) / 3 = 0
score = MTA_TS([0; 1; 5; 3], [1; 2; 4; 1], [1; -1; 0; 0]);
assert(abs(score) < tol);

%% only unsuccessful changes give a negative score

score = MTA_TS([0; 3; 5; 3], [1; 2; 4; 1], [1; -1; 0; 0]);
assert(abs(score - (-2/3)) < tol);

%% no change in the unchanged reactions gives an infinite score

score = MTA_TS([2; 1; 4; 1], [1; 2; 4; 1], [1; -1; 0; 0]);
assert(isinf(score) && score > 0);

% change the directory
cd(currentDir)
