% The COBRAToolbox: testCompareMultSamp.m
%
% Purpose:
%     - compareMultSamp computes the mass distribution vectors (MDVs) of several sets of sampled
%       flux vectors with calcMDVfromSamp and collects their means and standard deviations.
%       The function is quarantined for the defect below: it calls calcMDVfromSamp with four
%       arguments, one more than its signature accepts, so every non-empty set of samples
%       stops with an error. This file only opens the test; it asserts nothing about the
%       function.
%
% Function under test:
%     src/dataIntegration/fluxomics/compareMultSamp.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - the documented inputs include a model structure; no solver.
%
% Coverage exemptions:
%     every line - compareMultSamp is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: calcMDVfromSamp is called with four arguments, every non-empty sample set stops with an error
%       SEVERITY: error
%       TRIGGER: with the fixtures of testFitC13Data, load('point.mat', 'v0');
%         load('model.mat', 'model'); compareMultSamp([], model, struct('points', v0))
%       OBSERVED: (R2025a, 2026-11-16) "Too many input arguments." at line 57, the call
%         calcMDVfromSamp(model, xglc, samp, measuredMetabolites); calcMDVfromSamp takes
%         (glc, points, experiment). Only an empty struct array of samples returns (totalz = 0,
%         zscore = 0, empty ave and stdev)
%       EXPECTED: the MDVs of each sample set, e.g. calcMDVfromSamp(xglc, samps(i).points,
%         experiment), collected in mdvs.ave and mdvs.stdev
%       LINES: 57
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testCompareMultSamp'));
cd(fileDir);

% declare the requirements of this test. This test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
