% The COBRAToolbox: testOptimalScores.m
%
% Purpose:
%     - optimalScores collapses the 3-D reaction score matrix SCORE (global) of modelBorgifier
%       into a total score per reaction pair, normalized to [0, 1], with the best match of
%       each compared reaction; given a training list rxnList (positive: index of the
%       matching template reaction, 0: new reaction, -1: undecided) and an optimizer ('svm',
%       'RF', 'linear', 'exp' or 'none') it first weights the score dimensions. The function
%       is QUARANTINED (Constitution III-Defects, quarantine in back-fill campaigns): a
%       training list with exactly one matched reaction stops with an index error, so no
%       assertion about the function is made. With two matched reactions and 'none', the
%       weights are ones (R2025a, 2026-11-15).
%
% Function under test:
%     src/reconstruction/comparison/modelBorgifier/optimalScores.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver; a test would set the globals SCORE, CMODEL
%     and TMODEL by hand. The 'linear' and 'exp' optimizers call fminunc and fmincon
%     (Optimization Toolbox).
%
% Coverage exemptions:
%     every line - optimalScores is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: A training list with exactly one matched reaction stops with an index error
%       SEVERITY: error
%       TRIGGER: global SCORE CMODEL TMODEL; SCORE = rand(3, 3, 2); CMODEL.metNums =
%         zeros(3, 5); TMODEL.metNums = zeros(3, 5); optimalScores([1; 0; -1], 'none')
%       OBSERVED: "Index in position 1 exceeds array bounds. Index must not exceed 1." at
%         line 75: hitPos is 1 x 2 ([row, match]) and length(hitPos) = 2 counts its columns,
%         so the loop over the hits runs twice (also for 'svm', 'RF', 'linear' and 'exp',
%         as the loop precedes the choice of optimizer) (R2025a, 2026-11-15)
%       EXPECTED: one hit: hitVec of size 2 x 1, missVec of size 2 x 2, the weights and the
%         normalized scoreTotal returned (size(hitPos, 1) instead of length(hitPos))
%       LINES: 63, 68, 74-75
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testOptimalScores'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
