% The COBRAToolbox: testIllustrate_ppp.m
%
% Purpose:
%     - illustrate_ppp draws, for every sample and every metabolite pair (one pair per column
%       of mets), the growth rates stored by performPPP as a surface seen from above, marks
%       the bounds of the first exchange of the pruned model and saves the figure as
%       phasePlane_<sample>_<met1>_<met2>.pdf. The function is QUARANTINED (Constitution
%       III-Defects, quarantine in back-fill campaigns): more than two metabolite pairs stop
%       the call with an index error, so no assertion about the function is made.
%
% Function under test:
%     src/dataIntegration/metabotools/illustrate_ppp.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; a hand-built result structure would suffice.
%
% Coverage exemptions:
%     every line - illustrate_ppp is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: More than two metabolite pairs stop the call with an index error
%       SEVERITY: error
%       TRIGGER: R.S1.modelPruned = struct('rxns', {{'EX_glc(e)'; 'EX_o2(e)'}}, 'lb', [-10; -20],
%         'ub', [0; 0]); R.S1.maxBiomass.f = 1; R.S1.<name> = struct('growthRates', [0.1 0.2;
%         0.3 0.4], 'bounds', [-1 -2; -2 -4]) for <name> phasePlane_EX_glc_EX_o2,
%         phasePlane_EX_glc_EX_glc and phasePlane_EX_o2_EX_o2; illustrate_ppp(R, {'EX_glc(e)',
%         'EX_glc(e)', 'EX_o2(e)'; 'EX_o2(e)', 'EX_glc(e)', 'EX_o2(e)'}, tempname-folder,
%         {'S1'}, {'x'; 'y'; 'z'}, 10, 1e-6)
%       OBSERVED: Index in position 1 exceeds array bounds. Index must not exceed 2. (line 28;
%         R2025a, 2026-11-15) after the PDFs of the first two pairs: line 28 tests mets{p, 1}
%         (row p) where the pair is column p (mets{1, p}, as lines 29-31 use)
%       EXPECTED: one PDF per pair
%       LINES: 28
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testIllustrate_ppp'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
