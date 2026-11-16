% The COBRAToolbox: testStandardGibbsFormationEnergyStats.m
%
% Purpose:
%     - standardGibbsFormationEnergyStats counts the metabolites whose standard Gibbs energy of
%       formation comes from equilibrium constants (dGft0Source 'Keq'), from group contribution
%       (any other source) or from nowhere (NaN), prints the number of unique reactants without
%       an estimate and, if figures is non-zero, saves a pie chart dfG0provinencePieChart.fig.
%       A test would check the three counts against a hand-built modelT.met array.
%     - The function is QUARANTINED (Constitution III-Defects, quarantine in back-fill
%       campaigns): the counts are offset by eps and the figures option always fails (defects
%       below), so this file makes no assertion about the function.
%
% Function under test:
%     src/analysis/thermo/directionalityReport/standardGibbsFormationEnergyStats.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - hand-built thermodynamic model fields, a figure, no solver.
%
% Coverage exemptions:
%     every line - standardGibbsFormationEnergyStats is quarantined for the defect below
%     (feature 20261113-142115-test-backfill-tiers).
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The documented figures option always fails in pie
%       SEVERITY: unusable-option
%       TRIGGER: standardGibbsFormationEnergyStats(modelT, 1) with modelT.S = [-1 0; 1 -1; 0 1;
%       0 1], mets {'a[c]'; 'b[c]'; 'c[c]'; 'd[e]'} and dGft0Source 'Keq', 'GC', 'GC', 'Keq'
%       OBSERVED: "Text labels must be a string or a cell array of character vectors." raised by
%       pie from line 50 (MATLAB R2025a): each label is itself a cell array
%       EXPECTED: the pie chart saved as dfG0provinencePieChart.fig
%       LINES: 50-54
%     - DEFECT: The returned counts are offset by eps
%       SEVERITY: wrong-result
%       TRIGGER: standardGibbsFormationEnergyStats(modelT, 0) with the model above and
%       dGft0Source 'Keq', 'GC', NaN, 'Keq'
%       OBSERVED: nKeq = 2, nGC = 1.000000000000000222, nNone = 1.000000000000000222 (nGC == 1
%       is false); with no NaN source nNone = eps (2.2204e-16) instead of 0 (MATLAB R2025a):
%       lines 24-26 start every count at eps
%       EXPECTED: integer counts, as documented ("number of metabolites"), 0 when none
%       LINES: 24-26
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testStandardGibbsFormationEnergyStats'));
cd(fileDir);

% declare the requirements of this test. The function is quarantined, so this file needs no
% solver, MATLAB toolbox or particular operating system; the call is the standard opening of
% a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
