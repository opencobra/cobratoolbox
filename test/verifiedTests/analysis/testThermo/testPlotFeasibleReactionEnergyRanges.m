% The COBRAToolbox: testPlotFeasibleReactionEnergyRanges.m
%
% Purpose:
%     - plotFeasibleReactionEnergyRanges draws, for every reaction of a thermodynamically
%       constrained model, the feasible range [DrGtMin, DrGtMax] of the transformed reaction
%       Gibbs energy as error bars sorted by their midpoint. A test would check the midpoints,
%       half-widths and sort order of the error bars against values worked out from a
%       hand-built modelT (rxns, DrGtMin, DrGtMax).
%     - The function is QUARANTINED (Constitution III-Defects, quarantine in back-fill
%       campaigns): every call stops with an error (first defect below), so this file makes no
%       assertion about the function.
%
% Function under test:
%     src/analysis/thermo/directionalityReport/plotFeasibleReactionEnergyRanges.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - hand-built thermodynamic model fields, a figure, no solver.
%
% Coverage exemptions:
%     every line - plotFeasibleReactionEnergyRanges is quarantined for the defect below
%     (feature 20261113-142115-test-backfill-tiers).
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Every call fails when the error bars are adjusted
%       SEVERITY: error
%       TRIGGER: any call, e.g. plotFeasibleReactionEnergyRanges(modelT) with modelT.rxns =
%       {'r1'; 'r2'; 'r3'}, modelT.DrGtMin = [-10; -50; 5], modelT.DrGtMax = [10; -20; 30]
%       (also with rxns as a row)
%       OBSERVED: "Index exceeds array bounds." at line 50 (MATLAB R2025a): get(errorbar1,
%       'Children') returns an empty array for an ErrorBar object, so hE_c(2) does not exist;
%       the same code follows at lines 63-69
%       EXPECTED: the documented figure of the feasible reaction energy ranges
%       LINES: 49-55, 63-69
%     - DEFECT: Only the first reaction is plotted for the documented n x 1 rxns
%       SEVERITY: wrong-result
%       TRIGGER: modelT.rxns as the documented `n x 1` cell array with n > 1, e.g. the input above
%       OBSERVED: line 16 sets nRxn = size(modelT.rxns, 2), which is 1 for a column, so the loop
%       of lines 23-27 reads only reaction 1 (read from the code; in MATLAB R2025a the call
%       stops at line 50 first, see the defect above)
%       EXPECTED: one error bar per reaction, nRxn = n
%       LINES: 16
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testPlotFeasibleReactionEnergyRanges'));
cd(fileDir);

% declare the requirements of this test. The function is quarantined, so this file needs no
% solver, MATLAB toolbox or particular operating system; the call is the standard opening of
% a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
