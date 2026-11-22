% The COBRAToolbox: testGenerateStackedBarPlot.m
%
% Purpose:
%     - generateStackedBarPlot merges, per sample, the taxa below 1% relative abundance into
%       'Others', sorts the taxa by total abundance, draws one stacked bar per sample with a
%       colour-blind-friendly palette and a legend, and saves the figure as
%       RelativeAbundance_stackedBarPlot.fig and .svg in saveDir. The function is QUARANTINED
%       (Constitution III-Defects, quarantine in back-fill campaigns): it errors for a single
%       sample (defect below), so no assertion about the function is made.
%
% Function under test:
%     src/analysis/persephone/additionalFunctions/generateStackedBarPlot.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; a test would use a hand-built table, an invisible figure
%     and a temporary folder.
%
% Coverage exemptions:
%     every line - generateStackedBarPlot is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Errors for a single sample
%       SEVERITY: error
%       TRIGGER: T = table({'t1'; 't2'; 't3'}, [0.5; 0.495; 0.005], 'VariableNames',
%         {'Taxon', 's1'}); generateStackedBarPlot(T, tempname)
%       OBSERVED: MATLAB:noPublicFieldForClass, Unrecognized property 'FaceColor' for class
%         'matlab.graphics.GraphicsPlaceholder'. For one sample bar (line 51) receives a
%         1-by-4 vector and draws a single Bar series, so b(2) on line 78 does not exist.
%       EXPECTED: one stacked bar with the taxa t1, t2 and Others (the header says 'for single
%         or multiple samples'), saved as .fig and .svg
%       LINES: 51, 77-79
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testGenerateStackedBarPlot'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
