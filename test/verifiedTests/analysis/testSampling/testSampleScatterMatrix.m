% The COBRAToolbox: testSampleScatterMatrix.m
%
% Purpose:
%     - sampleScatterMatrix draws a scatterplot matrix of flux samples: pairwise scatterplots
%       of the requested reactions with their histograms on the diagonal, or, with a second
%       set of reactions, the scatterplots between the two sets with the histograms on the
%       first row and column; optional inputs set the number of points, the font size and
%       the display of correlation coefficients. The function is QUARANTINED (Constitution
%       III-Defects, quarantine in back-fill campaigns): its documented optional inputs
%       cannot be omitted one at a time (defect below), so no assertion about the function
%       is made.
%
% Function under test:
%     src/analysis/sampling/sampleScatterMatrix.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - a test would use a three-reaction createModel model, a seeded random sample
%     matrix and invisible figures; no solver.
%
% Coverage exemptions:
%     every line - sampleScatterMatrix is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The documented optional inputs cannot be omitted one at a time
%       SEVERITY: error
%       TRIGGER: model = createModel({'R1'; 'R2'; 'R3'}, {'r1'; 'r2'; 'r3'}, {' -> A'; 'A ->
%         B'; 'B -> '}, [], zeros(3, 1), 10 * ones(3, 1)); rng(1); sample = rand(3, 50);
%         sampleScatterMatrix({'R1', 'R2'}, model, sample, 20) or
%         sampleScatterMatrix({'R1', 'R2'}, model, sample, 20, 12)
%       OBSERVED: MATLAB R2025a: both calls stop with 'Not enough input arguments.' at line
%         53, which reads dispRFlag although only nPoints (and fontSize) were given; line 71
%         reads fontSize in the same way. The calls with 3, 6 and 7 arguments run.
%       EXPECTED: the omitted optional inputs take their documented defaults (dispRFlag
%         false, fontSize calculated from the number of reactions), as in the call with 3
%         arguments
%       LINES: 53, 71
%     - DEFECT: The progress of the two-set layout exceeds 100 %
%       SEVERITY: cosmetic
%       TRIGGER: the model and sample above: sampleScatterMatrix({'R1', 'R2'}, model, sample,
%         20, [], true, {'R3'})
%       OBSERVED: MATLAB R2025a: the progress bar printed by showprogress runs to 116 % and
%         133 %; line 84 computes ((i - 1) * nRxns + j) / (nRxns * nRxns2) with nRxns where
%         the row length is nRxns2
%       EXPECTED: the progress ends at 100 % ((i - 1) * nRxns2 + j)
%       LINES: 84
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testSampleScatterMatrix'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
