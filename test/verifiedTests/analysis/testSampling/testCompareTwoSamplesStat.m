% The COBRAToolbox: testCompareTwoSamplesStat.m
%
% Purpose:
%     - compareTwoSamplesStat compares two samples (variables x sample points) variable by
%       variable with the Kolmogorov-Smirnov, rank-sum, chi-square and t tests and returns the
%       statistics and p values of the selected tests. The function is QUARANTINED
%       (Constitution III-Defects, quarantine in back-fill campaigns): the chi-square "p
%       values" are the cumulative probabilities of a statistic computed on relative
%       frequencies (defect below), so no assertion about the function is made.
%
% Function under test:
%     src/analysis/sampling/compareTwoSamplesStat.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; a test would use hand-built random samples with a fixed
%     seed.
%
% Coverage exemptions:
%     every line - compareTwoSamplesStat is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The chi-square p values are cumulative probabilities, near 0 for identical samples
%       SEVERITY: wrong-result
%       TRIGGER: rng(1); s = randn(2, 200); [stats, pVals] = compareTwoSamplesStat(s, s,
%         {'chiSquare'}) and compareTwoSamplesStat(s, s + 5, {'chiSquare'})
%       OBSERVED: identical samples give stats.chisquare = [0; 0] and pVals.chisquare = [0; 0];
%         samples shifted by 5 standard deviations (no overlap) give stats.chisquare =
%         [1.9604; 2.0000] and pVals.chisquare = [0.4193; 0.4276] (MATLAB R2025a). Line 75
%         returns the lower tail chi2cdf(stat, nBin - 1), and lines 70-73 compute the
%         statistic from relative frequencies (counts / nSample), so it is at most 2 whatever
%         the sample size.
%       EXPECTED: p values of the chi-square test (upper tail of the statistic computed from
%         the counts): 1 for identical samples and close to 0 for samples that do not overlap,
%         as the other tests give (ks, ranksum and ttest p values are 1 for identical samples)
%       LINES: 70-75
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testCompareTwoSamplesStat'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
