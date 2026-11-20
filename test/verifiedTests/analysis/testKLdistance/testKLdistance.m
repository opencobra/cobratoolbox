% The COBRAToolbox: testKLdistance.m
%
% Purpose:
%     - KLdistance(data1, data2, num_iter, parameters) compares two populations parameter by
%       parameter (one column of data1 and data2 per parameter): the first distance is the
%       Kullback-Leibler distance (KLDis) between the kernel density estimates
%       (cobraKsdensity) of the second and of the first population; num_iter - 1 further
%       distances are computed after random permutations of the population labels; one figure
%       per parameter shows the histogram of the distances with the first one marked, titled
%       with the parameter name. The output holds the distances of the last parameter.
%     - Once the defect below is fixed, the test should check: the distance is zero between
%       two identical populations and positive between shifted populations (x and x + 100,
%       disjoint supports) and between x and 3 * x; the first distance against KLDis of the
%       two densities evaluated on one common grid (computed independently, not with the
%       function's own pairing); the permutation distances against an independent
%       re-implementation of the label shuffle with a fixed seed; non-negativity; the number
%       of distances and of figures, and the figure titles (figures invisible and closed).
%       Quarantined: no behaviour of KLdistance is asserted until the wrong-result defect
%       below is fixed; this file only opens the test.
%
% Function under test:
%     src/analysis/KLdistance/KLdistance.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver, hand-built data (figures are invisible and closed).
%
% Coverage exemptions:
%     every line - KLdistance is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The two densities are compared on different grids, so distinct populations
%         get a zero distance
%       SEVERITY: wrong-result
%       TRIGGER: x = [1.0; 2.0; 2.5; 4.0; 5.5; 6.0]; KLdistance(x, x + 100, 1, {'a'}) (two
%         populations with disjoint supports); also KLdistance(x, 3 * x, 1, {'a'})
%       OBSERVED: (R2025a, 2026-11-17) dist = 1.32646e-30 for x and x + 100 and 2.08731e-31
%         for x and 3 * x, i.e. zero up to rounding: cobraKsdensity evaluates each density on
%         100 points spanning its own sample (grids [-4.76, 11.76] and [95.24, 111.76] here)
%         and lines 34-35 and 47-48 discard the grid (xi); the two density vectors are equal
%         (max difference 3.2e-16), so KLDis (lines 36 and 50) compares values at unrelated
%         x points. The permutation distances (lines 39-51) share the error
%       EXPECTED: the Kullback-Leibler distance between the two distributions, i.e. the two
%         densities evaluated on one common grid: a clearly positive distance for disjoint
%         or rescaled populations
%       LINES: 34-36, 47-50
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-13.
%     - Quarantined after the independent review (T021), 2026-11-17.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testKLdistance'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
