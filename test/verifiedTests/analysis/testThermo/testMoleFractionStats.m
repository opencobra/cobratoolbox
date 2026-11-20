% The COBRAToolbox: testMoleFractionStats.m
%
% Purpose:
%     - moleFractionStats(modelT) checks that the mole fractions of every reactant sum to one
%       and are positive, then draws four figures: a histogram of the number of species per
%       reactant (above 0.1 %), a stacked bar chart of the mole fractions, and, for the
%       cytoplasmic reactants whose largest mole fraction is below 0.95, a mole-fraction chart
%       and a connectivity chart, saved as moleFraction95.fig and
%       moleFraction95connectivity.fig in the current folder. Quarantined: no behaviour of
%       moleFractionStats is asserted until the defect below is fixed.
%
% Function under test:
%     src/analysis/thermo/protons/moleFractionStats.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - reporting for a model, no solver; a test would use a hand-built model with S,
%     mets, metNames and mf, invisible figures closed at the end and a tempname working folder.
%
% Coverage exemptions:
%     every line - moleFractionStats is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Fewer than two cytoplasmic reactants with a spread distribution stop the call
%       SEVERITY: error
%       TRIGGER: modelT.S = sparse([1 0; 0 1; 1 1]), modelT.mets = {'a[c]'; 'b[c]'; 'c[e]'},
%         modelT.metNames = {'A'; 'B'; 'C'} and modelT.mf = {[0.5; 0.5]; [0.0005; 0.9995]; 1}
%         (one [c] reactant whose largest mole fraction is below 0.95), or
%         modelT.mf = {1; 1; 1} (none)
%       OBSERVED: MATLAB R2025a, 2026-11-16: with one such reactant "Limits must be a 2-element
%         vector of increasing numeric values." from ylim([0.5 0.5]) at line 117; with none
%         "Unrecognized function or variable 'metInd'." at line 115 (metInd is assigned only
%         inside the selection of line 90). With mf = {[0.5; 0.5]; [0.3; 0.3; 0.4]; 1} (two
%         such reactants) the call ends normally
%       EXPECTED: the figures are drawn for any model with valid mole fractions, the
%         mole-fraction chart with one bar or none
%       LINES: 115, 117
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testMoleFractionStats'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
